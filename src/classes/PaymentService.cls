/**
* @author Graham MacRobie
* @date November 13, 2017
*
* @description Service class that handles Payment processing functions, including sorting payments by Project or
* Contact, updating Projects or Contacts with Payment totals, and calculating the Most Recent Payment Date.
*/

public with sharing class PaymentService {
	public static Integer MAX_SYNC_RECOMPUTE_ROWS = 10000;  // maximum number of rows before asynchronous batch is used

	public static Integer ROW_LIMIT = 10000;

	private static Map<String, String> fields;
	private static Decimal paymentAmount;
	private static Date paymentDate;

	private static String jsonData;

	/**
	* @description Inner class to more easily keep track of previous and new values for Payment amount and date.
	*/

	public class PaymentDelta {
		public Decimal previousAmount;
		public Decimal newAmount;

		public Date previousDate;
		public Date newDate;

		/**************************************************************************************************************
		* @description Convenience constructor with all previous and new values.
		*
		* @param previousAmount the Payment amount before insert/update
		* @param newAmount the Payment amount after insert/update
		* @param previousDate the Payment Date before insert/update
		* @param newDate the Payment Date after insert/update
		*/

		public PaymentDelta(Decimal previousAmount, Decimal newAmount, Date previousDate, Date newDate) {
			this.previousAmount = previousAmount;
			this.newAmount = newAmount;
			this.previousDate = previousDate;
			this.newDate = newDate;
		}

		/**************************************************************************************************************
		* @description Convenience constructor with new values only.  Previous values are initialized to 0 (for 
		* payment amount) and null (for payment date).
		*
		* @param newAmount the Payment amount after insert/update
		* @param newDate the Payment Date after insert/update
		*/

		public PaymentDelta(Decimal newAmount, Date newDate) {
			this.previousAmount = 0;
			this.newAmount = newAmount;
			this.previousDate = null;
			this.newDate = newDate;
		}
	}

	/**************************************************************************************************************
	* @description Kicks off three batches in sequence that reset payment totals and most recent payment dates
	* for all projects and contacts.
	*/

	public static void resetTotals() {
		ZeroProjectTotalsBatch.go();
	}

	/**************************************************************************************************************
	* @description Gets all the payments from the database and converts them into PaymentDto objects.
	*
	* @param maxRows the maximum number of rows to return
	*
	* @return Returns a PaymentsDto object with all the payments
	*/

	public static PaymentsDto getAllPayments(Integer maxRows) {
		PaymentsDto payments = new PaymentsDto();

		List<Payment__c> paymentList = [select 
			id, 
			name, 
			Project__c, 
			Project__r.name, 
			Project__r.TotalPayments__c, 
			Project__r.MostRecentPaymentDate__c, 
			Payer__c, 
			Payer__r.name, 
			Payer__r.FirstName,
			Payer__r.LastName,
			Payer__r.TotalPayments__c, 
			Payer__r.MostRecentPaymentDate__c, 
			Payer__r.Photo__c,
			PaymentDate__c, 
			PaymentAmount__c 

			from Payment__c order by PaymentDate__c desc, name desc limit :maxRows];

		for (Payment__c payment : paymentList) {
			payments.addPayment(new PaymentDto(payment));
		}

		return payments;
	}

	/**************************************************************************************************************
	* @description Gets all the payments for a payer from the database and converts them into PaymentDto objects.
	*
	* @param payerId the record Id of the payer of this Payment__c
	* @param maxRows the maximum number of rows to return
	*
	* @return Returns a PaymentsDto object with all the payments
	*/

	public static PaymentsDto getAllPaymentsForPayer(Id payerId, Integer maxRows) {
		PaymentsDto payments = new PaymentsDto();

		List<Payment__c> paymentList = [select 
			id, 
			name, 
			Project__c, 
			Project__r.name, 
			Project__r.TotalPayments__c, 
			Project__r.MostRecentPaymentDate__c, 
			Payer__c, 
			Payer__r.name, 
			Payer__r.FirstName,
			Payer__r.LastName,
			Payer__r.TotalPayments__c, 
			Payer__r.MostRecentPaymentDate__c, 
			Payer__r.Photo__c,
			PaymentDate__c, 
			PaymentAmount__c 

			from Payment__c where Payer__c = :payerId order by PaymentDate__c desc, name desc limit :maxRows];

		for (Payment__c payment : paymentList) {
			payments.addPayment(new PaymentDto(payment));
		}

		return payments;
	}

	/**************************************************************************************************************
	* @description Gets one payment from the database and converts it into a PaymentDto object.
	*
	* @param paymentId the Id of the Payment__c object to retrieve
	*
	* @return Returns a PaymentsDto object with the single payment
	*/

	public static PaymentsDto getPayment(Id paymentId) {
		PaymentsDto payments = new PaymentsDto();

		Payment__c payment = [select 
			id, 
			name, 
			Project__c, 
			Project__r.name, 
			Project__r.TotalPayments__c, 
			Project__r.MostRecentPaymentDate__c, 
			Payer__c, 
			Payer__r.name, 
			Payer__r.FirstName,
			Payer__r.LastName,
			Payer__r.TotalPayments__c, 
			Payer__r.MostRecentPaymentDate__c, 
			Payer__r.Photo__c,
			PaymentDate__c, 
			PaymentAmount__c 

			from Payment__c where id = :paymentId];

		payments.addPayment(new PaymentDto(payment));

		return payments;
	}

	/**************************************************************************************************************
	* @description Sorts Payment__c objects into buckets depending on what Project or Contact they belong to.  Also
	* converts Payment__c objects into PaymentDelta objects for simpler processing later.  This is a bulkification
	* strategy to avoid multiple SOQL queries that could do the same thing.
	*
	* @param payments the raw list of Payment__c objects to sort
	* @param oldMap the oldMap object from the Payment__c trigger, or null if it doesn't exist
	* @param fieldName the name of the field within Payment__c that identifies the lookup field (Project__c or Payer__c)
	* @param isDelete specifies whether the current transaction is a delete operation
	*
	* @return Returns a grouped Map of List<PaymentDelta>, each key is one project or contact Id
	*/

    public static Map<Id, List<PaymentDelta>> getBucket(Payment__c[] payments, Map<Id, Payment__c> oldMap, String fieldName, Boolean isDelete) {
        Map<Id, List<PaymentDelta>> results = new Map<Id, List<PaymentDelta>>();  // project Id, list of payment deltas

        for (Payment__c payment : payments) {
            List<PaymentDelta> paymentList = results.get((Id) payment.get(fieldName));  // dynamic lookup

            if (paymentList == null) {
                paymentList = new List<PaymentDelta>();
                results.put((Id) payment.get(fieldName), paymentList);
            }

            Payment__c previousPayment = (oldMap == null) ? null : oldMap.get(payment.id);  // previousPayment, only if oldMap exists

            // create PaymentDelta based on whether it's an insert, update, or delete

            if (previousPayment != null) {
                paymentList.add(new PaymentDelta(previousPayment.PaymentAmount__c, payment.PaymentAmount__c, previousPayment.PaymentDate__c, payment.PaymentDate__c));

            } else {
            	if (isDelete) {
            		paymentList.add(new PaymentDelta(payment.PaymentAmount__c, 0, payment.PaymentDate__c, null));

        		} else {
	                paymentList.add(new PaymentDelta(payment.PaymentAmount__c, payment.PaymentDate__c));

        		}
            }                
        }

        return results;
    }

	/**************************************************************************************************************
	* @description Processes adjustments to the TotalPayments__c and MostRecentPaymentDate__c fields on
	* Project__c or Contact.  Handles adjustments to TotalPayments with an accumulator strategy so no rescan
	* should ever be necessary.  Handles adjustments to MostRecentPaymentDate__c by comparing against the
	* current max value, but also handles the tricky scenario where a PaymentDate__c that is the same as the 
	* MostRecentPaymentDate__c is changed to an earlier date, meaning that a rescan/recompute is necessary.
	* If the number of rows would exceed MAX_SYNC_RECOMPUTE_ROWS, that task is offloaded to a batch job,
	* enabling this algorithm to handle a database with millions of Project__c, Contact, and/or Payment__c objects.
	*
	* @param paymentDeltaMap sorted buckets, typically from the getBucket method
	* @param objectName the name of the object to apply adjustments to (Project__c or Contact)
	* @param lookupFieldName the name of the lookup field on Payment__c that refers to the object (Project__c or Payer__c)
	*/

    public static void applyAdjustments(Map<Id, List<PaymentDelta>> paymentDeltaMap, String objectName, String lookupFieldName) {
        Set<Id> objectSet = new Set<Id>(paymentDeltaMap.keySet());

        // get current values from Project__c or Contact objects that are affected

        String soql = 'select id, TotalPayments__c, MostRecentPaymentDate__c, Recomputing__c from ' + objectName + ' where id in :objectSet';

        Map<Id, SObject> objectMap = new Map<Id, SObject>(Database.query(soql));

        Map<Id, SObject> toUpdate = new Map<Id, SObject>();

        Set<Id> toRecompute = new Set<Id>();  // list of object Ids that will require a recompute/rescan

        for (SObject theObject : objectMap.values()) {
        	if ((Boolean) theObject.get('Recomputing__c')) {  // batch is currently running against this object, shouldn't interfere
        		throw new DatabaseBusyException(Label.PPG_MSG_Database_Busy + ' (' + theObject.id + ')');
        	}

        	Date currentDate = (Date) theObject.get('MostRecentPaymentDate__c');

        	if (currentDate == null) {
        		currentDate = Date.newInstance(0, 1, 1);
        	}

        	Date maxDate = currentDate;

            List<PaymentDelta> paymentList = paymentDeltaMap.get(theObject.id);

            Decimal adjustment = 0;

            for (PaymentDelta delta : paymentList) {
                adjustment -= delta.previousAmount;  // subtract previous amount
                adjustment += delta.newAmount;  // add back in new amount

				if ((delta.previousDate != null) && (delta.previousDate == currentDate) && ((delta.newDate == null) || (delta.newDate < currentDate))) {
                	// adjusted a payment date to an earlier date when it was possibly the current maximum, or deleted

                	toRecompute.add(theObject.id);

				} else if ((delta.newDate != null) && (delta.newDate >= maxDate)) {
                	maxDate = delta.newDate;
                }
            }

            if (adjustment != 0) {  // non-zero adjustment, add to object
            	Decimal previousAmount = (Decimal) theObject.get('TotalPayments__c');

            	theObject.put('TotalPayments__c', ((previousAmount == null) ? 0 : previousAmount) + adjustment);

            	toUpdate.put(theObject.id, theObject);
            }

            if (maxDate > currentDate) {  // most recent payment date has changed
            	theObject.put('MostRecentPaymentDate__c', maxDate);

				toUpdate.put(theObject.id, theObject);
            }
        }

        if (toRecompute.size() > 0) {
	        // At least one payment date has been adjusted where that date was the same as the current Most Recent Payment Date.
	        // This means that the Payment__c table will need to be rescanned for the new maximum (since we're not using rollups).
	        // Instead of using an aggregate max/group by, this is processed "manually" so that we can avoid the maximum SOQL row
	        // governor limit.  If it would exceed the limit, the same algorithm is spun off asynchronously into a batch.
	        // Instead of hard-coding the 50,000 row limit, the limit is taken from the MAX_SYNC_RECOMPUTE_ROWS static value
	        // in this class so that it can be optimised for CPU time as well as the governor limit.

        	soql = 'select ' + lookupFieldName + ', PaymentDate__c from Payment__c where ' + lookupFieldName + ' in :toRecompute limit :MAX_SYNC_RECOMPUTE_ROWS';

        	List<Payment__c> payments = Database.query(soql);

        	if (payments.size() == MAX_SYNC_RECOMPUTE_ROWS) {  // too big for synchronous recompute, must use batch
        		RecomputeMostRecentPaymentDateBatch.go(toRecompute, lookupFieldName, objectName);

        	} else {  
        		// this is equivalent to an aggregate max/group by query, but doing it this way allows us to avoid
        		// query row limits and shunt off to batch if necessary

	        	Map<Id, Date> maxDateMap = new Map<Id, Date>();

	        	for (Id recomputeId : toRecompute) {
	        		maxDateMap.put(recomputeId, null);
	        	}

	        	// find max date for each object id, store in map

	        	for (Payment__c payment : payments) {
	        		Date theDate = maxDateMap.get((Id) payment.get(lookupFieldName));

	        		if ((theDate == null) || (payment.PaymentDate__c > theDate)) {
	        			maxDateMap.put((Id) payment.get(lookupFieldName), payment.PaymentDate__c);
	        		}
	        	}

	        	// apply max date to each object

	        	for (Id objectId : maxDateMap.keySet()) {
	        		SObject theObject = objectMap.get(objectId);

	        		theObject.put('MostRecentPaymentDate__c', maxDateMap.get(objectId));

	        		toUpdate.put(theObject.id, theObject);
	        	}
        	}
        }

        update toUpdate.values();  // intentionally don't catch exception - nothing can be done in trigger anyway
    }

	/**************************************************************************************************************
	* @description Convenience method to get buckets for Project__c and Contact, and then apply adjustments based
	* on the Payment__c objects in those buckets.
	*
	* @param payments a list of the Payment__c objects to be processed
	* @param oldMap the oldMap value from the current trigger context, if it exists, or null otherwise
	* @param isDelete indicates whether the current transaction is a delete
	*/

    public static void updateProjectsAndContacts(List<Payment__c> payments, Map<Id, Payment__c> oldMap, Boolean isDelete) {
        Map<Id, List<PaymentDelta>> projectMap = PaymentService.getBucket(payments, oldMap, 'Project__c', isDelete);
        PaymentService.applyAdjustments(projectMap, 'Project__c', 'Project__c');

        Map<Id, List<PaymentDelta>> payerMap = PaymentService.getBucket(payments, oldMap, 'Payer__c', isDelete);
        PaymentService.applyAdjustments(payerMap, 'Contact', 'Payer__c');
    }

	/**************************************************************************************************************
	* @description Sets the "global" error message (not associated with any specific field)
	*
	* @param message the error message
	*/

	private static void setError(String message) {
		PaymentsDto payments = new PaymentsDto();
		
		payments.setError(message);
		
		jsonData = payments.toJson();
	}

	/**************************************************************************************************************
	* @description Adds an error message associated with a specific field.
	*
	* @param field the field that the error is associated with
	* @param message the error message
	*/

	private static void setFieldError(String field, String message) {
		PaymentsDto payments = new PaymentsDto();
		
		payments.addFieldError(field, message);
		
		jsonData = payments.toJson();
	}

	/**************************************************************************************************************
	* @description Checks to make sure the payment amount is greater than 0, less than $1B, and numerical.
	*
	* @return true if the payment amount is valid
	*/

	private static Boolean validatePaymentAmount() {
		paymentAmount = null;

		try {
			paymentAmount = Decimal.valueOf(fields.get('paymentAmount'));
			paymentAmount.setScale(2);

		} catch (TypeException ex) {
			setFieldError('paymentAmount', Label.PPG_MSG_Payment_Numerical);

			return false;
		}

		if (paymentAmount <= 0) {
			setFieldError('paymentAmount', Label.PPG_MSG_Payment_Positive);

			return false;
		}

		if (paymentAmount > 1000000000) {
			setFieldError('paymentAmount', Label.PPG_MSG_Payment_Max);

			return false;
		}

		return true;
	}

	/**************************************************************************************************************
	* @description Checks to make sure the payment date is no older than January 1 of last year, and not in the
	* future.
	*
	* @return true if the payment date is valid
	*/

	private static Boolean validatePaymentDate() {
		paymentDate = null;

		try {
			paymentDate = Date.valueOf(fields.get('paymentDate'));

		} catch (TypeException ex) {
			setFieldError('paymentDate', Label.PPG_MSG_Payment_Date_Format);

			return false;
		}

		if (paymentDate > Date.today()) {
			setFieldError('paymentDate', Label.PPG_MSG_Payment_Date_Future);

			return false;
		}

		if (paymentDate.year() < (Date.today().year() - 1)) {
			setFieldError('paymentDate', Label.PPG_MSG_Payment_Date_Last_Year);

			return false;
		}

		return true;
	}

	/**************************************************************************************************************
	* @description Adds a new Payment__c record (with validation).
	*
	* @param params query parameters from the VF page, details specified by DataTables Editor
	*
	* @return JSON data including the new Payment__c record
	*/

	public static String doCreate(Map<String, String> params) {
		CustomPermissionsReader cpr = new CustomPermissionsReader();

		if (!cpr.hasPermission('PaymentAdd')) {
			setError(Label.PPG_MSG_No_Payment_Create_Permission);

			return jsonData;
		}

		fields = new Map<String, String>();

		// parse DataTables Editor parameters

		Pattern thePattern = Pattern.compile('data\\[0\\]\\[(.*?)\\]');

		for (String key : params.keySet()) {
			Matcher theMatcher = thePattern.matcher(key);

			if (theMatcher.matches()) {
				fields.put(theMatcher.group(1), params.get(key));
			}
		}

		Payment__c newPayment = new Payment__c();

		Id projectId = null;

		try {
			projectId = (Id) fields.get('projectSelect');

		} catch (StringException ex) {
			setFieldError('projectSelect', Label.PPG_MSG_Project_Name_Selected);

			return jsonData;
		}

		if (projectId == null) {
			setFieldError('projectSelect', Label.PPG_MSG_Project_Name_Selected);

			return jsonData;
		}

		newPayment.Project__c = projectId;

		Id payerId = null;

		try {
			payerId = (Id) fields.get('payerId');

		} catch (StringException ex) {
			setError(Label.PPG_MSG_Payer_Id_Invalid);

			return jsonData;
		}

		if (payerId == null) {
			setError(Label.PPG_MSG_Payer_Id_Invalid);

			return jsonData;
		}

		newPayment.Payer__c = payerId;

		if (!validatePaymentAmount()) {
			return jsonData;
		}

		newPayment.PaymentAmount__c = paymentAmount;

		if (!validatePaymentDate()) {
			return jsonData;
		}

		newPayment.PaymentDate__c = paymentDate;

		try {
			insert newPayment;

		} catch (DmlException ex) {
			System.debug(ex);

			setError(Label.PPG_MSG_Payment_Create_Failed);

			return jsonData;
		}

		PaymentsDto payments = PaymentService.getAllPaymentsForPayer(newPayment.Payer__c, ROW_LIMIT);

		jsonData = payments.toJson();

		return jsonData;
	}

	/**************************************************************************************************************
	* @description Edits an existing Payment__c record (with validation).
	*
	* @param params query parameters from the VF page, details specified by DataTables Editor
	*
	* @return JSON data including the edited Payment__c record
	*/

	public static String doEdit(Map<String, String> params) {
		CustomPermissionsReader cpr = new CustomPermissionsReader();

		if (!cpr.hasPermission('PaymentEdit')) {
			setError(Label.PPG_MSG_No_Payment_Edit_Permission);

			return jsonData;
		}

		Id paymentId = null;

		fields = new Map<String, String>();

		// parse DataTables Editor parameters

		Pattern thePattern = Pattern.compile('data\\[(.*?)\\]\\[(.*?)\\]');

		for (String key : params.keySet()) {
			Matcher theMatcher = thePattern.matcher(key);

			if (theMatcher.matches()) {
				paymentId = theMatcher.group(1);

				fields.put(theMatcher.group(2), params.get(key));
			}
		}

		if (paymentId == null) {
			setError(Label.PPG_MSG_Payment_Id_Missing);

			return jsonData;
		}

		Payment__c payment = [select id, Payer__c from Payment__c where id = :paymentId];

		if (payment == null) {
			setError(Label.PPG_MSG_Unable_to_Locate_Payment + ' (' + paymentId + ')');

			return jsonData;
		}

		Boolean needsUpdate = false;

		if (fields.containsKey('paymentAmount')) {
			if (!validatePaymentAmount()) {
				return jsonData;
			}

			payment.put('PaymentAmount__c', paymentAmount);
			needsUpdate = true;
		}

		if (fields.containsKey('paymentDate')) {
			if (!validatePaymentDate()) {
				return jsonData;
			}

			payment.put('PaymentDate__c', paymentDate);
			needsUpdate = true;
		}

		if (needsUpdate) {
			try {
				update payment;

			} catch (DmlException ex) {
				System.debug(ex);

				setError(Label.PPG_MSG_Payment_Edit_Failed);

				return jsonData;
			}
		}

		PaymentsDto payments = PaymentService.getAllPaymentsForPayer(payment.Payer__c, ROW_LIMIT);

		jsonData = payments.toJson();

		return jsonData;
	}

	/**************************************************************************************************************
	* @description Deletes an existing Payment__c record.
	*
	* @param params query parameters from the VF page, details specified by DataTables Editor
	*
	* @return JSON data including the remaining Payment__c records
	*/

	public static String doDelete(Map<String, String> params) {
		CustomPermissionsReader cpr = new CustomPermissionsReader();

		if (!cpr.hasPermission('PaymentDelete')) {
			setError(Label.PPG_MSG_No_Payment_Delete_Permission);

			return jsonData;
		}

		Id paymentId = null;

		// parse DataTables Editor parameters

		Pattern thePattern = Pattern.compile('data\\[(.*?)\\]\\[paymentId\\]');

		for (String key : params.keySet()) {
			Matcher theMatcher = thePattern.matcher(key);

			if (theMatcher.matches()) {
				paymentId = theMatcher.group(1);

				break;
			}
		}

		if (paymentId == null) {
			setError(Label.PPG_MSG_Payment_Id_Missing);

			return jsonData;
		}

		Payment__c payment = [select id, Payer__c from Payment__c where id = :paymentId];

		if (payment == null) {
			setError(Label.PPG_MSG_Unable_to_Locate_Payment + ' (' + paymentId + ')');

			return jsonData;
		}

		Id payerId = payment.Payer__c;

		try {
			delete payment;

		} catch (DmlException ex) {
			System.debug(ex);

			setError(Label.PPG_MSG_Payment_Delete_Failed);

			return jsonData;
		}

		PaymentsDto payments = PaymentService.getAllPaymentsForPayer(payerId, ROW_LIMIT);

		jsonData = payments.toJson();

		return jsonData;
	}
}
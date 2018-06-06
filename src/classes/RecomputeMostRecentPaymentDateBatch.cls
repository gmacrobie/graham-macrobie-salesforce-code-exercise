/**
* @author Graham MacRobie
* @date November 15, 2017
*
* @description Batch fallback for when synchronous recompute of most recent payment date in PaymentService has too
* many rows to succeed.
*/

global class RecomputeMostRecentPaymentDateBatch implements Database.Batchable<sObject>, Database.Stateful {
	global Set<Id> toRecompute;
	global String lookupFieldName;
	global String objectName;

	global Map<Id, Date> maxDateMap;

	global static void go(Set<Id> toRecompute, String lookupFieldName, String objectName) {
		String soql = 'select id from ' + objectName + ' where id in :toRecompute';

		List<SObject> objectList = Database.query(soql);

		for (SObject theObject : objectList) {
			theObject.put('Recomputing__c', true);
		}

		update objectList;

		Database.executeBatch(new RecomputeMostRecentPaymentDateBatch(toRecompute, lookupFieldName, objectName), 49999);
	}

	global RecomputeMostRecentPaymentDateBatch(Set<Id> toRecompute, String lookupFieldName, String objectName) {
		this.toRecompute = toRecompute;
		this.lookupFieldName = lookupFieldName;
		this.objectName = objectName;

		maxDateMap = new Map<Id, Date>();

		for (Id recomputeId : toRecompute) {
			maxDateMap.put(recomputeId, null);
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('select ' + lookupFieldName + ', PaymentDate__c from Payment__c where ' + lookupFieldName + ' in :toRecompute');
	}

   	global void execute(Database.BatchableContext BC, List<Payment__c> scope) {
		// this is equivalent to an aggregate max/group by query, but doing it this way allows us to avoid query row limits

		// find max date for each object id, store in map

		for (Payment__c payment : scope) {
			Date theDate = maxDateMap.get((Id) payment.get(lookupFieldName));

			if ((theDate == null) || (payment.PaymentDate__c > theDate)) {
				maxDateMap.put((Id) payment.get(lookupFieldName), payment.PaymentDate__c);
			}
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		Set<Id> objectIds = new Set<Id>(maxDateMap.keySet());

		String soql = 'select id from ' + objectName + ' where id in :objectIds';

		Map<Id, SObject> objectMap = new Map<Id, SObject>(Database.query(soql));

		List<SObject> toUpdate = new List<SObject>();

		// apply max date to each object

		for (Id objectId : maxDateMap.keySet()) {
			SObject theObject = objectMap.get(objectId);

			theObject.put('MostRecentPaymentDate__c', maxDateMap.get(objectId));

			toUpdate.add(theObject);
		}

		update toUpdate;

		soql = 'select id from ' + objectName + ' where id in :toRecompute';

		List<SObject> objectList = Database.query(soql);

		for (SObject theObject : objectList) {
			theObject.put('Recomputing__c', false);
		}

		update objectList;
	}
}
/**
* @author Graham MacRobie
* @date November 13, 2017
*
* @description Indicates that an insert/update/delete could not be processed because a batch is currently running that requires
* locked access to avoid race conditions.  Typically this would only happen if either Project__c and/or Contact became very large
* (50,000+ rows) and a PaymentDate__c was adjusted to an earlier date.  The resulting rescan must be processed asynchronously
* in a batch, but we can't have updates to those values while it's working.
*/

public class DatabaseBusyException extends Exception {
}
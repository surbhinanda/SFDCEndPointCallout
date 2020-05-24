    /*
    ***********************************************************************************************
    *  (Description) This class is used for calling rest point when transaction item size and transaction count is same. for details refer following steps
    *
    * 1) This Handler is called to perform the business rule
    *	which will fill the data in map for insert, update , delete and undelete operations.
    *	2) Once transaction item object size and trancation count is same then  end point is called to send the data to
    *	external system using queable interface.
    * Assumption is- when  transaction record count is updated manually - b)  Record is inserted in transaction item- ideally
    * it should be roll up summary field - so that it should  get updated automatically when record will get createated in Transaction Item.
    * Assumption2 - as  each transaction should be associated with transaction but as per payload - there we are not ataching transactionid to transaction item
    * so each data should be processed one by one. This payload should  have transactionid atatched to
    * it so that external system able to identify which transaction it is.
    *

    * Created By: Surbhi Gupta.
    * Revisions: NIL

    ***************************************************************************************************
    */
    public class TransactionItemTriggerHandler {

        public static void onAfter(List<TransactionItem__c> newItemList,map<Id,TransactionItem__c> Itemoldmap) {
            Set<Id> transactionIdSet = new Set<Id>();
            if(trigger.new != null){
                for(TransactionItem__c rec : newItemList){
                    transactionIdSet.add(rec.Transaction__c);
                }
            }

            if(trigger.oldMap != null){
                for(TransactionItem__c rec : Itemoldmap.values()){
                    transactionIdSet.add(rec.Transaction__c);
                }
            }

            Map<id, List<TransactionItem__c>> parentToChildMap = new Map<id, List<TransactionItem__c>>();
            Map<id, integer> parentCount = new Map<id, integer>();
            if(transactionIdSet !=null){
                List<TransactionItem__c> transactionItemList = [SELECT id, name, Item_Cost__c, Transaction__c, Transaction__r.Transaction_Count__c FROM TransactionItem__c where Transaction__c in: transactionIdSet];
                for(TransactionItem__c rec : transactionItemList){
                    if(parentToChildMap.containsKey(rec.Transaction__c))
                        parentToChildMap.get(rec.Transaction__c).add(rec);
                    else{
                        parentToChildMap.put(rec.Transaction__c, new List<TransactionItem__c>{rec});
                        parentCount.put(rec.Transaction__c, integer.valueof(rec.Transaction__r.Transaction_Count__c));
                    }
                }
            }
            system.debug('parentToChildMap::'+parentToChildMap);

            if(!parentToChildMap.isEmpty()){
                for(String ParentId : parentToChildMap.keyset()){
                    system.debug('parentToChildMap.get(ParentId).size()---->>>>'+parentToChildMap.get(ParentId).size());
                    if(parentToChildMap.get(ParentId).size() == parentCount.get(ParentId)){
                        system.enqueueJob(new ProcessTransactionItemQueueable(ParentId, parentToChildMap.get(ParentId)));
                    }
                }
            }

        }
    }
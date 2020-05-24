    /*
    ***********************************************************************************************
    *
    /*
    * 1) Queueable interface used to send the request to end point- Named credentails needs to be set -
    *	so that  authetication could be made. It get parameter from trigger handler
    *	so that we can fill the wrapper class of
    *	desired format and serialise the data for payload.
    *	2) Wrapepr class is filled for tranacation and transaction item  from constructor of queable interface
    *	3) Http request is sent to external system- Here end point is dummy and response is fetched.
    *	4) if response is success then it secondpayload call is sent with wrapper class of Transaction with same job id as this is not having any DML operations so no need to sperate out to another queable interface.
    *	5)- can be achieved-  Http callout can give different responses and  based on that we can log it into custom object to track error handling
    *	and atatchment can be added to view more details of payload we can track more
    *	low  level response  and we can resend the failed request by chaining or via batch.
    *	6)other Apex Classes to create Persistent Logs of type Error or
    * Information as opposed to native Debug Logs.
    *
    *
    * Created By: Surbhi Gupta.
    *
    *
    *
    * 
    * Revisions: NIL
    */


    public class ProcessTransactionItemQueueable implements Queueable,Database.AllowsCallouts{
        @testVisible
        private static Boolean doChainJob = true;

        public string transactionId = '';
        public List<TransactionItem__c> transactionItemList = new List<TransactionItem__c>();

        public ProcessTransactionItemQueueable(String transactionId, List<TransactionItem__c> transactionItemList){
            this.transactionId = transactionId;
            this.transactionItemList = transactionItemList;
        }

        public void execute(QueueableContext qc){

            List<TransactionItemWrapper> TRIWrapperList = new List<TransactionItemWrapper>();
            for(TransactionItem__c rec : transactionItemList){
                TransactionItemWrapper TRIWrapper = new TransactionItemWrapper();

                TransactionItemWrapper.Keys TRIKey = new TransactionItemWrapper.Keys();
                TRIKey.TransactionItemID = rec.id;

                TransactionItemWrapper.Values TRIValues = new TransactionItemWrapper.Values();
                TRIValues.ItemCost = string.Valueof(rec.Item_Cost__c);
                TRIValues.ItemName = rec.Name;

                TRIWrapper.Keys = TRIKey;
                TRIWrapper.Values = TRIValues;
                TRIWrapperList.add(TRIWrapper);
            }
            system.debug('TRIWrapperList::'+JSON.serialize(TRIWrapperList));
            String reqBody = JSON.serialize(TRIWrapperList);
            Id jobId = qc.getJobId();
            String endPoint1 = 'http://www.apexdevnet.com';

            String response =TransactionUtility.sendPayload(reqBody,jobId,endPoint1);

            if(response.endsWithIgnoreCase('successfull')){
                 String reqBodyTransaction = getTransactionList(transactionId);
                 system.debug('reqBodyTransaction::'+reqBodyTransaction);
                 String endPoint2 = 'http://www.apexdevnet.com';
                 String TRPayloadresponse = TransactionUtility.sendPayload(reqBodyTransaction,jobId,endPoint2);
                 system.debug('second payload sent successfully-'+TRPayloadresponse);

            }
            else {
                system.debug('Failed response');
            }
        }
             private static String getTransactionList(String transactionID){
                system.debug('Inside second payload-->>>>>');
                map<ID,List<transaction__C>> transactionDetails = new map<Id,List<transaction__C>>();

                List<Transaction__c> tranRec = [SELECT id, Transaction_Count__c,Total_Cost__c,Total_Discount__c,Name,CreatedDate,LastModifiedDate
                                   FROM Transaction__c
                                   WHERE Id =:transactionID];
                TransactionWrapper TRWrapper = new TransactionWrapper();
                for(Transaction__c recTra: tranRec){
                    TransactionWrapper.Keys TRKey = new TransactionWrapper.Keys();
                        TRKey.TransactionID = recTra.id;

                    TransactionWrapper.Values TRValues = new TransactionWrapper.Values();
                        TRValues.TotalCost = string.Valueof(recTra.Total_Cost__c);
                        TRValues.TotalDiscount = string.Valueof(recTra.Total_Discount__c);
                         DateTime d = recTra.LastModifiedDate;
                        String dateStr =d.format('yyy/MM/dd');
                        TRValues.TransactionDate =dateStr;
                        TRValues.TotalCount = String.Valueof(recTra.Transaction_Count__c);

                        TRWrapper.Keys = TRKey;
                        TRWrapper.Values = TRValues;


                }
                system.debug('Seonc payload--->>>'+JSON.serialize(TRWrapper));
                return JSON.serialize(TRWrapper);
            }






    }
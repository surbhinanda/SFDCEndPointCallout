    @isTest
    public class TransactionItemTriggerHandlerTest {

        @testSetup
        private static void testDataSetUp(){
            Transaction__c transction = new Transaction__c(Transaction_Count__c= 2,
                                                           Total_Cost__c =100,
                                                           Total_Discount__c=500
                                                          );
            insert transction;
            TransactionItem__c transctionItem = new TransactionItem__c(Item_Cost__c= 10,
                                                                       Transaction__c =transction.id);
            insert transctionItem;
        }


        private static testMethod void createTransactionItem() {

            Test.setMock(HttpCalloutMock.class, new TransactionItemHttpCalloutMock());

            Id transactionId = [select id,name from Transaction__c].id;
            Test.startTest();
            TransactionItem__c transctionItem = new TransactionItem__c(Item_Cost__c= 10,
                                                                       Transaction__c =transactionId);
            insert transctionItem;
            Test.stopTest();

            System.assertEquals(2, [select count() from TransactionItem__c where Transaction__c =: transactionId]);


        }
        private static testMethod void updateTransactionItem() {
            Test.setMock(HttpCalloutMock.class, new TransactionItemHttpCalloutMock());

            Transaction__c transactionObj = [select id,name,Transaction_Count__c from Transaction__c];
            transactionobj.Transaction_Count__c = 1;
            update transactionObj;

            TransactionItem__c transactionItem = [select id,Item_Cost__c,Transaction__c from TransactionItem__c where Transaction__c =:transactionObj.id];
            Test.startTest();
            transactionItem.Item_Cost__c = 200;
            update transactionItem;
            Test.stopTest();

            System.assertEquals(1, [select count() from TransactionItem__c where Transaction__c =: transactionObj.id]);


        }
    }
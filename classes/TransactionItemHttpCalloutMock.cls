   /* Mock repsonse class is written so that mock response is executed
    *
    * Surbhi Gupta
    */

   @isTest
   global class TransactionItemHttpCalloutMock implements HttpCalloutMock {


        global HTTPResponse respond(HTTPRequest req) {
           // Optionally, only send a mock response for a specific endpoint
           // and method.
           System.assertEquals('http://www.apexdevnet.com', req.getEndpoint());
           System.assertEquals('POST', req.getMethod());

           // Create a fake response
           HttpResponse res = new HttpResponse();
           res.setHeader('Content-Type', 'application/json');
           res.setBody('successfull');
           res.setStatusCode(200);
           return res;
       }

   }
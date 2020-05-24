    public class TransactionUtility {

         public static String sendPayload(String reqBody,Id jobId,String URL ) {
               Long start = System.now().getTime();
                 String success ='successfull';
                 try{
                    HttpResponse response = HTTPCallout(URL, reqBody);
                    if(response.getStatusCode() == 200){
                        system.debug('Status is okay');
                        return success;
                  }else{
                            system.debug('Status is NoOK');
                     }

                 }catch(Exception ex){
                     system.debug(ex.getStackTraceString().replace('\n',' / ')+' - '+ex.getMessage());
                     }

                return success;

        }
         public Static HttpResponse HTTPCallout(String EndPoint, String reqBody) {
                Http h = new Http();
                HttpRequest request = new HttpRequest();
                request.setHeader('Content-Type','application/json');
                request.setMethod('POST');
                request.setEndpoint(EndPoint);
                request.setTimeout(60000);
                request.setBody(reqBody);

                HttpResponse response = h.send(request);
                return response;

        }

    }
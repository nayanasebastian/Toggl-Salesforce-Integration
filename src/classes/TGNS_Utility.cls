public class TGNS_Utility {
    //description
   // public static <returntype> methodName([SObject sObj], [String fieldName]) {
     //logic
   // }

    private static String getOverride;

    public static String sendHTTPRequest(String url, String apiKey){
        try{
          HttpRequest req = new HttpRequest();
          req.setMethod('GET');
          req.setHeader('Connection', 'keep-alive');
          req.setHeader('Authorization', 
                        'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(apiKey + ':api_token'))
                        );
          req.setEndpoint(url);
          return HTTPRequest(req);
        }
        catch(Exception expn) {
          throw new UtilityException(expn.getMessage());
        }
       
    }

    public static String HTTPRequest(HttpRequest request) {       
        if (getOverride != null) {
            return getOverride;
        }
        Http htp = new Http();
        HttpResponse response = htp.send(request);
        if (response.getStatusCode() != 200) {
            throw new UtilityException('Invalid status code ' + response.getStatusCode());
        }
        return response.getBody();
    }

    public class UtilityException extends Exception{}
}
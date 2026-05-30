/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-19-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public  with sharing class GoogleDriveHandler {
    @AuraEnabled
    public static Map<string, Object> getFile(){      

        string url ='callout:Google_Drive_API_2/drive/v3/files';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        HttpResponse res = new Http().send(req);
        system.debug('res'+res.getBody());
        if(res.getStatusCode()==200){
            return (Map<string, Object>)JSON.deserializeUntyped(res.getBody());
        }
        return (Map<string, Object>)JSON.deserializeUntyped(res.getBody());        

    }
   

    @AuraEnabled
    public static Map<String, String> previewFile(String id) {

    HttpRequest metaReq = new HttpRequest();
    metaReq.setEndpoint(
        'callout:Google_Drive_API_2/drive/v3/files/' + id
        + '?fields=id,name,mimeType'
    );
    metaReq.setMethod('GET');
    HttpResponse metaRes = new Http().send(metaReq);

    String mimeType = 'application/octet-stream';
    String fileName = 'file';

    if (metaRes.getStatusCode() == 200) {
        Map<String,Object> meta =
            (Map<String,Object>) JSON.deserializeUntyped(
                metaRes.getBody()
            );
        mimeType = (String) meta.get('mimeType');
        fileName = (String) meta.get('name');
    }

    // Step 2 — Google native files cannot download
    if (mimeType != null &&
        mimeType.startsWith('application/vnd.google-apps')) {
        return new Map<String,String>{
            'base64'   => '',
            'mimeType' => mimeType,
            'name'     => fileName,
            'type'     => 'google_native'
        };
    }

    // Step 3 — Download file content
    HttpRequest req = new HttpRequest();
    req.setEndpoint(
        'callout:Google_Drive_API_2/drive/v3/files/' + id
        + '?alt=media'
    );
    req.setMethod('GET');
    req.setTimeout(120000);
    HttpResponse res = new Http().send(req);

    System.debug('previewFile status: ' + res.getStatusCode());

    if (res.getStatusCode() == 200) {
        String base64Content =
            EncodingUtil.base64Encode(res.getBodyAsBlob());

        // Determine type for LWC rendering
        String type = 'other';
        if      (mimeType == 'application/pdf')
            type = 'pdf';
        else if (mimeType != null &&
                 mimeType.startsWith('image/'))
            type = 'image';
        else if (mimeType == 'text/plain')
            type = 'text';
        else if (mimeType == 'text/csv')
            type = 'csv';
        else if (mimeType == 'application/json')
            type = 'json';
        else if (mimeType == 'text/html')
            type = 'text';

        return new Map<String,String>{
            'base64'   => base64Content,
            'mimeType' => mimeType,
            'name'     => fileName,
            'type'     => type,
            'id' => id
        };
    }
    throw new AuraHandledException(
        'Failed to preview file: ' + res.getBody()
    );
}

    @AuraEnabled 
    public static string deleteFile(string id){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Google_Drive_API_2/drive/v3/files/'+id);
        req.setMethod('DELETE');
        req.setTimeout(120000); 
        req.setHeader('Content-Type', 'application/json');
        //https://www.googleapis.com/files/1odgjBpFTXIuEOi1HuCn3ux8cQbPD5EJG
        HttpResponse res = new Http().send(req);
        system.debug('res'+res.getBody());
        if(res.getStatusCode()==204){
            return 'Success';
        }
        else{
            return '';
        }
    }

    @AuraEnabled
public static Map<String, String> downloadFile(String id) {
    try {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            'callout:Google_Drive_API_2/drive/v3/files/'
            + id + '?alt=media'
        );
        req.setMethod('GET');
        req.setTimeout(120000);
        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 200) {
            return new Map<String,String>{
                'base64' => EncodingUtil.base64Encode(
                                res.getBodyAsBlob())
            };
        }
        throw new AuraHandledException(
            'Download failed: ' + res.getBody()
        );

    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}

@AuraEnabled
    public static String uploadFile(String base64Data, String fileName, String mimeType) {
        
        // 1. Clean the base64 string
        String base64Content = base64Data;
        if (base64Data.contains('base64,')) {
            base64Content = base64Data.substringAfter('base64,');
        }

        // 2. Fallback for mimeType if none is provided
        if (String.isBlank(mimeType)) {
            mimeType = 'application/octet-stream';
        }

        String boundary = 'SF_BOUNDARY_001';
        String delimiter = '\r\n--' + boundary + '\r\n';
        String closeDelim = '\r\n--' + boundary + '--';
                
        // 3. Build Metadata JSON
        Map<String, Object> fileMetadata = new Map<String, Object>{
            'name' => fileName,
            'mimeType' => mimeType
        };
        String metadataJson = JSON.serialize(fileMetadata);

        // 4. Build the Multipart Body
        // FIXED: Using base64Content instead of base64Data here
        String body = '--' + boundary + '\r\n' +
                  'Content-Type: application/json; charset=UTF-8\r\n\r\n' +
                  metadataJson + 
                  delimiter +
                  'Content-Type: ' + mimeType + '\r\n' +
                  'Content-Transfer-Encoding: base64\r\n\r\n' +
                  base64Content + 
                  closeDelim;

        // 5. Configure Callout
        String url = 'callout:Google_Drive_API_2/upload/drive/v3/files?uploadType=multipart';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'multipart/related; boundary="' + boundary + '"');
        req.setBody(body);
        req.setTimeout(120000); // 2 minutes for larger files
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // 6. Handle Response
        if(res.getStatusCode() != 200) {
            throw new AuraHandledException('Failed to upload file: ' + res.getBody());
        } else {
            System.debug('Success Response: => : ' + res.getBody());
            
            // Parse the Google Drive File ID from the response and return it
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) responseMap.get('id');
        }
    }
}
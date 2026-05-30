/**
 * @description       : Handles file uploads to Google Drive via Multipart/Related
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @last modified on  : 03-19-2026
**/
public with sharing class UploadFileHandler {
    
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
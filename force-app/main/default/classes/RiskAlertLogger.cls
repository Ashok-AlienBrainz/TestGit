/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-28-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class RiskAlertLogger {
    
   public static void log(String ticker, String status, String rawResponse, String alertType, Id accountId, String apexClass) {
        System.debug('Thisis status value on log '+status +' '+alertType);
        Risk_Alert_Log__c logEntry = new Risk_Alert_Log__c();
        logEntry.Ticker__c = ticker;
        logEntry.Status__c = status;
        logEntry.Row_Response__c = rawResponse;
        logEntry.Alert_Type__c = alertType;
        logEntry.Account__c = accountId;
        
        try {
            Database.SaveResult sr = Database.insert(logEntry, false);
            
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('RiskAlertLogger failed to save log: ' + err.getMessage());
                }
            }
        } catch (Exception e) {
            System.debug('Critical failure in RiskAlertLogger: ' + e.getMessage());
        }
    }
}
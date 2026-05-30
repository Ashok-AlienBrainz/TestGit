/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-30-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class LeadTriggerHandler {
   
    public static void dynamicLeadValidationUsingMetadata(List<Lead> leadList){

        List<Lead_Validation__mdt> valition =  [SELECT Field_Name__c, Value__c, Error_Message__c FROM Lead_Validation__mdt];

        for(lead lead : leadList){
            // Map<String , schema.sObjectField> fieldMap = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap();
           // Schema.DescribeFieldResult fieldResult = fieldMap.get(valition[0].Field_Name__c).getDescribe();
            String fieldName = valition[0].Field_Name__c ;
            Object fieldValue = lead.get(fieldName);
            Decimal recordValue = (Decimal)fieldValue;
            Decimal targetValue = (valition[0].Value__c);
            
            System.debug('fieldValue' + fieldValue);
            System.debug('targetValue' + targetValue);
            if(recordValue < targetValue){
                lead.addError(valition[0].Error_Message__c);
            }
        }

    }
}
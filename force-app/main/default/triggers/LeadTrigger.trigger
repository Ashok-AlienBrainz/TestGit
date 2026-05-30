/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-30-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger LeadTrigger on Lead (before insert) {

   switch on Trigger.operationType {
    when BEFORE_INSERT {
      LeadTriggerHandler.dynamicLeadValidationUsingMetadata(Trigger.new);
      
    }
  }

}
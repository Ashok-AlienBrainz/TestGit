/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-28-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger AccountTrigger on Account (before insert , before update , before delete , after insert , after update , after delete , after undelete) {

  switch on Trigger.operationType{

    when BEFORE_INSERT{
      
    }
    when BEFORE_UPDATE{
      AccountTriggerHandler.updateBasedOnCustomSetting(Trigger.new , trigger.OldMap);
    }
    when AFTER_UPDATE{
      AccountTriggerHandler.udpateAddressOnContact(Trigger.newMap , Trigger.oldMap);
      
    }
    when BEFORE_DELETE{
      // First, prevent deletion if Account has related Opportunities that are not Closed Lost
      AccountTriggerHandler.preventDeleteIfOpenOppsExist(Trigger.old);
      // If allowed, proceed with existing delete logic for related Contacts/logging
      AccountTriggerHandler.deleteContactWhenAccountDelete(Trigger.old);
    }
  }
}

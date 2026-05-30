/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-03-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger CaseTrigger on case (before insert , before update , before delete ,after insert , after update , after delete , after undelete) {


  switch on Trigger.operationType{
    
    when BEFORE_INSERT{

    }
    when BEFORE_UPDATE{
      

    }
    when AFTER_UPDATE{
      CaseTriggerHandler.tastAssignToQuote(Trigger.newMap , Trigger.oldMap);
    }
  }


}

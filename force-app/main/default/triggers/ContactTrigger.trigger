/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-30-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger ContactTrigger on Contact (before insert , after Insert , before update , after update , before delete , after delete , after undelete) {

  switch on Trigger.operationType {
    when BEFORE_INSERT {
      System.debug('Before Insert +++');
      ContactTriggerHandler.contactPhoneFormetter(trigger.New);
      ContactTriggerHandler.duplicateCotactCheck(trigger.New);
      System.debug('Before Insert --');
     
      
    }
    when AFTER_INSERT {
      System.debug('After Insert +++');
      ContactTriggerHandler.countContactOnInerts(Trigger.New);
      //ContactTriggerHandler.countContoctOnAccountOnInsert(Trigger.New);
      System.debug('After Insert ---');
    }
    when BEFORE_UPDATE {}
    when AFTER_UPDATE {
        system.debug('After Update +++');
        ContactTriggerHandler.countContactUpdate(Trigger.new , Trigger.oldMap);
        //ContactTriggerHandler.countContoctOnAccountOnUpdate(Trigger.oldMap, Trigger.newMap);  
        system.debug('After Update ---');
      }
    when BEFORE_DELETE {
      System.debug('Before Delete +++');
      ContactTriggerHandler.preventDeleteContactWhenAccountActive(Trigger.old);
      
      System.debug('Before Delete ---');
    }
    when AFTER_DELETE {
      System.debug('After Delete +++');
      ContactTriggerHandler.countContactOnInerts(Trigger.old);
     // ContactTriggerHandler.countContactOnAccountOnDelete(Trigger.oldMap);
      System.debug('After Delete ---');
    }
    when AFTER_UNDELETE {}
  }


}
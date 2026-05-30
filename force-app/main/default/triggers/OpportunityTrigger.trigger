/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-28-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger OpportunityTrigger on Opportunity (after insert ,  after update, after delete, after undelete , before insert , before update , before delete) {


  Switch on Trigger.operationType{
    when BEFORE_INSERT{}
    when AFTER_INSERT{
      OpportunityTriggerHAndler.createTaskWhenCloseWon(Trigger.new);
      OpportunityTriggerHAndler.calculateTotalAmountWOfClosedWonOnInsert(trigger.new);
      opporuntyAmountCounter.recalculateForAccounts(new Map<Id, Opportunity>(Trigger.new).keySet());
    }
    when BEFORE_UPDATE{}
    when AFTER_UPDATE{
      OpportunityTriggerHAndler.calculateTotalAmountWOfClosedWonOnUpdate(trigger.newMap , trigger.oldMap);
      OpportunityTriggerHAndler.opportunityUpdateThenAccountAndParentAccountAndCaseUpdate(Trigger.newMap , trigger.oldMap);
      Set<Id> acctIds = new Set<Id>();
      for (Opportunity o : Trigger.new) if (o.AccountId != null) acctIds.add(o.AccountId);
      for (Opportunity o : Trigger.old) if (o.AccountId != null) acctIds.add(o.AccountId);
      if (!acctIds.isEmpty()) opporuntyAmountCounter.recalculateForAccounts(acctIds);
    }
    when BEFORE_DELETE{}
    when AFTER_DELETE{
            OpportunityTriggerHAndler.calculateTotalAmountWOfClosedWonOnDelete(trigger.old);
            Set<Id> acctIds = new Set<Id>();
            for (Opportunity o : Trigger.old) if (o.AccountId != null) acctIds.add(o.AccountId);
            if (!acctIds.isEmpty()) opporuntyAmountCounter.recalculateForAccounts(acctIds);

    }
    when AFTER_UNDELETE{
                  OpportunityTriggerHAndler.calculateTotalAmountWOfClosedWonOnUndelete(trigger.new);
                  opporuntyAmountCounter.recalculateForAccounts(new Map<Id, Opportunity>(Trigger.new).keySet());

    }
  }

}

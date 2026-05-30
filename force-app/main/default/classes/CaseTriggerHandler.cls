/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-03-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CaseTriggerHandler {
   
    public static void tastAssignToQuote(Map<Id , Case> newMap , Map<Id , case> oldMap){

        List<case> caseList = new List<Case>();
        for(Case cs : newMap.values()){
            if(cs.Priority != oldMap.get(cs.Id).Priority && cs.Priority =='High'){
                caseList.add(cs);
            }
        }

        if(!caseList.isEmpty()){
            System.enqueueJob(new CaseQueueableHandler(caseList));
        }
        

    }
}
/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-21-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OpportunityTriggerHAndler {
    
    public static void createTaskWhenCloseWon(List<Opportunity> oppList){
        List<Task> taskList = new List<Task>();
        for(Opportunity opp : oppList){
            {
                if(opp.StageName == 'Closed Won'){
                    Task task = new Task();
                    task.WhatId = opp.Id;
                    task.Subject = 'Follow-Up: Enterprise Opportunity';
                    task.OwnerId = opp.OwnerId;
                    task.ActivityDate= System.today().addDays(3);
                    taskList.add(task);

                }
            }
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }

    public static  void addDescription(List<Opportunity> oppList){

        for(Opportunity opp : oppList){
            if(opp.Type =='New Customer'){
                opp.Description ='New customer opportunity, focus on onboarding';
            }
            else if(opp.Type =='Existing Customer - Upgrade'){
                 opp.Description ='Upgrade opportunity for existing customer';
            }
            else if(opp.Type ==null){
                 opp.Description ='';
            }
        }

    }

    public static void calculateTotalAmountWOfClosedWonOnInsert(List<Opportunity> oppList){
         set<id> accIds = new set<id>();
        for(Opportunity opp : oppList){
          if(opp.AccountId!= null && opp.StageName == 'Closed Won'){
            accIds.add(opp.AccountId);
          }
        }
        calculateTotalAmountWOfClosedWon(accIds);

    }
    public static void calculateTotalAmountWOfClosedWonOnUpdate(Map<Id , Opportunity> newMap , Map<Id , Opportunity> oldMap){
         set<id> accIds = new set<id>();
        for(Opportunity opp : newMap.values()){
          if(opp.AccountId!= null && opp.StageName != oldMap.get(opp.id).StageName &&  opp.StageName == 'Closed Won'){
             accIds.add(opp.AccountId);
          }
        }
        calculateTotalAmountWOfClosedWon(accIds);

    }

      public static void calculateTotalAmountWOfClosedWonOnDelete(list<opportunity> oppList){
         set<id> accIds = new set<id>();
        for(Opportunity opp : oppList){
          if( opp.AccountId!= null && opp.StageName == 'Closed Won'){
             accIds.add(opp.AccountId);
          }
        }
        calculateTotalAmountWOfClosedWon(accIds);

    }
     public static void calculateTotalAmountWOfClosedWonOnUndelete(list<opportunity> oppList){
         set<id> accIds = new set<id>();
        for(Opportunity opp : oppList){
          if( opp.AccountId!= null && opp.StageName == 'Closed Won'){
            accIds.add(opp.AccountId);
          }
        }
        calculateTotalAmountWOfClosedWon(accIds);

    }


    public static void calculateTotalAmountWOfClosedWon(set<id> accIds){


         System.debug('accIds' + accIds);
        List<AggregateResult> aggList =[SELECT AccountId , SUM(Amount) totalAmount FROM Opportunity WHERE AccountId IN: accIds AND StageName = 'Closed Won' GROUP BY AccountId];

        system.debug('aggList' + aggList);
        List<Account> accSet = new List<Account>();

        for(AggregateResult agg : aggList){
            Account acc = new Account();
            acc.Id =(id)agg.get('AccountId');
            acc.Total_Closed_Won_Opp_Amount__c = (Decimal)agg.get('totalAmount');
            accSet.add(acc);
        }
        System.debug('accSet' + accSet);
        if(!accSet.isEmpty()){
            update accSet;
        }
    }



    public static void opportunityUpdateThenAccountAndParentAccountAndCaseUpdate(Map<Id , Opportunity> newMap , Map<Id , Opportunity> oldMap){

        List<Account> accList  = new List<Account>();
        for(Opportunity opp : newMap.values()){
            if(opp.Description  != oldMap.get(opp.Id).Description){
                System.debug('opportunityUpdateThenAccountAndParentAccountAndCaseUpdate '+opp.Description );
                System.debug('opportunityUpdateThenAccountAndParentAccountAndCaseUpdate '+oldMap.get(opp.Id).Description );

                If(opp.AccountId != null){
                    System.debug('opp.Account.ParentId != null '+opp.Account.ParentId != null + ' pparent Id '+opp.Account.ParentId );
                    System.debug('Parent Id '+opp.Account.Parent.Id );
                    if(opp.Account.ParentId != null){
                        System.debug('Account Parent');
                    	Account Acc = new Account();
						acc.Id = opp.Account.ParentId;
						acc.Description =opp.Description +' account';
						accList.add(acc);                        
                    }
                      System.debug('Account ');

                    	Account Acc2 = new Account();
						acc2.Id = opp.AccountId;
						acc2.Description =opp.Description +' parent account';
						accList.add(acc2);                    
                    }
            }
        }
        System.debug('acclist '+acclist);

        if(!acclist.IsEmpty()){
            update acclist; 
        }

        
    }
}
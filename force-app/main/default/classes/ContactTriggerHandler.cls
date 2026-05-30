/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-30-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ContactTriggerHandler {

    public static void contactPhoneFormetter(list<contact> contactList){
        for(Contact con : contactList)
        {
            if(con.Phone != null ){
                String regex = '[^0-9]';
                string numberOnly = con.phone.replaceAll(regex, '');
                con.phone = numberOnly;
                
            }
        }


    }

    public static void duplicateCotactCheck(List<Contact> conlist){

        set<String> emailSet = new Set<String>();
        Map<string , Id > emailToContactMap = new Map<string , Id>();
        for(Contact con : conlist){
            if(String.isNotBlank(con.Email)){
                String emailLower = con.Email.toLowerCase();
                if(emailSet.contains(emailLower)){
                    con.addError('Duplicate Email');
                }else{
                    emailSet.add(emailLower);
                    emailToContactMap.put(emailLower , con.Id);
                }
            }
        }                                                                           

        if(!emailSet.isEmpty()){
            for(Contact oldCon :[SELECT Id , Name , Email FROM Contact WHERE Email IN:emailset AND Id NOT IN : Conlist]){
                emailToContactMap.put(oldCon.Email.toLowerCase() , oldCon.Id);
            }
            for(Contact con : conlist){
                if(string.isNotBlank(Con.Email)){
                    if(emailToContactMap.containsKey(con.Email.toLowerCase()) && emailToContactMap.get(con.Email.toLowerCase()) != con.Id){

                  con.addError('Duplicate email found: ' + con.Email + 
                                 '. This email is already associated with Contact ID: ' + 
                                 emailToContactMap.get(con.Email.toLowerCase()));

                    }
                }
            }
        }

    }

    public static void countContoctOnAccountOnInsert(List<contact> conList){

        Map<Id, Integer> accConCountMap = new Map<Id , Integer>();
        List<Id> accountList = new List<id>();
        for(Contact con : conList ){
            if(con.AccountId != null){
                accountList.add(con.AccountId);

            }
        }
        System.debug('accountList' + accountList);
        Map<Id , Account> fatchAccountMap = new Map<Id , Account>([SELECT Id , Name , Total_Contacts__c FROM Account WHERE Id IN :accountList]);

        System.debug('fatchAccountMap' + fatchAccountMap);
        for(Contact con : ConList){
            if(con.AccountId != null){
                if(accConCountMap.containsKey(con.AccountId)){
                    accConCountMap.put(con.AccountId , accConCountMap.get(con.AccountId) + 1);
                }
                else{
                    accConCountMap.put(con.AccountId , 1);
                }
            }
            
        }
         System.debug('accConCountMap' + accConCountMap);
        System.debug('accConCountMap' + JSON.serialize(accConCountMap));
        for(Account acc : fatchAccountMap.values()){
            Integer totalContact = accConCountMap.get(acc.Id);
            Decimal oldTotalContact = acc.Total_Contacts__c;
            acc.Total_Contacts__c = totalContact +(oldTotalContact == null ? 0 : oldTotalContact);
        }

        update fatchAccountMap.values();
    }

    public static void countContoctOnAccountOnUpdate(Map<Id , Contact> oldMap , Map<Id , Contact> newMap){

        Map<Id , Integer> newAccConCountMap = new Map<Id , Integer>();
        Map<Id , Integer> OldAccConCountMap = new Map<Id , Integer>();
        
        List<Id> newAddedAccountList = new List<Id>();
        List<Id> OldAddedAccountList = new List<Id>();

        for(Contact newCon : newMap.values()){
            if(newCon.AccountId != null){
                if(newCon.AccountId != oldMap.get(newCon.Id).AccountId){
                    newAddedAccountList.add(newCon.AccountId);
                    OldAddedAccountList.add(oldMap.get(newCon.Id).AccountId);

                }
                
            }
        }
        System.debug('newAddedAccountList' + newAddedAccountList);
        System.debug('OldAddedAccountList' + OldAddedAccountList);
        Map<Id , Account> fetchAddedAccount = new Map<Id , Account>([SELECT Id , Name , Total_Contacts__c FROM Account WHERE Id IN :newAddedAccountList]);
        Map<Id , Account> fetchRemoveAccount = new Map<Id , Account>([SELECT Id , Name , Total_Contacts__c FROM Account WHERE Id IN :OldAddedAccountList]);


        System.debug('fetchAddedAccount' + fetchAddedAccount);
        System.debug('fetchRemoveAccount' + fetchRemoveAccount);
        for(contact con : newMap.values()){
            if(con.AccountId != null){
                if(newAccConCountMap.containsKey(con.AccountId)){
                    newAccConCountMap.put(con.AccountId , newAccConCountMap.get(con.AccountId) + 1);
                }else {
                    newAccConCountMap.put(con.AccountId , 1);
                }
            }
        }
         for(contact con : oldMap.values()){
            if(con.AccountId != null){
                if(OldAccConCountMap.containsKey(con.AccountId)){
                    OldAccConCountMap.put(con.AccountId , OldAccConCountMap.get(con.AccountId) +1);
                }else {
                    OldAccConCountMap.put(con.AccountId , 1);
                }
            }
        }

        System.debug('newAccConCountMap' + newAccConCountMap);
        System.debug('OldAccConCountMap' + OldAccConCountMap);

         for(Account acc : fetchAddedAccount.values()){
            Integer totalContact = newAccConCountMap.get(acc.Id);
            Decimal oldTotalContact = acc.Total_Contacts__c;
            acc.Total_Contacts__c = totalContact +(oldTotalContact == null ? 0 : oldTotalContact);
        }
          for(Account acc : fetchRemoveAccount.values()){
            Integer totalContact = OldAccConCountMap.get(acc.Id);
            Decimal oldTotalContact = acc.Total_Contacts__c;
            acc.Total_Contacts__c = (oldTotalContact == null ? 0 : oldTotalContact) - totalContact;
        }

        if(!fetchAddedAccount.isEmpty() )
            update fetchAddedAccount.values();

        if(!fetchRemoveAccount.isEmpty() )
            update fetchRemoveAccount.values();

    }

    public static void countContactOnAccountOnDelete(Map<Id , Contact> oldMap){


        Map<Id , Integer> OldAccConCountMap = new Map<Id , Integer>();

        List<Id> OldAddedAccountList = new List<Id>();
        for(Contact con : oldMap.values() ){
            if(con.AccountId != null){
                OldAddedAccountList.add(con.AccountId);
            }
        }
        
        Map<Id , Account> fetchRemoveAccount = new Map<Id , Account>([SELECT Id , Name , Total_Contacts__c FROM Account WHERE Id IN :OldAddedAccountList]);

        for(Contact con : oldMap.values()){
            if(con.AccountId != null){
                if(OldAccConCountMap.containsKey(con.AccountId )){

                    OldAccConCountMap.put(con.AccountId , oldAccConCountMap.get(con.AccountId)+1);
                }
                else{
                    OldAccConCountMap.put(con.AccountId , 1);
                }
            }
        }

        for(Account  acc : fetchRemoveAccount.values()){
          
                Integer totalContact = OldAccConCountMap.get(acc.Id);
                Decimal oldTotalContact = acc.Total_Contacts__c;
                acc.Total_Contacts__c = (oldTotalContact == null ? 0 : oldTotalContact) - totalContact;
            
        }
        update fetchRemoveAccount.values();
    
    }

    // Thisis short and ggod way 
    public static void countContactOnInerts(List<Contact> conList){

        set<Id> accIds = new set<Id>();
        for(Contact con : conList){
            if(con.AccountId != null){
                accIds.add(con.AccountId);
            }
        }
        List<AggregateResult> argg = [SELECT count(Id) totalCountacts, AccountID   FROM Contact WHERE AccountId IN :accIds GROUP BY AccountId];

        List<Account> accList = new List<Account>();
        for(AggregateResult ar : argg){
            Id accId = (Id)ar.get('AccountID');
            Integer totalContact = (Integer)ar.get('totalCountacts');

            Account acc = new Account(Id = accId , Total_Contacts__c = totalContact);
            accList.add(acc);

        }
        update accList;

    }

    public static void countContactUpdate(List<Contact> newCon , Map<Id , Contact> oldMap){
    
      set<Id> accIds = new set<Id>();
        for(Contact con : newCon){
            if(con.AccountId != oldMap.get(con.Id).AccountId){
                accIds.add(con.AccountId);
            }
        }
        List<AggregateResult> argg = [SELECT count(Id) totalCountacts, AccountID   FROM Contact WHERE AccountId IN :accIds GROUP BY AccountId];

        List<Account> accList = new List<Account>();
        for(AggregateResult ar : argg){
            Id accId = (Id)ar.get('AccountID');
            Integer totalContact = (Integer)ar.get('totalCountacts');

            Account acc = new Account(Id = accId , Total_Contacts__c = totalContact);
            accList.add(acc);

        }
        update accList;
    
    }


    public static void preventDeleteContactWhenAccountActive(List<Contact>conList){

        set<Id> accIds = new set<Id>();
        for(Contact con : conList){
            if(con.AccountId !=null){
                accIds.add(con.AccountId);
            }
        }

        Map<Id , Account> accMap = New Map <Id , Account > ([SELECT Id , Name , Active__c FROM Account WHERE Id IN: accIds]);
        for(Contact con : conList){
            if(accMap.get(con.AccountId).Active__c =='Yes'){
                con.addError('Connot delete  contact from active Account');
            }
        }


    }

}
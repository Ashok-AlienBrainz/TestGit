/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-28-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AccountTriggerHandler {

    // Prevent Account deletion if it has related Opportunities not in "Closed Lost".
    // Allows deletion only when there are no related Opps OR all related Opps are "Closed Lost".
    public static void preventDeleteIfOpenOppsExist(List<Account> oldAccounts) {
        if (oldAccounts == null || oldAccounts.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();
        for (Account a : oldAccounts) {
            if (a.Id != null) accIds.add(a.Id);
        }
        if (accIds.isEmpty()) return;

        // Count Opportunities per Account that are NOT Closed Lost (including null StageName)
        // If count > 0 for an account, block deletion.
        AggregateResult[] agg = [
            SELECT AccountId accId, COUNT(Id) cnt
            FROM Opportunity
            WHERE AccountId IN :accIds
              AND (StageName = NULL OR StageName != 'Closed Lost')
            GROUP BY AccountId
        ];

        Map<Id, Integer> openOppCountsByAccount = new Map<Id, Integer>();
        for (AggregateResult ar : agg) {
            Id accId = (Id) ar.get('accId');
            Integer cnt = (Integer) ar.get('cnt');
            openOppCountsByAccount.put(accId, cnt);
        }

        for (Account a : oldAccounts) {
            Integer cnt = openOppCountsByAccount.get(a.Id);
            if (cnt != null && cnt > 0) {
                a.addError('You cannot delete this Account because it has related Opportunities that are not Closed Lost.');
            }
        }
    }


    public static void udpateAddressOnContact(Map<Id , Account > newMap , Map<Id , Account > oldMap){

        set<Id> accIds = new set<Id>();

        for(Account acc : newMap.values()){
            if(acc.BillingAddress != oldMap.get(acc.Id).BillingAddress
                ||acc.BillingCity != oldMap.get(acc.Id).BillingCity
                ||acc.BillingCountry != oldMap.get(acc.Id).BillingCountry
                ||acc.BillingState != oldMap.get(acc.Id).BillingState
                ||acc.BillingStreet != oldMap.get(acc.Id).BillingStreet
                ||acc.BillingPostalCode != oldMap.get(acc.Id).BillingPostalCode
            ){
                accIds.add(acc.Id);
            }
        }
        System.debug('update this line ');
                System.debug('update this line ');

        List<Account> AccParentChildList = [SELECT ID , Name  , BillingCity , BillingCountry , BillingState , BillingStreet , BillingPostalCode , 
                                            (SELECT ID ,  NAME , MailingCity , MailingCountry , MailingState , MailingStreet , MailingPostalCode FROM Contacts) FROM Account  WHERE Id IN : accIds];


    List<Contact>    contactList = new List<Contact>();
        for(Account acc : AccParentChildList){
            if(acc.Contacts.size()> 0){
                for(Contact Con : acc.Contacts){
                    Con.MailingCity = acc.BillingCity;
                    Con.MailingCountry = acc.BillingCountry;
                    Con.MailingState = acc.BillingState;
                    Con.MailingStreet = acc.BillingStreet;
                    Con.MailingPostalCode = acc.BillingPostalCode;
                    contactList.add(Con);
                }

            }
        }
        if(!contactList.isEmpty()){
            update contactList;
        }
    }

    public static void deleteContactWhenAccountDelete(List<Account> accList){

        System.debug('accList'+accList);
        List<Contact> deleteContactList = [SELECT Id , AccountID FROM Contact WHERE AccountID IN : accList ];

        System.debug('deleteContactList'+deleteContactList);
        List<Deleted_Contact_Log__c> deleteRecord = new List<Deleted_Contact_Log__c>();

        for(Contact con : deleteContactList){
            Deleted_Contact_Log__c delCon = new Deleted_Contact_Log__c();
            delCon.Contact_Id__c = con.Id;
            delCon.Account_Id__c = con.AccountId;
            delCon.Deleted_Date__c = System.today();
            deleteRecord.add(delCon);

        }
        System.debug('deleteRecord'+deleteRecord);
        if(!deleteContactList.isEmpty()){
            delete deleteContactList;
        }

        if(!deleteRecord.isEmpty()){
            insert deleteRecord;
        }
    }

    public static void updateBasedOnCustomSetting(List<Account> newAcc , Map<Id , Account> oldMap){

        list<Account> accList = new List<Account> ();
        List<Account__c> accCustomSettingList = [SELECt Id ,  Source_Field__c ,  Target_Field__c ,  Value__c FROM Account__c LIMIT 1];

        System.debug('accCustomSettingList'+accCustomSettingList);
        for(Account acc : newAcc){
            if(acc.Industry != oldMap.get(acc.Id).Industry && acc.Industry == 'Technology'){

                if(accCustomSettingList[0].Source_Field__c == 'Industry')
                {
                    String sourceField = accCustomSettingList[0].Source_Field__c;
                    String targetField = accCustomSettingList[0].Target_Field__c;
                    String conditionValue = accCustomSettingList[0].Value__c;
                    System.debug('sourceField'+sourceField);
                    System.debug('targetField'+targetField);
                    System.debug('conditionValue'+conditionValue);
                    // object newValue = acc.get(sourceField);
                    // object oldValue = oldMap.get(sourceField);
                    acc.put (targetField , conditionValue);
                }

            }
        }
    }
    
    
}

/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-15-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class LazyLoadingData {
   
    
    @AuraEnabled
    public static List<Account> getAccountList(){
        List<Account> accList = [SELECT Id, Name FROM Account ];
        return accList;
    }
}

/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-16-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class lazyLoadingData {  

    public class WrapperClass{
       @AuraEnabled public Integer totalRecord { get; set; }
       @AuraEnabled public List<Account> accList { get; set; }
    }
    
    @AuraEnabled(cacheable=true)
    public static WrapperClass getAccountList(Integer offset , Integer limits){
        WrapperClass accWrapper = new WrapperClass();
        accWrapper.totalRecord = [SELECT COUNT() FROM Account];         
        accWrapper.accList = [SELECT Id, Name FROM Account ORDER BY Name ASC LIMIT :limits OFFSET :offset];

        return accWrapper;
    }
}

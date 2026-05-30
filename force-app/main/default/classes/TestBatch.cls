/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-19-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TestBatch implements Database.Batchable<sObject>{

    public database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator('select id from Account';)
    }
    public void execute(Database.BatchableContext bc , list<sObject> scope){
        system.debug('This is batch class');
    }
    public void finish(database.BatchableContext bc){
        
    }
    
    
}
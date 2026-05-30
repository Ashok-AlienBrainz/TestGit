/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-19-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TestScheduable implements Schedulable  {

    public void execute(SchedulableContext  context){
        System.debug('This is scheduable class');
    }
    
    
}
/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-27-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TestFuture {
    
    @future
    public static void futureMethod(){

        System.debug('Future Method Called');
        TestQueueable queueable = new TestQueueable();
        System.enqueueJob(queueable);

        
    }
    
}
/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-27-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TestQueueable implements Queueable {
   
    public void execute(QueueableContext context){
        System.debug('This is Queuable Class');
        //TestFuture.futureMethod();
        TestQueueable queueable = new TestQueueable();
        System.enqueueJob(queueable);
    }
}
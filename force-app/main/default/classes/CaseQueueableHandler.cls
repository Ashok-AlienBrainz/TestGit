/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-03-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CaseQueueableHandler implements Queueable {

    private List<Case> caseList;
    public CaseQueueableHandler(List<Case> caseList){
        this.caseList = caseList;
    }
    
    public void execute(QueueableContext context){

        List<Group> queue = [SELECT Id , Name , Type FROm Group WHERE Type ='Queue' AND NAME ='task assignment queue' LIMIT 1];

        set<Id> caseId = new List<Id>();
        list<Task> existingTask = [SELECT Id , WhatId , subject  FROM Task WHERE WhatId IN :caseList AND  subject LIKE 'Escalated case%' LIMIT 50000];

        Map<id , task>  taskMap = new Map<Id , task>();
        for(task t : existingTask){
            taskMap.put(t.whatId , t);
        }
        List<Task> newTask = new List<Task>();

        for(case cs : this.caseList){
            if(!taskMap.containsKey(cs.Id)){
                task tk = new Task();
                tk.subject ='Escalated Case : '+cs.CaseNumber;
                tk.OwnerId = queue[0].id;
                tk.Priority = 'Normal';
                tk.status   = 'In Progress';
                tk.WhatId = cs.id;
                tk.ActivityDate = System.today().addDays(3);
                newTask.add(tk);        

            }
           
        }
        if(!newTask.isEmpty()){
            insert newTask;
        }

        

        
    }
}
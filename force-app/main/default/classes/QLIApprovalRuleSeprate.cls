/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class QLIApprovalRuleSeprate {
    global class OutputWrapper { 
        public OutputWrapper(List<QLIApprovalRuleSeprateWrapper> a) {
            result = a;
        }
        @InvocableVariable
        public List<QLIApprovalRuleSeprateWrapper> result; 
        
    }
    @InvocableMethod 
    public static List<OutputWrapper> queueListName(List<String> inputs) {
        
        Map<String, Approval_Request_Data_Set__mdt> mcs =	Approval_Request_Data_Set__mdt.getAll();
        System.debug('MCS '+mcs);
        
        Map<String ,Approval_Request_Data_Set__mdt> mcsCustom = new   Map<String ,Approval_Request_Data_Set__mdt>();
        for(String developerName : mcs.keySet()){
            Approval_Request_Data_Set__mdt mdt = mcs.get(developerName);
            mcsCustom.put(mdt.Approval_Rule__c ,mdt);
            
        }

        System.debug('inputs '+inputs);

        
        LIst<QLIApprovalRuleSeprateWrapper> out = new List<QLIApprovalRuleSeprateWrapper>();
        
        List<QuoteLineItem> QLIList = [SELECT Id,QuoteId, Approval_Rule__c , Approval_status__c FROM QuoteLineItem WHERE QuoteId IN:inputs  AND Approval_status__c ='Send for Approved' ];
        System.debug('QuoteLineItem '+QLIList);
        Map<Id, List<String>> qliIdApprovalRule = new Map<Id , list<String>>(); //QLI Id and rule and with seprated by ,
        Map<Id , List<string>> qliQueue = new Map<Id , List<string>>();
        for(QuoteLineItem qli : QLIList){
            List<String> aRuleList = new List<string>();
            for (String item : qli.Approval_Rule__c.split(',')) {
                    String cleaned = item.trim();
                    if (!String.isBlank(cleaned)) {
                        //if(!aRuleList.contains(cleaned))
                            aRuleList.add(cleaned);                         
                    }
            }
            qliIdApprovalRule.put(qli.Id , aRuleList);
            
        }
        System.debug('qliIdApprovalRule '+qliIdApprovalRule);

        Map<Id ,string> allQueueTestMap = new Map<Id , String>() ;
        set<string> queueSet = new Set<string>();
        for(Id Id :qliIdApprovalRule.keySet() ){
            List<string> queueList = new List<String>();
            string queueNameText ='';
            for(string rule : qliIdApprovalRule.get(Id))
            {
                System.debug('rule '+rule);
                System.debug('mcsCustom.get(rule) '+mcsCustom.get(rule));
                Approval_Request_Data_Set__mdt rec= mcsCustom.get(rule);
                
                for (String QueueItem : rec.Queues__c.split(',')) {
                    String cleanedQueue = QueueItem.trim();
                    if (!String.isBlank(cleanedQueue)) {
                        if(!queueList.contains(cleanedQueue)){
 	                    queueList.add(cleanedQueue);
                        queueSet.add(cleanedQueue);
                            queueNameText+=cleanedQueue +',';}
                     }
				}                
            }
            qliQueue.put(Id ,queueList);
            string queueNameText2 = queueNameText.removeEnd(',');
            allQueueTestMap.put(Id , queueNameText2);
            
            
        }
        System.debug('qliQueue '+qliQueue);

        List<String> uniqueQueueList = new List<String>(queueSet); // all queuelist with unique 

        for(Id id :qliQueue.keyset() ){            
           out.add(new QLIApprovalRuleSeprateWrapper(qliQueue.get(id),id ,uniqueQueueList , allQueueTestMap.get(Id))); 
             //list of queue according qli id . qliId , all queue with unique, queue according to qli as a string         
        }       
        
  
        
        List<OutputWrapper> output = new list<OutputWrapper>{new OutputWrapper(out)};
        return output;
    	
    
    }

}
public class QLIApprovalRuleSeprateWrapper {
    public QLIApprovalRuleSeprateWrapper(List<String>a, String b , List<string> queueIds , string queueName ) {
            QueueNames = a;
            QLIId = b;
        	QueueIdCollection =queueIds;
        	QueueNamesCollection=queueName;
        }
        @InvocableVariable @AuraEnabled 
        public List<String> QueueNames; 
        @InvocableVariable @AuraEnabled
        public string QLIId;
    	@InvocableVariable @AuraEnabled
        public List<String> QueueIdCollection;
     	@InvocableVariable @AuraEnabled
        public string QueueNamesCollection;

}
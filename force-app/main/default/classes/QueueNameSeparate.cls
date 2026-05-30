global class QueueNameSeparate {

    @InvocableMethod(
        label='Split Queue Names'
        description='Splits comma-separated values from multiple rows and returns one combined List<List<String>>'
    )
    public static List<List<String>> queueListName(List<List<String>> inputs) {
   
        List<List<String>> finalOutput = new List<List<String>>();
        List<String> merged = new List<String>();

        for (List<String> row : inputs) {
            if (row == null || row.isEmpty() || String.isBlank(row[0])) continue;
			for(String queueList : row)
            {
                for (String item : queueList.split(',')) {
                    String cleaned = item.trim();
                    if (!String.isBlank(cleaned)) {
                        if(!merged.contains(cleaned))
                        	merged.add(cleaned);
                    }
            	}                
            }            
        }
        finalOutput.add(merged);

        System.debug('OUTPUT → ' + finalOutput);
        return finalOutput;
    }
}
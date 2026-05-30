/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-28-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class opporuntyAmountCounter {
    // Recursion guard to avoid re-entry if any indirect updates occur
    private static Boolean isRunning = false;

    /**
     * Recalculate the total Opportunity Amount per Account and update the Account field.
     * Assumes Account.Total_Opportunity_Amount__c (Currency) exists.
     */
    public static void recalculateForAccounts(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) return;
        if (isRunning) return;
        isRunning = true;
        try {
            // Aggregate sum of Amount by AccountId for all Opportunities (all stages)
            Map<Id, Decimal> acctTotals = new Map<Id, Decimal>();
            for (AggregateResult ar : [
                SELECT AccountId aid, SUM(Amount) sumAmt
                FROM Opportunity
                WHERE AccountId IN :accountIds
                GROUP BY AccountId
            ]) {
                acctTotals.put((Id) ar.get('aid'), (Decimal) ar.get('sumAmt'));
            }

            // Prepare Account updates - default to zero when no opps exist
            List<Account> toUpdate = new List<Account>();
            for (Id accId : accountIds) {
                Decimal total = acctTotals.containsKey(accId) ? acctTotals.get(accId) : 0;
                toUpdate.add(new Account(
                    Id = accId,
                    Total_Opportunity_Amount__c = total
                ));
            }

            if (!toUpdate.isEmpty()) {
                // Allow partial success; log failures
                Database.SaveResult[] results = Database.update(toUpdate, false);
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        for (Database.Error e : results[i].getErrors()) {
                            System.debug(LoggingLevel.WARN, 'Account update failed for ' + toUpdate[i].Id + ': ' + e.getMessage());
                        }
                    }
                }
            }
        } finally {
            isRunning = false;
        }
    }
}

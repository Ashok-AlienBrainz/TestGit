/**
 * @description       : Bridge between LWC components and the Apex service layer.
 *                      cacheable=true  → safe for @wire (read-only, cached).
 *                      cacheable=false → required for callouts and DML.
 * @author            : TradeSync Project
 * @last modified on  : 04-28-2026
**/
public with sharing class PortfoliaController {

    @AuraEnabled(cacheable=true)
    public static List<Portfolio_Holding__c> getPortfolioHoldings(Id accountId) {
        return [
            SELECT Id,
                   Ticker_Symbol__c,
                   Quantity__c,
                   Purchase_Price__c,
                   Current_Price__c,
                   Change_Pct__c,        // FIX: was missing — caused blank Change % column and broke LMS threshold logic
                   Weight_Pct__c,
                   Portfolio__c
            FROM   Portfolio_Holding__c
            WHERE  Portfolio__r.Account__c = :accountId
            WITH   USER_MODE
        ];
    }

    @AuraEnabled(cacheable=false)
    public static StockQuoteWrapper.QuoteData fetchLiveQuote(String ticker, Id accountId) {
        try {
            system.debug('This is ticker '+ ticker);
            // FIX: accountId now passed through to MarketDataSErvice so logger links to Account
            StockQuoteWrapper.QuoteData stockWrapper =  MarketDataSErvice.getQuotes(ticker, accountId);
            system.debug('MarketDataSErvice.getQuotes(ticker, accountId); '+stockWrapper);
            return stockWrapper;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static void saveRiskScore(Id portfolioId, Decimal score) {
        try {
            Portfolio__c port = new Portfolio__c(
                Id             = portfolioId,
                Risk_Score__c  = score,
                Last_Synced__c = System.now()
            );
            update as user port;
        } catch (Exception e) {
            throw new AuraHandledException('Update failed: ' + e.getMessage());
        }
    }
}
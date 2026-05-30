/**
 * @description       : Wrapper class to parse JSON response from Twelve Data API.
 *                      Maps API field names exactly — any mismatch silently returns null.
 * @author            : TradeSync Project
 * @last modified on  : 04-28-2026
**/
public with sharing class StockQuoteWrapper {

    public class QuoteData {
        @AuraEnabled public String symbol;
        @AuraEnabled public String name;
        @AuraEnabled public String exchange;
        @AuraEnabled public String currency1;
        @AuraEnabled public String quoteDate;
        @AuraEnabled public Decimal open;
        @AuraEnabled public Decimal high;
        @AuraEnabled public Decimal low;
        @AuraEnabled public Decimal close;
        @AuraEnabled public Decimal change;
        @AuraEnabled public Decimal percent_change;
        @AuraEnabled public Long volume;
        @AuraEnabled public Long average_volume;
        @AuraEnabled public Boolean is_market_open;
    }

    public static QuoteData parse(String jsonString) {
        if (String.isBlank(jsonString)) {
            return null;
        }
        try {
            Map<String,Object> apiData = (Map<String,Object>) JSON.deserializeUntyped(jsonString);
            
            StockQuoteWrapper.QuoteData qData = new StockQuoteWrapper.QuoteData();  

            qData.symbol = String.valueOf(apiData.get('symbol'));
            qData.name = String.valueOf(apiData.get('name'));
            qData.exchange = String.valueOf(apiData.get('exchange'));
            qData.currency1 = String.valueOf(apiData.get('currency'));
            qData.quoteDate = String.valueOf(apiData.get('datetime'));

            qData.open = Decimal.valueOf(String.valueOf(apiData.get('open')));
            qData.high = Decimal.valueOf(String.valueOf(apiData.get('high')));
            qData.low = Decimal.valueOf(String.valueOf(apiData.get('low')));
            qData.close = Decimal.valueOf(String.valueOf(apiData.get('close')));
            qData.change = Decimal.valueOf(String.valueOf(apiData.get('change')));
            qData.percent_change = Decimal.valueOf(String.valueOf(apiData.get('percent_change')));
            qData.volume = Long.valueOf(String.valueOf(apiData.get('volume')));
            qData.average_volume = Long.valueOf(String.valueOf(apiData.get('average_volume')));
            qData.is_market_open = (Boolean) apiData.get('is_market_open');



            
            System.debug('This is value on qData '+ qData);
            return Qdata;//(QuoteData) System.JSON.deserialize(jsonString, QuoteData.class);
        } catch (Exception e) {
            System.debug('StockQuoteWrapper.parse error: ' + e.getMessage());
            return null;
        }
    }
}
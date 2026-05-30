/**
 * @description       : HTTP callout service to Twelve Data API.
 *                      All config driven from API_Config__mdt — zero hardcoded values.
 *                      accountId passed in so the logger can link records to the Account.
 * @author            : TradeSync Project
 * @last modified on  : 04-28-2026
**/
public with sharing class MarketDataSErvice {

    public static StockQuoteWrapper.QuoteData getQuotes(String symbol, Id accountId) {

        API_Config__mdt config = [
            SELECT Id,
                   Base_URL__c,
                   Is_Active__c,
                   Max_Symboles_Per_Call__c,
                   Named_Credential_Name__c,
                   Quote_Endpoint__c,
                   Request_Timeout_ms__c
            FROM   API_Config__mdt
            WHERE  DeveloperName = 'Twelve_Data_Production'
            LIMIT  1
        ];

        String endpoint = 'callout:' + config.Named_Credential_Name__c
                        + config.Quote_Endpoint__c
                        + '?symbol=' + symbol;

        Http        http = new Http();
        HttpRequest req  = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(config.Request_Timeout_ms__c.intValue());

        HttpResponse                 res    = null;   // FIX: explicit null init — prevents NPE in finally if send() throws
        StockQuoteWrapper.QuoteData  result = null;

        try {
            res = http.send(req);

            if (res.getStatusCode() == 200) {
                System.debug('Thisis returning Responces Body '+res.getBody());
                result = StockQuoteWrapper.parse(res.getBody());
            } else {
                throw new CalloutException('API returned status: ' + res.getStatusCode());
            }

        } catch (System.CalloutException e) {
            System.debug('MarketDataSErvice callout error: ' + e.getMessage());
            throw new AuraHandledException('Communication failure with Market Data Provider.');

        } catch (System.JSONException e) {
            System.debug('MarketDataSErvice JSON error: ' + e.getMessage());
            throw new AuraHandledException('Unable to process market data format.');

        } finally {
            // FIX: accountId now passed through from PortfoliaController — log is linked to Account
            RiskAlertLogger.log(
                symbol,
                (res != null && res.getStatusCode() == 200) ? 'Success' : 'Error',
                res != null ? res.getBody() : 'No Response',
                'Market Data Sync',
                accountId,           // FIX: was hardcoded null
                'MarketDataSErvice'
            );
        }

        return result;
    }
}
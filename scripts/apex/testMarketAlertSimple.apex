/**
 * @description Simple test to verify the marketAlertPanel data flow
 * @usage       Execute in Anonymous Window
 */

// Get an Account (or use a specific ID)
Account acc = [SELECT Id, Name FROM Account LIMIT 1];
System.debug('Account: ' + acc.Name + ' (' + acc.Id + ')');

// Test 1: Fetch portfolio holdings (what portfolioRiskDashboard does)
List<Portfolio_Holding__c> holdings = PortfoliaController.getPortfolioHoldings(acc.Id);
System.debug('\n=== Portfolio Holdings ===');
System.debug('Total Holdings: ' + holdings.size());

if (holdings.isEmpty()) {
    System.debug('⚠️ No holdings found. Create some Portfolio_Holding__c records first.');
} else {
    // Display each holding
    for (Portfolio_Holding__c h : holdings) {
        System.debug('Ticker: ' + h.Ticker_Symbol__c + 
                     ' | Change: ' + h.Change_Pct__c + '%' +
                     ' | Weight: ' + h.Weight_Pct__c + '%');
        
        // Check if it would trigger an alert
        if (h.Change_Pct__c != null && h.Change_Pct__c < -8) {
            System.debug('  🚨 ALERT: This holding triggers LMS message');
            System.debug('  Message Payload:');
            System.debug('    - tickerSymbol: ' + h.Ticker_Symbol__c);
            System.debug('    - alertType: CRITICAL_DROP');
            System.debug('    - changePercent: ' + h.Change_Pct__c);
            System.debug('    - accountId: ' + acc.Id);
        }
    }
}

// Test 2: Simulate what marketAlertPanel does when it receives LMS message
System.debug('\n=== Simulating marketAlertPanel callout ===');
if (!holdings.isEmpty()) {
    String ticker = holdings[0].Ticker_Symbol__c;
    System.debug('Calling fetchLiveQuote for: ' + ticker);
    
    try {
        StockQuoteWrapper.QuoteData quote = PortfoliaController.fetchLiveQuote(ticker, acc.Id);
        
        System.debug('\n✅ Live Quote Retrieved:');
        System.debug('Symbol: ' + quote.symbol);
        System.debug('Price: $' + quote.close);
        System.debug('Change: ' + quote.percent_change + '%');
        System.debug('Timestamp: ' + quote.datetime1);
        
        System.debug('\nThis data is what gets stored in liveQuote property:');
        System.debug(JSON.serializePretty(quote));
        
    } catch (Exception e) {
        System.debug('❌ Callout failed: ' + e.getMessage());
    }
} else {
    System.debug('⚠️ No holdings to test callout');
}

System.debug('\n=== SUMMARY ===');
System.debug('When LMS message is received, marketAlertPanel updates:');
System.debug('1. isLoading = true (shows spinner)');
System.debug('2. Calls fetchLiveQuote with ticker + accountId');
System.debug('3. Updates liveQuote property with API response');
System.debug('4. isLoading = false (hides spinner, shows quote card)');
System.debug('5. Toast notification appears with success/error message');
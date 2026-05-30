/**
 * @description Creates completely fresh test data for marketAlertPanel testing
 *              New Account, Portfolio, and Holdings with threshold breaches
 * @usage       Execute in Anonymous Window
 */

// Step 1: Create a new test Account
Account newAccount = new Account(
    Name = 'Tech Investment Portfolio - Test ' + System.now().format(),
    Industry = 'Technology',
    Type = 'Investor'
);
insert newAccount;

System.debug('✅ Created New Account: ' + newAccount.Name);
System.debug('   Account ID: ' + newAccount.Id);

// Step 2: Create a new Portfolio for this Account
Portfolio__c newPortfolio = new Portfolio__c(
    Name = 'High Growth Tech Portfolio',
    Account__c = newAccount.Id,
    Risk_Score__c = 65.8
);
insert newPortfolio;

System.debug('\n✅ Created New Portfolio: ' + newPortfolio.Name);
System.debug('   Portfolio ID: ' + newPortfolio.Id);

// Step 3: Create fresh Portfolio Holdings with various scenarios
List<Portfolio_Holding__c> newHoldings = new List<Portfolio_Holding__c>();

// Holding 1: AAPL - Critical drop (TRIGGERS ALERT)
newHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = newPortfolio.Id,
    Ticker_Symbol__c = 'AAPL',
    Quantity__c = 150,
    Purchase_Price__c = 185.00,
    Current_Price__c = 169.50,
    Change_Pct__c = -8.38,  // Below -8% threshold → ALERT
    Weight_Pct__c = 42.5
));

// Holding 2: MSFT - Moderate drop (NO ALERT)
newHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = newPortfolio.Id,
    Ticker_Symbol__c = 'MSFT',
    Quantity__c = 80,
    Purchase_Price__c = 420.00,
    Current_Price__c = 398.00,
    Change_Pct__c = -5.24,  // Above -8% threshold → NO ALERT
    Weight_Pct__c = 28.7
));

// Holding 3: NVDA - Severe drop (TRIGGERS ALERT)
newHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = newPortfolio.Id,
    Ticker_Symbol__c = 'NVDA',
    Quantity__c = 50,
    Purchase_Price__c = 880.00,
    Current_Price__c = 792.00,
    Change_Pct__c = -10.00,  // Below -8% threshold → ALERT
    Weight_Pct__c = 18.6
));

// Holding 4: GOOGL - Minor drop (NO ALERT)
newHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = newPortfolio.Id,
    Ticker_Symbol__c = 'GOOGL',
    Quantity__c = 25,
    Purchase_Price__c = 142.00,
    Current_Price__c = 138.50,
    Change_Pct__c = -2.46,  // Above -8% threshold → NO ALERT
    Weight_Pct__c = 10.2
));

// Insert all holdings
insert newHoldings;

System.debug('\n✅ Created ' + newHoldings.size() + ' Portfolio Holdings');

// Step 4: Verify the data by calling controller method
List<Portfolio_Holding__c> verifyHoldings = PortfoliaController.getPortfolioHoldings(newAccount.Id);
System.debug('\n=== VERIFICATION ===');
System.debug('Holdings Retrieved: ' + verifyHoldings.size());

// Step 5: Check which holdings trigger alerts
System.debug('\n=== ALERT THRESHOLD ANALYSIS ===');
Integer alertCount = 0;
for (Portfolio_Holding__c h : verifyHoldings) {
    String status = (h.Change_Pct__c < -8) ? '🚨 ALERT' : '✓ OK';
    System.debug(status + ' | ' + h.Ticker_Symbol__c + 
                 ' | Change: ' + h.Change_Pct__c + '%' +
                 ' | Weight: ' + h.Weight_Pct__c + '%');
    
    if (h.Change_Pct__c < -8) {
        alertCount++;
        
        // Show the LMS message that will be published
        Map<String, Object> messagePayload = new Map<String, Object>{
            'tickerSymbol' => h.Ticker_Symbol__c,
            'alertType' => 'CRITICAL_DROP',
            'changePercent' => h.Change_Pct__c,
            'accountId' => newAccount.Id
        };
        System.debug('    📡 LMS Payload: ' + JSON.serialize(messagePayload));
    }
}

// Step 6: Summary and next steps
System.debug('\n╔═══════════════════════════════════════════════════════════╗');
System.debug('║              TEST DATA CREATION SUMMARY                   ║');
System.debug('╚═══════════════════════════════════════════════════════════╝');
System.debug('Account Name     : ' + newAccount.Name);
System.debug('Account ID       : ' + newAccount.Id);
System.debug('Portfolio Name   : ' + newPortfolio.Name);
System.debug('Portfolio ID     : ' + newPortfolio.Id);
System.debug('Total Holdings   : ' + newHoldings.size());
System.debug('Alerts Expected  : ' + alertCount);
System.debug('─────────────────────────────────────────────────────────────');

System.debug('\n╔═══════════════════════════════════════════════════════════╗');
System.debug('║                   NEXT STEPS                              ║');
System.debug('╚═══════════════════════════════════════════════════════════╝');
System.debug('1. Copy this Account ID: ' + newAccount.Id);
System.debug('2. Open this URL in your browser:');
System.debug('   /lightning/r/Account/' + newAccount.Id + '/view');
System.debug('3. Edit the Account record page');
System.debug('4. Add "portfolioRiskDashboard" component');
System.debug('5. Add "marketAlertPanel" component');
System.debug('6. Activate and save the page');
System.debug('7. Refresh - you will see ' + alertCount + ' LMS alerts trigger!');
System.debug('─────────────────────────────────────────────────────────────');

System.debug('\n╔═══════════════════════════════════════════════════════════╗');
System.debug('║            WHAT HAPPENS IN marketAlertPanel               ║');
System.debug('╚═══════════════════════════════════════════════════════════╝');
System.debug('When page loads, for each alert:');
System.debug('1. portfolioRiskDashboard publishes LMS message');
System.debug('2. marketAlertPanel subscription executes');
System.debug('3. handleMessage() receives message payload');
System.debug('4. isLoading = true (spinner shows)');
System.debug('5. Calls fetchLiveQuote(ticker, accountId)');
System.debug('6. Updates liveQuote property with API response:');
System.debug('   {');
System.debug('     symbol: "AAPL",');
System.debug('     close: 169.50,');
System.debug('     percent_change: -8.38,');
System.debug('     datetime1: "2026-04-28T14:43:00Z"');
System.debug('   }');
System.debug('7. isLoading = false (card displays)');
System.debug('8. Success toast notification appears');
System.debug('─────────────────────────────────────────────────────────────');

System.debug('\n✅ Fresh test data created successfully!\n');
/**
 * @description Test script to simulate LMS RiskAlert message flow
 *              Execute this in Anonymous Window to trigger marketAlertPanel subscription
 * @usage       1. Open Developer Console > Debug > Open Execute Anonymous Window
 *              2. Paste this code
 *              3. Check "Open Log" checkbox
 *              4. Click Execute
 */

// Step 1: Get or create test Account with Portfolio
Account testAccount = [
    SELECT Id, Name 
    FROM Account 
    WHERE Name = 'Pinebrook Ventures' 
    LIMIT 1
];

if (testAccount == null) {
    testAccount = new Account(Name = 'Test Portfolio Account');
    insert testAccount;
}

System.debug('Using Account: ' + testAccount.Name + ' (ID: ' + testAccount.Id + ')');

// Step 2: Get or create Portfolio for this Account
Portfolio__c portfolio;
List<Portfolio__c> existingPortfolios = [
    SELECT Id, Name, Account__c 
    FROM Portfolio__c 
    WHERE Account__c = :testAccount.Id 
    LIMIT 1
];

if (existingPortfolios.isEmpty()) {
    portfolio = new Portfolio__c(
        Name = 'Test Portfolio',
        Account__c = testAccount.Id,
        Risk_Score__c = 75.5
    );
    insert portfolio;
    System.debug('Created new Portfolio: ' + portfolio.Id);
} else {
    portfolio = existingPortfolios[0];
    System.debug('Using existing Portfolio: ' + portfolio.Id);
}

// Step 3: Create or update Portfolio Holdings with threshold breaches
List<Portfolio_Holding__c> holdings = new List<Portfolio_Holding__c>();

// Holding 1: AAPL with critical drop (triggers alert)
Portfolio_Holding__c aapl = new Portfolio_Holding__c(
    Portfolio__c = portfolio.Id,
    Ticker_Symbol__c = 'AAPL',
    Quantity__c = 100,
    Purchase_Price__c = 180.00,
    Current_Price__c = 165.50,
    Change_Pct__c = -8.06,  // Below -8% threshold - WILL TRIGGER ALERT
    Weight_Pct__c = 45.5
);

// Holding 2: GOOGL with moderate drop (no alert)
Portfolio_Holding__c googl = new Portfolio_Holding__c(
    Portfolio__c = portfolio.Id,
    Ticker_Symbol__c = 'GOOGL',
    Quantity__c = 50,
    Purchase_Price__c = 140.00,
    Current_Price__c = 135.20,
    Change_Pct__c = -3.43,  // Above -8% threshold - no alert
    Weight_Pct__c = 30.2
);

// Holding 3: TSLA with severe drop (triggers alert)
Portfolio_Holding__c tsla = new Portfolio_Holding__c(
    Portfolio__c = portfolio.Id,
    Ticker_Symbol__c = 'TSLA',
    Quantity__c = 75,
    Purchase_Price__c = 250.00,
    Current_Price__c = 225.00,
    Change_Pct__c = -10.0,  // Below -8% threshold - WILL TRIGGER ALERT
    Weight_Pct__c = 24.3
);

holdings.add(aapl);
holdings.add(googl);
holdings.add(tsla);

// Delete existing holdings for clean test
delete [SELECT Id FROM Portfolio_Holding__c WHERE Portfolio__c = :portfolio.Id];

// Insert new holdings
insert holdings;

System.debug('=== TEST HOLDINGS CREATED ===');
System.debug('Total Holdings: ' + holdings.size());
System.debug('AAPL: Change ' + aapl.Change_Pct__c + '% (ALERT EXPECTED)');
System.debug('GOOGL: Change ' + googl.Change_Pct__c + '% (no alert)');
System.debug('TSLA: Change ' + tsla.Change_Pct__c + '% (ALERT EXPECTED)');

// Step 4: Simulate the wire adapter call that portfolioRiskDashboard makes
System.debug('\n=== SIMULATING WIRE CALL ===');
List<Portfolio_Holding__c> wireResult = PortfoliaController.getPortfolioHoldings(testAccount.Id);
System.debug('Holdings returned: ' + wireResult.size());

// Step 5: Simulate the threshold check logic
System.debug('\n=== CHECKING ALERT THRESHOLDS ===');
Integer alertCount = 0;
for (Portfolio_Holding__c holding : wireResult) {
    if (holding.Change_Pct__c < -8) {
        alertCount++;
        System.debug('🚨 ALERT TRIGGERED for ' + holding.Ticker_Symbol__c);
        System.debug('   Change: ' + holding.Change_Pct__c + '%');
        System.debug('   AccountId: ' + testAccount.Id);
        System.debug('   Message Type: CRITICAL_DROP');
        
        // This is what the LMS message payload looks like:
        Map<String, Object> messagePayload = new Map<String, Object>{
            'tickerSymbol' => holding.Ticker_Symbol__c,
            'alertType' => 'CRITICAL_DROP',
            'changePercent' => holding.Change_Pct__c,
            'accountId' => testAccount.Id
        };
        System.debug('   Payload: ' + JSON.serialize(messagePayload));
    }
}

System.debug('\n=== TEST SUMMARY ===');
System.debug('Total Alerts Expected: ' + alertCount);
System.debug('Account ID to use in Lightning: ' + testAccount.Id);
System.debug('\nNEXT STEPS:');
System.debug('1. Open the Account record page in Lightning: ' + testAccount.Id);
System.debug('2. Add portfolioRiskDashboard component to the page');
System.debug('3. Add marketAlertPanel component to the page');
System.debug('4. When page loads, portfolioRiskDashboard will publish ' + alertCount + ' LMS messages');
System.debug('5. marketAlertPanel will subscribe and call fetchLiveQuote for each alert');
System.debug('\n✅ Test data created successfully!');
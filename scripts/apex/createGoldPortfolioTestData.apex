/**
 * @description Creates fresh test data with Gold/Commodity portfolio holdings
 *              New company, Portfolio, and Holdings with precious metals
 * @usage       Execute in Anonymous Window
 */

// Step 1: Create a new commodity investment company
Account goldCompany = new Account(
    Name = 'Golden Horizons Investment LLC - ' + System.now().format(),
    Industry = 'Financial Services',
    Type = 'Investor',
    Description = 'Precious Metals & Commodities Investment Firm'
);
insert goldCompany;

System.debug('✅ Created New Investment Company: ' + goldCompany.Name);
System.debug('   Account ID: ' + goldCompany.Id);

// Step 2: Create a Precious Metals Portfolio
Portfolio__c goldPortfolio = new Portfolio__c(
    Name = 'Premium Gold & Metals Portfolio',
    Account__c = goldCompany.Id,
    Risk_Score__c = 52.3
);
insert goldPortfolio;

System.debug('\n✅ Created New Portfolio: ' + goldPortfolio.Name);
System.debug('   Portfolio ID: ' + goldPortfolio.Id);

// Step 3: Create Gold/Commodity Holdings
List<Portfolio_Holding__c> commodityHoldings = new List<Portfolio_Holding__c>();

// Holding 1: GLD (Gold ETF) - Critical drop (TRIGGERS ALERT)
commodityHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = goldPortfolio.Id,
    Ticker_Symbol__c = 'GLD',
    Quantity__c = 200,
    Purchase_Price__c = 195.50,
    Current_Price__c = 178.75,
    Change_Pct__c = -8.57,  // Below -8% threshold → ALERT
    Weight_Pct__c = 38.2
));

// Holding 2: SLV (Silver ETF) - Severe drop (TRIGGERS ALERT)
commodityHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = goldPortfolio.Id,
    Ticker_Symbol__c = 'SLV',
    Quantity__c = 500,
    Purchase_Price__c = 24.80,
    Current_Price__c = 21.95,
    Change_Pct__c = -11.49,  // Below -8% threshold → ALERT
    Weight_Pct__c = 25.4
));

// Holding 3: PALL (Palladium ETF) - Moderate drop (NO ALERT)
commodityHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = goldPortfolio.Id,
    Ticker_Symbol__c = 'PALL',
    Quantity__c = 75,
    Purchase_Price__c = 88.60,
    Current_Price__c = 84.20,
    Change_Pct__c = -4.97,  // Above -8% threshold → NO ALERT
    Weight_Pct__c = 18.9
));

// Holding 4: PPLT (Platinum ETF) - Minor drop (NO ALERT)
commodityHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = goldPortfolio.Id,
    Ticker_Symbol__c = 'PPLT',
    Quantity__c = 100,
    Purchase_Price__c = 92.30,
    Current_Price__c = 89.85,
    Change_Pct__c = -2.65,  // Above -8% threshold → NO ALERT
    Weight_Pct__c = 17.5
));

// Holding 5: GLTR (Gold/Silver Mix) - Critical drop (TRIGGERS ALERT)
commodityHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = goldPortfolio.Id,
    Ticker_Symbol__c = 'GLTR',
    Quantity__c = 150,
    Purchase_Price__c = 112.00,
    Current_Price__c = 101.50,
    Change_Pct__c = -9.38,  // Below -8% threshold → ALERT
    Weight_Pct__c = 0  // Will be auto-calculated
));

// Insert all commodity holdings
insert commodityHoldings;

System.debug('\n✅ Created ' + commodityHoldings.size() + ' Commodity Holdings');

// Step 4: Verify the data
List<Portfolio_Holding__c> verifyHoldings = PortfoliaController.getPortfolioHoldings(goldCompany.Id);
System.debug('\n=== VERIFICATION ===');
System.debug('Holdings Retrieved: ' + verifyHoldings.size());

// Step 5: Analyze alert thresholds
System.debug('\n=== PRECIOUS METALS ALERT ANALYSIS ===');
Integer alertCount = 0;
for (Portfolio_Holding__c h : verifyHoldings) {
    String status = (h.Change_Pct__c < -8) ? '🚨 ALERT' : '✓ OK';
    String metalType = '';
    
    // Add commodity type for clarity
    if (h.Ticker_Symbol__c == 'GLD') metalType = '(Gold)';
    else if (h.Ticker_Symbol__c == 'SLV') metalType = '(Silver)';
    else if (h.Ticker_Symbol__c == 'PALL') metalType = '(Palladium)';
    else if (h.Ticker_Symbol__c == 'PPLT') metalType = '(Platinum)';
    else if (h.Ticker_Symbol__c == 'GLTR') metalType = '(Gold/Silver Mix)';
    
    System.debug(status + ' | ' + h.Ticker_Symbol__c + ' ' + metalType + 
                 ' | Change: ' + h.Change_Pct__c + '%' +
                 ' | Weight: ' + h.Weight_Pct__c + '%');
    
    if (h.Change_Pct__c < -8) {
        alertCount++;
        
        // Show LMS message payload
        Map<String, Object> messagePayload = new Map<String, Object>{
            'tickerSymbol' => h.Ticker_Symbol__c,
            'alertType' => 'CRITICAL_DROP',
            'changePercent' => h.Change_Pct__c,
            'accountId' => goldCompany.Id
        };
        System.debug('    📡 LMS Payload: ' + JSON.serialize(messagePayload));
    }
}

// Step 6: Summary
System.debug('\n╔═══════════════════════════════════════════════════════════╗');
System.debug('║         GOLD PORTFOLIO TEST DATA SUMMARY                 ║');
System.debug('╚═══════════════════════════════════════════════════════════╝');
System.debug('Company Name     : ' + goldCompany.Name);
System.debug('Account ID       : ' + goldCompany.Id);
System.debug('Portfolio Name   : ' + goldPortfolio.Name);
System.debug('Portfolio ID     : ' + goldPortfolio.Id);
System.debug('Portfolio Type   : Precious Metals & Commodities');
System.debug('Total Holdings   : ' + commodityHoldings.size());
System.debug('Alerts Expected  : ' + alertCount + ' (GLD, SLV, GLTR)');
System.debug('─────────────────────────────────────────────────────────────');

System.debug('\n╔═══════════════════════════════════════════════════════════╗');
System.debug('║              HOLDINGS BREAKDOWN                           ║');
System.debug('╚═══════════════════════════════════════════════════════════╝');
System.debug('1. GLD  (Gold ETF)           → 200 units @ $195.50 → -8.57%  🚨');
System.debug('2. SLV  (Silver ETF)         → 500 units @ $24.80  → -11.49% 🚨');
System.debug('3. PALL (Palladium ETF)      → 75 units  @ $88.60  → -4.97%  ✓');
System.debug('4. PPLT (Platinum ETF)       → 100 units @ $92.30  → -2.65%  ✓');
System.debug('5. GLTR (Gold/Silver Mix)    → 150 units @ $112.00 → -9.38%  🚨');
System.debug('─────────────────────────────────────────────────────────────');

System.debug('\n╔═══════════════════════════════════════════════════════════╗');
System.debug('║                   NEXT STEPS                              ║');
System.debug('╚═══════════════════════════════════════════════════════════╝');
System.debug('1. Copy Account ID: ' + goldCompany.Id);
System.debug('2. Open in Lightning:');
System.debug('   /lightning/r/Account/' + goldCompany.Id + '/view');
System.debug('3. Edit the Account record page');
System.debug('4. Add "portfolioRiskDashboard" component');
System.debug('5. Add "marketAlertPanel" component');
System.debug('6. Activate and save the page');
System.debug('7. Refresh to see ' + alertCount + ' precious metal alerts!');
System.debug('─────────────────────────────────────────────────────────────');

System.debug('\n╔═══════════════════════════════════════════════════════════╗');
System.debug('║       WHAT UPDATES IN marketAlertPanel                    ║');
System.debug('╚═══════════════════════════════════════════════════════════╝');
System.debug('For each commodity alert triggered:');
System.debug('');
System.debug('1. portfolioRiskDashboard detects Change_Pct__c < -8%');
System.debug('2. Publishes LMS message on RISK_CHANNEL:');
System.debug('   {');
System.debug('     tickerSymbol: "GLD",');
System.debug('     alertType: "CRITICAL_DROP",');
System.debug('     changePercent: -8.57,');
System.debug('     accountId: "' + goldCompany.Id + '"');
System.debug('   }');
System.debug('');
System.debug('3. marketAlertPanel subscription receives message');
System.debug('4. handleMessage(message) executes');
System.debug('5. Sets isLoading = true → spinner appears');
System.debug('6. Calls fetchLiveQuote(ticker, accountId)');
System.debug('7. Updates this.liveQuote property:');
System.debug('   {');
System.debug('     symbol: "GLD",');
System.debug('     close: 178.75,');
System.debug('     percent_change: -8.57,');
System.debug('     datetime1: "2026-04-28T14:53:00Z"');
System.debug('   }');
System.debug('8. Sets isLoading = false → card displays');
System.debug('9. Shows toast: "Alert Confirmed - Live data for GLD"');
System.debug('─────────────────────────────────────────────────────────────');

System.debug('\n✅ Gold portfolio test data created successfully!');
System.debug('📊 Ready to test marketAlertPanel with commodity holdings!\n');
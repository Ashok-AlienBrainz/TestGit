/**
 * @description Creates test data for Defense & Weapons Market Portfolio
 *              Open market weapons trading company with various holdings
 * @usage       Execute in Anonymous Window
 */

// Step 1: Create Defense Trading Company
Account weaponCompany = new Account(
    Name = 'Global Defense Trading Corp - ' + System.now().format(),
    Industry = 'Defense & Aerospace',
    Type = 'Distributor',
    Description = 'International Defense & Weapons Trading Platform'
);
insert weaponCompany;

System.debug('✅ Created Defense Company: ' + weaponCompany.Name);
System.debug('   Account ID: ' + weaponCompany.Id);

// Step 2: Create Weapons Portfolio
Portfolio__c weaponPortfolio = new Portfolio__c(
    Name = 'Defense & Arms Market Portfolio',
    Account__c = weaponCompany.Id,
    Risk_Score__c = 78.5
);
insert weaponPortfolio;

System.debug('\n✅ Created Portfolio: ' + weaponPortfolio.Name);
System.debug('   Portfolio ID: ' + weaponPortfolio.Id);

// Step 3: Create Defense/Weapons Holdings
List<Portfolio_Holding__c> weaponHoldings = new List<Portfolio_Holding__c>();

// Holding 1: LMT (Lockheed Martin) - Critical drop (TRIGGERS ALERT)
weaponHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = weaponPortfolio.Id,
    Ticker_Symbol__c = 'LMT',
    Quantity__c = 120,
    Purchase_Price__c = 485.00,
    Current_Price__c = 442.50,
    Change_Pct__c = -8.76,  // Below -8% threshold → ALERT
    Weight_Pct__c = 32.8
));

// Holding 2: BA (Boeing Defense) - Severe drop (TRIGGERS ALERT)
weaponHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = weaponPortfolio.Id,
    Ticker_Symbol__c = 'BA',
    Quantity__c = 200,
    Purchase_Price__c = 215.00,
    Current_Price__c = 188.75,
    Change_Pct__c = -12.21,  // Below -8% threshold → ALERT
    Weight_Pct__c = 28.5
));

// Holding 3: RTX (Raytheon) - Moderate drop (NO ALERT)
weaponHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = weaponPortfolio.Id,
    Ticker_Symbol__c = 'RTX',
    Quantity__c = 150,
    Purchase_Price__c = 102.50,
    Current_Price__c = 97.80,
    Change_Pct__c = -4.59,  // Above -8% threshold → NO ALERT
    Weight_Pct__c = 22.4
));

// Holding 4: NOC (Northrop Grumman) - Minor drop (NO ALERT)
weaponHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = weaponPortfolio.Id,
    Ticker_Symbol__c = 'NOC',
    Quantity__c = 80,
    Purchase_Price__c = 468.00,
    Current_Price__c = 455.20,
    Change_Pct__c = -2.74,  // Above -8% threshold → NO ALERT
    Weight_Pct__c = 16.3
));

// Holding 5: GD (General Dynamics) - Critical drop (TRIGGERS ALERT)
weaponHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = weaponPortfolio.Id,
    Ticker_Symbol__c = 'GD',
    Quantity__c = 100,
    Purchase_Price__c = 268.00,
    Current_Price__c = 242.50,
    Change_Pct__c = -9.51,  // Below -8% threshold → ALERT
    Weight_Pct__c = 0  // Will be calculated
));

// Holding 6: HII (Huntington Ingalls) - Minor gain (NO ALERT)
weaponHoldings.add(new Portfolio_Holding__c(
    Portfolio__c = weaponPortfolio.Id,
    Ticker_Symbol__c = 'HII',
    Quantity__c = 60,
    Purchase_Price__c = 225.00,
    Current_Price__c = 231.50,
    Change_Pct__c = 2.89,  // Positive change → NO ALERT
    Weight_Pct__c = 0
));

// Insert all weapon holdings
insert weaponHoldings;

System.debug('\n✅ Created ' + weaponHoldings.size() + ' Defense Holdings');

// Step 4: Verify data
List<Portfolio_Holding__c> verifyHoldings = PortfoliaController.getPortfolioHoldings(weaponCompany.Id);
System.debug('\n=== VERIFICATION ===');
System.debug('Holdings Retrieved: ' + verifyHoldings.size());

// Step 5: Analyze market alerts
System.debug('\n=== DEFENSE MARKET ALERT ANALYSIS ===');
Integer alertCount = 0;
for (Portfolio_Holding__c h : verifyHoldings) {
    String status = (h.Change_Pct__c < -8) ? '🚨 ALERT' : '✓ OK';
    String companyType = '';
    
    // Add company type for clarity
    if (h.Ticker_Symbol__c == 'LMT') companyType = '(Lockheed Martin)';
    else if (h.Ticker_Symbol__c == 'BA') companyType = '(Boeing Defense)';
    else if (h.Ticker_Symbol__c == 'RTX') companyType = '(Raytheon)';
    else if (h.Ticker_Symbol__c == 'NOC') companyType = '(Northrop Grumman)';
    else if (h.Ticker_Symbol__c == 'GD') companyType = '(General Dynamics)';
    else if (h.Ticker_Symbol__c == 'HII') companyType = '(Huntington Ingalls)';
    
    System.debug(status + ' | ' + h.Ticker_Symbol__c + ' ' + companyType + 
                 ' | Change: ' + h.Change_Pct__c + '%' +
                 ' | Weight: ' + h.Weight_Pct__c + '%');
    
    if (h.Change_Pct__c < -8) {
        alertCount++;
        
        // Show LMS message payload
        Map<String, Object> messagePayload = new Map<String, Object>{
            'tickerSymbol' => h.Ticker_Symbol__c,
            'alertType' => 'CRITICAL_DROP',
            'changePercent' => h.Change_Pct__c,
            'accountId' => weaponCompany.Id
        };
        System.debug('    📡 LMS Payload: ' + JSON.serialize(messagePayload));
    }
}

// Step 6: Summary
System.debug('\n╔═══════════════════════════════════════════════════════════╗');
System.debug('║       DEFENSE MARKET TEST DATA SUMMARY                   ║');
System.debug('╚═══════════════════════════════════════════════════════════╝');
System.debug('Company Name     : ' + weaponCompany.Name);
System.debug('Account ID       : ' + weaponCompany.Id);
System.debug('Portfolio Name   : ' + weaponPortfolio.Name);
System.debug('Portfolio ID     : ' + weaponPortfolio.Id);
System.debug('Market Type      : Open Defense & Weapons Trading');
System.debug('Total Holdings   : ' + weaponHoldings.size());
System.debug('Alerts Expected  : ' + alertCount + ' (LMT, BA, GD)');
System.debug('Market Hours     : 24/7 Open Trading Platform');
System.debug('─────────────────────────────────────────────────────────────');

System.debug('\n╔═══════════════════════════════════════════════════════════╗');
System.debug('║              DEFENSE HOLDINGS BREAKDOWN                  ║');
System.debug('╚═══════════════════════════════════════════════════════════╝');
System.debug('1. LMT (Lockheed Martin)      → 120 units @ $485.00 → -8.76%  🚨');
System.debug('2. BA  (Boeing Defense)       → 200 units @ $215.00 → -12.21% 🚨');
System.debug('3. RTX (Raytheon)             → 150 units @ $102.50 → -4.59%  ✓');
System.debug('4. NOC (Northrop Grumman)     → 80 units  @ $468.00 → -2.74%  ✓');
System.debug('5. GD  (General Dynamics)     → 100 units @ $268.00 → -9.51%  🚨');
System.debug('6. HII (Huntington Ingalls)   → 60 units  @ $225.00 → +2.89%  ✓');
System.debug('─────────────────────────────────────────────────────────────');

System.debug('\n╔═══════════════════════════════════════════════════════════╗');
System.debug('║                   NEXT STEPS                              ║');
System.debug('╚═══════════════════════════════════════════════════════════╝');
System.debug('1. Copy Account ID: ' + weaponCompany.Id);
System.debug('2. Open in Lightning Experience:');
System.debug('   /lightning/r/Account/' + weaponCompany.Id + '/view');
System.debug('3. Edit the Account record page');
System.debug('4. Add "portfolioRiskDashboard" component');
System.debug('5. Add "marketAlertPanel" component');
System.debug('6. Activate and save the page');
System.debug('7. Refresh to see ' + alertCount + ' defense market alerts!');
System.debug('8. Open market operates 24/7 - alerts available anytime');
System.debug('─────────────────────────────────────────────────────────────');

System.debug('\n╔═══════════════════════════════════════════════════════════╗');
System.debug('║       WHAT UPDATES IN marketAlertPanel                    ║');
System.debug('╚═══════════════════════════════════════════════════════════╝');
System.debug('For each defense market alert triggered:');
System.debug('');
System.debug('1. portfolioRiskDashboard detects Change_Pct__c < -8%');
System.debug('2. Publishes LMS message on RISK_CHANNEL:');
System.debug('   {');
System.debug('     tickerSymbol: "LMT",');
System.debug('     alertType: "CRITICAL_DROP",');
System.debug('     changePercent: -8.76,');
System.debug('     accountId: "' + weaponCompany.Id + '"');
System.debug('   }');
System.debug('');
System.debug('3. marketAlertPanel subscription receives message');
System.debug('4. handleMessage(message) executes');
System.debug('5. Sets isLoading = true → spinner appears');
System.debug('6. Calls fetchLiveQuote(ticker, accountId)');
System.debug('7. Updates this.liveQuote property:');
System.debug('   {');
System.debug('     symbol: "LMT",');
System.debug('     close: 442.50,');
System.debug('     percent_change: -8.76,');
System.debug('     datetime1: "' + System.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + '"');
System.debug('   }');
System.debug('8. Sets isLoading = false → card displays');
System.debug('9. Shows toast: "Alert Confirmed - Live data for LMT"');
System.debug('─────────────────────────────────────────────────────────────');

System.debug('\n✅ Defense market test data created successfully!');
System.debug('🎯 Open Market - Available 24/7 for weapons trading!');
System.debug('📊 Ready to test marketAlertPanel with defense holdings!\n');
import { LightningElement, api, wire, track } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import RISK_CHANNEL from '@salesforce/messageChannel/RiskAlert__c';
import getPortfolioHoldings from '@salesforce/apex/PortfoliaController.getPortfolioHoldings';

export default class PortfolioRiskDashboard extends LightningElement {

  @api recordId;           // Account Id injected by the record page
  @track holdings = [];    // FIX: initialise as [] not null — prevents isEmpty crash
  totalRiskScore = 0;
  error;
  isLoading = true;

  @wire(MessageContext)
  messageContext;

  @wire(getPortfolioHoldings, { accountId: '$recordId' })
  wiredHoldings({ data, error }) {
    // FIX: isLoading = false always runs last — even if neither branch fires
    if (data) {
      this.holdings = data;
      this.error = undefined;
      this.calculateRisk();
      this.checkAlertThresholds();
    } else if (error) {
      this.error = error;
      this.holdings = [];
    }
    this.isLoading = false;   // FIX: moved here — always executes, prevents infinite spinner
  }

  // FIX: guard against null — was crashing before wire resolved
  get isEmpty() {
    return !this.holdings || this.holdings.length === 0;
  }

  calculateRisk() {
    const score = this.holdings.reduce(
      (sum, h) => sum + (h.Weight_Pct__c || 0), 0
    );
    this.totalRiskScore = score.toFixed(2);
  }

  checkAlertThresholds() {
    // Change_Pct__c is now returned from SOQL — this logic will fire correctly
    this.holdings.forEach(holding => {
      if (holding.Change_Pct__c < -8) {
        const payload = {
          tickerSymbol: holding.Ticker_Symbol__c,
          alertType: 'CRITICAL_DROP',
          changePercent: holding.Change_Pct__c,
          accountId: this.recordId
        };
        publish(this.messageContext, RISK_CHANNEL, payload);
      }
    });
  }
}
import { LightningElement, api } from 'lwc';

// FIX: Weight_Pct__c changed from type 'percent' to type 'number'
// lightning-datatable 'percent' type multiplies value by 100 automatically.
// Your field stores 42.0 (already a percentage) so it was showing 4,200%.
// Using 'number' with a % symbol in the label is the correct approach.
const COLUMNS = [
  {
    label: 'Ticker',
    fieldName: 'Ticker_Symbol__c',
    type: 'text'
  },
  {
    label: 'Quantity',
    fieldName: 'Quantity__c',
    type: 'number'
  },
  {
    label: 'Purchase Price',
    fieldName: 'Purchase_Price__c',
    type: 'currency',
    typeAttributes: { currencyCode: 'USD', minimumFractionDigits: 2 }
  },
  {
    label: 'Current Price',
    fieldName: 'Current_Price__c',
    type: 'currency',
    typeAttributes: { currencyCode: 'USD', minimumFractionDigits: 2 }
  },
  {
    label: 'Change %',
    fieldName: 'Change_Pct__c',
    type: 'number',
    typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 },
    cellAttributes: {
      class: { fieldName: 'riskColorClass' },
      alignment: 'left'
    }
  },
  {
    label: 'Weight %',
    fieldName: 'Weight_Pct__c',
    type: 'number',                          // FIX: was 'percent' — caused 4200% display
    typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 }
  }
];

export default class RiskScoreCard extends LightningElement {

  columns = COLUMNS;
  _processedHoldings = [];

  // FIX: Use @api setter instead of a getter so processing runs ONCE
  // when data arrives — not on every render cycle.
  @api
  set holdings(value) {
    this._processedHoldings = (value || []).map(item => {
      let riskClass = 'slds-text-color_success';

      if (item.Change_Pct__c < -8) {
        riskClass = 'slds-text-color_error';
      } else if (item.Change_Pct__c < -4) {
        riskClass = 'slds-text-color_weak';
      }

      return { ...item, riskColorClass: riskClass };
    });
  }

  get holdings() {
    return this._processedHoldings;
  }

  @api aggregateScore;

  get isEmpty() {
    return !this._processedHoldings || this._processedHoldings.length === 0;
  }
}
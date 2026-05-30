/**
 * @description : marketAlertPanel — subscribes to RiskAlert__c LMS channel.
 *                Fires imperative callout to Twelve Data API on threshold breach.
 *                Displays full live quote card with OHLC, volume, and advisor guidance.
 * @author      : TradeSync Project
 * @last modified on : 04-29-2026
 */
import { LightningElement, wire, track } from 'lwc';
import {
  subscribe,
  unsubscribe,
  MessageContext,
  APPLICATION_SCOPE
} from 'lightning/messageService';
import RISK_CHANNEL from '@salesforce/messageChannel/RiskAlert__c';
import fetchLiveQuote from '@salesforce/apex/PortfoliaController.fetchLiveQuote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MarketAlertPanel extends LightningElement {

  subscription = null;
  @track liveQuote = null;
  isLoading = false;

  @wire(MessageContext)
  messageContext;

  // ── Lifecycle ─────────────────────────────────────────────

  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  // ── LMS ───────────────────────────────────────────────────

  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        RISK_CHANNEL,
        (message) => this.handleMessage(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  async handleMessage(message) {
    // Guard: drop duplicate messages while a callout is already in-flight
    if (this.isLoading) return;

    this.isLoading = true;
    const ticker = message.tickerSymbol;

    try {
      const result = await fetchLiveQuote({
        ticker: ticker,
        accountId: message.accountId
      });

      this.liveQuote = result;

      this.dispatchEvent(
        new ShowToastEvent({
          title: '⚠ Risk Alert Confirmed',
          message: `${ticker} live price loaded. Change: ${message.changePercent}%. Review the panel for full details.`,
          variant: 'warning',
          mode: 'dismissible'
        })
      );

    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Live Price Unavailable',
          message: error.body ? error.body.message : 'Twelve Data API did not respond. Check Named Credential and Remote Site Settings.',
          variant: 'error',
          mode: 'sticky'
        })
      );
    } finally {
      this.isLoading = false;
    }
  }

  // ── Computed properties ───────────────────────────────────

  /**
   * Controls whether the live quote card renders.
   * Uses hasLiveQuote instead of liveQuote.symbol directly
   * so the template condition is clean and safe.
   */
  get hasLiveQuote() {
    return this.liveQuote !== null && this.liveQuote.symbol !== undefined;
  }

  /** "Market Open" green pill / "Market Closed" grey pill */
  get marketStatus() {
    if (!this.liveQuote) return 'Unknown';
    return this.liveQuote.is_market_open ? 'Market Open' : 'Market Closed';
  }

  get marketStatusClass() {
    const base = 'market-status-badge ';
    return this.liveQuote && this.liveQuote.is_market_open
      ? base + 'status-open'
      : base + 'status-closed';
  }

  /** Red arrow-down for negative, green arrow-up for positive */
  get changeClass() {
    const base = 'price-change ';
    if (!this.liveQuote) return base;
    return this.liveQuote.percent_change >= 0
      ? base + 'change-positive'
      : base + 'change-negative';
  }

  get changeIcon() {
    if (!this.liveQuote) return 'utility:arrowdown';
    return this.liveQuote.percent_change >= 0
      ? 'utility:arrowup'
      : 'utility:arrowdown';
  }

  /**
   * Compares today's volume to the rolling average.
   * Labels: High Activity / Normal / Low Activity
   * Used so the advisor can instantly see if selling pressure is unusual.
   */
  get volumeLabel() {
    if (!this.liveQuote || !this.liveQuote.average_volume) return '—';
    const ratio = this.liveQuote.volume / this.liveQuote.average_volume;
    if (ratio > 1.3) return 'High activity';
    if (ratio < 0.7) return 'Low activity';
    return 'Normal';
  }

  get volumeClass() {
    if (!this.liveQuote || !this.liveQuote.average_volume) return 'ohlc-val';
    const ratio = this.liveQuote.volume / this.liveQuote.average_volume;
    if (ratio > 1.3) return 'ohlc-val volume-high';
    if (ratio < 0.7) return 'ohlc-val volume-low';
    return 'ohlc-val volume-normal';
  }

  /**
   * Plain-English advisor guidance generated from the live data.
   * Tells the advisor what the numbers mean without them having to interpret.
   */
  get advisorGuidance() {
    if (!this.liveQuote) return '';

    const pct = parseFloat(this.liveQuote.percent_change);
    const vol = this.liveQuote.volume;
    const avgVol = this.liveQuote.average_volume;
    const ticker = this.liveQuote.symbol;
    const isOpen = this.liveQuote.is_market_open;

    let guidance = `${ticker} has moved ${pct.toFixed(2)}% `;
    guidance += isOpen ? 'during today\'s active session. ' : 'in the last completed session. ';

    if (vol > avgVol * 1.3) {
      guidance += 'Volume is significantly above average — this suggests strong institutional selling pressure. ';
    } else if (vol < avgVol * 0.7) {
      guidance += 'Volume is below average — the move may be driven by thin liquidity rather than broad market conviction. ';
    } else {
      guidance += 'Volume is in the normal range — this is a market-driven move. ';
    }

    if (pct < -10) {
      guidance += 'Consider contacting the client immediately and reviewing stop-loss positions.';
    } else if (pct < -8) {
      guidance += 'Review the client\'s exposure to this position and assess whether rebalancing is appropriate.';
    } else {
      guidance += 'Monitor closely and reassess if the decline continues.';
    }

    return guidance;
  }
}
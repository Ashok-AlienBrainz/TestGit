import { LightningElement, api } from 'lwc';

export default class TestChild extends LightningElement {



  message;
  @api
  get childMessage() {
    return this.message;

  }

  set childMessage(value) {
    this.message = value;
  }

  handleButtonClick() {
    const bubbleEvent = new CustomEvent('notify', {
      detail: { message: 'Hello from the deepest level!' },
      bubbles: true,    // Allows the event to move up the internal DOM
      composed: true    // Allows the event to cross the Shadow DOM boundary to parents
    });

    this.dispatchEvent(bubbleEvent);
  }

}
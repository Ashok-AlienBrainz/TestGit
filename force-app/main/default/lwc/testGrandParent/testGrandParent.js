import { LightningElement, track } from 'lwc';

export default class TestGrandParent extends LightningElement {
  @track grandparentMessage = 'Waiting...';

  handleGrandparentNotify(event) {
    // The event successfully bubbled all the way here!
    this.grandparentMessage = 'Caught by Grandparent: ' + event.detail.message;
  }
}
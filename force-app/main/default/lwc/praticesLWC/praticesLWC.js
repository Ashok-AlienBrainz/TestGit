import { LightningElement } from 'lwc';

export default class PraticesLWC extends LightningElement {

  greeting = '';

  // 2. The event handler that runs every time the user types
  handleInputChange(event) {
    // 'event.target.value' captures the current text in the box
    this.greeting = event.target.value;
    console.log('Enter Value is ' + this.greeting);

  }
  hanldeChange() {
    console.log('Enter Value is ' + this.greeting);
    for (let char of this.greeting) {
      console.log(char);
    }

  }
}
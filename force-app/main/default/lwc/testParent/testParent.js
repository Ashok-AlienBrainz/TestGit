import { LightningElement, track } from 'lwc';

export default class TestParent extends LightningElement {

  message = '';
  inputValue = ''

  _obj = {
    name: 'Ashok',
    age: 25
  }
  handleChange(event) {
    this.message = event.target.value;

  }
  handleChangeObj() {
    console.log('obj', JSON.stringify(this._obj));
    this.obj = {
      ...this._obj,
      name: 'Ashok Kumar',
      age: 26
    }
    console.log('Update obj', JSON.stringify(this._obj));
  }

  get obj() {
    console.log('get obj', JSON.stringify(this._obj));
    return this._obj;
  }

  set obj(value) {
    console.log('set obj', JSON.stringify(value));
    this._obj = value;

  }
  @track parentMessage = 'Waiting...';

  handleChildNotify(event) {
    // event.detail contains the data sent from child
    this.parentMessage = 'Caught by Parent: ' + event.detail.message;
  }





}
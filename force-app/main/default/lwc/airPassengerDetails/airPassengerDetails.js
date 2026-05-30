import { LightningElement, track, api } from 'lwc';

export default class AirPassengerDetails extends LightningElement {

  @track salutation;
  @track firstName;
  @track lastName;
  @track email;
  @track age;
  @track passportNumber;
  @track gender;

  @api passengerIndex
  @api passengerLabel
  _passengerData = {};

  @api
  set passengerData(value) {
    this._passengerData = value || {}
    this.salutation = this._passengerData.salutation || '';
    this.firstName = this._passengerData.firstName || '';
    this.lastName = this._passengerData.lastName || '';
    this.email = this._passengerData.email || '';
    this.age = this._passengerData.age || '';
    this.passportNumber = this._passengerData.passportNumber || '';
    this.gender = this._passengerData.gender || '';

    console.log(
      'Passenger data restored:',
      JSON.stringify(this._passengerData)
    );

  }

  get passengerData() {
    return this._passengerData;
  }

  get salutationOptions() {
    return [
      { label: 'Mr.', value: 'Mr.' },
      { label: 'Ms.', value: 'Ms.' },
      { label: 'Mrs.', value: 'Mrs.' },
      { label: 'Dr.', value: 'Dr.' },
      { label: 'Prof.', value: 'Prof.' },
    ];
  }
  get genderOptions() {
    return [
      { label: 'Male', value: 'Male' },
      { label: 'Female', value: 'Female' }
    ];
  }

  handleUniversalChange(event) {
    // Identify which field is changing
    const fieldName = event.target.name;
    const userData = {};

    userData.passengerIndex = this.passengerIndex;
    userData.passengerLabel = this.passengerLabel;

    if (fieldName === 'name') {
      // Special handling for the Name component
      this.salutation = event.detail.salutation;
      this.firstName = event.detail.firstName;
      this.lastName = event.detail.lastName;
      userData.salutation = event.detail.salutation;
      userData.firstName = event.detail.firstName;
      userData.lastName = event.detail.lastName;

    } else if (fieldName === 'email') {
      this.email = event.target.value;
      userData.email = event.target.value;

    } else if (fieldName === 'age') {
      this.age = event.target.value;
      userData.age = event.target.value;

    } else if (fieldName === 'passport') {
      this.passportNumber = event.target.value;
      userData.passportNumber = event.target.value;

    } else if (fieldName === 'gender') {
      userData.gender = event.detail.value;
      this.gender = event.detail.value;

    }
    this._passengerData = {
      ...this._passengerData,
      ...userData
    };

  }

  @api
  getPassengerData() {
    console.log("thisis child method call from aprent " + JSON.stringify(this._passengerData));
    return this._passengerData;

  }
}
import { LightningElement, api, wire, track } from 'lwc';
export default class AirDataFatch extends LightningElement {

  _selectedId = '';
  selectedValue;
  @api airData = [];
  @api error;
  @track flight;

  _airAllData = [];

  passengerNumbers;
  passNum = '';

  @api
  set selectedId(value) {
    this._selectedId = value || '';
    this.selectedValue = this._selectedId;

    // Rebuild flight when component is recreated
    this.populateFlight();

  }

  get selectedId() {
    return this._selectedId;
  }

  @api
  set airAllData(value) {
    this._airAllData = value || [];

    // Rebuild flight when data arrives
    this.populateFlight();
  }
  get airAllData() {
    return this._airAllData;

  }
  @api
  set passengerNumbers(value) {
    this.passNum = value || '';
    console.log('Setter passengerNumbers:', this.passNum);

  }
  get passengerNumbers() {
    return this.passNum;
  }

  populateFlight() {
    if (this._selectedId && this._airAllData.length > 0) {
      const dataValue = this._airAllData.filter(
        item => item.Id === this._selectedId
      );

      this.flight = dataValue.length > 0 ? dataValue[0] : null;
    } else {
      this.flight = null;
    }

    console.log('Repopulated flight:', JSON.stringify(this.flight));
  }


  handleChange(event) {
    this.selectedValue = event.detail.value;
    this._selectedId = this.selectedValue;

    // Populate flight immediately
    this.populateFlight();

    console.log('Selected flight:', JSON.stringify(this.flight));

    this.passengerNumbers = '';
    // Send selected Id to parent
    this.dispatchEvent(
      new CustomEvent('selectedid', {
        detail: {
          selectedId: this.selectedValue,
          passengerNumbers: ''
        }

      })
    );
  }

  passengerHandleChange(event) {
    console.log('this is value on passenger in child ' + event.detail.value);
    this.passengerNumbers = event.detail.value;
    const selectEvent = new CustomEvent('passengernumber', {
      detail: this.passengerNumbers
    });
    this.dispatchEvent(selectEvent);
  }




}

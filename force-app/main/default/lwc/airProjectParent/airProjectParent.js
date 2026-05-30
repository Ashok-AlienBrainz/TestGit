import { LightningElement, wire, track } from 'lwc';
import getAirMetadata from '@salesforce/apex/AirDataHandler.getAirMetadata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AirProjectParent extends LightningElement {


  @track steps = [
    { label: 'Flight Selection', value: 'step-1' },
    { label: 'Passenger Deatils', value: 'step-2' },
    { label: 'Seat Selection', value: 'step-3' },
    { label: 'Confirmation', value: 'step-4' }
  ];


  @track airAllData = [];
  @track airData = [];
  error;
  selectedId = '';
  setPassengerValue = '';

  handleAddButton = 0;
  addButtonShow = true;

  @track passengerInputValue = [];



  @wire(getAirMetadata)
  airData({ error, data }) {
    if (data) {
      this.airAllData = data;
      console.log('This is airAllData ' + JSON.stringify(this.airAllData));
      this.airData = data.map(value => ({
        value: value.Id,
        label: value.FlightNumber + ' ' + value.OriginAirport + ' -> ' + value.destinationAir

      })
      )
      console.log('This is airData ' + JSON.stringify(this.airData));

    }
    else if (error) {
      this.error = error;
      console.log('Error : ' + JSON.stringify(error));
    }
  }

  handleSelectedId(event) {
    this.selectedId = event.detail.selectedId;
    this.setPassengerValue = event.detail.passengerNumbers

  }

  currentIndex = 0;


  get currentStep() {
    console.log('current step get ' + this.steps[this.currentIndex].value);
    return this.steps[this.currentIndex].value;
  }

  // Returns the label of the current step
  get currentStepLabel() {
    return this.steps[this.currentIndex].label;
  }

  // Disable Previous button on first step
  get isFirstStep() {
    return this.currentIndex === 0;
  }

  // Disable Next button on last step
  get isLastStep() {
    return this.currentIndex === this.steps.length - 1;
  }

  // Move to next step
  handleNext() {
    console.log('this.setPassengerValue.length ' + this.setPassengerValue.length);
    if (this.setPassengerValue.length === 0) {
      this.showToast('Toast Notification Error', 'Put Number of Passeger', 'error');
      return;

    }

    if (this.currentStep === 'step-2') {
      const passengerComponents =
        this.template.querySelectorAll('c-air-passenger-details');

      this.allPassengerData = [];

      passengerComponents.forEach(component => {
        this.allPassengerData.push(
          component.getPassengerData()
        );
      });

      console.log(
        'All Passenger Data:',
        JSON.stringify(this.allPassengerData)
      );
    }

    if (this.currentIndex < this.steps.length - 1) {
      this.currentIndex++;
    }
  }
  get isStepOne() {
    return this.currentStep?.trim() === 'step-1';
  }
  get isStepTwo() {
    return this.currentStep === 'step-2';
  }
  get isStepThree() {
    return this.currentStep === 'step-3';
  }
  // Move to previous step
  handlePrevious() {
    if (this.currentIndex > 0) {
      this.currentIndex--;
    }

  }
  passengerNumberChange(event) {
    this.setPassengerValue = event.detail;

  }


  showToast(variant, title, message) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    })
    this.dispatchEvent(event);
  }

  get passengers() {
    const count = Number(this.setPassengerValue) || 0;

    return Array.from({ length: count }, (_, index) => ({
      id: index + 1,
      label: `Passenger ${index + 1}`
    }));
  }

  // How many passenger forms are currently shown
  visiblePassengerCount = 1;

  // Only the first N passengers are rendered
  // get visiblePassengers() {
  //   return this.passengers.slice(0, this.visiblePassengerCount);
  // }

  // Show Add More button only if there are remaining passengers
  get showAddMoreButton() {
    return this.visiblePassengerCount < this.passengers.length;
  }

  // Called when "Add More Passenger Detail" is clicked
  handleAddMorePassenger() {

    if (this.visiblePassengerCount < this.passengers.length) {
      this.visiblePassengerCount++;
    }
  }


  // Parent JS
  // Stores all passengers using passengerIndex as the key
  allPassengerData = {};

  handlePassengerChange(event) {
    const passenger = event.detail;
    const index = passenger.passengerIndex;

    this.allPassengerData = {
      ...this.allPassengerData,
      [index]: passenger
    };

    console.log(
      'All Passenger Data:',
      JSON.stringify(this.allPassengerData)
    );
  }



  // Create passenger objects and attach saved data to each one
  get visiblePassengers() {
    const count = Number(this.setPassengerValue) || 0;

    const passengers = Array.from({ length: count }, (_, index) => ({
      id: index + 1,
      label: `Passenger ${index + 1}`,

      // Pass previously saved data back to the child
      passengerData: this.allPassengerData[index + 1] || {}
    }));

    // Show only the currently visible passenger forms
    return passengers.slice(0, this.visiblePassengerCount);
  }



}
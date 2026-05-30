import { LightningElement, track } from 'lwc';
import lazyLoadingData from '@salesforce/apex/lazyLoadingData.getAccountList';
import { updateRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";




const columns = [
  { label: 'Name', fieldName: 'Name', editable: true },
  { label: 'Id ', fieldName: 'Id' }
]
export default class LazyLoadingUsingPagination extends LightningElement {

  columnsList = columns;

  startIndex = 0;
  endIndex = 4;
  currectPage = 1;
  totalPage = 0;

  previesHide = false;
  nextHide = false;
  draftValues = [];

  selectedRowsIds = [];
  selectedRowIdSet = new Set();



  @track lazyData = [];
  connectedCallback() {
    this.fetchData();

  }

  fetchData() {
    lazyLoadingData({ offset: this.startIndex, limits: 4 })
      .then(result => {
        this.totalPage = Math.ceil(result.totalRecord / 4);
        this.lazyData = result.accList;
        console.log('result', JSON.stringify(result));
        this.selectedRowsIds = this.lazyData
          .filter(row => this.selectedRowIdSet.has(row.Id))
          .map(row => row.Id);

        console.log('this.selectedRowsIds 3', JSON.stringify(this.selectedRowsIds));

      })
      .catch(error => {
        console.log('error', error);
      })

    if (this.currectPage == 1) {
      this.previesHide = true;
    }
    else {
      this.previesHide = false;
    }
    if (this.currectPage == this.totalPage) {
      this.nextHide = true;
    }
    else {
      this.nextHide = false;
    }
  }

  previesHandleClick() {
    this.endIndex = this.startIndex;
    this.startIndex = this.startIndex - 4;
    this.currectPage = this.currectPage - 1;


    console.log('previesHandleClick')
    console.log('this.startIndex', this.startIndex);
    console.log('this.endIndex', this.endIndex);
    this.fetchData();



  }
  nextHandleClick() {

    this.startIndex = this.endIndex;
    this.endIndex = this.endIndex + 4;
    this.currectPage = this.currectPage + 1;
    if (this.currectPage == this.totalPage) {
      this.nextHide = true;
    }
    console.log('nextHandleClick')
    console.log('this.startIndex', this.startIndex);
    console.log('this.endIndex', this.endIndex);
    this.fetchData();


  }

  handleRowSelection(event) {
    console.log('handleRowSelection');
    console.log('event', event.detail.selectedRows);

    const selectedRows = event.detail.selectedRows;
    const currentPageIds = this.lazyData.map(row => row.Id);

    // // Remove unchecked rows of current page
    currentPageIds.forEach(id => {
      const stillSelected = selectedRows.some(row => row.Id === id);
      if (!stillSelected) {
        this.selectedRowIdSet.delete(id);
      }
    });

    // Add selected rows
    selectedRows.forEach(row => {
      this.selectedRowIdSet.add(row.Id);
    });

    // Update datatable binding
    this.selectedRowsIds = [...this.selectedRowIdSet];
    console.log('this.selectedRowsIds', JSON.stringify(this.selectedRowsIds));
  }

  async handleSave(event) {
    console.log('handleSave');

    const draftValues = event.detail.draftValues;
    console.log('Draft values:', JSON.stringify(draftValues));

    // Prepare records for updateRecord
    const recordInputs = draftValues.map(draft => {
      return {
        fields: { ...draft }
      };
    });

    try {
      // Update records
      await Promise.all(
        recordInputs.map(recordInput => updateRecord(recordInput))
      );

      // Success toast
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Success',
          message: 'Records updated successfully',
          variant: 'success'
        })
      );

      // Clear draft values
      this.draftValues = [];

      // Reload current page data
      this.fetchData();
    }
    catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error updating records',
          message: error.body?.message || error.message,
          variant: 'error'
        })
      );
    }
  }

}
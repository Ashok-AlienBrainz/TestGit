import { LightningElement, track, api, wire } from 'lwc';
import getFiles from '@salesforce/apex/GoogleDriveHandler.getFile';
import uploadFileApex from '@salesforce/apex/GoogleDriveHandler.uploadFile';
import previewFiles from '@salesforce/apex/GoogleDriveHandler.previewFile';
import deleteFile from '@salesforce/apex/GoogleDriveHandler.deleteFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import downloadFileApex from '@salesforce/apex/GoogleDriveHandler.downloadFile';


export default class GoogleDriveComponent extends LightningElement {

  @track files = [];
  error = '';

  isLoadingPreview = false;
  showUploadModal = false;

  @track fileData;
  @track fileName;
  @track filePreviewUrl;
  @track isUploading = false;
  @track status;

  showPreview = false;

  @track previewUrl = '';
  @track previewText = '';
  @track currentMimeType = '';
  @track currentBase64 = '';
  @track currentFileName = '';

  connectedCallback() {
    this.getFile();
  }

  // get all files from google drive
  getFile() {
    this.isLoadingPreview = true;
    getFiles()
      .then(result => {
        console.log(result);
        this.files = result.files.map(file => {
          return {
            id: file.id,
            name: file.name,
            mimeType: file.mimeType,
          }
        })
        console.log('There are files ' + this.files);
      })
      .catch(error => {
        console.log(error);
        this.error = error;
      })
      .finally(() => {
        this.isLoadingPreview = false;
      });

  }


  // this is for upload file
  openUploadModal() {
    this.showUploadModal = true;
  }

  closeUploadModal() {
    this.showUploadModal = false;
    // Clear out the form so it's fresh next time they open it
    this.fileData = undefined;
    this.filePreviewUrl = undefined;
    this.status = undefined;
  }

  // Getter for disabling the button
  get isUploadDisabled() {
    return this.isUploading || !this.fileData;
  }


  handleFileChange(event) {
    const file = event.target.files[0];
    if (!file) {
      this.fileData = undefined;
      this.filePreviewUrl = undefined;
      this.mimeType = undefined;
      return;
    }

    this.fileName = file.name;
    this.mimeType = file.type;

    const reader = new FileReader();
    reader.onload = () => {
      // full data URI: "data:image/png;base64,iVBORw0KGgoAAAANS..."
      this.fileData = reader.result;
      this.filePreviewUrl = reader.result; // this drives the <img> src
    };
    reader.onerror = (err) => {
      this.status = 'Error reading file: ' + err;
    };
    reader.readAsDataURL(file);
  }

  uploadFile() {

    if (!this.fileData) {
      this.status = 'Please choose a file first.';
      return;
    }

    this.isUploading = true;
    this.status = 'Uploading...';

    uploadFileApex({
      base64Data: this.fileData,
      fileName: this.fileName,
      mimeType: this.mimeType
    })
      .then((newVersionId) => {

        this.status = 'Upload successful! Google Drive File Id: ' + newVersionId;
        this.handleToastMesssage('Upload successful!', 'Success', 'success');
        this.fileData = undefined;
        this.filePreviewUrl = undefined;

      })
      .catch((error) => {
        console.error('Upload failed:', error);
        let msg = (error.body?.pageErrors?.[0]?.message)
          || error.body?.message
          || error.message
          || 'Unknown error';
        this.status = 'Upload failed: ' + msg;
        this.handleToastMesssage('Upload failed: ' + msg, 'Error', 'error');
      })
      .finally(() => {
        this.isUploadng = false;
        this.getFile();
        this.isUploading = false;
        this.filedata = '';
        this.filePreviewUrl = '';
        this.showUploadModal = false;
      });
  }



  // for previre when upload 
  get isImage() {
    return this.currentMimeType &&
      this.currentMimeType.startsWith('image/');
  }
  get isText() {
    // ONLY include actual readable text types here
    return this.currentMimeType === 'text/plain' ||
      this.currentMimeType === 'text/csv' ||
      this.currentMimeType === 'text/html' ||
      this.currentMimeType === 'application/json'
  }

  get isPdf() {
    return this.currentMimeType === 'application/pdf';
  }
  get isGoogleNative() {
    return this.currentMimeType != null &&
      this.currentMimeType.startsWith(
        'application/vnd.google-apps'
      );
  }
  get isOther() {
    return !this.isImage && !this.isText && !this.isPdf && !this.isGoogleNative;;
  }



  // for preview 
  handlePreview(event) {
    console.log('File Preview Id ' + event.target.dataset.id);
    this.isLoadingPreview = true;
    this.showPreview = true;
    this.previewUrl = '';
    this.previewText = '';

    previewFiles({ id: event.target.dataset.id })
      .then(result => {
        const mimeType = result.mimeType;
        const base64 = result.base64;
        const type = result.type;

        // Store for download
        this.currentMimeType = mimeType;
        this.currentBase64 = base64;
        this.currentFileName = result.name || 'file';

        switch (type) {

          case 'image':
            this.previewUrl = 'data:' + mimeType
              + ';base64,' + base64;
            break;

          case 'text':
            try {
              this.previewText = atob(base64);
            } catch (e) {
              this.previewText = 'Could not decode content.';
            }
            break;

          case 'csv':
            try {
              this.previewText = atob(base64);
            } catch (e) {
              this.previewText = 'Could not decode CSV.';
            }
            break;

          case 'json':
            try {
              this.previewText = JSON.stringify(
                JSON.parse(atob(base64)),
                null, 2
              );
            } catch (e) {
              this.previewText = atob(base64);
            }
            break;

          case 'pdf':
            // show download button — handled in template
            console.log('PDF - download only');
            break;

          case 'google_native':
            // show message — handled in template
            console.log('Google native - not supported');
            break;

          default:
            console.log('Other type - download only');
            break;
        }
      })
      .catch(error => {
        console.error('preview file error: ' + error);
        this.showPreview = false;
      })
      .finally(() => {
        this.isLoadingPreview = false;
      });
  }

  // ADD download handler for PDF and other files
  handleDownloadPreview() {

    if (!this.currentBase64) return;

    try {

      const a = document.createElement('a');
      a.href = 'data:application/octet-stream;base64,'
        + this.currentBase64;
      a.download = this.currentFileName;
      a.click();

    } catch (e) {
      console.error('Download error:', e);
    }
  }

  closePreview() {
    this.showPreview = false;
    this.previewUrl = '';
    this.previewText = '';
    this.currentMimeType = '';
    this.currentBase64 = '';
  }
  //preview download 
  handleDelete(event) {
    console.log('File Delete Id ' + event.target.dataset.id);
    const fileIdToDelete = event.target.dataset.id;
    this.isLoadingPreview = true;
    deleteFile({ id: fileIdToDelete })
      .then(result => {
        console.log('File deleted successfully ' + result);
        const filterFiles = this.files.filter(item => item.id !== fileIdToDelete);
        this.files = [...filterFiles];
        this.handleToastMesssage('File deleted successfully', 'Success', 'success');
        console.log('Files after delete ' + this.files);

      })
      .catch(error => {
        console.log(error);
        this.error = error;
        this.handleToastMesssage('File delete failed', 'Error', 'error');
      })
      .finally(() => {
        this.isLoadingPreview = false;
      });

  }

  //handler row download button 
  handleDownload(event) {
    const fileId = event.target.dataset.id;
    console.log('File Download Id ' + fileId);
    const file = this.files.filter(item => item.id === fileId);
    console.log('File Download Id ' + JSON.stringify(file));
    const fileName = file ? file[0].name : 'download';
    console.log('File Download Id ' + fileName);

    this.isLoadingPreview = true;

    downloadFileApex({ id: fileId })
      .then(result => {
        const a = document.createElement('a');
        a.href = 'data:application/octet-stream;base64,'
          + result.base64;
        a.download = fileName // ← name already in row
        a.click();
      })
      .catch(error => {
        this.handleToastMesssage(
          'Download failed: ' +
          (error.body?.message || error.message),
          'Error',
          'error'
        );
      })
      .finally(() => {
        this.isLoadingPreview = false;
      });
  }


  handleToastMesssage(message, title, variant) {
    const evt = new ShowToastEvent({
      message: message,
      title: title,
      variant: variant,
      mode: 'dismissable'
    });
    this.dispatchEvent(evt);
  }
}
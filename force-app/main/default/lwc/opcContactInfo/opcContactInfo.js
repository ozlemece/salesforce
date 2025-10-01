import { LightningElement } from 'lwc';
// import getMetadataRecords from '@salesforce/apex/OPCContactInfoController.getMetadataRecords';
// import updateMetadataContact from '@salesforce/apex/OPCContactInfoController.updateMetadataContact';
import getUserWithMetadata from '@salesforce/apex/OPCContactInfoController.getUserWithMetadata';
import getUserType from '@salesforce/apex/OPCContactInfoController.getUserType';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpcContactInfo extends LightningElement {
    records = [];
    hasError = false;
    screenMessage = '';
    email = '';
    phone = '';
    address = '';
    isSystemAdmin = false;
    showModal = false;
    param = 'OPCUser::' + this.screenMessage + '::' + this.email + '::' + this.phone + '::' + this.address;

    connectedCallback() {
        // getUserType()
        //     .then(result => {
        //         console.log('User Type:', result);
        //         this.isSystemAdmin = result === 'System Administrator';
        //     })
        //     .catch(error => {
        //         console.error('Error getting user type:', error);
        //         console.log('error1: ',error);
        //         this.ShowToastEvent('error', 'Error', error.body.message);
        //     });

        // getMetadataRecords({ contactType: 'OPCUser' })
        //     .then(data => {
        //         this.records = data;
        //         this.hasError = false;
        //         console.log('data: ',data);
        //     })
        //     .catch(error => {
        //         console.error('Error loading contact records:', error);
        //         this.ShowToastEvent('error', 'Error', error.body.message);
        //         this.hasError = true;
        //         console.log('error2: ',error);

        //     });
        getUserWithMetadata({ contactType: 'OPCUser' })
            .then(result => {
                const userType = result.userType; 
                const records = result.records;

                console.log('User Type:', userType);
                this.isSystemAdmin = userType === 'System Administrator';

                this.records = records;
                this.hasError = false;
                console.log('Records:', records);
            })
            .catch(error => {
                console.error('Error:', error);
                this.hasError = true;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body?.message || 'Unknown error',
                        variant: 'error'
                    })
                );
            });
    }

    openModal() {
        this.showModal = true;
    }

    handleInputChange(event) {
        this[event.target.name] = event.target.value;
    }

    handleSave() {
        updateMetadataContact({ param: 'OPCUser::' + this.screenMessage + '::' + this.email + '::' + this.phone + '::' + this.address })
            .then(() => {
                this.ShowToastEvent('success', 'Success', 'Contact information updated successfully');
                this.closeModal();
                window.location.reload();
            })
            .catch(error => {
                console.error('Error updating contact info:', error);
                console.log('error3: ',error);
                this.ShowToastEvent('error', 'Error', error.body.message);
            });
    }

    closeModal() {
        this.showModal = false;
        this.resetValues();
        this.isSystemAdmin = true;
    }

    resetValues() {
        this.screenMessage = '';
        this.email = '';
        this.phone = '';
        this.address = '';
    }

    ShowToastEvent(variant, title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}

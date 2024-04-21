/**
 * @description : JS file which will help in capturing passenger details
 * @Author: Varun Kumar Sirisilla
 */
import { LightningElement, api } from 'lwc';
import bookSeats from '@salesforce/apex/CW_BookVehicleController.bookSeats';
import { showToast } from 'c/cwUtils';
export default class CwCapturePassengerDetails extends LightningElement {
    // Public properties
    @api passengerObjLst;
    @api reservationObj;

    // Getter for gender options
    get genderOptions() {
        return [{ label: 'Male', value: 'Male' }, { label: 'Female', value: 'Female' }];
    }

    // Handles input change for passenger details
    handleInputChange(event) {
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;
        var passengerObjLstCpy = JSON.parse(JSON.stringify(this.passengerObjLst));
        passengerObjLstCpy[index][fieldName] = value;
        this.passengerObjLst = passengerObjLstCpy;
    }

    // Handles field change for reservation details
    handleFieldChange(event) {
        let fieldName = event.target.name;
        var reservationObj = JSON.parse(JSON.stringify(this.reservationObj));
        reservationObj[fieldName] = event.target.value;
        this.reservationObj = reservationObj;
    }

    // Handles save action
    onSave() {

        var inputFieldsValid = true;

        for (var i = 0; i < this.passengerObjLst.length; i++) {

            if (this.passengerObjLst[i].Name == null || this.passengerObjLst[i].Name == '' ||
                this.passengerObjLst[i].CW_Gender__c == null || this.passengerObjLst[i].CW_Gender__c == '' ||
                this.passengerObjLst[i].CW_Age__c == null || this.passengerObjLst[i].CW_Age__c == '') {
                inputFieldsValid = false;
                break;
            }

        }

        if (this.reservationObj.CW_Address__c == null || this.reservationObj.CW_Address__c == '' ||
            this.reservationObj.CW_Phone__c == null || this.reservationObj.CW_Phone__c == '') {
            inputFieldsValid = false;
        }

        if (!inputFieldsValid) {
            showToast(this, 'Error', 'Please fill all the required fields', 'Error', '');
            return;
        }

        // Starts spinner
        this.dispatchCustomEvent('startspinner');

        bookSeats({
            passengerListStr: JSON.stringify(this.passengerObjLst),
            reservationObjStr: JSON.stringify(this.reservationObj)
        })
            .then(result => {
                if (result == 'success') {
                    // Handles navigation to next page
                    this.dispatchCustomEvent('nextpage');
                } else {
                    showToast(this, 'Error', result, 'Error', '');
                }
            })
            .catch(error => {
                console.error(error);
                showToast(this, 'Error', 'Something went wrong', 'Error', '');
            })
            .finally(() => {
                // Stops the spinner regardless of the outcome
                this.dispatchCustomEvent('stopspinner');
            });
    }

    // Handles navigation to previous page
    onPreviousPage() {
        this.dispatchCustomEvent('previouspage');
    }

    dispatchCustomEvent(eventName) {
        this.dispatchEvent(new CustomEvent(eventName));
    }
}
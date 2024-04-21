/**
 * @File Name: CwVehicleLayout.js
 * @Description: Represents a Lightning Web Component for handling vehicle layout modifications and submission
 * @Author: Varun Kumar Sirisilla
 */

import { LightningElement, api } from 'lwc';
import { updateRecord } from "lightning/uiRecordApi";
import { showToast } from 'c/cwUtils';

// Constants for action names
const ACTION_ADD_SEAT = 'addSeat';
const ACTION_EMPTY_SPACE = 'emptySpace';
const ACTION_ADD_ROW = 'addRow';
const ACTION_DELETE_ROW = 'deleteRow';
const SEAT_AVAILABLE_CLASS = 'seatButtonAvailableStyle slds-button slds-button_neutral slds-button_stretch';
const SEAT_SELECTED_CLASS = 'seatButtonSelectedStyle slds-button slds-button_neutral slds-button_stretch';
const SEAT_BOOKED_CLASS = 'seatButtonBookedStyle slds-button slds-button_neutral slds-button_stretch';
export default class CwVehicleLayout extends LightningElement {

    @api recId; // The record Id
    @api previewMode = false; // Flag indicating whether preview mode is enabled
    @api selectedTrip; // The selected trip record
    @api layoutObj = { rows: [] }; // The layout object containing rows and seats

    seatAvailableClass = SEAT_AVAILABLE_CLASS;
    seatSelectedClass = SEAT_SELECTED_CLASS;
    seatBookedClass = SEAT_BOOKED_CLASS;
    currentSeatNumber; // The current seat number

    onAddSeat(event) {
        this.handleSeatModification(event, ACTION_ADD_SEAT);
    }

    onEmptySpace(event) {
        this.handleSeatModification(event, ACTION_EMPTY_SPACE);
    }

    onAddRow(event) {
        this.handleRowModification(event, ACTION_ADD_ROW);
    }

    onDeleteEntireRow(event) {
        this.handleRowModification(event, ACTION_DELETE_ROW);
    }

    /**
    * Handles addition or removal of seats.
    * @param {Event} event - The event object containing the target details.
    * @param {string} action - The action to be performed ('addSeat' or 'emptySpace').
    */
    handleSeatModification(event, action) {
        try {
            const rowIndex = event.target.name;
            const rowNo = event.target.value;
            var copiedLayoutObject = this.cloneObject(this.layoutObj);
            if (action == ACTION_ADD_SEAT) {
                this.addSeat(copiedLayoutObject, rowIndex, rowNo);
            } else if (action == ACTION_EMPTY_SPACE) {
                this.addEmptySpace(copiedLayoutObject, rowIndex);
            }
            this.layoutObj = copiedLayoutObject;
        } catch (error) {
            this.handleError(error);
        }
    }

    // Adds a seat to the layout
    addSeat(layoutObject, rowIndex, rowNo) {
        if (this.currentSeatNumber != null) {
            // Check if currentSeatNumber is not null
            if (this.currentSeatNumber !== null) {
                // Check if seats array exists
                if (layoutObject.rows[rowIndex].seats !== null) {
                    let isDuplicateSeat = false;

                    var seats = layoutObject.rows[rowIndex].seats;

                    // Iterate through existing seats in the row to check for duplicates
                    for (let i = 0; i < seats.length; i++) {
                        if (seats[i].seatNoValue == (rowNo + '-' + this.currentSeatNumber)) {
                            // If duplicate seat number found, set isDuplicateSeat to true
                            isDuplicateSeat = true;
                            break;
                        }
                    }

                    // If duplicate seat number found, show error message and exit function
                    if (isDuplicateSeat) {
                        showToast(this, 'Error', 'Duplicate Seat Number ' + this.currentSeatNumber + ' For Row No ' + rowNo, 'Error', '');
                        return;
                    }
                }

                // Add the new seat to the layout object
                layoutObject.rows[rowIndex].seats.push({
                    seatNoLabel: this.currentSeatNumber,
                    seatNoValue: rowNo + '-' + this.currentSeatNumber,
                    isSelected: false,
                    isAvailable: true,
                    class: SEAT_AVAILABLE_CLASS
                });

                // Reset currentSeatNumber after adding the seat
                this.currentSeatNumber = null;

            }

        } else {
            showToast(this, 'Error', 'Please enter seat number', 'Error', '');
        }
    }

    // Adds an empty space to the layout
    addEmptySpace(layoutObject, rowIndex) {
        layoutObject.rows[rowIndex].seats.push({});
    }

    // Handles addition or deletion of rows
    handleRowModification(event, action) {
        try {
            var copiedLayoutObject = this.cloneObject(this.layoutObj);
            if (action == ACTION_ADD_ROW) {
                this.addRow(copiedLayoutObject);
            } else if (action == ACTION_DELETE_ROW) {
                this.deleteRow(copiedLayoutObject, event);
            }
            this.layoutObj = copiedLayoutObject;
        } catch (error) {
            this.handleError(error);
        }
    }

    // Adds a row to the layout
    addRow(layoutObject) {
        const newRowNo = layoutObject.rows.length + 1;
        const newRow = { rowNo: newRowNo, seats: [] };
        layoutObject.rows.push(newRow);
    }

    // Deletes a row from the layout
    deleteRow(layoutObject, event) {
        const rowIndex = event.target.name;
        layoutObject.rows.splice(rowIndex, 1);
    }

    // Helper function to clone object
    cloneObject(obj) {
        return JSON.parse(JSON.stringify(obj));
    }

    // Handles manual entry of seat number
    onSeatNumberManualEntryChange(event) {
        this.currentSeatNumber = event.target.value;
    }

    // Handles seat selection
    onSeatSelection(event) {
        if(!this.previewMode){
            return;
        }
        var copiedLayoutObject = this.cloneObject(this.layoutObj);
        var seatIndex = event.target.value;
        var rowIndex = event.target.name;
        var isSelected = copiedLayoutObject.rows[rowIndex].seats[seatIndex].isSelected;
        if (isSelected) {
            copiedLayoutObject.rows[rowIndex].seats[seatIndex].isSelected = false;
            copiedLayoutObject.rows[rowIndex].seats[seatIndex].class = SEAT_AVAILABLE_CLASS;
        } else {
            copiedLayoutObject.rows[rowIndex].seats[seatIndex].isSelected = true;
            copiedLayoutObject.rows[rowIndex].seats[seatIndex].class = SEAT_SELECTED_CLASS;
        }
        this.layoutObj = copiedLayoutObject;
    }

    // Handles navigation to previous page
    onPreviousPage() {
        this.dispatchEvent(new CustomEvent('previouspage'));
    }

    // Starts spinner
    startSpinner() {
        this.dispatchEvent(new CustomEvent('startspinner'));
    }

    // Stops spinner
    stopSpinner() {
        this.dispatchEvent(new CustomEvent('stopspinner'));
    }

    //Reset layout object
    onReset() {
        this.layoutObj = { rows: [] };
    }

    // Handles errors
    handleError(error) {
        console.error(error);
        alert(error);
        showToast(this, 'Error', 'Error occured', 'Error', '');
    }

    // Submits layout modifications
    onSubmit(event) {
        try {
            if (!this.previewMode) {
                this.updateLayoutRecord();
            } else {
                this.handlePreviewModeSubmit();
            }
        } catch (error) {
            this.handleError(error);
        }

    }

    /**
     * Handles submission of preview mode.
     * @module handlePreviewModeSubmit
     */
    handlePreviewModeSubmit() {

        // Initialize variables
        var passengerObjList = [];
        var reservationObj = {};
        const layoutObj = this.layoutObj;

        // Loop through each row and seat to collect selected seats data
        for (var i = 0; i < layoutObj.rows.length; i++) {
            for (var j = 0; j < layoutObj.rows[i].seats.length; j++) {
                if (layoutObj.rows[i].seats[j].isSelected) {

                    // Create passenger object for selected seat
                    var passengerObj = {
                        CW_Seat_Number__c: layoutObj.rows[i].seats[j].seatNoValue,
                        Name: null,
                        CW_Gender__c: null,
                        CW_Age__c: null,
                        CW_Reservation__c: null
                    };

                    // Update reservation object with selected seat number
                    reservationObj.CW_Seat_Numbers__c = reservationObj.CW_Seat_Numbers__c
                        ? reservationObj.CW_Seat_Numbers__c + ',' + passengerObj.CW_Seat_Number__c
                        : passengerObj.CW_Seat_Number__c;

                    // Add passenger object to list
                    passengerObjList.push(passengerObj);
                }
            }
        }

        // If selected seats exist, proceed to next page with reservation details
        if (passengerObjList.length > 0) {
            const totalPrice = (passengerObjList.length) * this.selectedTrip.CW_Price__c;
            reservationObj.CW_Total_Amount__c = totalPrice;
            reservationObj.CW_Trip__c = this.selectedTrip.Id;
            // Dispatch event to navigate to next page with passenger and reservation details
            this.dispatchEvent(new CustomEvent('nextpageevent', {
                detail: {
                    passengerObjList,
                    reservationObj
                }
            }));
        } else {
            // Show error message if no seat is selected
            showToast(this, 'Error', 'Please select a seat to proceed', 'Error', '');
        }

    }

    // Updates layout record
    updateLayoutRecord() {

        let atLeastOneSeatExists = false;

        // Check if rows exist and contain seats
        if (!this.layoutObj.rows || this.layoutObj.rows.length == 0) {
            showToast(this, 'Error', 'Please add at least one row', 'Error', '');
            return;
        }

        // Iterate through rows and check if at least one seat exists
        for (let i = 0; i < this.layoutObj.rows.length; i++) {
            const seats = this.layoutObj.rows[i].seats;
            if (seats) {
                for (let j = 0; j < seats.length; j++) {
                    if (seats[j].seatNoValue != null) {
                        atLeastOneSeatExists = true;
                        break;
                    }
                }
            }
            if (atLeastOneSeatExists) {
                break;
            }
        }

        // If no seats found, show error message
        if (!atLeastOneSeatExists) {
            showToast(this, 'Error', 'Please add at least one seat', 'Error', '');
            return;
        }

        this.startSpinner();

        // Prepare fields for record update
        const fields = {
            Id: this.recId,
            CW_Layout_JSON__c: JSON.stringify(this.layoutObj)
        };

        const recordInput = { fields };

        // Update record
        updateRecord(recordInput)
            .then(() => {
                showToast(this, 'Success', 'Layout Updated Successfully!', 'success', '');
                this.stopSpinner();
            })
            .catch(error => {
                showToast(this, 'Error', error.body.message, 'Error', '');
                this.stopSpinner();
            });

    }

}
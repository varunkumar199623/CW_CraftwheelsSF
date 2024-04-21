/**
 * @File Name: CwVehicleLayoutBuilder.js
 * @Description: Lightning Web Component to display and edit vehicle layout information.
 * @Author: Varun Kumar Sirisilla
 */

import { LightningElement, api, wire } from 'lwc';
import VEHICLE_LAYOUT_JSON_FIELD from "@salesforce/schema/CW_Vehicle_Layout__c.CW_Layout_JSON__c";
import TRIP_VEHICLE_LAYOUT_JSON_FIELD from "@salesforce/schema/CW_Trip__c.CW_Layout_JSON__c";
import { getRecord } from "lightning/uiRecordApi";
import { showToast } from 'c/cwUtils';

// Define constant fields for vehicle layout and trip
const VEHICLE_LAYOUT_FIELDS = [VEHICLE_LAYOUT_JSON_FIELD];
const TRIP_FIELDS = [TRIP_VEHICLE_LAYOUT_JSON_FIELD];
const VEHICLE_LAYOUT_OBJ_NAME = 'CW_Vehicle_Layout__c';

export default class CwVehicleLayoutBuilder extends LightningElement {
    @api recordId;
    @api objectApiName;

    // Variable to control the spinner visibility
    showSpinner = false;

    // Object to hold the layout structure
    layoutObj = {rows: []};

    // Wire method to fetch record data
    @wire(getRecord, {
        recordId: "$recordId",
        fields: "$fields"
    })
    wiredVehicleLayout({ error, data }) {
        // Handle error or retrieve data
        if (error) {
            this.handleError();
        } else if (data) {
            this.handleData(data);
        }
    }

    // Determine fields based on object type
    get fields() {
        return this.objectApiName == VEHICLE_LAYOUT_OBJ_NAME ? VEHICLE_LAYOUT_FIELDS : TRIP_FIELDS;
    }

    // Method to start the spinner
    startSpinner() {
        this.showSpinner = true;
    }

    // Method to stop the spinner
    stopSpinner() {
        this.showSpinner = false;
    }

    // Method to handle error
    handleError() {
        showToast(this, 'Error', 'Something went wrong. Please contact Admin', 'Error', '');
    }

    // Method to handle fetched data
    handleData(data) {
        const layoutJson = data.fields.CW_Layout_JSON__c.value;
        // Parse and assign layout JSON if present
        if (layoutJson) {
            this.layoutObj = JSON.parse(layoutJson);
        }
    }
}
import { LightningElement, wire, api } from 'lwc';
import ORIGIN_FIELD from "@salesforce/schema/CW_Route__c.CW_Origin__c";
import DESTINATION_FIELD from "@salesforce/schema/CW_Route__c.CW_Destination__c";
import { getRecord } from 'lightning/uiRecordApi';

const fields = [ORIGIN_FIELD, DESTINATION_FIELD];

export default class CwShowMap extends LightningElement {

    @api recordId;
    mapMarkers = [];
    @wire(getRecord, { recordId: '$recordId', fields: fields })
    wiredContact({ error, data }) {
        if (error) {
            console.log('Error Occered in @Wire-->' + error.body.message);
        } else if (data) {
            this.mapMarkers = [
                {
                    location: {
                        City: data.fields.CW_Origin__c.value,
                        Country: 'India',
                    },
                    title: 'Source'
                }, {
                    location: {
                        City: data.fields.CW_Destination__c.value,
                        Country: 'India',
                    },
                    title: 'Destination'
                }
            ];
        }
    }
}
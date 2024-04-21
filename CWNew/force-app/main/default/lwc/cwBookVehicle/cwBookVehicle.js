import { LightningElement } from 'lwc';
import getMatchingTrips from '@salesforce/apex/CW_BookVehicleController.getMatchingTrips';
import { showToast } from 'c/cwUtils';
export default class CwBookVehicle extends LightningElement {

    // Properties
    showSpinner = false;
    selectedTrip;
    layoutObj;
    passengerObjLst;
    reservationObj;
    currentStep = "1";
    steps = [{
        label: 'Select Origin And Destination',
        value: "1"
    }, {
        label: 'Select Seats',
        value: "2"
    }, {
        label: 'Enter Passenger Details',
        value: "3"
    }, {
        label: 'Booking Confirmation',
        value: "4"
    }]
    step = 1;
    showFirstPage = true;
    showSecondPage = false;
    showThirdPage = false;
    showFourthPage = false;
    trips;
    mapMarkers = [];

    //Get Trips
    onGetTrips() {
        try {
            this.trips = [];

            if (this.refs.CW_Destination__c.value == null || this.refs.CW_Destination__c.value == '' ||
                this.refs.CW_Origin__c.value == null || this.refs.CW_Origin__c.value == '' ||
                this.refs.travelDate.value == null || this.refs.travelDate.value == '') {
                showToast(this, 'Error', 'Please fill all required fields', 'Error', '');
                return;
            }

            if (this.refs.CW_Destination__c.value == this.refs.CW_Origin__c.value){
                showToast(this, 'Error', 'Origin and Destination cannot be same', 'Error', '');
                return;
            }

            this.startSpinner();

            getMatchingTrips({
                origin: this.refs.CW_Origin__c.value,
                destination: this.refs.CW_Destination__c.value,
                travelDate: this.refs.travelDate.value
            })
                .then(result => {
                    if (result && result.length > 0) {
                        this.trips = result;
                    } else {
                        showToast(this, 'Error', 'Trips Not available', 'Error', '');
                    }
                })
                .catch(error => {
                    showToast(this, 'Error', 'Something went wrong!', 'Error', '');
                    console.error(error);
                })
                .finally(() => {
                    // Stops the spinner regardless of the outcome
                    this.stopSpinner();
                });
        } catch (error) {
            showToast(this, 'Error', 'Something went wrong!', 'Error', '');
            console.error(error);
        }

    }

    // Handles booking a trip
    onBook(event) {
        var tripRec = event.target.value;
        this.selectedTrip = tripRec;
        this.layoutObj = JSON.parse(tripRec.CW_Layout_JSON__c);
        this.nextPage();
    }

    // Shows spinner
    startSpinner() {
        this.showSpinner = true;
    }

    // Hides spinner
    stopSpinner() {
        this.showSpinner = false;
    }

    // Moves to the next step
    nextPage() {
        if (this.step != 4) {
            this.step++;
        }
        this.handleSetUpSteps();
    }

    // Moves to the previous step
    previousPage() {
        if (this.step != 1) {
            this.step--;
        }
        this.handleSetUpSteps();
    }

    // Sets up steps based on current step
    handleSetUpSteps() {
        this.showFirstPage = this.step == 1;
        this.showSecondPage = this.step == 2;
        this.showThirdPage = this.step == 3;
        this.showFourthPage = this.step == 4;
        this.currentStep = "" + this.step;
    }

    // Handles next page event
    nextPageEvent(event) {
        this.passengerObjLst = event.detail.passengerObjList;
        this.reservationObj = event.detail.reservationObj;
        this.nextPage();
    }

}
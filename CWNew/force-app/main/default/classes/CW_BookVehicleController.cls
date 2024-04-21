/*
@Name : CW_BookVehicleController
@Author : Varun Kumar Sirisilla
@Description : Acts as controller class for Book vehicle LWC
*/ 
public with sharing class CW_BookVehicleController {
    
    /*
@Name : getMatchingTrips
@Author : Varun Kumar Sirisilla
@Description : This method get the trip records based on origin and destination and travel date
@params : String, String, Date
@return : List<CW_Trip__c>
*/ 
    @AuraEnabled
    public static List<CW_Trip__c> getMatchingTrips(String origin, String destination, Date travelDate) {
        return CW_SOQLHelper.getMatchingTrips(origin, destination, travelDate);
    }
    
    /*
@Name : bookSeats
@Author : Varun Kumar Sirisilla
@Description : Books seats for passengers.
@params : String, String
@return : String
*/ 
    @AuraEnabled
    public static String bookSeats(String passengerListStr, String reservationObjStr) {
        try {
            // Deserialize reservation object
            CW_Reservation__c reservation = (CW_Reservation__c) JSON.deserialize(reservationObjStr, CW_Reservation__c.class);
            Set<String> selectedSeatNoValues = new Set<String>(reservation.CW_Seat_Numbers__c.split(','));
            
            // Fetch existing trip record
            CW_Trip__c existingTripRec = CW_SOQLHelper.getExistingTripRec(reservation.CW_Trip__c);
            
            // Deserialize layout object
            Map<String, Object> layoutObj = (Map<String, Object>) JSON.deserializeUntyped(existingTripRec.CW_Layout_JSON__c);
            
            // Check for seat availability and book seats
            Boolean isSeatsAvailableForFuture = updateSeatsAvailability(layoutObj, selectedSeatNoValues);
            
            // Create a list to hold the reservation
            List<CW_Reservation__c> reservationList = new List<CW_Reservation__c>{reservation};
                // Insert reservation
                reservationList = CW_DMLHelper.performDML(reservationList, CW_DMLHelper.INSERT_DML, 'CW_Reservation__c');
            
            // Deserialize passenger list
            List<CW_Passenger__c> passengerList = (List<CW_Passenger__c>) JSON.deserialize(passengerListStr, List<CW_Passenger__c>.class);
            
            // Associate passengers with reservation
            for (CW_Passenger__c eachPassenger : passengerList) {
                eachPassenger.CW_Reservation__c = reservationList[0].Id;
            }
            
            // Insert passengers
            CW_DMLHelper.performDML(passengerList, CW_DMLHelper.INSERT_DML, 'CW_Passenger__c');
            
            // Update trip details
            CW_Trip__c trip = new CW_Trip__c();
            trip.Id = reservation.CW_Trip__c;
            trip.CW_Layout_JSON__c = JSON.serialize(layoutObj);
            trip.CW_Is_Seats_Available__c = isSeatsAvailableForFuture;
            CW_DMLHelper.performDML(new List<SObject>{trip}, CW_DMLHelper.UPDATE_DML, 'CW_Trip__c');
            
            return 'success';
        } catch (Exception e) {
            System.debug(e.getMessage() + e.getLinenumber());
            // Return error message and line number in case of exception
            return e.getMessage();
        }
    }
    
    /*
@Name : updateSeatsAvailability
@Author : Varun Kumar Sirisilla
@Description : Updates seat availability based on selected seats.
@params : Map<String, Object>, Set<String>
@return : Boolean
*/
    private static Boolean updateSeatsAvailability(Map<String, Object> layoutObj, Set<String> selectedSeatNoValues) {
        Boolean isSeatsAvailableForFuture = false;
        if (layoutObj.containsKey('rows') && layoutObj.get('rows') != null) {
            List<Object> rowList = (List<Object>) layoutObj.get('rows');
            for (Object row : rowList) {
                Map<String, Object> rowMap = (Map<String, Object>) row;
                if (rowMap.containsKey('seats') && rowMap.get('seats') != null) {
                    for (Object seat : (List<Object>) rowMap.get('seats')) {
                        Map<String, Object> seatMap = (Map<String, Object>) seat;
                        if (seatMap.containsKey('seatNoValue')) {
                            String seatNoValue = String.valueOf(seatMap.get('seatNoValue'));
                            Boolean isSeatAvailable = (Boolean) seatMap.get('isAvailable');
                            if (selectedSeatNoValues.contains(seatNoValue)) {
                                selectedSeatNoValues.remove(seatNoValue);
                                if (isSeatAvailable) {
                                    // Book the selected seat
                                    seatMap.put('isAvailable', false);
                                    seatMap.put('disabled', true);
                                    seatMap.put('class', 'seatButtonBookedStyle slds-button slds-button_neutral slds-button_stretch');
                                } else {
                                    // Throw an exception if the selected seat is not available
                                    throw new CW_Exception('Selected Seats Not Available for Booking');
                                }
                            }
                            // Check if any seats are available for future bookings
                            if ((Boolean) seatMap.get('isAvailable') && !isSeatsAvailableForFuture) {
                                isSeatsAvailableForFuture = true;
                            }
                        }
                    }
                }
            }
            // Throw an exception if any selected seat is not available
            if (!selectedSeatNoValues.isEmpty()) {
                throw new CW_Exception('Selected Seats Not Available for Booking');
            }
        }
        return isSeatsAvailableForFuture;
    }
    
    // Custom exception class
    public class CW_Exception extends Exception {}
}
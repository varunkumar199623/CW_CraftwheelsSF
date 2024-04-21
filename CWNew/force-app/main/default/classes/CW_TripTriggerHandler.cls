/*
@Name : CW_TripTriggerHandler
@Author : Varun Kumar Sirisilla
@Description : Trigger handler trip trigger
*/
public with sharing class CW_TripTriggerHandler {
    
    /**
     * Handles the before insert trigger for CW_Trip__c records.
     * Checks for trip overlaps and adds errors if any overlaps are found.
     * @param newTripRecs List of CW_Trip__c records to be inserted
     */
    public static void onBeforeInsert(List<CW_Trip__c> newTripRecs){
        // Call the method to check for trip overlaps
        checkForTripOverlap(newTripRecs);
    }
    
    /**
     * Handles the before update trigger for CW_Trip__c records.
     * Checks for trip overlaps and adds errors if any overlaps are found.
     * @param updatedTripRecs List of updated CW_Trip__c records
     */
    public static void onBeforeUpdate(List<CW_Trip__c> updatedTripRecs){
        // Call the method to check for trip overlaps
        checkForTripOverlap(updatedTripRecs);
    }
    
    /**
     * Checks for trip overlaps among the given list of CW_Trip__c records.
     * Adds errors to the new trip records if overlaps are found.
     * @param tripRecs List of CW_Trip__c records to check for overlaps
     */
    private static void checkForTripOverlap(List<CW_Trip__c> tripRecs){
        // Set to store unique route IDs
        Set<Id> routeIds = new Set<Id>();
        // Map to store vehicle ID and related trip records
        Map<Id,List<CW_Trip__c>> vehicleTripMap = new Map<Id,List<CW_Trip__c>>();
        // Map to store route ID and related vehicle ID
        Map<Id,Id> routeVehicleIdMap = new Map<Id,Id>();
        
        // Collect unique route IDs from the given trip records
        for(CW_Trip__c tripRec : tripRecs){
            routeIds.add(tripRec.CW_Route__c);
        }
        
        // Query route records to collect unique vehicle IDs
        for(CW_Route__c eachRoute : [SELECT Id,CW_Vehicle__c FROM CW_Route__c WHERE Id IN: routeIds]){
            routeVehicleIdMap.put(eachRoute.Id, eachRoute.CW_Vehicle__c);
        }
        
        // Query trip records related to the vehicles in the routes
        for(CW_Trip__c tripRec : [SELECT Id, Name,CW_Route__c, CW_Arrival__c, CW_Departure__c, CW_Route__r.CW_Vehicle__c  FROM CW_Trip__c WHERE CW_Route__r.CW_Vehicle__c IN: routeVehicleIdMap.values()]){
            if(vehicleTripMap.containsKey(tripRec.CW_Route__r.CW_Vehicle__c)){
                vehicleTripMap.get(tripRec.CW_Route__r.CW_Vehicle__c).add(tripRec);
            }else{
                vehicleTripMap.put(tripRec.CW_Route__r.CW_Vehicle__c, new List<CW_Trip__c>{tripRec});
            }
        }
        
        // Iterate over each new trip record to check for overlaps
        for(CW_Trip__c newTripRec : tripRecs){
            // Convert arrival and departure DateTime to target timezone
            Datetime newTripArrival = convertToOtherTimeZone(newTripRec.CW_Arrival__c,'GMT','IST');
            Datetime newTripDeparture = convertToOtherTimeZone(newTripRec.CW_Departure__c,'GMT','IST');
            // Check if vehicle and route mappings are null
            if(routeVehicleIdMap.get(newTripRec.CW_Route__c) == null || vehicleTripMap.get(routeVehicleIdMap.get(newTripRec.CW_Route__c)) == null){
                continue; // Skip further processing
            }
            // Get existing trips related to the vehicle
            List<CW_Trip__c> existingTrips = vehicleTripMap.get(routeVehicleIdMap.get(newTripRec.CW_Route__c));
            // Iterate over existing trips to check for overlaps
            for(CW_Trip__c existingTrip : existingTrips){
                // Skip checking against the same trip
                if(existingTrip.Id != newTripRec.Id){
                    // Convert existing trip arrival and departure DateTime to target timezone
                    Datetime existingTripArrival = convertToOtherTimeZone(existingTrip.CW_Arrival__c,'GMT','IST');
                    Datetime existingTripDeparture = convertToOtherTimeZone(existingTrip.CW_Departure__c,'GMT','IST');
                    
                    // Check for overlaps using various conditions
                    if ((newTripDeparture >= existingTripDeparture && newTripDeparture <= existingTripArrival) ||
                        (newTripArrival >= existingTripDeparture && newTripArrival <= existingTripArrival) ||
                        (existingTripDeparture >= newTripDeparture && existingTripDeparture <= newTripArrival) ||
                        (existingTripArrival >= newTripDeparture && existingTripArrival <= newTripArrival)) {
                            // Add error message if overlap found
                            newTripRec.addError('Trip overlaps with existing trip ' + existingTrip.Name +
                                                ' (Departure : ' + existingTripDeparture + ', Arrival : ' + existingTripArrival+')');
                            break; // Exit loop once overlap is found
                        }
                }
            }
        }
    }
    
    /**
     * Converts the given DateTime from source timezone to target timezone.
     * @param dttime DateTime to be converted
     * @param sourceTimezone Source timezone
     * @param targetTimezone Target timezone
     * @return Converted DateTime
     */
    public static DateTime convertToOtherTimeZone(DateTime dttime, String sourceTimezone, String targetTimezone) {
        // Get the source timezone offset
        TimeZone tz = Timezone.getTimeZone(sourceTimezone);
        Integer offset = tz.getOffset(dttime);
        
        // Get the target timezone offset
        TimeZone targetTZ = Timezone.getTimeZone(targetTimezone);
        Integer offsetTotargetTZ = targetTZ.getOffset(dttime);
        // Calculate the correction needed to adjust the DateTime
        Integer correction = offsetTotargetTZ - offset;
        
        // Add the correction to the DateTime to convert it to the target timezone
        DateTime targetDT = dttime.addMinutes(correction / (1000 * 60));
        
        return targetDT; // Return the converted DateTime
    }
}
/*
@Name : CW_SOQLHelper
@Author : Varun Kumar Sirisilla
@Description : All the SOQL queries are performed in this class
*/ 
public with sharing class CW_SOQLHelper {
    
    /*
@Name : getActiveRoutesQuery
@Author : Varun Kumar Sirisilla
@Description : This method will get all active routes record and passed to batch class
@return : String
*/ 
    public static String getActiveRoutesQuery() {
        return 'SELECT Id, CW_Vehicle__r.CW_Vehicle_Layout__r.CW_Layout_JSON__c, CW_Departure_Time__c, CW_Price__c, CW_Runs_On__c, CW_Trip_Duration__c ' +
            'FROM CW_Route__c ' +
            'WHERE CW_Is_Active__c = true WITH USER_MODE';
    }
    
    /*
@Name : getMatchingTrips
@Author : Varun Kumar Sirisilla
@Description : This method get the trip records based on origin and destination and travel date
@params : String, String, Date
@return : List<CW_Trip__c>
*/ 
    public static List<CW_Trip__c> getMatchingTrips(String origin, String destination, Date travelDate) {
        return [SELECT Id, CW_Layout_JSON__c, CW_Price__c, CW_Arrival__c, CW_Departure__c, 
                CW_Route__r.CW_Origin__c, CW_Route__r.CW_Destination__c  
                FROM CW_Trip__c 
                WHERE CW_Route__r.CW_Destination__c = :destination 
                AND CW_Route__r.CW_Origin__c = :origin 
                AND CW_Travel_Date__c = :travelDate 
                AND CW_Is_Active__c = TRUE 
                AND CW_Is_Seats_Available__c = TRUE 
                AND CW_Is_Booking_Closed__c  = FALSE 
                WITH USER_MODE];
    }
    
    /*
@Name : getExistingTripRec
@Author : Varun Kumar Sirisilla
@Description : This method get the trip records
@params : Id
@return : CW_Trip__c
*/ 
    public static CW_Trip__c getExistingTripRec(Id tripId) {
        return [SELECT Id, CW_Layout_JSON__c  
                FROM CW_Trip__c 
                WHERE Id = :tripId WITH USER_MODE];
    }
    
}
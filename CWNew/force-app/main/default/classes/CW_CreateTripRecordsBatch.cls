/*
@Name : CW_CreateTripRecordsBatch
@Author : Varun Kumar Sirisilla
@Description : Batch class which will create trip records on daily basis
*/ 
public with sharing class CW_CreateTripRecordsBatch implements Database.Batchable<sObject>, Schedulable  {
    
    private Map<String, CW_General_Setting__mdt> cwGeneralSettings = CW_General_Setting__mdt.getAll();
    
    /*
@Name : start
@Author : Varun Kumar Sirisilla
@Description : Start method-> returns active routes
*/ 
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(CW_SOQLHelper.getActiveRoutesQuery());
    }
    
    /*
@Name : execute
@Author : Varun Kumar Sirisilla
@Description : Includes trip record creation logic
*/ 
    public void execute(Database.BatchableContext BC, List<CW_Route__c> scope) {
        List<CW_Trip__c> tripInsertRecords = new List<CW_Trip__c>();
        
        for (CW_Route__c route : scope) {
            CW_Trip__c tripRec = new CW_Trip__c();
            
            populateArrAndDepDtTime(tripRec,route,Date.today().addDays(Integer.valueOf(cwGeneralSettings.get('CW_Booking_Opens_Before').CW_Value__c)));
            
            String dayOfWeek = tripRec.CW_Departure__c.format('EEEE');
            
            if (route.CW_Runs_On__c.contains(dayOfWeek)) {
                populateTripRecord(tripRec,route);
                tripInsertRecords.add(tripRec);
            }
        }
        Database.SaveResult[] saveResults = Database.insert(tripInsertRecords, false);
        //Logging errored record to log object will be covered in next phase
        for (Database.SaveResult saveResult : saveResults) {
            if (saveResult.isSuccess()) {
                System.debug('Record Succesffully created '+saveResult.getId());
            } else {
                // Record failed to insert/update
                for (Database.Error error : saveResult.getErrors()) {
                    System.debug('Record Failed'+error);
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        // Optional: Add any finish logic here
    }
    
    /*
@Name : execute
@Author : Varun Kumar Sirisilla
@Description : schedules CW_CreateTripRecordsBatch
*/ 
    public void execute(SchedulableContext sc) {
        CW_CreateTripRecordsBatch batchJob = new CW_CreateTripRecordsBatch(); 
        Database.executeBatch(batchJob,Integer.valueOf(cwGeneralSettings.get('CW_Trip_Creation_Batch_Size').CW_Value__c));            
    }
    
    /*
@Name : populateArrAndDepDtTime
@Author : Varun Kumar Sirisilla
@Description : calculate arrival and departure date time
*/ 
    public static void populateArrAndDepDtTime(CW_Trip__c tripRec,CW_Route__c route,Date travelDate){
        List<String> tripDurationFormat = route.CW_Trip_Duration__c.split(':');
        Datetime departureDateTime = Datetime.newInstance(
            travelDate,
            route.CW_Departure_Time__c
        );
        Datetime arrivalDateTime = departureDateTime.addHours(Integer.valueOf(tripDurationFormat[0]))
            .addMinutes(Integer.valueOf(tripDurationFormat[1]));
        tripRec.CW_Departure__c = departureDateTime;
        tripRec.CW_Arrival__c = arrivalDateTime;
    }
    
    /*
@Name : createTrip
@Author : Varun Kumar Sirisilla
@Description : calls from screen flow to create trip record
*/ 
    @InvocableMethod
    public static List<FlowOutputs> createTrip(List<FlowInputs> inputList){
        List<FlowOutputs> flowOutputLst = new List<FlowOutputs>();
        FlowOutputs flowOutput = new FlowOutputs();
        try{
            FlowInputs input = inputList[0];
            CW_Route__c route = input.route;
            CW_Trip__c tripRec = new CW_Trip__c();
            populateTripRecord(tripRec,route);
            populateArrAndDepDtTime(tripRec,route,input.travelDate);
            tripRec.CW_Layout_JSON__c = input.layoutJSON;
            insert tripRec;
            flowOutput.result = 'Trip Record Created Successfully!';
            flowOutputLst.add(flowOutput);
            return flowOutputLst;
        }catch(Exception e){
            flowOutput.result = e.getMessage();
            flowOutputLst.add(flowOutput);
            return flowOutputLst;
        }
    }
    
    /**
* Inner class to represent the output of the invocable method.
*/
    public class FlowOutputs{
        @InvocableVariable(required = true)
        public String result;
    }
    
    /**
* Inner class to represent the input variables for the invocable method.
*/
    public class FlowInputs {
        @InvocableVariable(required = true)
        public CW_Route__c route;
        
        @InvocableVariable(required = true)
        public Date travelDate;
        
        @InvocableVariable(required = true)
        public String layoutJSON;
        
    }
    
    /**
* Populates trip record fields based on the provided route information.
* 
* @param tripRec The trip record to populate.
* @param route The route information to use for populating the trip record.
*/
    private static void populateTripRecord(CW_Trip__c tripRec,CW_Route__c route){
        tripRec.CW_Route__c = route.Id;
        tripRec.CW_Is_Active__c = TRUE;
        tripRec.CW_Is_Seats_Available__c = TRUE;
        tripRec.CW_Price__c  = route.CW_Price__c;
        tripRec.CW_Layout_JSON__c  = route.CW_Vehicle__r.CW_Vehicle_Layout__r.CW_Layout_JSON__c;
    }
    
}
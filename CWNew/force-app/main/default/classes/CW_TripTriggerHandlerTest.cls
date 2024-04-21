/*
@Name : CW_TripTriggerHandlerTest
@Author : Varun Kumar Sirisilla
@Description : test class for CW_TripTriggerHandler
*/
@isTest
private class CW_TripTriggerHandlerTest {
    
    /**
     * Test method to validate trip overlap detection.
     */
    @isTest
    static void testTripOverlapDetection() {
        // Create test vehicle layout
        CW_Vehicle_Layout__c layout = new CW_Vehicle_Layout__c();
        layout.Name = 'Test Layout';
        layout.CW_Layout_JSON__c  = '{"rows":[{"rowNo":1,"seats":[{"seatNoLabel":"A","seatNoValue":"1-A","isSelected":false,"isAvailable":true,"class":"seatButtonAvailableStyle slds-button slds-button_neutral slds-button_stretch"},{"seatNoLabel":"B","seatNoValue":"1-B","isSelected":false,"isAvailable":true,"class":"seatButtonAvailableStyle slds-button slds-button_neutral slds-button_stretch"}]}]}';
        insert layout;
        
        // Create test vehicle
        CW_Vehicle__c testVehicle = new CW_Vehicle__c();
        testVehicle.CW_Vehicle_Layout__c  = layout.Id;
        testVehicle.CW_Maker__c = 'Tata Motors';
        testVehicle.CW_Vehicle_Type__c = 'Bus';
        insert testVehicle;
        
        // Create test routes
        CW_Route__c route = new CW_Route__c();
        route.CW_Origin__c = 'Hyderabad';
        route.CW_Destination__c = 'Chennai';
        route.CW_Price__c = 1000;
        route.CW_Is_Active__c = TRUE;
        route.CW_Departure_Time__c = Time.newInstance(14, 30, 0, 0);
        route.CW_Trip_Duration__c = '12:40';
        route.CW_Vehicle__c = testVehicle.Id;
        route.CW_Runs_On__c = 'Sunday;Tuesday;Wednesday;Thursday;Friday;Saturday';
        insert route;
        
        CW_Route__c route1 = new CW_Route__c();
        route1.CW_Origin__c = 'Hyderabad';
        route1.CW_Destination__c = 'Cochin';
        route1.CW_Price__c = 1000;
        route1.CW_Is_Active__c = TRUE;
        route1.CW_Departure_Time__c = Time.newInstance(14, 30, 0, 0);
        route1.CW_Trip_Duration__c = '12:40';
        route1.CW_Vehicle__c = testVehicle.Id;
        route1.CW_Runs_On__c = 'Sunday;Tuesday;Wednesday;Thursday;Friday;Saturday';
        insert route1;
        
        // Retrieve inserted route records
        CW_Route__c routeRecord = [SELECT Id, 
                                   CW_Vehicle__r.CW_Vehicle_Layout__r.CW_Layout_JSON__c, 
                                   CW_Departure_Time__c, 
                                   CW_Price__c, 
                                   CW_Runs_On__c, 
                                   CW_Trip_Duration__c FROM CW_Route__c WHERE Id =: route.Id];
        
        CW_Route__c routeRecord1 = [SELECT Id, 
                                    CW_Vehicle__r.CW_Vehicle_Layout__r.CW_Layout_JSON__c, 
                                    CW_Departure_Time__c, 
                                    CW_Price__c, 
                                    CW_Runs_On__c, 
                                    CW_Trip_Duration__c FROM CW_Route__c WHERE Id =: route1.Id];
        
        // Create flow inputs for trip creation
        List<CW_CreateTripRecordsBatch.FlowOutputs> flowOutputs = new List<CW_CreateTripRecordsBatch.FlowOutputs>();
        CW_CreateTripRecordsBatch.FlowInputs input = new CW_CreateTripRecordsBatch.FlowInputs();
        
        // Test trip creation for the first route
        input.route = routeRecord;
        input.travelDate = Date.today().addDays(49);
        input.layoutJSON = routeRecord.CW_Vehicle__r.CW_Vehicle_Layout__r.CW_Layout_JSON__c;
        flowOutputs = CW_CreateTripRecordsBatch.createTrip(new List<CW_CreateTripRecordsBatch.FlowInputs>{input});
        // Assert that the trip creation is successful
        System.assertEquals('Trip Record Created Successfully!', flowOutputs[0].result);
        
        // Test trip creation for the second route
        input.route = routeRecord1;
        input.travelDate = Date.today().addDays(49);
        input.layoutJSON = routeRecord1.CW_Vehicle__r.CW_Vehicle_Layout__r.CW_Layout_JSON__c;
        flowOutputs = CW_CreateTripRecordsBatch.createTrip(new List<CW_CreateTripRecordsBatch.FlowInputs>{input});
        // Assert that the trip creation is unsuccessful due to trip overlap
        System.assertEquals(true, flowOutputs[0].result != 'Trip Record Created Successfully!');
    }
}
/*
@Name : CW_BookVehicleControllerTest
@Author : Varun Kumar Sirisilla
@Description : test class for CW_BookVehicleController
*/
@isTest
public class CW_BookVehicleControllerTest {
    
    /*
@Name : createTestData
@Author : Varun Kumar Sirisilla
@Description : Creates test data
*/
    @TestSetup static void createTestData() {
        CW_Vehicle_Layout__c layout = new CW_Vehicle_Layout__c();
        layout.Name = 'Test Layout';
        layout.CW_Layout_JSON__c  = '{"rows":[{"rowNo":1,"seats":[{"seatNoLabel":"A","seatNoValue":"1-A","isSelected":false,"isAvailable":true,"class":"seatButtonAvailableStyle slds-button slds-button_neutral slds-button_stretch"},{"seatNoLabel":"B","seatNoValue":"1-B","isSelected":false,"isAvailable":true,"class":"seatButtonAvailableStyle slds-button slds-button_neutral slds-button_stretch"}]}]}';
        insert layout;
        
        CW_Vehicle__c testVehicle = new CW_Vehicle__c();
        testVehicle.CW_Vehicle_Layout__c  = layout.Id;
        testVehicle.CW_Maker__c = 'Tata Motors';
        testVehicle.CW_Vehicle_Type__c = 'Bus';
        insert testVehicle;
        
        CW_Route__c route = new CW_Route__c();
        route.CW_Origin__c = 'Hyderabad';
        route.CW_Destination__c = 'Chennai';
        route.CW_Price__c = 1000;
        route.CW_Is_Active__c = TRUE;
        route.CW_Departure_Time__c = Time.newInstance(14, 30, 0, 0);
        route.CW_Trip_Duration__c = '12:40';
        route.CW_Vehicle__c = testVehicle.Id;
        route.CW_Runs_On__c = 'Sunday;Monday;Tuesday;Wednesday;Thursday;Friday;Saturday';
        insert route;
        
        CW_Route__c route1 = new CW_Route__c();
        route1.CW_Origin__c = 'Hyderabad';
        route1.CW_Destination__c = 'Cochin';
        route1.CW_Price__c = 1000;
        route1.CW_Is_Active__c = TRUE;
        route1.CW_Departure_Time__c = Time.newInstance(14, 30, 0, 0);
        route1.CW_Trip_Duration__c = '12:40';
        route1.CW_Vehicle__c = testVehicle.Id;
        route1.CW_Runs_On__c = 'Sunday;Monday;Tuesday;Wednesday;Thursday;Friday;Saturday';
        insert route1;
        
        CW_Route__c routeRecord = [SELECT Id, 
                                   CW_Vehicle__r.CW_Vehicle_Layout__r.CW_Layout_JSON__c, 
                                   CW_Departure_Time__c, 
                                   CW_Price__c, 
                                   CW_Runs_On__c, 
                                   CW_Trip_Duration__c FROM CW_Route__c WHERE Id =: route.Id];
        
        CW_CreateTripRecordsBatch.FlowInputs input = new CW_CreateTripRecordsBatch.FlowInputs();
        input.route = routeRecord;
        input.travelDate = Date.today().addDays(49);
        input.layoutJSON = routeRecord.CW_Vehicle__r.CW_Vehicle_Layout__r.CW_Layout_JSON__c;
        CW_CreateTripRecordsBatch.createTrip(new List<CW_CreateTripRecordsBatch.FlowInputs>{input});
    }
    
    /*
@Name : testCreateTripsBatch
@Author : Varun Kumar Sirisilla
@Description : tests CreateTripsBatch class
*/
    @isTest
    static void testCreateTripsBatch(){
        Test.startTest();
        String cronExp = '0 0 0 * * ?'; // Example: Daily at midnight
        String jobId = System.schedule('TESTING_CW_Create_Trips_Batch',cronExp, new CW_CreateTripRecordsBatch());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronExp,ct.CronExpression);
        Test.stopTest();
    }
    
    /*
@Name : testGetMatchingTrips
@Author : Varun Kumar Sirisilla
@Description : this will get test GetMatchingTrips methods
*/
    @isTest
    static void testGetMatchingTrips(){
        List<CW_Trip__c> tripRecords = CW_BookVehicleController.getMatchingTrips('Hyderabad','Chennai',Date.today().addDays(49));
        System.assertEquals(TRUE,tripRecords.size() > 0);
    }
    
    /*
@Name : testBookSeats
@Author : Varun Kumar Sirisilla
@Description : this will get test BookSeats method
*/
    @isTest
    static void testBookSeats(){
        CW_Reservation__c reservation = new CW_Reservation__c();
        reservation.CW_Address__c = 'Test';
        reservation.CW_Seat_Numbers__c = '1-A';
        reservation.CW_Total_Amount__c = 1000;
        reservation.CW_Phone__c = '1323232323';
        reservation.CW_Trip__c = [SELECT Id FROM CW_Trip__c LIMIT 1].Id;
        CW_Passenger__c passenger = new CW_Passenger__c();
        passenger.Name = 'Test';
        passenger.CW_Gender__c = 'Male';
        passenger.CW_Age__c = 28;
        passenger.CW_Seat_Number__c = '1-A';
        String resultPos = CW_BookVehicleController.bookSeats(JSON.serialize(new List<CW_Passenger__c>{passenger}),JSON.serialize(reservation));
        System.assertEquals(TRUE,resultPos == 'success');
        
        String resultNeg = CW_BookVehicleController.bookSeats(JSON.serialize(new List<CW_Passenger__c>{passenger}),JSON.serialize(reservation));
        System.assertEquals(TRUE,resultNeg == 'Selected Seats Not Available for Booking');
    }
}
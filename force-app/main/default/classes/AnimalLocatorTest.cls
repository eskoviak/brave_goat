@isTest
public with sharing class AnimalLocatorTest {

    //@isTest static void testGetCallout() {
    //    String  response = AnimalLocator.getAnimalNameById(1);
   // }

    @isTest static void testGetCalloutMock() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        //String response = AnimalLocator.getAnimalNameById(1);
        //System.assertEquals(response, 'ima string');
    }
}

@isTest
public with sharing class AnimalLocatorTest {

    @isTest static void testGetCalloutMock() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String name = AnimalLocator.getAnimalNameById(1);
        System.assertEquals(name, 'chicken');
    }
}
@isTest
private class ParkLocatorTest {
    @isTest static void testCallout(){
        Test.setMock(WebServiceMock.class, new ParkServiceMock());
        String[] parks = ParkLocator.country('Germany');
        System.assertEquals(1, parks.size());

    }
}
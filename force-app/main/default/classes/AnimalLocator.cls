public with sharing class AnimalLocator {
    public static String getAnimalNameById(Integer animalId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String rv = '';
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals/' + animalId);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			//System.debug(results);
            Object animal = results.get('animal');
            //system.debug(animal);
            Map<String, Object> facts = (Map<String, Object>) animal;
            //system.debug(facts.get('name'));
            rv=(String) facts.get('name');
        }
   
        return rv;
    }
}
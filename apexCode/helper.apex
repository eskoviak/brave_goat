/* String parentId = '0011U00001E8vYHQAZ';
Account result = [SELECT Id, Name, (SELECT Id, Name FROM Contacts WHERE AccountId = :parentId) FROM Account WHERE Id = :parentId];

System.debug(result); */
/* 
String personKey = '164328845';
String rv = '';
String APIMurl = 'https://apis.tst.redwingshoes.com/masterdata/v1;rev=2';
Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint(APIMUrl + '/semarchy/api/rest/query/RWS_MDM_PRD/Person/GD/' + personKey);
request.setMethod('GET');
request.setHeader('Ocp-Apim-Subscription-Key','b21905a5b23f40d88bacbcd01b51fe2e');
HttpResponse response = http.send(request);
if (response.getStatusCode() == 200) {
    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
    System.debug(m.get('EnrichedPrimaryEmail'));
} else {
    rv = '{ "error" : "' + response.getStatus() + '" }';
}

//System.debug(rv);
*/
/* 
String jsonInput = '{' +
    '"records": [' +
    '    {' +
    '        "PersonKey": 163964654,' +
    '        "SourceSystem": "XCENTER",' +
    '        "FirstName": "John",' +
    '        "LastName": "Green",' +
    '        "MelissaPersonatorAddress.FormattedAddress" : "300 Red Wing Ave S, 210, Red Wing, MN, 55066"' +
    '   },' +
    '   {' +
    '        "PersonKey": 163964656,' +
    '        "SourceSystem": "XCENTER",' +
    '        "FirstName": "John",' +
    '        "LastName": "White"' +
    '   }' +
    ']' +
'}';

 */
/* Map<String, Object> records = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
//List<Map<String, String>> persons = (List<Map<String, String>>) records.get('records');
List<Object> persons = (List<Object>) records.get('records');
//Map<String, Object> persons = (Map<String, Object>) JSON.deserializeUntyped(records);
for( Object p : persons ) {
    System.debug(p);
}
 */

/* 
XDMPerson persons = XDMPerson.parse(jsonInput);
for( XDMPerson.Person person : persons.records ) {

    Map<String, 
//System.debug(person.MPA_FormattedAddress);
}
 */

String JSONContent =
    '{"isActive":true}';
JSONParser parser = 
   JSON.createParser(JSONContent);
// Advance to the start object marker.
parser.nextToken();
// Advance to the next value.
parser.nextValue();
String fieldName = parser.getCurrentName();
// Get the Boolean value.
Boolean isActive = parser.getBooleanValue();
System.debug( fieldName+'='+isActive);

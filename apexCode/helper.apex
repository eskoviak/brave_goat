/* String parentId = '0011U00001E8vYHQAZ';
Account result = [SELECT Id, Name, (SELECT Id, Name FROM Contacts WHERE AccountId = :parentId) FROM Account WHERE Id = :parentId];

System.debug(result); */

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
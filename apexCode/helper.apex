/* // Create a list
List<Integer> ls1 = new List<Integer>();
// Add two integers to the list
ls1.add(1);
ls1.add(2);
System.debug(ls1);
 */

/* List<String> ls2 = new List<String>();
ls2.add('Dumpy');
ls2.add('Ass');
System.debug(String.valueOf(ls2));
System.debug(ls2.toString()); */
/* 
String input = '80559000008105_1';
String output = 'C' + input.replace('_1', '').leftPad(13, '0');
System.debug(input);
System.debug(output);


List<PersonSales__x> sales = [SELECT ExternalId, xactDate__c, item__c FROM PersonSales__x WHERE ExternalID = '170587144' ];
System.debug(sales);

 */

List<Map<String, String>> records = new List<Map<String, String>>();
Map<String, String> key = new Map<String, String>();
key.put('PublisherID', 'XCENTER');
key.put('SourceID', 'C'+ ('80136008565663_1').replace('_1', '').leftPad(14, '0') );
records.add(key.clone());
key.clear();
key.put('PublisherID', 'XCENTER');
key.put('SourceID', 'C' + ('236008565663_1').replace('_1', '').leftPad(14, '0') );
records.add(key.clone());
Map<String, Object> wrapper = new Map<String, Object>();
wrapper.put('records', records);
String strJson = JSON.serialize(wrapper);
System.debug(strJson);
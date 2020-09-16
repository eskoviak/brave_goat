/* List<List<sObject>> searchList = [FIND 'Flum' IN ALL FIELDS RETURNING Account(Name)];
Account[] searchAccts = (Account[]) searchList[0];
System.debug('Found the following Accts:');
for (Account a : searchAccts) {
    System.debug(a.name);
} */

/* List<List<sObject>> searchList = [FIND '5027090451' IN ALL FIELDS Returning Person__x];

Person__x[] searchPers = (Person__x[]) searchlist[0];

for (Person__x p : searchPers) {
    System.debug(p.ExternalId);
} */

String phrase = 'Ludwig Beethoven Bonn';
List<String> tokens = phrase.normalizeSpace().replace('\\s', '|').split('|');
for(String token : tokens) {

    System.debug('Token: ' + token.length());
}
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

String phrase = '"Ludwig Beethoven" "Symph No. 5" Bonn DE';
phrase = phrase.normalizeSpace();
System.debug('String to parse: ' + phrase);
List<String> tokens = new List<String>();
//String token;
Integer testChar;
Integer startToken = 0;
Boolean quoteOn = false;
Boolean tokenOn = false;
for(Integer i = 0; i< phrase.length(); i++){
    testChar = phrase.charAt(i);
    if ((testChar == 34)  && !quoteOn) {
        quoteOn = true;
        startToken = i+1;
        tokenOn = true;
        continue;
    }

    if ((testChar == 34) && quoteOn) {
        quoteOn = false;
        tokenOn = false;
        tokens.add(phrase.substring(startToken, i));
        continue;
    }

    if (testChar == 32 && quoteOn) {
        continue;
    }

    if (testChar == 32 && tokenOn) {
        tokenOn = false;
        tokens.add(phrase.substring(startToken, i));
        continue;
    }

    if (tokenOn) {
        continue;
    }

    if (!tokenOn) {
        tokenOn = true;
        startToken = i;
        continue;
    }
}
if(tokenOn) {
    tokens.add(phrase.substring(startToken));
}
System.debug(tokens);
String parentId = '0011U00001E8vYHQAZ';
Account result = [SELECT Id, Name, (SELECT Id, Name FROM Contacts WHERE AccountId = :parentId) FROM Account WHERE Id = :parentId];

System.debug(result);
@isTest
public with sharing class XDMConnectionTest {

    @isTest static void testSync() {
        DataSource.ConnectionParams params = new DataSource.ConnectionParams();
        DataSource.Provider provider = new XDMProvider();
        DataSource.Connection connection = provider.getConnection(params);        

        List<DataSource.Table> tables = connection.sync();
        System.assertEquals(1, tables.size());
        System.assertEquals('Person', tables[0].name);
    }

    @isTest static void testQuery() {
        DataSource.ConnectionParams params = new DataSource.ConnectionParams();
        DataSource.Provider provider = new XDMProvider();
        DataSource.Connection connection = provider.getConnection(params);
        DataSource.QueryContext context = new DataSource.QueryContext();
        context.tableSelection = new DataSource.TableSelection();

        // SELECT ExternalId, FullPersonName
        List<DataSource.ColumnSelection> columns = new List<DataSource.ColumnSelection>();
        DataSource.ColumnSelection colExternalId = new DataSource.ColumnSelection();
        colExternalId.columnName = 'ExternalId';
        columns.add(colExternalId);
        DataSource.ColumnSelection colFullPersonName = new DataSource.ColumnSelection();
        colFullPersonName.columnName = 'FullPersonName';
        columns.add(colFullPersonName);
        context.tableSelection.columnsSelected = columns;
        
        // FROM Person
        context.tableSelection.tableSelected = 'Person';

        // WHERE ExternalId = '17700326' (This is pro-forma only--the callout is mocked and will
        //                                return two abbreviated rows)
        context.tableSelection.filter = new DataSource.Filter();
        context.tableSelection.filter.columnName = 'ExternalId';
        context.tableSelection.filter.columnValue = '17700326';  // Herr Beethoven
        DataSource.TableResult results = connection.query(context);
        System.assertEquals(2, results.rows.size());
    }
}

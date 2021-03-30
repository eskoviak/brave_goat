@isTest
public with sharing class XDMConnectionTest {

    public static DataSource.ConnectionParams params = new DataSource.ConnectionParams();
    public static DataSource.Provider provider = new XDMProvider();
    public static DataSource.Connection connection = provider.getConnection(params);

    @TestSetup
    static void setup(){ }

    @isTest static void testSync() {
        List<DataSource.Table> tables = connection.sync();
        System.assertEquals(2, tables.size());
        //System.assert(tables.contains('Person'));
        //System.assert(tables.contains('PersonSales'));
    }

    @isTest static void testQueryPerson() {
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

    @isTest static void testQueryPersonSales() {
        DataSource.QueryContext context = new DataSource.QueryContext();
        context.tableSelection = new DataSource.TableSelection();

        // SELECT ExternalId, xactDate
        List<DataSource.ColumnSelection> columns = new List<DataSource.ColumnSelection>();
        DataSource.ColumnSelection colExternalId = new DataSource.ColumnSelection();
        colExternalId.columnName = 'ExternalId';
        columns.add(colExternalId);
        DataSource.ColumnSelection colxactDate = new DataSource.ColumnSelection();
        colxactDate.columnName = 'xactDate';
        columns.add(colxactDate);
        context.tableSelection.columnsSelected = columns;

        // FROM PersonSales
        context.tableSelection.tableSelected = 'PersonSales';        

        // WHERE ExternalId = '17700326' (This is pro-forma only--the callout is mocked and will
        //                                return two abbreviated rows)
        context.tableSelection.filter = new DataSource.Filter();
        context.tableSelection.filter.columnName = 'ExternalId';
        context.tableSelection.filter.columnValue = '17700326';  // Herr Beethoven
        DataSource.TableResult results = connection.query(context);
        System.assertEquals(2, results.rows.size());

    }

    @isTest static void testSearch() {
        DataSource.SearchContext context = new DataSource.SearchContext();
        context.tableSelections = new List<DataSource.TableSelection>();

        // Find <phrase> (This is pro-forma only--the callout is mocked and will
        //                return two abbreviated rows)
        context.searchPhrase='8885551212';

        // IN ALL ROWS assumed

        // RETURNING ( Person() )
        DataSource.TableSelection selection = new DataSource.TableSelection();
        selection.tableSelected = 'Person';
        context.tableSelections.add(selection);


        List<DataSource.TableResult> results = connection.search(context);
        System.assertEquals(1, results.size());
    }
}

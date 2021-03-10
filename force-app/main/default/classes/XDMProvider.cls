global with sharing class XDMProvider
    extends DataSource.Provider  {
    
    public XDMProvider() {}

    override global List<DataSource.AuthenticationCapability> getAuthenticationCapabilities() {
        List<DataSource.AuthenticationCapability> capabilities = new List<DataSource.AuthenticationCapability>();
        capabilities.add(DataSource.AuthenticationCapability.ANONYMOUS);
        return capabilities;
    }

    override global List<DataSource.Capability> getCapabilities() {
        List<DataSource.Capability> capabilities = new List<DataSource.Capability>();
        capabilities.add(DataSource.Capability.ROW_QUERY);
        capabilities.add(DataSource.Capability.SEARCH);
        return capabilities;
    }

    override global DataSource.Connection getConnection(DataSource.ConnectionParams connectionParams) {
        connectionParams.endpoint = 'https://apis.tst.redwingshoes.com';
        connectionParams.oauthToken = 'b21905a5b23f40d88bacbcd01b51fe2e';
        //connectionParams.repository = 'RWS_MDM_PRD';
        return new XDMConnection(connectionParams);
    }
}
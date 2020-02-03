public class ParkLocator {
    public static string[] country(String country) {
        ParkService.ParksImplPort ps = new ParkService.ParksImplPort();
        return ps.byCountry(country);
    } 
}

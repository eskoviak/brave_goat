public class StringArrayTest {

    public static List<String> generateStringArray(Integer length){
        List<String> rv = new String[] {};
            String tmp = 'Test ';
            for(Integer i=0;i<length;i++){
                rv.add(tmp+i);
            }
        return rv;
    }
}
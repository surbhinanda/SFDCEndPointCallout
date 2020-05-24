public class TransactionItemWrapper {

    public Keys keys;
    public Values values;

    public class Keys {
        public String TransactionItemID;
    }

    public class Values {
        public String ItemCost;
        public String ItemName;
    }

    
    public static List<TransactionItemWrapper> parse(String json) {
        return (List<TransactionItemWrapper>) System.JSON.deserialize(json, List<TransactionItemWrapper>.class);
    }
}
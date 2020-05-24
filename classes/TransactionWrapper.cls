public class TransactionWrapper{

    public Keys keys;
    public Values values;

    public class Keys {
        public String TransactionID;
    }

    public class Values {
        public String TotalCost;
        public String TotalDiscount;
        public String TransactionDate;
        public String TotalCount;
    }

    
    public static List<TransactionWrapper> parse(String json) {
        return (List<TransactionWrapper>) System.JSON.deserialize(json, List<TransactionWrapper>.class);
    }
}
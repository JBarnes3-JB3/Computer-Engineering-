import HelloApp.*;
import org.omg.CosNaming.*;
import org.omg.CosNaming.NamingContextPackage.*;
import org.omg.CORBA.*;
import org.omg.PortableServer.*;
import org.omg.PortableServer.POA;

import java.util.HashMap;

class HelloImpl extends HelloPOA {

  private ORB orb;
  private HashMap<String, Order> orders = new HashMap<>();

  public void setORB(ORB orb_val) {
    orb = orb_val;
  }

  // View Menu
  public String viewMenu() {
    return "Menu:\nFried Chicken: $5\nCola: $1";
  }

  // Place Order
  public String placeOrder(String username, int chickenQty, int colaQty)
      throws InvalidOrder {

    if (chickenQty < 0 || colaQty < 0) {
      throw new InvalidOrder("Quantity cannot be negative");
    }

    int total = chickenQty * 5 + colaQty;

    Order order = new Order(username, chickenQty, colaQty, total);
    orders.put(username, order);

    return "Order received!";
  }

  // Check Order Status
  public Order checkOrderStatus(String username)
      throws OrderNotFound {

    if (!orders.containsKey(username)) {
      throw new OrderNotFound("No order found for user");
    }

    return orders.get(username);
  }

  // Manager View All Orders
  public Order[] viewAllOrders() {
    return orders.values().toArray(new Order[0]);
  }
}

public class HelloServer {

  public static void main(String args[]) {
    try {
      ORB orb = ORB.init(args, null);

      POA rootpoa = POAHelper.narrow(orb.resolve_initial_references("RootPOA"));
      rootpoa.the_POAManager().activate();

      HelloImpl helloImpl = new HelloImpl();
      helloImpl.setORB(orb);

      org.omg.CORBA.Object ref = rootpoa.servant_to_reference(helloImpl);
      Hello href = HelloHelper.narrow(ref);

      org.omg.CORBA.Object objRef =
          orb.resolve_initial_references("NameService");
      NamingContextExt ncRef = NamingContextExtHelper.narrow(objRef);

      String name = "Hello";
      NameComponent path[] = ncRef.to_name(name);
      ncRef.rebind(path, href);

      System.out.println("Server ready and waiting...");

      orb.run();

    } catch (Exception e) {
      System.err.println("ERROR: " + e);
      e.printStackTrace(System.out);
    }

    System.out.println("Server Exiting...");
  }
}

import HelloApp.*;
import org.omg.CosNaming.*;
import org.omg.CORBA.*;

import java.util.Scanner;

public class HelloClient {

  static Hello helloImpl;

  public static void main(String args[]) {
    try {
      ORB orb = ORB.init(args, null);

      org.omg.CORBA.Object objRef =
          orb.resolve_initial_references("NameService");
      NamingContextExt ncRef = NamingContextExtHelper.narrow(objRef);

      helloImpl = HelloHelper.narrow(ncRef.resolve_str("Hello"));

      Scanner sc = new Scanner(System.in);

      while (true) {
        System.out.println("\n==== MENU ====");
        System.out.println("1. View Menu");
        System.out.println("2. Place Order");
        System.out.println("3. Check Order Status");
        System.out.println("4. Manager View All Orders");
        System.out.println("5. Run Performance Test");
        System.out.println("6. Exit");
        System.out.print("Choice: ");

        int choice = sc.nextInt();
        sc.nextLine(); // consume newline

        switch (choice) {

          case 1:
            long start1 = System.nanoTime();
            System.out.println(helloImpl.viewMenu());
            long end1 = System.nanoTime();
            System.out.println("Time: " + (end1 - start1) + " ns");
            break;

          case 2:
            System.out.print("Enter username: ");
            String user = sc.nextLine();

            System.out.print("Chicken quantity: ");
            int chicken = sc.nextInt();

            System.out.print("Cola quantity: ");
            int cola = sc.nextInt();
            sc.nextLine();

            try {
              long start2 = System.nanoTime();
              String result = helloImpl.placeOrder(user, chicken, cola);
              long end2 = System.nanoTime();

              System.out.println(result);
              System.out.println("Time: " + (end2 - start2) + " ns");

            } catch (InvalidOrder e) {
              System.out.println("Error: " + e.message);
            }
            break;

          case 3:
            System.out.print("Enter username: ");
            String checkUser = sc.nextLine();

            try {
              long start3 = System.nanoTime();
              Order o = helloImpl.checkOrderStatus(checkUser);
              long end3 = System.nanoTime();

              System.out.println("\nOrder Details:");
              System.out.println("User: " + o.username);
              System.out.println("Chicken: " + o.chickenQty);
              System.out.println("Cola: " + o.colaQty);
              System.out.println("Total: $" + o.totalPrice);

              System.out.println("Time: " + (end3 - start3) + " ns");

            } catch (OrderNotFound e) {
              System.out.println("Error: " + e.message);
            }
            break;

          case 4:
            long start4 = System.nanoTime();
            Order[] orders = helloImpl.viewAllOrders();
            long end4 = System.nanoTime();

            System.out.println("\nAll Orders:");
            for (Order o : orders) {
              System.out.println("------------------");
              System.out.println("User: " + o.username);
              System.out.println("Chicken: " + o.chickenQty);
              System.out.println("Cola: " + o.colaQty);
              System.out.println("Total: $" + o.totalPrice);
            }

            System.out.println("Time: " + (end4 - start4) + " ns");
            break;

          case 5:
            runMeasurements();
            break;

          case 6:
            System.out.println("Exiting...");
            System.exit(0);

          default:
            System.out.println("Invalid choice.");
        }
      }

    } catch (Exception e) {
      System.out.println("ERROR: " + e);
      e.printStackTrace(System.out);
    }
  }

  // ===============================
  // PERFORMANCE TEST FUNCTION
  // ===============================
  public static void runMeasurements() {

    int runs = 10;

    try {
      long totalViewMenu = 0;
      long totalPlaceOrder = 0;
      long totalCheckOrder = 0;
      long totalViewAll = 0;

      // preload one order
      helloImpl.placeOrder("testUser", 2, 3);

      for (int i = 0; i < runs; i++) {

        long start, end;

        // viewMenu
        start = System.nanoTime();
        helloImpl.viewMenu();
        end = System.nanoTime();
        totalViewMenu += (end - start);

        // placeOrder
        start = System.nanoTime();
        helloImpl.placeOrder("user" + i, 1, 1);
        end = System.nanoTime();
        totalPlaceOrder += (end - start);

        // checkOrderStatus
        start = System.nanoTime();
        helloImpl.checkOrderStatus("testUser");
        end = System.nanoTime();
        totalCheckOrder += (end - start);

        // viewAllOrders
        start = System.nanoTime();
        helloImpl.viewAllOrders();
        end = System.nanoTime();
        totalViewAll += (end - start);
      }

      System.out.println("\n===== PERFORMANCE RESULTS =====");
      System.out.println("Runs per test: " + runs);

      System.out.println("viewMenu Avg Time: " + (totalViewMenu / runs) + " ns");
      System.out.println("placeOrder Avg Time: " + (totalPlaceOrder / runs) + " ns");
      System.out.println("checkOrderStatus Avg Time: " + (totalCheckOrder / runs) + " ns");
      System.out.println("viewAllOrders Avg Time: " + (totalViewAll / runs) + " ns");

    } catch (Exception e) {
      System.out.println("Measurement error: " + e);
    }
  }
}

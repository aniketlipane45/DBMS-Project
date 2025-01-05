 **Subscription Service Management**

Project Overview
This project is a database solution for managing subscriptions, payments, and service renewals. It includes features such as automated account suspension for non-payment, discount calculations based on subscription duration, and reminders for upcoming subscription expirations. Designed for subscription-based services, it ensures seamless operations with efficient data handling.

---

# Key Features

1. Tables and Relationships
-Users Table:
  Stores user information such as name, email, and account status (e.g., Active, Suspended).
  ```sql
  CREATE TABLE Users (
      user_id INT PRIMARY KEY,
      user_name VARCHAR(100),
      email VARCHAR(100),
      status VARCHAR(50) DEFAULT 'Active'
  );
  ```

- Services Table:
  Contains subscription plan details such as name and price.
  ```sql
  CREATE TABLE Services (
      service_id INT PRIMARY KEY,
      service_name VARCHAR(100),
      price DECIMAL(10, 2)
  );
  ```

- Subscriptions Table:
  Links users to their subscribed services, along with start and end dates.
  ```sql
  CREATE TABLE Subscriptions (
      subscription_id INT PRIMARY KEY,
      user_id INT,
      service_id INT,
      start_date DATE,
      end_date DATE,
      FOREIGN KEY (user_id) REFERENCES Users(user_id),
      FOREIGN KEY (service_id) REFERENCES Services(service_id)
  );
  ```

- Payments Table:
  Records payment history, including amounts and dates.
  ```sql
  CREATE TABLE Payments (
      payment_id INT PRIMARY KEY,
      user_id INT,
      amount DECIMAL(10, 2),
      payment_date DATE,
      FOREIGN KEY (user_id) REFERENCES Users(user_id)
  );
  ```

2. SQL Features Implemented
- Data Insertions:
  Populated the database with sample data for users, services, subscriptions, and payments.
  ```sql
  INSERT INTO Users (user_id, user_name, email, status) VALUES
  (1, 'Alice Johnson', 'alice.johnson@example.com', 'Active');
  ```

- Query for Expiring Subscriptions:
  Retrieve subscriptions expiring within the next 7 days.
  ```sql
  SELECT u.user_name, u.email, s.service_name, sub.end_date
  FROM Subscriptions sub
  JOIN Users u ON sub.user_id = u.user_id
  JOIN Services s ON sub.service_id = s.service_id
  WHERE sub.end_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7' DAY;
  ```

- Trigger for Account Suspension:
  Automatically suspends accounts after 30 days of non-payment.
  ```sql
  CREATE OR REPLACE TRIGGER suspend_account_after_non_payment
  AFTER INSERT ON Payments
  FOR EACH ROW
  DECLARE
      last_payment_date DATE;
  BEGIN
      SELECT MAX(payment_date) INTO last_payment_date
      FROM Payments
      WHERE user_id = :NEW.user_id;

      IF (SYSDATE - last_payment_date) > 30 THEN
          UPDATE Users SET status = 'Suspended' WHERE user_id = :NEW.user_id;
      END IF;
  END;
  ```

- Function for Discount Calculation:
  Calculates discounts based on subscription duration.
  ```sql
  CREATE OR REPLACE FUNCTION calculate_discount(p_user_id INT) RETURN NUMBER IS
      v_start_date DATE;
      v_end_date DATE;
      v_duration INT;
      v_discount NUMBER := 0;
  BEGIN
      SELECT start_date, end_date INTO v_start_date, v_end_date
      FROM Subscriptions
      WHERE user_id = p_user_id;

      v_duration := MONTHS_BETWEEN(v_end_date, v_start_date);
      IF v_duration >= 12 THEN
          v_discount := 0.10;
      ELSIF v_duration >= 6 THEN
          v_discount := 0.05;
      END IF;
      RETURN v_discount;
  END;
  ```

- Trigger for Auto-renewal:
  Automatically renews subscriptions after payment.
  ```sql
  CREATE OR REPLACE TRIGGER auto_renew_subscription
  AFTER INSERT ON Payments
  FOR EACH ROW
  DECLARE
      v_end_date DATE;
  BEGIN
      SELECT end_date INTO v_end_date
      FROM Subscriptions
      WHERE user_id = :NEW.user_id;

      UPDATE Subscriptions
      SET end_date = ADD_MONTHS(v_end_date, 12)
      WHERE user_id = :NEW.user_id;
  END;
  ```

---

How to Run

1. Database Setup:
   - Use an Oracle database instance.
   - Execute the table creation scripts in the order: `Users`, `Services`, `Subscriptions`, `Payments`.

2. Insert Sample Data:
   - Use the provided `INSERT` statements to populate tables with test data.

3. Test Queries and Triggers:
   - Run the provided queries and observe results.
   - Verify triggers by adding new payments or testing expired subscriptions.

4. Functions:
   - Test the `calculate_discount` function by passing a valid user ID.
   - Example:
     ```sql
     SELECT calculate_discount(1) AS discount_percentage FROM dual;
     ```

---

Contributing
Contributions are welcome! Feel free to fork this repository, make changes, and submit a pull request.

---

License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Contact
For any queries or suggestions, reach out to [aniketlipane12345@gmail.com](mailto:aniketlipane12345@gmail.com).


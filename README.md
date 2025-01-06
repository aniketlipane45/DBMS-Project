# **Subscription Service Management System**

## **Project Created By**  
Lipane Aniket Ashok  
Student of Amrutvahini College of Engineering  
T.E  Computer Engineering Department (under Zensar Python and SQL Training)



## **Project Description**  
This project is a robust subscription service management system implemented using Oracle SQL and PL/SQL. It provides functionality for managing users, subscriptions, payments, and services. The system also includes advanced features such as account suspension for overdue payments, automated subscription renewals, and discount calculations based on subscription duration.  

Key components include:  
1. **Users**: Manages user information such as name, email, and account status.  
2. **Services**: Maintains details about subscription plans, including names and prices.  
3. **Subscriptions**: Tracks user subscriptions, including service details, start and end dates.  
4. **Payments**: Logs payment records, ensuring accurate tracking of subscription renewals.  



## **Key Features**  

### **Data Modeling**
- Designed relational database tables with appropriate data types, constraints, and relationships.  

### **SQL and PL/SQL Implementation**
- Comprehensive SQL statements for data manipulation:
  - **INSERT**: Populate tables with sample data.  
  - **SELECT**: Retrieve and analyze data (e.g., upcoming expirations, account statuses).  
  - **Triggers**: Automated account suspension and subscription renewals.
  - **Functions**: Calculate discounts based on subscription duration.  

### **Data Integrity**
- Referential integrity is enforced through foreign key relationships, ensuring consistent and valid data across all tables.  

### **Automation**
- **Account Suspension**: Users with overdue payments for over 30 days are automatically suspended.  
- **Subscription Renewal**: Paid subscriptions are renewed automatically for the next cycle.  

---

## **Technologies Used**  
- **PL/SQL** (Oracle Database): For triggers, functions, and advanced logic implementation.  
- **SQL**: For data manipulation and querying.  



## **Guidance**  
This project was created under the guidance of **Sir Aniruddh Gaikwad**.  



## **How to Use the System**  

### **Database Setup**  
1. Use an Oracle database instance.  
2. Execute the following scripts in order:  
   - Create Tables  
   - Insert Sample Data  
   - Add Triggers and Functions  

### **Testing the System**  
1. **Insert Payments**: Simulate user payments to test triggers and renewals.  
2. **Run Queries**: Retrieve and analyze system data (e.g., expiring subscriptions, discount eligibility).  
3. **Check Automation**: Ensure triggers for account suspension and auto-renewals work as expected.  



## **Sample SQL Code**  

### **Account Suspension Trigger**  
Automatically suspends users if payments are overdue by 30 days.  
```sql
CREATE OR REPLACE TRIGGER suspend_account_after_non_payment
AFTER INSERT OR UPDATE ON Payments
FOR EACH ROW
DECLARE
    last_payment_date DATE;
BEGIN
    SELECT MAX(payment_date) INTO last_payment_date
    FROM Payments
    WHERE user_id = :NEW.user_id;

    IF (SYSDATE - last_payment_date) > 30 THEN
        UPDATE Users
        SET status = 'Suspended'
        WHERE user_id = :NEW.user_id;
    END IF;
END;
/
```

### **Discount Calculation Function**  
Determines discounts based on subscription duration.  
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
/
```




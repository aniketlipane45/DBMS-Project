-- Users Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    email VARCHAR(100),
    status VARCHAR(50) DEFAULT 'Active'  -- Active, Suspended
);

-- Services Table (e.g., different subscription plans)
CREATE TABLE Services (
    service_id INT PRIMARY KEY,
    service_name VARCHAR(100),
    price DECIMAL(10, 2)
);

-- Subscriptions Table (links users with services)
CREATE TABLE Subscriptions (
    subscription_id INT PRIMARY KEY,
    user_id INT,
    service_id INT,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);

-- Payments Table (records payment history)
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10, 2),
    payment_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Sample data for Users
INSERT INTO Users (user_id, user_name, email, status) VALUES
(1, 'Alice Johnson', 'alice.johnson@example.com', 'Active'),
(2, 'Bob Smith', 'bob.smith@example.com', 'Active'),
(3, 'Charlie Brown', 'charlie.brown@example.com', 'Suspended'),
(4, 'David Wilson', 'david.wilson@example.com', 'Active'),
(5, 'Emma White', 'emma.white@example.com', 'Active');

-- Sample data for Services
INSERT INTO Services (service_id, service_name, price) VALUES
(1, 'Basic Plan', 9.99),
(2, 'Standard Plan', 19.99),
(3, 'Premium Plan', 29.99);

-- Sample data for Subscriptions
INSERT INTO Subscriptions (subscription_id, user_id, service_id, start_date, end_date) VALUES
(1, 1, 1, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD')),
(2, 2, 2, TO_DATE('2024-05-01', 'YYYY-MM-DD'), TO_DATE('2025-04-30', 'YYYY-MM-DD')),
(3, 3, 3, TO_DATE('2024-07-01', 'YYYY-MM-DD'), TO_DATE('2025-06-30', 'YYYY-MM-DD')),
(4, 4, 2, TO_DATE('2024-10-01', 'YYYY-MM-DD'), TO_DATE('2025-09-30', 'YYYY-MM-DD')),
(5, 5, 1, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-02-28', 'YYYY-MM-DD'));

-- Sample data for Payments
INSERT INTO Payments (payment_id, user_id, amount, payment_date) VALUES
(1, 1, 9.99, TO_DATE('2024-01-01', 'YYYY-MM-DD')),
(2, 2, 19.99, TO_DATE('2024-05-01', 'YYYY-MM-DD')),
(3, 3, 29.99, TO_DATE('2024-07-01', 'YYYY-MM-DD')),
(4, 4, 19.99, TO_DATE('2024-10-01', 'YYYY-MM-DD')),
(5, 5, 9.99, TO_DATE('2024-03-01', 'YYYY-MM-DD'));

-- Trigger to suspend account after 30 days of non-payment
CREATE OR REPLACE TRIGGER suspend_account_after_non_payment
AFTER INSERT OR UPDATE ON Payments
FOR EACH ROW
DECLARE
    last_payment_date DATE;
BEGIN
    SELECT MAX(payment_date) INTO last_payment_date
    FROM Payments
    WHERE user_id = :NEW.user_id;

    -- Check if the last payment is more than 30 days old
    IF (SYSDATE - last_payment_date) > 30 THEN
        UPDATE Users
        SET status = 'Suspended'
        WHERE user_id = :NEW.user_id;
    END IF;
END;
/

-- PL/SQL function to calculate discount
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

-- Trigger for auto-renewal of subscriptions
CREATE OR REPLACE TRIGGER auto_renew_subscription
AFTER INSERT ON Payments
FOR EACH ROW
DECLARE
    v_end_date DATE;
BEGIN
    SELECT end_date INTO v_end_date
    FROM Subscriptions
    WHERE user_id = :NEW.user_id
    AND service_id IN (SELECT service_id FROM Subscriptions WHERE user_id = :NEW.user_id);

    UPDATE Subscriptions
    SET end_date = ADD_MONTHS(v_end_date, 12)
    WHERE user_id = :NEW.user_id
    AND service_id = (SELECT service_id FROM Subscriptions WHERE user_id = :NEW.user_id);
END;
/

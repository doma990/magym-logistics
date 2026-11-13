CREATE DATABASE LocalDeliveryMarketplace_Team_44;
GO
USE LocalDeliveryMarketplace_Team_44;
GO
-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.createAllTables
AS
BEGIN
    BEGIN TRY
    BEGIN TRANSACTION;
 CREATE TABLE dbo.Zone(
        zone_id int identity(1,1) NOT NULL,
        zone_name varchar(50) NOT NULL UNIQUE,
        delivery_fee decimal(10,2) NOT NULL CHECK (delivery_fee >= 0),
        PRIMARY KEY (zone_id)
    );

    CREATE TABLE dbo.Users
    (
        user_id int identity(1,1) NOT NULL,
        first_name varchar(30) NOT NULL,
        middle_name varchar(30) NULL,
        last_name varchar(30) NOT NULL,
        username varchar(30) NOT NULL UNIQUE,
        password varchar(30) NOT NULL,
        email varchar(100) NOT NULL UNIQUE,
        dob date NULL,
        account_status varchar(20) NOT NULL DEFAULT 'Active' CHECK (account_status IN ('Active', 'Blacklisted')),
        PRIMARY KEY (user_id)
    );

    CREATE TABLE dbo.User_Phone
    (
        user_id int NOT NULL,
        phone char(11) NOT NULL,
        PRIMARY KEY (user_id, phone),
        CONSTRAINT FK_User_Phone_user_id FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id)
    );

    CREATE TABLE dbo.Admin
    
    (
        admin_id int NOT NULL,
        role varchar(20) NOT NULL DEFAULT 'Super Admin' CHECK (role IN ('Super Admin', 'Zone Admin')),
        zone_id int NULL,
        PRIMARY KEY (admin_id),
        CONSTRAINT FK_Admin_admin_id FOREIGN KEY (admin_id) REFERENCES dbo.Users(user_id),
        CONSTRAINT FK_Admin_zone_id FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id)
    );

    CREATE TABLE dbo.Partner
    (
        partner_id int NOT NULL,
        PRIMARY KEY (partner_id),
        CONSTRAINT FK_Partner_partner_id FOREIGN KEY (partner_id) REFERENCES dbo.Users(user_id)
    );

    CREATE TABLE dbo.Rider
    (
        rider_id int NOT NULL,
        vehicle_type varchar(30) NOT NULL,
        plate_no varchar(15) NOT NULL UNIQUE,
        license_no varchar(20) NOT NULL UNIQUE,
        is_available bit NOT NULL DEFAULT 1,
        zone_id int NOT NULL,
        PRIMARY KEY (rider_id),
        CONSTRAINT FK_Rider_rider_id FOREIGN KEY (rider_id) REFERENCES dbo.Users(user_id),
        CONSTRAINT FK_Rider_zone_id FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id)
    );

    CREATE TABLE dbo.Customer
    (
        customer_id int NOT NULL,
        wallet_balance decimal(10,2) NOT NULL DEFAULT 0 CHECK (wallet_balance >= 0),
        PRIMARY KEY (customer_id),
        CONSTRAINT FK_Customer_customer_id FOREIGN KEY (customer_id) REFERENCES dbo.Users(user_id)
    );

    CREATE TABLE dbo.Address
      (
        address_id int identity(1,1) NOT NULL,
        description varchar(150) NOT NULL,
        is_active bit NOT NULL DEFAULT 1,
        customer_id int NOT NULL,
        zone_id int NOT NULL,
        PRIMARY KEY (address_id),
        CONSTRAINT FK_Address_customer_id FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
        CONSTRAINT FK_Address_zone_id FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id)
    );

    CREATE TABLE dbo.Card
    (
        card_id int identity(1,1) NOT NULL,
        card_no char(16) NOT NULL,
        card_holder_name varchar(100) NOT NULL,
        expiration_date date NOT NULL,
        customer_id int NOT NULL,
        PRIMARY KEY (card_id),
        CONSTRAINT FK_Card_customer_id FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
        UNIQUE (customer_id, card_no)
    );

    CREATE TABLE dbo.Business (
        business_id int identity(1,1) NOT NULL,
        name varchar(100) NOT NULL,
        description varchar(255) NULL,
        link_website varchar(255) NULL,
        opening_hour time NOT NULL,
        closing_hour time NOT NULL,
        expected_delivery_time int NOT NULL CHECK (expected_delivery_time > 0),
        status varchar(20) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Active', 'Suspended', 'Rejected')),
        suspension_reason varchar(255) NULL,
        partner_id int NOT NULL UNIQUE,
        zone_id int NOT NULL,
        PRIMARY KEY (business_id),
        CONSTRAINT FK_Business_partner_id FOREIGN KEY (partner_id) REFERENCES dbo.Partner(partner_id),
        CONSTRAINT FK_Business_zone_id FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id)
    );

    CREATE TABLE dbo.Business_Phone
    (
        business_id int NOT NULL,
        phone char(11) NOT NULL,
        PRIMARY KEY (business_id, phone),
        CONSTRAINT FK_Business_Phone_business_id FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id)
    );

    CREATE TABLE dbo.Restaurant
    (
        business_id int NOT NULL,
        cuisine_type varchar(50) NOT NULL,
        food_category varchar(50) NOT NULL,
        PRIMARY KEY (business_id),
        CONSTRAINT FK_Restaurant_business_id FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id)
    );

    CREATE TABLE dbo.Pharmacy
    (
        business_id int NOT NULL,
        pharmacy_type varchar(50) NOT NULL,
        PRIMARY KEY (business_id),
        CONSTRAINT FK_Pharmacy_business_id FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id)
    );

    CREATE TABLE dbo.Blacklist
    (
        customer_id int NOT NULL,
        admin_id int NOT NULL,
        reason varchar(255) NOT NULL,
        PRIMARY KEY (customer_id),
        CONSTRAINT FK_Blacklist_customer_id FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
        CONSTRAINT FK_Blacklist_admin_id FOREIGN KEY (admin_id) REFERENCES dbo.Admin(admin_id)
    );

    CREATE TABLE dbo.Product
    (
        product_id int identity(1,1) NOT NULL,
        name varchar(100) NOT NULL,
        description varchar(255) NULL,
        category varchar(50) NOT NULL,
        price decimal(10,2) NOT NULL CHECK (price > 0),
        discount_amount decimal(10,2) NOT NULL DEFAULT 0,
        is_available bit NOT NULL DEFAULT 1,
        business_id int NOT NULL,
        PRIMARY KEY (product_id),
        CONSTRAINT FK_Product_business_id FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id),
        CHECK (discount_amount >= 0 AND discount_amount <= 0.5 * price)
    );

    CREATE TABLE dbo.Favorite_Business
    (
        customer_id int NOT NULL,
        business_id int NOT NULL,
        PRIMARY KEY (customer_id, business_id),
        CONSTRAINT FK_Favorite_Business_customer_id FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
        CONSTRAINT FK_Favorite_Business_business_id FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id)
    );

    CREATE TABLE dbo.Favorite_Product
    (
        customer_id int NOT NULL,
        product_id int NOT NULL,
        PRIMARY KEY (customer_id, product_id),
        CONSTRAINT FK_Favorite_Product_customer_id FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
        CONSTRAINT FK_Favorite_Product_product_id FOREIGN KEY (product_id) REFERENCES dbo.Product(product_id)
    );

    CREATE TABLE dbo.Voucher
   (
        voucher_id int identity(1,1) NOT NULL,
        promo_code varchar(30) NOT NULL UNIQUE,
        is_percentage bit NOT NULL,
        amount decimal(10,2) NOT NULL CHECK (amount > 0),
        expiry_date date NOT NULL,
        status varchar(20) NOT NULL DEFAULT 'Unused' CHECK (status IN ('Unused', 'Used')),
        customer_id int NOT NULL,
        PRIMARY KEY (voucher_id),
        CONSTRAINT FK_Voucher_customer_id FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id)
    );

    CREATE TABLE dbo.Cart
    (
        cart_id int identity(1,1) NOT NULL,
        status varchar(20) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Checked Out')),
        created_at datetime NOT NULL DEFAULT GETDATE(),
        customer_id int NOT NULL,
        address_id int NOT NULL,
        PRIMARY KEY (cart_id),
        CONSTRAINT FK_Cart_customer_id FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
        CONSTRAINT FK_Cart_address_id FOREIGN KEY (address_id) REFERENCES dbo.Address(address_id)
    );

    CREATE TABLE dbo.CartItem
    (
        cart_id int NOT NULL,
        product_id int NOT NULL,
        quantity int NOT NULL CHECK (quantity BETWEEN 1 AND 10),
        notes varchar(255) NULL,
        unit_price decimal(10,2) NULL,
        PRIMARY KEY (cart_id, product_id),
        CONSTRAINT FK_CartItem_cart_id FOREIGN KEY (cart_id) REFERENCES dbo.Cart(cart_id),
        CONSTRAINT FK_CartItem_product_id FOREIGN KEY (product_id) REFERENCES dbo.Product(product_id)
    );

    CREATE TABLE dbo.Orders
    (
        order_id int identity(1,1) NOT NULL,
        order_date datetime NOT NULL,
        status varchar(20) NOT NULL DEFAULT 'Placed' CHECK (status IN ('Placed', 'In Progress', 'Delivered', 'Cancelled')),
        discount_amount decimal(10,2) NOT NULL DEFAULT 0,
        total_amount decimal(10,2) NOT NULL,
        cart_id int NOT NULL UNIQUE,
        zone_id int NOT NULL,
        voucher_id int NULL,
        PRIMARY KEY (order_id),
        CONSTRAINT FK_Orders_cart_id FOREIGN KEY (cart_id) REFERENCES dbo.Cart(cart_id),
        CONSTRAINT FK_Orders_zone_id FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id),
        CONSTRAINT FK_Orders_voucher_id FOREIGN KEY (voucher_id) REFERENCES dbo.Voucher(voucher_id)
    );

    CREATE TABLE dbo.SubOrder
    (
        suborder_id int identity(1,1) NOT NULL,
        status varchar(20) NOT NULL DEFAULT 'Placed' CHECK (status IN ('Placed', 'Assigned', 'Picked Up', 'Delivered', 'Cancelled')),
        total_price decimal(10,2) NOT NULL,
        delivery_fee decimal(10,2) NOT NULL,
        order_id int NOT NULL,
        business_id int NOT NULL,
        PRIMARY KEY (suborder_id),
        CONSTRAINT FK_SubOrder_order_id FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
        CONSTRAINT FK_SubOrder_business_id FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id),
        UNIQUE (order_id, business_id)
    );

    CREATE TABLE dbo.Delivery
    (
        delivery_id int identity(1,1) NOT NULL,
        assigned_at datetime NOT NULL,
        picked_up_at datetime NULL,
        delivered_at datetime NULL,
        tracking_time int NULL,
        rider_rating int NULL CHECK (rider_rating BETWEEN 1 AND 5),
        suborder_id int NOT NULL UNIQUE,
        rider_id int NOT NULL,
        PRIMARY KEY (delivery_id),
        CONSTRAINT FK_Delivery_suborder_id FOREIGN KEY (suborder_id) REFERENCES dbo.SubOrder(suborder_id),
        CONSTRAINT FK_Delivery_rider_id FOREIGN KEY (rider_id) REFERENCES dbo.Rider(rider_id)
    );

    CREATE TABLE dbo.Payment
    (
        payment_id int identity(1,1) NOT NULL,
        amount decimal(10,2) NOT NULL,
        currency varchar(3) NOT NULL DEFAULT 'EGP' CHECK (currency IN ('EGP')),
        method varchar(20) NOT NULL CHECK (method IN ('Cash', 'Card', 'Wallet')),
        transaction_date datetime NOT NULL,
        refunded_amount decimal(10,2) NOT NULL DEFAULT 0,
        order_id int NOT NULL UNIQUE,
        card_id int NULL,
        PRIMARY KEY (payment_id),
        CONSTRAINT FK_Payment_order_id FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
        CONSTRAINT FK_Payment_card_id FOREIGN KEY (card_id) REFERENCES dbo.Card(card_id),
        CHECK (refunded_amount <= amount)
    );

    CREATE TABLE dbo.Feedback
    (
        feedback_id int identity(1,1) NOT NULL,
        headline varchar(100) NOT NULL,
        description varchar(500) NULL,
        rating int NOT NULL CHECK (rating BETWEEN 1 AND 5),
        feedback_date datetime NOT NULL DEFAULT GETDATE(),
        suborder_id int NOT NULL UNIQUE,
        PRIMARY KEY (feedback_id),
        CONSTRAINT FK_Feedback_suborder_id FOREIGN KEY (suborder_id) REFERENCES dbo.SubOrder(suborder_id)
    );

    COMMIT TRANSACTION;
    RETURN 0;
    END TRY
    BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    RETURN -1;
    END CATCH;
END;
GO

EXEC dbo.createAllTables;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.dropAllTables
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DROP TABLE dbo.Feedback;
        DROP TABLE dbo.Payment;
        DROP TABLE dbo.Delivery;
        DROP TABLE dbo.SubOrder;
        DROP TABLE dbo.Orders;
        DROP TABLE dbo.CartItem;
        DROP TABLE dbo.Cart;
        DROP TABLE dbo.Voucher;
        DROP TABLE dbo.Favorite_Product;
        DROP TABLE dbo.Favorite_Business;
        DROP TABLE dbo.Product;
        DROP TABLE dbo.Blacklist;
        DROP TABLE dbo.Pharmacy;
        DROP TABLE dbo.Restaurant;
        DROP TABLE dbo.Business_Phone;
        DROP TABLE dbo.Business;
        DROP TABLE dbo.Card;
        DROP TABLE dbo.Address;
        DROP TABLE dbo.Customer;
        DROP TABLE dbo.Rider;
        DROP TABLE dbo.Partner;
        DROP TABLE dbo.Admin;
        DROP TABLE dbo.User_Phone;
        DROP TABLE dbo.Users;
        DROP TABLE dbo.Zone;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        RETURN -1;
    END CATCH;
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.dropAllProceduresFunctionsViews
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        DROP PROCEDURE dbo.Suspend_Business;
        DROP PROCEDURE dbo.Reinstate_Business;
        DROP PROCEDURE dbo.Create_Zone;
        DROP PROCEDURE dbo.Update_Zone_Fee;
        DROP PROCEDURE dbo.clearAllTables;
        DROP PROCEDURE dbo.dropAllTables;
        DROP PROCEDURE dbo.createAllTables;
        DROP FUNCTION dbo.ZoneOrderReport;
        DROP FUNCTION dbo.Daily_Revenue_Report;
        DROP FUNCTION dbo.BusinessRefunds;
        DROP VIEW dbo.BusinessesPerZone;
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.clearAllTables
AS
BEGIN
    DECLARE @result int;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC @result = dbo.dropAllTables;
        IF @result = 0
            EXEC @result = dbo.createAllTables;

        IF @result <> 0
        BEGIN
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            RETURN @result;
        END;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH;
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE VIEW dbo.BusinessesPerZone
AS
SELECT z.zone_id, z.zone_name, COUNT(b.business_id) AS business_count
FROM dbo.Zone z
LEFT JOIN dbo.Business b ON b.zone_id = z.zone_id AND b.status = 'Active'
GROUP BY z.zone_id, z.zone_name;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE FUNCTION dbo.BusinessRefunds(@business_id int)
RETURNS TABLE
AS
RETURN
(
SELECT s.order_id, c.customer_id, p.method,
    CASE WHEN s.total_price + s.delivery_fee > p.amount - p.refunded_amount
         THEN p.amount - p.refunded_amount
         ELSE s.total_price + s.delivery_fee
    END AS refund_amount
FROM dbo.SubOrder s
INNER JOIN dbo.Orders o ON o.order_id = s.order_id
INNER JOIN dbo.Cart c ON c.cart_id = o.cart_id
INNER JOIN dbo.Payment p ON p.order_id = o.order_id
WHERE s.business_id = @business_id AND s.status IN ('Placed', 'Assigned')
);
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.Suspend_Business
@business_id int, @admin_id int, @reason varchar(255)
AS
BEGIN
    IF @business_id IS NULL OR @admin_id IS NULL OR @reason IS NULL OR @reason = ''
        RETURN -1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Admin WHERE admin_id = @admin_id)
        RETURN -3;

    IF EXISTS (SELECT 1
               FROM dbo.Admin a INNER JOIN dbo.Business b ON a.zone_id <> b.zone_id
               WHERE a.admin_id = @admin_id AND a.role = 'Zone Admin'
               AND b.business_id = @business_id)
        RETURN -3;

    IF NOT EXISTS (SELECT 1 FROM dbo.Business
                   WHERE business_id = @business_id AND status = 'Active')
        RETURN -4;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.Customer
        SET wallet_balance = wallet_balance +
            (SELECT SUM(r.refund_amount) FROM dbo.BusinessRefunds(@business_id) r
             WHERE r.customer_id = Customer.customer_id
             AND r.method <> 'Cash')
        WHERE customer_id IN (SELECT customer_id FROM dbo.BusinessRefunds(@business_id)
                              WHERE method <> 'Cash');

        UPDATE dbo.Payment
        SET refunded_amount = refunded_amount +
            (SELECT r.refund_amount FROM dbo.BusinessRefunds(@business_id) r
             WHERE r.order_id = Payment.order_id)
        WHERE order_id IN (SELECT order_id FROM dbo.BusinessRefunds(@business_id));

        UPDATE dbo.SubOrder
        SET status = 'Cancelled'
        WHERE business_id = @business_id AND status IN ('Placed', 'Assigned');

        UPDATE dbo.Orders
        SET status = CASE
            WHEN NOT EXISTS (SELECT 1 FROM dbo.SubOrder s
                             WHERE s.order_id = Orders.order_id
                             AND s.status <> 'Cancelled') THEN 'Cancelled'
            WHEN NOT EXISTS (SELECT 1 FROM dbo.SubOrder s
                             WHERE s.order_id = Orders.order_id
                             AND s.status NOT IN ('Cancelled', 'Delivered')) THEN 'Delivered'
            WHEN EXISTS (SELECT 1 FROM dbo.SubOrder s
                         WHERE s.order_id = Orders.order_id
                         AND s.status IN ('Picked Up', 'Delivered')) THEN 'In Progress'
            ELSE 'Placed'
        END
        WHERE order_id IN (SELECT order_id FROM dbo.SubOrder
                          WHERE business_id = @business_id AND status = 'Cancelled');

        UPDATE dbo.Voucher
        SET status = 'Unused'
        WHERE voucher_id IN
            (SELECT voucher_id FROM dbo.Orders
             WHERE status = 'Cancelled'
             AND order_id IN (SELECT order_id FROM dbo.SubOrder
                          WHERE business_id = @business_id AND status = 'Cancelled'));

        UPDATE dbo.Orders
        SET voucher_id = NULL
        WHERE status = 'Cancelled'
        AND order_id IN (SELECT order_id FROM dbo.SubOrder
                          WHERE business_id = @business_id AND status = 'Cancelled');

        UPDATE dbo.Product
        SET is_available = 0
        WHERE business_id = @business_id;

        UPDATE dbo.Business
        SET status = 'Suspended', suspension_reason = @reason
        WHERE business_id = @business_id;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.Reinstate_Business
@business_id int, @super_admin_id int
AS
BEGIN
    IF @business_id IS NULL OR @super_admin_id IS NULL
        RETURN -1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Admin
                   WHERE admin_id = @super_admin_id AND role = 'Super Admin')
        RETURN -3;

    IF NOT EXISTS (SELECT 1 FROM dbo.Business
                   WHERE business_id = @business_id AND status = 'Suspended')
        RETURN -4;

    UPDATE dbo.Business
    SET status = 'Active', suspension_reason = NULL
    WHERE business_id = @business_id;
    RETURN 0;
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.Create_Zone
@zone_name varchar(50), @delivery_fee decimal(10,2), @super_admin_id int
AS
BEGIN
    IF @zone_name IS NULL OR @zone_name = '' OR @delivery_fee IS NULL
       OR @delivery_fee < 0 OR @super_admin_id IS NULL
        RETURN -1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Admin
                   WHERE admin_id = @super_admin_id AND role = 'Super Admin')
        RETURN -3;

    IF EXISTS (SELECT 1 FROM dbo.Zone WHERE zone_name = @zone_name)
        RETURN -2;

    INSERT INTO dbo.Zone (zone_name, delivery_fee)
    VALUES (@zone_name, @delivery_fee);
    RETURN 0;
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.Update_Zone_Fee
@zone_id int, @new_fee decimal(10,2), @super_admin_id int
AS
BEGIN
    IF @zone_id IS NULL OR @new_fee IS NULL OR @new_fee < 0 OR @super_admin_id IS NULL
        RETURN -1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Admin
                   WHERE admin_id = @super_admin_id AND role = 'Super Admin')
        RETURN -3;

    UPDATE dbo.Zone
    SET delivery_fee = @new_fee
    WHERE zone_id = @zone_id;
    RETURN 0;
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE FUNCTION dbo.ZoneOrderReport(@zone_id int, @from_date date, @to_date date)
RETURNS TABLE
AS
RETURN
(
    SELECT z.zone_id, z.zone_name, COUNT(o.order_id) AS number_of_orders,
           CAST(AVG(o.total_amount) AS decimal(10,2)) AS avg_order_total,
           CAST(ISNULL((SELECT SUM(s.total_price) * 0.10
                        FROM dbo.SubOrder s INNER JOIN dbo.Orders o2 ON o2.order_id = s.order_id
                        WHERE o2.zone_id = z.zone_id AND o2.status <> 'Cancelled'
                        AND s.status <> 'Cancelled'
                        AND CAST(o2.order_date AS date) BETWEEN @from_date AND @to_date), 0)
                AS decimal(10,2)) AS platform_commission
    FROM dbo.Zone z
    LEFT JOIN dbo.Orders o ON o.zone_id = z.zone_id AND o.status <> 'Cancelled'
         AND CAST(o.order_date AS date) BETWEEN @from_date AND @to_date
    WHERE z.zone_id = @zone_id AND @from_date <= @to_date
    GROUP BY z.zone_id, z.zone_name
);
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE FUNCTION dbo.Daily_Revenue_Report(@report_date date)
RETURNS TABLE
AS
RETURN
(
    SELECT z.zone_name, CAST('Restaurant' AS varchar(20)) AS business_type,
           COUNT(*) AS number_of_suborders,
           CAST(SUM(s.total_price) AS decimal(10,2)) AS gross_sales,
           CAST(SUM(s.delivery_fee) AS decimal(10,2)) AS delivery_fees,
           CAST(SUM(s.total_price) * 0.10 AS decimal(10,2)) AS platform_commission
    FROM dbo.Orders o
    INNER JOIN dbo.Zone z ON z.zone_id = o.zone_id
    INNER JOIN dbo.SubOrder s ON s.order_id = o.order_id
    INNER JOIN dbo.Restaurant r ON r.business_id = s.business_id
    WHERE CAST(o.order_date AS date) = @report_date AND s.status <> 'Cancelled'
    GROUP BY z.zone_id, z.zone_name

    UNION ALL

    SELECT z.zone_name, CAST('Pharmacy' AS varchar(20)), COUNT(*),
           CAST(SUM(s.total_price) AS decimal(10,2)),
           CAST(SUM(s.delivery_fee) AS decimal(10,2)),
           CAST(SUM(s.total_price) * 0.10 AS decimal(10,2))
    FROM dbo.Orders o
    INNER JOIN dbo.Zone z ON z.zone_id = o.zone_id
    INNER JOIN dbo.SubOrder s ON s.order_id = o.order_id
    INNER JOIN dbo.Pharmacy p ON p.business_id = s.business_id
    WHERE CAST(o.order_date AS date) = @report_date AND s.status <> 'Cancelled'
    GROUP BY z.zone_id, z.zone_name
);
GO

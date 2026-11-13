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
        CONSTRAINT FK_Admin_zone_id FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id),
        CHECK ((role = 'Super Admin' AND zone_id IS NULL) OR (role = 'Zone Admin' AND zone_id IS NOT NULL))
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
        CONSTRAINT FK_Business_zone_id FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id),
        CHECK (status = 'Suspended' OR suspension_reason IS NULL)
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
        CONSTRAINT FK_Voucher_customer_id FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
        CHECK (is_percentage = 0 OR amount BETWEEN 1 AND 100)
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

        DROP VIEW IF EXISTS dbo.allBusinessProfiles;

        DROP VIEW IF EXISTS dbo.BusinessRatingsSummary;

        DROP VIEW IF EXISTS dbo.ActiveVouchers;

        DROP VIEW IF EXISTS dbo.PendingBusinessApprovals;

        DROP VIEW IF EXISTS dbo.RiderPerformanceSummary;

        DROP VIEW IF EXISTS dbo.TopSellingProducts;

        DROP VIEW IF EXISTS dbo.ZoneDeliveryPerformance;

        DROP FUNCTION IF EXISTS dbo.CustomerLoginValidation;

        DROP FUNCTION IF EXISTS dbo.PartnerLoginValidation;

        DROP FUNCTION IF EXISTS dbo.RiderLoginValidation;

        DROP FUNCTION IF EXISTS dbo.AdminLoginValidation;

        DROP FUNCTION IF EXISTS dbo.TopRiders;

        DROP FUNCTION IF EXISTS dbo.BusinessSalesReport;

        DROP FUNCTION IF EXISTS dbo.BusinessFeedbackOverview;

        DROP FUNCTION IF EXISTS dbo.Calculate_Voucher_Discount;

        DROP FUNCTION IF EXISTS dbo.My_Order_History;

        DROP FUNCTION IF EXISTS dbo.My_Favorites;

        DROP FUNCTION IF EXISTS dbo.Recommended_Products;

        DROP FUNCTION IF EXISTS dbo.My_Active_Deliveries;

        DROP FUNCTION IF EXISTS dbo.My_Earnings;

        DROP FUNCTION IF EXISTS dbo.My_Rating_Summary;

        DROP FUNCTION IF EXISTS dbo.My_Delivery_History;

        DROP FUNCTION IF EXISTS dbo.Search_Platform;

        DROP FUNCTION IF EXISTS dbo.Reconcile_Order_Totals;

        DROP FUNCTION IF EXISTS dbo.Nearby_Businesses_By_Category;

        DROP FUNCTION IF EXISTS dbo.Platform_Health_Snapshot;

        DROP FUNCTION IF EXISTS dbo.Detect_Voucher_Abuse;

        DROP PROCEDURE IF EXISTS dbo.Customer_Register;

        DROP PROCEDURE IF EXISTS dbo.Partner_Register;

        DROP PROCEDURE IF EXISTS dbo.Rider_Register;

        DROP PROCEDURE IF EXISTS dbo.Change_Password;

        DROP PROCEDURE IF EXISTS dbo.Create_Admin;

        DROP PROCEDURE IF EXISTS dbo.Approve_Business;

        DROP PROCEDURE IF EXISTS dbo.Reject_Business;

        DROP PROCEDURE IF EXISTS dbo.Assign_Admin_Zone;

        DROP PROCEDURE IF EXISTS dbo.Issue_Voucher;

        DROP PROCEDURE IF EXISTS dbo.Blacklist_Customer;

        DROP PROCEDURE IF EXISTS dbo.Lift_Customer_Blacklist;

        DROP PROCEDURE IF EXISTS dbo.Register_Business;

        DROP PROCEDURE IF EXISTS dbo.Update_Business_Info;

        DROP PROCEDURE IF EXISTS dbo.Upsert_Product;

        DROP PROCEDURE IF EXISTS dbo.Toggle_Product_Status;

        DROP PROCEDURE IF EXISTS dbo.Set_Product_Promotion;

        DROP PROCEDURE IF EXISTS dbo.Add_Customer_Address;

        DROP PROCEDURE IF EXISTS dbo.Update_Delete_Customer_Address;

        DROP PROCEDURE IF EXISTS dbo.Add_Card;

        DROP PROCEDURE IF EXISTS dbo.Create_Cart;

        DROP PROCEDURE IF EXISTS dbo.Add_To_Cart;

        DROP PROCEDURE IF EXISTS dbo.Remove_From_Cart;

        DROP PROCEDURE IF EXISTS dbo.Checkout_Cart;

        DROP PROCEDURE IF EXISTS dbo.Cancel_Order;

        DROP PROCEDURE IF EXISTS dbo.Reorder;

        DROP PROCEDURE IF EXISTS dbo.Submit_Feedback;

        DROP PROCEDURE IF EXISTS dbo.Rate_Rider;

        DROP PROCEDURE IF EXISTS dbo.Toggle_Favorite;

        DROP PROCEDURE IF EXISTS dbo.Set_Rider_Availability;

        DROP PROCEDURE IF EXISTS dbo.Mark_Picked_Up;

        DROP PROCEDURE IF EXISTS dbo.Mark_Delivered;

        DROP PROCEDURE IF EXISTS dbo.Change_Active_Address;

        DROP VIEW IF EXISTS dbo.BusinessesPerZone;
        DROP FUNCTION IF EXISTS dbo.ZoneOrderReport;
        DROP FUNCTION IF EXISTS dbo.Daily_Revenue_Report;
        DROP PROCEDURE IF EXISTS dbo.createAllTables;
        DROP PROCEDURE IF EXISTS dbo.dropAllTables;
        DROP PROCEDURE IF EXISTS dbo.clearAllTables;
        DROP PROCEDURE IF EXISTS dbo.Suspend_Business;
        DROP PROCEDURE IF EXISTS dbo.Reinstate_Business;
        DROP PROCEDURE IF EXISTS dbo.Create_Zone;
        DROP PROCEDURE IF EXISTS dbo.Update_Zone_Fee;

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
CREATE PROCEDURE dbo.clearAllTables
AS
BEGIN
    BEGIN TRY
    BEGIN TRANSACTION;

    ALTER TABLE dbo.User_Phone DROP CONSTRAINT FK_User_Phone_user_id;
    ALTER TABLE dbo.Admin DROP CONSTRAINT FK_Admin_admin_id;
    ALTER TABLE dbo.Admin DROP CONSTRAINT FK_Admin_zone_id;
    ALTER TABLE dbo.Partner DROP CONSTRAINT FK_Partner_partner_id;
    ALTER TABLE dbo.Rider DROP CONSTRAINT FK_Rider_rider_id;
    ALTER TABLE dbo.Rider DROP CONSTRAINT FK_Rider_zone_id;
    ALTER TABLE dbo.Customer DROP CONSTRAINT FK_Customer_customer_id;
    ALTER TABLE dbo.Address DROP CONSTRAINT FK_Address_customer_id;
    ALTER TABLE dbo.Address DROP CONSTRAINT FK_Address_zone_id;
    ALTER TABLE dbo.Card DROP CONSTRAINT FK_Card_customer_id;
    ALTER TABLE dbo.Business DROP CONSTRAINT FK_Business_partner_id;
    ALTER TABLE dbo.Business DROP CONSTRAINT FK_Business_zone_id;
    ALTER TABLE dbo.Business_Phone DROP CONSTRAINT FK_Business_Phone_business_id;
    ALTER TABLE dbo.Restaurant DROP CONSTRAINT FK_Restaurant_business_id;
    ALTER TABLE dbo.Pharmacy DROP CONSTRAINT FK_Pharmacy_business_id;
    ALTER TABLE dbo.Blacklist DROP CONSTRAINT FK_Blacklist_customer_id;
    ALTER TABLE dbo.Blacklist DROP CONSTRAINT FK_Blacklist_admin_id;
    ALTER TABLE dbo.Product DROP CONSTRAINT FK_Product_business_id;
    ALTER TABLE dbo.Favorite_Business DROP CONSTRAINT FK_Favorite_Business_customer_id;
    ALTER TABLE dbo.Favorite_Business DROP CONSTRAINT FK_Favorite_Business_business_id;
    ALTER TABLE dbo.Favorite_Product DROP CONSTRAINT FK_Favorite_Product_customer_id;
    ALTER TABLE dbo.Favorite_Product DROP CONSTRAINT FK_Favorite_Product_product_id;
    ALTER TABLE dbo.Voucher DROP CONSTRAINT FK_Voucher_customer_id;
    ALTER TABLE dbo.Cart DROP CONSTRAINT FK_Cart_customer_id;
    ALTER TABLE dbo.Cart DROP CONSTRAINT FK_Cart_address_id;
    ALTER TABLE dbo.CartItem DROP CONSTRAINT FK_CartItem_cart_id;
    ALTER TABLE dbo.CartItem DROP CONSTRAINT FK_CartItem_product_id;
    ALTER TABLE dbo.Orders DROP CONSTRAINT FK_Orders_cart_id;
    ALTER TABLE dbo.Orders DROP CONSTRAINT FK_Orders_zone_id;
    ALTER TABLE dbo.Orders DROP CONSTRAINT FK_Orders_voucher_id;
    ALTER TABLE dbo.SubOrder DROP CONSTRAINT FK_SubOrder_order_id;
    ALTER TABLE dbo.SubOrder DROP CONSTRAINT FK_SubOrder_business_id;
    ALTER TABLE dbo.Delivery DROP CONSTRAINT FK_Delivery_suborder_id;
    ALTER TABLE dbo.Delivery DROP CONSTRAINT FK_Delivery_rider_id;
    ALTER TABLE dbo.Payment DROP CONSTRAINT FK_Payment_order_id;
    ALTER TABLE dbo.Payment DROP CONSTRAINT FK_Payment_card_id;
    ALTER TABLE dbo.Feedback DROP CONSTRAINT FK_Feedback_suborder_id;

    TRUNCATE TABLE dbo.Feedback;
    TRUNCATE TABLE dbo.Payment;
    TRUNCATE TABLE dbo.Delivery;
    TRUNCATE TABLE dbo.SubOrder;
    TRUNCATE TABLE dbo.Orders;
    TRUNCATE TABLE dbo.CartItem;
    TRUNCATE TABLE dbo.Cart;
    TRUNCATE TABLE dbo.Voucher;
    TRUNCATE TABLE dbo.Favorite_Product;
    TRUNCATE TABLE dbo.Favorite_Business;
    TRUNCATE TABLE dbo.Product;
    TRUNCATE TABLE dbo.Blacklist;
    TRUNCATE TABLE dbo.Pharmacy;
    TRUNCATE TABLE dbo.Restaurant;
    TRUNCATE TABLE dbo.Business_Phone;
    TRUNCATE TABLE dbo.Business;
    TRUNCATE TABLE dbo.Card;
    TRUNCATE TABLE dbo.Address;
    TRUNCATE TABLE dbo.Customer;
    TRUNCATE TABLE dbo.Rider;
    TRUNCATE TABLE dbo.Partner;
    TRUNCATE TABLE dbo.Admin;
    TRUNCATE TABLE dbo.User_Phone;
    TRUNCATE TABLE dbo.Users;
    TRUNCATE TABLE dbo.Zone;

    ALTER TABLE dbo.User_Phone ADD CONSTRAINT FK_User_Phone_user_id
        FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id);
    ALTER TABLE dbo.Admin ADD CONSTRAINT FK_Admin_admin_id
        FOREIGN KEY (admin_id) REFERENCES dbo.Users(user_id);
    ALTER TABLE dbo.Admin ADD CONSTRAINT FK_Admin_zone_id
        FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id);
    ALTER TABLE dbo.Partner ADD CONSTRAINT FK_Partner_partner_id
        FOREIGN KEY (partner_id) REFERENCES dbo.Users(user_id);
    ALTER TABLE dbo.Rider ADD CONSTRAINT FK_Rider_rider_id
        FOREIGN KEY (rider_id) REFERENCES dbo.Users(user_id);
    ALTER TABLE dbo.Rider ADD CONSTRAINT FK_Rider_zone_id
        FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id);
    ALTER TABLE dbo.Customer ADD CONSTRAINT FK_Customer_customer_id
        FOREIGN KEY (customer_id) REFERENCES dbo.Users(user_id);
    ALTER TABLE dbo.Address ADD CONSTRAINT FK_Address_customer_id
        FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id);
    ALTER TABLE dbo.Address ADD CONSTRAINT FK_Address_zone_id
        FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id);
    ALTER TABLE dbo.Card ADD CONSTRAINT FK_Card_customer_id
        FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id);
    ALTER TABLE dbo.Business ADD CONSTRAINT FK_Business_partner_id
        FOREIGN KEY (partner_id) REFERENCES dbo.Partner(partner_id);
    ALTER TABLE dbo.Business ADD CONSTRAINT FK_Business_zone_id
        FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id);
    ALTER TABLE dbo.Business_Phone ADD CONSTRAINT FK_Business_Phone_business_id
        FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id);
    ALTER TABLE dbo.Restaurant ADD CONSTRAINT FK_Restaurant_business_id
        FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id);
    ALTER TABLE dbo.Pharmacy ADD CONSTRAINT FK_Pharmacy_business_id
        FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id);
    ALTER TABLE dbo.Blacklist ADD CONSTRAINT FK_Blacklist_customer_id
        FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id);
    ALTER TABLE dbo.Blacklist ADD CONSTRAINT FK_Blacklist_admin_id
        FOREIGN KEY (admin_id) REFERENCES dbo.Admin(admin_id);
    ALTER TABLE dbo.Product ADD CONSTRAINT FK_Product_business_id
        FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id);
    ALTER TABLE dbo.Favorite_Business ADD CONSTRAINT FK_Favorite_Business_customer_id
        FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id);
    ALTER TABLE dbo.Favorite_Business ADD CONSTRAINT FK_Favorite_Business_business_id
        FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id);
    ALTER TABLE dbo.Favorite_Product ADD CONSTRAINT FK_Favorite_Product_customer_id
        FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id);
    ALTER TABLE dbo.Favorite_Product ADD CONSTRAINT FK_Favorite_Product_product_id
        FOREIGN KEY (product_id) REFERENCES dbo.Product(product_id);
    ALTER TABLE dbo.Voucher ADD CONSTRAINT FK_Voucher_customer_id
        FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id);
    ALTER TABLE dbo.Cart ADD CONSTRAINT FK_Cart_customer_id
        FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id);
    ALTER TABLE dbo.Cart ADD CONSTRAINT FK_Cart_address_id
        FOREIGN KEY (address_id) REFERENCES dbo.Address(address_id);
    ALTER TABLE dbo.CartItem ADD CONSTRAINT FK_CartItem_cart_id
        FOREIGN KEY (cart_id) REFERENCES dbo.Cart(cart_id);
    ALTER TABLE dbo.CartItem ADD CONSTRAINT FK_CartItem_product_id
        FOREIGN KEY (product_id) REFERENCES dbo.Product(product_id);
    ALTER TABLE dbo.Orders ADD CONSTRAINT FK_Orders_cart_id
        FOREIGN KEY (cart_id) REFERENCES dbo.Cart(cart_id);
    ALTER TABLE dbo.Orders ADD CONSTRAINT FK_Orders_zone_id
        FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id);
    ALTER TABLE dbo.Orders ADD CONSTRAINT FK_Orders_voucher_id
        FOREIGN KEY (voucher_id) REFERENCES dbo.Voucher(voucher_id);
    ALTER TABLE dbo.SubOrder ADD CONSTRAINT FK_SubOrder_order_id
        FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id);
    ALTER TABLE dbo.SubOrder ADD CONSTRAINT FK_SubOrder_business_id
        FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id);
    ALTER TABLE dbo.Delivery ADD CONSTRAINT FK_Delivery_suborder_id
        FOREIGN KEY (suborder_id) REFERENCES dbo.SubOrder(suborder_id);
    ALTER TABLE dbo.Delivery ADD CONSTRAINT FK_Delivery_rider_id
        FOREIGN KEY (rider_id) REFERENCES dbo.Rider(rider_id);
    ALTER TABLE dbo.Payment ADD CONSTRAINT FK_Payment_order_id
        FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id);
    ALTER TABLE dbo.Payment ADD CONSTRAINT FK_Payment_card_id
        FOREIGN KEY (card_id) REFERENCES dbo.Card(card_id);
    ALTER TABLE dbo.Feedback ADD CONSTRAINT FK_Feedback_suborder_id
        FOREIGN KEY (suborder_id) REFERENCES dbo.SubOrder(suborder_id);

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
    SELECT
        z.zone_id,
        z.zone_name,
        COUNT(b.business_id) AS business_count
    FROM dbo.Zone AS z
    LEFT JOIN dbo.Business AS b ON b.zone_id = z.zone_id AND b.status = 'Active'
    GROUP BY z.zone_id, z.zone_name;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.Suspend_Business
    @business_id int,
    @admin_id int,
    @reason varchar(255)
AS
BEGIN
     IF @business_id IS NULL
        OR @admin_id IS NULL
        OR @reason IS NULL
        OR @reason = ''
    BEGIN
        RETURN -1;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Admin AS admin_user
        INNER JOIN dbo.Users AS account
            ON account.user_id = admin_user.admin_id
        INNER JOIN dbo.Business AS business
            ON business.business_id = @business_id
        WHERE admin_user.admin_id = @admin_id
            AND account.account_status = 'Active'
            AND
            (
                admin_user.role = 'Super Admin'
                OR
                (
                    admin_user.role = 'Zone Admin'
                    AND admin_user.zone_id = business.zone_id
                )
            )
    )
    BEGIN
        RETURN -3;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Business
        WHERE business_id = @business_id AND status = 'Active'
    )
    BEGIN
        RETURN -4;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.SubOrder AS suborder
        WHERE suborder.business_id = @business_id
            AND suborder.status IN ('Placed', 'Assigned')
            AND NOT EXISTS
            (
                SELECT 1
                FROM dbo.Payment AS payment
                WHERE payment.order_id = suborder.order_id
            )
    )
    BEGIN
        RETURN -7;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.Customer
        SET wallet_balance = wallet_balance + ISNULL
        (
            (
                SELECT SUM(refunds.refund_amount)
                FROM
                (
                    SELECT
                        cart.customer_id,
                        CASE
                            WHEN NOT EXISTS
                            (
                                SELECT 1
                                FROM dbo.SubOrder AS other_suborder
                                WHERE other_suborder.order_id = suborder.order_id
                                    AND other_suborder.suborder_id <> suborder.suborder_id
                                    AND other_suborder.status <> 'Cancelled'
                            )
                                OR suborder.total_price + suborder.delivery_fee
                                    > payment.amount - payment.refunded_amount
                            THEN payment.amount - payment.refunded_amount
                            ELSE suborder.total_price + suborder.delivery_fee
                        END AS refund_amount
                    FROM dbo.SubOrder AS suborder
                    INNER JOIN dbo.Payment AS payment
                        ON payment.order_id = suborder.order_id
                    INNER JOIN dbo.Orders AS customer_order
                        ON customer_order.order_id = suborder.order_id
                    INNER JOIN dbo.Cart AS cart
                        ON cart.cart_id = customer_order.cart_id
                    WHERE suborder.business_id = @business_id
                        AND suborder.status IN ('Placed', 'Assigned')
                        AND payment.method <> 'Cash'
                ) AS refunds
                WHERE refunds.customer_id = Customer.customer_id
            ), 0
        )

        WHERE customer_id IN
        (
            SELECT cart.customer_id
            FROM dbo.Cart AS cart
            INNER JOIN dbo.Orders AS customer_order
                ON customer_order.cart_id = cart.cart_id
            INNER JOIN dbo.SubOrder AS suborder
                ON suborder.order_id = customer_order.order_id
            WHERE suborder.business_id = @business_id
                AND suborder.status IN ('Placed', 'Assigned')
        );

        UPDATE dbo.Payment
        SET refunded_amount = refunded_amount +
        (
            SELECT
                CASE
                    WHEN NOT EXISTS
                    (
                        SELECT 1
                        FROM dbo.SubOrder AS other_suborder
                        WHERE other_suborder.order_id = suborder.order_id
                            AND other_suborder.suborder_id <> suborder.suborder_id
                            AND other_suborder.status <> 'Cancelled'
                    )
                        OR suborder.total_price + suborder.delivery_fee
                            > Payment.amount - Payment.refunded_amount
                    THEN Payment.amount - Payment.refunded_amount
                    ELSE suborder.total_price + suborder.delivery_fee
                END
            FROM dbo.SubOrder AS suborder
            WHERE suborder.order_id = Payment.order_id
                AND suborder.business_id = @business_id
                AND suborder.status IN ('Placed', 'Assigned')
        )
        WHERE order_id IN
        (
            SELECT order_id
            FROM dbo.SubOrder
            WHERE business_id = @business_id AND status IN ('Placed', 'Assigned')
        );
    
        UPDATE dbo.Orders
        SET status =
            CASE
                WHEN NOT EXISTS
                (
                    SELECT 1
                    FROM dbo.SubOrder AS suborder
                    WHERE suborder.order_id = Orders.order_id
                        AND suborder.status <> 'Cancelled'
                        AND NOT
                        (
                            suborder.business_id = @business_id
                            AND suborder.status IN ('Placed', 'Assigned')
                        )
                )
                THEN 'Cancelled'

                WHEN NOT EXISTS
                (
                    SELECT 1
                    FROM dbo.SubOrder AS suborder
                    WHERE suborder.order_id = Orders.order_id
                        AND suborder.status NOT IN ('Cancelled', 'Delivered')
                        AND NOT
                        (
                            suborder.business_id = @business_id
                            AND suborder.status IN ('Placed', 'Assigned')
                        )
                )
                THEN 'Delivered'

                WHEN EXISTS
                (
                    SELECT 1
                    FROM dbo.SubOrder AS suborder
                    WHERE suborder.order_id = Orders.order_id
                        AND suborder.status IN ('Picked Up', 'Delivered')
                )
                THEN 'In Progress'

                ELSE 'Placed'
            END
        WHERE order_id IN
        (
            SELECT order_id
            FROM dbo.SubOrder
            WHERE business_id = @business_id
                AND status IN ('Placed', 'Assigned')
        );
        
        UPDATE dbo.Voucher
        SET status = 'Unused'
        WHERE voucher_id IN
        (
            SELECT customer_order.voucher_id
            FROM dbo.Orders AS customer_order
            INNER JOIN dbo.SubOrder AS suborder ON suborder.order_id = customer_order.order_id
            WHERE customer_order.status = 'Cancelled'
                AND suborder.business_id = @business_id
                AND suborder.status IN ('Placed', 'Assigned')
        );

        UPDATE dbo.Orders
        SET voucher_id = NULL
        WHERE status = 'Cancelled'
            AND order_id IN
            (
                SELECT order_id
                FROM dbo.SubOrder
                WHERE business_id = @business_id AND status IN ('Placed', 'Assigned')
            );

        UPDATE dbo.SubOrder
        SET status = 'Cancelled'
        WHERE business_id = @business_id
            AND status IN ('Placed', 'Assigned');

        UPDATE dbo.Product
        SET is_available = 0
        WHERE business_id = @business_id;

        UPDATE dbo.Business
        SET
            status = 'Suspended',
            suspension_reason = @reason
        WHERE business_id = @business_id;

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
CREATE PROCEDURE dbo.Reinstate_Business
    @business_id int,
    @super_admin_id int
AS
BEGIN
    IF @business_id IS NULL
        OR @super_admin_id IS NULL
    BEGIN
        RETURN -1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Admin AS admin_user
        INNER JOIN dbo.Users AS account
            ON account.user_id = admin_user.admin_id
        WHERE admin_user.admin_id = @super_admin_id
            AND admin_user.role = 'Super Admin'
            AND account.account_status = 'Active'
    )
    BEGIN
        RETURN -3;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Business
        WHERE business_id = @business_id
            AND status = 'Suspended'
    )
    BEGIN
        RETURN -4;
    END;

    BEGIN TRY
        UPDATE dbo.Business
        SET
            status = 'Active',
            suspension_reason = NULL
        WHERE business_id = @business_id
            AND status = 'Suspended';

        RETURN 0;
    END TRY
    BEGIN CATCH
        RETURN -1;
    END CATCH;
END;
GO
-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.Create_Zone
    @zone_name VARCHAR(50),
    @delivery_fee DECIMAL(10, 2),
    @super_admin_id INT
AS
BEGIN
    IF @zone_name IS NULL
        OR @zone_name = ''
        OR @delivery_fee IS NULL
        OR @delivery_fee < 0
        OR @super_admin_id IS NULL
    BEGIN
        RETURN -1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Admin AS admin_user
        INNER JOIN dbo.Users AS account
            ON account.user_id = admin_user.admin_id
        WHERE admin_user.admin_id = @super_admin_id
            AND admin_user.role = 'Super Admin'
            AND account.account_status = 'Active'
    )
    BEGIN
        RETURN -3;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.Zone
        WHERE zone_name = @zone_name
    )
    BEGIN
        RETURN -2;
    END;

    BEGIN TRY
        INSERT INTO dbo.Zone (zone_name, delivery_fee)
        VALUES (@zone_name, @delivery_fee);

        RETURN 0;
    END TRY
    BEGIN CATCH
        RETURN -1;
    END CATCH;
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.Update_Zone_Fee
    @zone_id INT,
    @new_fee DECIMAL(10, 2),
    @super_admin_id INT
AS
BEGIN
    IF @zone_id IS NULL
        OR @new_fee IS NULL
        OR @new_fee < 0
        OR @super_admin_id IS NULL
    BEGIN
        RETURN -1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Admin AS admin_user
        INNER JOIN dbo.Users AS account ON account.user_id = admin_user.admin_id
        WHERE admin_user.admin_id = @super_admin_id
            AND admin_user.role = 'Super Admin'
            AND account.account_status = 'Active'
    )
    BEGIN
        RETURN -3;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Zone
        WHERE zone_id = @zone_id
    )
    BEGIN
        RETURN -1;
    END;

    BEGIN TRY
        UPDATE dbo.Zone
        SET delivery_fee = @new_fee
        WHERE zone_id = @zone_id;

        RETURN 0;
    END TRY
    BEGIN CATCH
        RETURN -1;
    END CATCH;
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE FUNCTION dbo.ZoneOrderReport(@zone_id INT, @from_date DATE, @to_date DATE)
RETURNS TABLE
AS
RETURN
(
    SELECT
        zone.zone_id,
        zone.zone_name,
        (
            SELECT COUNT(*)
            FROM dbo.Orders AS customer_order
            WHERE customer_order.zone_id = zone.zone_id
                AND customer_order.status <> 'Cancelled'
                AND CAST(customer_order.order_date AS DATE)
                    BETWEEN @from_date AND @to_date
        ) AS number_of_orders,
        CAST
        (
            (
                SELECT AVG(customer_order.total_amount)
                FROM dbo.Orders AS customer_order
                WHERE customer_order.zone_id = zone.zone_id
                    AND customer_order.status <> 'Cancelled'
                    AND CAST(customer_order.order_date AS DATE)
                        BETWEEN @from_date AND @to_date
            )
            AS DECIMAL(10, 2)
        ) AS avg_order_total,
        CAST
        (
            ISNULL
            (
                (
                    SELECT SUM(suborder.total_price) * 0.10
                    FROM dbo.Orders AS customer_order
                    INNER JOIN dbo.SubOrder AS suborder
                        ON suborder.order_id = customer_order.order_id
                    WHERE customer_order.zone_id = zone.zone_id
                        AND customer_order.status <> 'Cancelled'
                        AND suborder.status <> 'Cancelled'
                        AND CAST(customer_order.order_date AS DATE)
                            BETWEEN @from_date AND @to_date
                ), 0
            ) AS DECIMAL(10, 2)
        ) AS platform_commission
    FROM dbo.Zone AS zone
    WHERE zone.zone_id = @zone_id
        AND @from_date <= @to_date
);
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE FUNCTION dbo.Daily_Revenue_Report(@report_date DATE)
RETURNS TABLE
AS
RETURN
(
    -- Restaurant totals.
    SELECT
        zone.zone_name,
        CAST('Restaurant' AS VARCHAR(20)) AS business_type,
        COUNT(*) AS number_of_suborders,
        CAST(SUM(suborder.total_price) AS DECIMAL(10, 2)) AS gross_sales,
        CAST(SUM(suborder.delivery_fee) AS DECIMAL(10, 2)) AS delivery_fees,
        CAST(SUM(suborder.total_price) * 0.10 AS DECIMAL(10, 2)) AS platform_commission
    FROM dbo.Orders AS customer_order
    INNER JOIN dbo.Zone AS zone
        ON zone.zone_id = customer_order.zone_id
    INNER JOIN dbo.SubOrder AS suborder
        ON suborder.order_id = customer_order.order_id
    INNER JOIN dbo.Restaurant AS restaurant
        ON restaurant.business_id = suborder.business_id
    WHERE CAST(customer_order.order_date AS DATE) = @report_date
        AND suborder.status <> 'Cancelled'
    GROUP BY
        zone.zone_id,
        zone.zone_name

    UNION ALL

    -- Pharmacy totals
    SELECT
        zone.zone_name,
        CAST('Pharmacy' AS VARCHAR(20)),
        COUNT(*),
        CAST(SUM(suborder.total_price) AS DECIMAL(10, 2)),
        CAST(SUM(suborder.delivery_fee) AS DECIMAL(10, 2)),
        CAST(SUM(suborder.total_price) * 0.10 AS DECIMAL(10, 2))
    FROM dbo.Orders AS customer_order
    INNER JOIN dbo.Zone AS zone
        ON zone.zone_id = customer_order.zone_id
    INNER JOIN dbo.SubOrder AS suborder
        ON suborder.order_id = customer_order.order_id
    INNER JOIN dbo.Pharmacy AS pharmacy
        ON pharmacy.business_id = suborder.business_id
    WHERE CAST(customer_order.order_date AS DATE) = @report_date
        AND suborder.status <> 'Cancelled'
    GROUP BY
        zone.zone_id,
        zone.zone_name
);
GO

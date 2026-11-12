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
        ROLLBACK TRANSACTION;
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

    BEGIN TRY DROP VIEW dbo.allBusinessProfiles; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP VIEW dbo.BusinessRatingsSummary; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP VIEW dbo.ActiveVouchers; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP VIEW dbo.PendingBusinessApprovals; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP VIEW dbo.RiderPerformanceSummary; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP VIEW dbo.TopSellingProducts; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP VIEW dbo.ZoneDeliveryPerformance; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.CustomerLoginValidation; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.PartnerLoginValidation; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.RiderLoginValidation; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.AdminLoginValidation; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.TopRiders; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.BusinessSalesReport; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.BusinessFeedbackOverview; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.Calculate_Voucher_Discount; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.My_Order_History; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.My_Favorites; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.Recommended_Products; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.My_Active_Deliveries; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.My_Earnings; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.My_Rating_Summary; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.My_Delivery_History; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.Search_Platform; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.Reconcile_Order_Totals; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.Nearby_Businesses_By_Category; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.Platform_Health_Snapshot; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP FUNCTION dbo.Detect_Voucher_Abuse; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Customer_Register; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Partner_Register; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Rider_Register; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Change_Password; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Create_Admin; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Approve_Business; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Reject_Business; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Assign_Admin_Zone; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Issue_Voucher; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Blacklist_Customer; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Lift_Customer_Blacklist; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Register_Business; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Update_Business_Info; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Upsert_Product; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Toggle_Product_Status; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Set_Product_Promotion; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Add_Customer_Address; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Update_Delete_Customer_Address; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Add_Card; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Create_Cart; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Add_To_Cart; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Remove_From_Cart; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Checkout_Cart; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Cancel_Order; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Reorder; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Submit_Feedback; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Rate_Rider; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Toggle_Favorite; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Set_Rider_Availability; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Mark_Picked_Up; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Mark_Delivered; END TRY
    BEGIN CATCH END CATCH;

    BEGIN TRY DROP PROCEDURE dbo.Change_Active_Address; END TRY
    BEGIN CATCH END CATCH;

    DROP VIEW dbo.BusinessesPerZone;
    DROP FUNCTION dbo.ZoneOrderReport;
    DROP FUNCTION dbo.Daily_Revenue_Report;
    DROP PROCEDURE dbo.createAllTables;
    DROP PROCEDURE dbo.dropAllTables;
    DROP PROCEDURE dbo.clearAllTables;
    DROP PROCEDURE dbo.Suspend_Business;
    DROP PROCEDURE dbo.Reinstate_Business;
    DROP PROCEDURE dbo.Create_Zone;
    DROP PROCEDURE dbo.Update_Zone_Fee;

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
    SELECT z.zone_id, z.zone_name, COUNT(b.business_id) AS business_count
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
     IF @business_id IS NULL OR @admin_id IS NULL OR @reason IS NULL OR @reason = ''
    RETURN -1;


    IF NOT EXISTS
    (
    SELECT 1
    FROM dbo.Admin AS a
    INNER JOIN dbo.Users AS u ON u.user_id = a.admin_id
    INNER JOIN dbo.Business AS b ON b.business_id = @business_id
    WHERE a.admin_id = @admin_id AND u.account_status = 'Active'
      AND (a.role = 'Super Admin' OR (a.role = 'Zone Admin' AND a.zone_id = b.zone_id))
    )
    RETURN -3;

    IF NOT EXISTS (SELECT 1 FROM dbo.Business WHERE business_id = @business_id AND status = 'Active')
    RETURN -4;

    IF EXISTS
    (
    SELECT 1 FROM dbo.SubOrder AS s
    WHERE s.business_id = @business_id AND s.status IN ('Placed', 'Assigned')
      AND NOT EXISTS (SELECT 1 FROM dbo.Payment AS p WHERE p.order_id = s.order_id)
    )
    RETURN -7;

    BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE dbo.Customer
    SET wallet_balance = wallet_balance + ISNULL(
        (SELECT SUM(refunds.refund_amount) FROM
         (SELECT c.customer_id, CASE
        WHEN NOT EXISTS (SELECT 1 FROM dbo.SubOrder AS other
                 WHERE other.order_id = s.order_id
                   AND other.suborder_id <> s.suborder_id
                   AND other.status <> 'Cancelled')
             OR s.total_price + s.delivery_fee > p.amount - p.refunded_amount
        THEN p.amount - p.refunded_amount
        ELSE s.total_price + s.delivery_fee END AS refund_amount
         FROM dbo.SubOrder AS s
         INNER JOIN dbo.Payment AS p ON p.order_id = s.order_id
         INNER JOIN dbo.Orders AS o ON o.order_id = s.order_id
         INNER JOIN dbo.Cart AS c ON c.cart_id = o.cart_id
         WHERE s.business_id = @business_id AND s.status IN ('Placed', 'Assigned')
           AND p.method <> 'Cash') AS refunds
         WHERE refunds.customer_id = Customer.customer_id), 0)
    WHERE customer_id IN
    (
        SELECT c.customer_id FROM dbo.Cart AS c
        INNER JOIN dbo.Orders AS o ON o.cart_id = c.cart_id
        INNER JOIN dbo.SubOrder AS s ON s.order_id = o.order_id
        WHERE s.business_id = @business_id AND s.status IN ('Placed', 'Assigned')
    );

    UPDATE dbo.Payment
    SET refunded_amount = refunded_amount +
        (SELECT CASE
        WHEN NOT EXISTS (SELECT 1 FROM dbo.SubOrder AS other
                 WHERE other.order_id = s.order_id
                   AND other.suborder_id <> s.suborder_id
                   AND other.status <> 'Cancelled')
             OR s.total_price + s.delivery_fee > Payment.amount - Payment.refunded_amount
        THEN Payment.amount - Payment.refunded_amount
        ELSE s.total_price + s.delivery_fee END
         FROM dbo.SubOrder AS s
         WHERE s.order_id = Payment.order_id AND s.business_id = @business_id
           AND s.status IN ('Placed', 'Assigned'))
    WHERE order_id IN
    (
        SELECT order_id FROM dbo.SubOrder
        WHERE business_id = @business_id AND status IN ('Placed', 'Assigned')
    );
    UPDATE dbo.Orders
    SET status = CASE
        WHEN NOT EXISTS
        (SELECT 1 FROM dbo.SubOrder AS s WHERE s.order_id = Orders.order_id
         AND s.status <> 'Cancelled'
         AND NOT (s.business_id = @business_id AND s.status IN ('Placed', 'Assigned')))
        THEN 'Cancelled'
        WHEN NOT EXISTS
        (SELECT 1 FROM dbo.SubOrder AS s WHERE s.order_id = Orders.order_id
         AND s.status NOT IN ('Cancelled', 'Delivered')
         AND NOT (s.business_id = @business_id AND s.status IN ('Placed', 'Assigned')))
        THEN 'Delivered'
        WHEN EXISTS
        (SELECT 1 FROM dbo.SubOrder AS s WHERE s.order_id = Orders.order_id
         AND s.status IN ('Picked Up', 'Delivered'))
        THEN 'In Progress'
        ELSE 'Placed' END
    WHERE order_id IN
    (
        SELECT order_id FROM dbo.SubOrder
        WHERE business_id = @business_id AND status IN ('Placed', 'Assigned')
    );

    UPDATE dbo.Voucher
    SET status = 'Unused'
    WHERE voucher_id IN
    (
        SELECT o.voucher_id FROM dbo.Orders AS o
        INNER JOIN dbo.SubOrder AS s ON s.order_id = o.order_id
        WHERE o.status = 'Cancelled' AND s.business_id = @business_id
          AND s.status IN ('Placed', 'Assigned')
    );

    UPDATE dbo.Orders
    SET voucher_id = NULL
    WHERE status = 'Cancelled' AND order_id IN
    (
        SELECT order_id FROM dbo.SubOrder
        WHERE business_id = @business_id AND status IN ('Placed', 'Assigned')
    );

    UPDATE dbo.SubOrder
    SET status = 'Cancelled'
    WHERE business_id = @business_id AND status IN ('Placed', 'Assigned');

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
    END CATCH;
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.Reinstate_Business
    @business_id int,
    @super_admin_id int
AS
BEGIN
    IF @business_id IS NULL OR @super_admin_id IS NULL
    RETURN -1;

    IF NOT EXISTS
    (
    SELECT 1 FROM dbo.Admin AS a
    INNER JOIN dbo.Users AS u ON u.user_id = a.admin_id
    WHERE a.admin_id = @super_admin_id AND a.role = 'Super Admin'
      AND u.account_status = 'Active'
    )
    RETURN -3;

    IF NOT EXISTS (SELECT 1 FROM dbo.Business
           WHERE business_id = @business_id AND status = 'Suspended')
    RETURN -4;

    BEGIN TRY
    UPDATE dbo.Business
    SET status = 'Active', suspension_reason = NULL
    WHERE business_id = @business_id AND status = 'Suspended';

    RETURN 0;
    END TRY
    BEGIN CATCH
    RETURN -1;
    END CATCH;
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.Create_Zone
    @zone_name varchar(50),
    @delivery_fee decimal(10,2),
    @super_admin_id int
AS
BEGIN
    IF @zone_name IS NULL OR @zone_name = ''
       OR @delivery_fee IS NULL OR @delivery_fee < 0 OR @super_admin_id IS NULL
    RETURN -1;

    IF NOT EXISTS
    (
    SELECT 1 FROM dbo.Admin AS a
    INNER JOIN dbo.Users AS u ON u.user_id = a.admin_id
    WHERE a.admin_id = @super_admin_id AND a.role = 'Super Admin'
      AND u.account_status = 'Active'
    )
    RETURN -3;

    IF EXISTS (SELECT 1 FROM dbo.Zone WHERE zone_name = @zone_name)
    RETURN -2;

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
    @zone_id int,
    @new_fee decimal(10,2),
    @super_admin_id int
AS
BEGIN
    IF @zone_id IS NULL OR @new_fee IS NULL OR @new_fee < 0 OR @super_admin_id IS NULL
    RETURN -1;

    IF NOT EXISTS
    (
    SELECT 1 FROM dbo.Admin AS a
    INNER JOIN dbo.Users AS u ON u.user_id = a.admin_id
    WHERE a.admin_id = @super_admin_id AND a.role = 'Super Admin'
      AND u.account_status = 'Active'
    )
    RETURN -3;

    IF NOT EXISTS (SELECT 1 FROM dbo.Zone WHERE zone_id = @zone_id)
    RETURN -1;

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
CREATE FUNCTION dbo.ZoneOrderReport
(
    @zone_id int,
    @from_date date,
    @to_date date
)
RETURNS TABLE
AS
RETURN
(
    SELECT z.zone_id, z.zone_name,
    (SELECT COUNT(*) FROM dbo.Orders AS o
     WHERE o.zone_id = z.zone_id AND o.status <> 'Cancelled'
       AND CAST(o.order_date AS date) BETWEEN @from_date AND @to_date) AS number_of_orders,
    CAST((SELECT AVG(o.total_amount) FROM dbo.Orders AS o
          WHERE o.zone_id = z.zone_id AND o.status <> 'Cancelled'
        AND CAST(o.order_date AS date) BETWEEN @from_date AND @to_date)
         AS decimal(10,2)) AS avg_order_total,
    CAST(ISNULL((SELECT SUM(s.total_price) * 0.10
             FROM dbo.Orders AS o
             INNER JOIN dbo.SubOrder AS s ON s.order_id = o.order_id
             WHERE o.zone_id = z.zone_id AND o.status <> 'Cancelled'
               AND s.status <> 'Cancelled'
               AND CAST(o.order_date AS date) BETWEEN @from_date AND @to_date), 0)
         AS decimal(10,2)) AS platform_commission
    FROM dbo.Zone AS z
    WHERE z.zone_id = @zone_id AND @from_date <= @to_date
);
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE FUNCTION dbo.Daily_Revenue_Report
(
    @report_date date
)
RETURNS TABLE
AS
RETURN
(
    SELECT z.zone_name, CAST('Restaurant' AS varchar(20)) AS business_type,
    COUNT(*) AS number_of_suborders,
    CAST(SUM(s.total_price) AS decimal(10,2)) AS gross_sales,
    CAST(SUM(s.delivery_fee) AS decimal(10,2)) AS delivery_fees,
    CAST(SUM(s.total_price) * 0.10 AS decimal(10,2)) AS platform_commission
    FROM dbo.Orders AS o
    INNER JOIN dbo.Zone AS z ON z.zone_id = o.zone_id
    INNER JOIN dbo.SubOrder AS s ON s.order_id = o.order_id
    INNER JOIN dbo.Restaurant AS r ON r.business_id = s.business_id
    WHERE CAST(o.order_date AS date) = @report_date AND s.status <> 'Cancelled'
    GROUP BY z.zone_id, z.zone_name

    UNION ALL

    SELECT z.zone_name, CAST('Pharmacy' AS varchar(20)), COUNT(*),
    CAST(SUM(s.total_price) AS decimal(10,2)),
    CAST(SUM(s.delivery_fee) AS decimal(10,2)),
    CAST(SUM(s.total_price) * 0.10 AS decimal(10,2))
    FROM dbo.Orders AS o
    INNER JOIN dbo.Zone AS z ON z.zone_id = o.zone_id
    INNER JOIN dbo.SubOrder AS s ON s.order_id = o.order_id
    INNER JOIN dbo.Pharmacy AS p ON p.business_id = s.business_id
    WHERE CAST(o.order_date AS date) = @report_date AND s.status <> 'Cancelled'
    GROUP BY z.zone_id, z.zone_name
);
GO

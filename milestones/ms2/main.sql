CREATE DATABASE LocalDeliveryMarketplace_Team_44;
GO

USE LocalDeliveryMarketplace_Team_44;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.createAllTables
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        CREATE TABLE dbo.Zone
        (
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
            FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id)
        );

        CREATE TABLE dbo.Admin
        (
            admin_id int NOT NULL,
            role varchar(20) NOT NULL DEFAULT 'Super Admin' CHECK (role IN ('Super Admin', 'Zone Admin')),
            zone_id int NULL,
            PRIMARY KEY (admin_id),
            FOREIGN KEY (admin_id) REFERENCES dbo.Users(user_id),
            FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id),
            CHECK ((role = 'Super Admin' AND zone_id IS NULL) OR (role = 'Zone Admin' AND zone_id IS NOT NULL))
        );

        CREATE TABLE dbo.Partner
        (
            partner_id int NOT NULL,
            PRIMARY KEY (partner_id),
            FOREIGN KEY (partner_id) REFERENCES dbo.Users(user_id)
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
            FOREIGN KEY (rider_id) REFERENCES dbo.Users(user_id),
            FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id)
        );

        CREATE TABLE dbo.Customer
        (
            customer_id int NOT NULL,
            wallet_balance decimal(10,2) NOT NULL DEFAULT 0 CHECK (wallet_balance >= 0),
            PRIMARY KEY (customer_id),
            FOREIGN KEY (customer_id) REFERENCES dbo.Users(user_id)
        );

        CREATE TABLE dbo.Address
        (
            address_id int identity(1,1) NOT NULL,
            description varchar(150) NOT NULL,
            is_active bit NOT NULL DEFAULT 1,
            customer_id int NOT NULL,
            zone_id int NOT NULL,
            PRIMARY KEY (address_id),
            FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
            FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id)
        );

        CREATE UNIQUE INDEX UX_Address_Active ON dbo.Address(customer_id) WHERE is_active = 1;

        CREATE TABLE dbo.Card
        (
            card_id int identity(1,1) NOT NULL,
            card_no char(16) NOT NULL,
            card_holder_name varchar(100) NOT NULL,
            expiration_date date NOT NULL,
            customer_id int NOT NULL,
            PRIMARY KEY (card_id),
            FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
            UNIQUE (customer_id, card_no)
        );

        CREATE TABLE dbo.Business
        (
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
            FOREIGN KEY (partner_id) REFERENCES dbo.Partner(partner_id),
            FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id),
            CHECK (status = 'Suspended' OR suspension_reason IS NULL)
        );

        CREATE TABLE dbo.Business_Phone
        (
            business_id int NOT NULL,
            phone char(11) NOT NULL,
            PRIMARY KEY (business_id, phone),
            FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id)
        );

        CREATE TABLE dbo.Restaurant
        (
            business_id int NOT NULL,
            cuisine_type varchar(50) NOT NULL,
            food_category varchar(50) NOT NULL,
            PRIMARY KEY (business_id),
            FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id)
        );

        CREATE TABLE dbo.Pharmacy
        (
            business_id int NOT NULL,
            pharmacy_type varchar(50) NOT NULL,
            PRIMARY KEY (business_id),
            FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id)
        );

        CREATE TABLE dbo.Blacklist
        (
            customer_id int NOT NULL,
            admin_id int NOT NULL,
            reason varchar(255) NOT NULL,
            PRIMARY KEY (customer_id),
            FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
            FOREIGN KEY (admin_id) REFERENCES dbo.Admin(admin_id)
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
            FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id),
            CHECK (discount_amount >= 0 AND discount_amount <= 0.5 * price)
        );

        CREATE TABLE dbo.Favorite_Business
        (
            customer_id int NOT NULL,
            business_id int NOT NULL,
            PRIMARY KEY (customer_id, business_id),
            FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
            FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id)
        );

        CREATE TABLE dbo.Favorite_Product
        (
            customer_id int NOT NULL,
            product_id int NOT NULL,
            PRIMARY KEY (customer_id, product_id),
            FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
            FOREIGN KEY (product_id) REFERENCES dbo.Product(product_id)
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
            FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
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
            FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id),
            FOREIGN KEY (address_id) REFERENCES dbo.Address(address_id)
        );

        CREATE UNIQUE INDEX UX_Cart_Active ON dbo.Cart(customer_id, address_id) WHERE status = 'Active';

        CREATE TABLE dbo.CartItem
        (
            cart_id int NOT NULL,
            product_id int NOT NULL,
            quantity int NOT NULL CHECK (quantity BETWEEN 1 AND 10),
            notes varchar(255) NULL,
            unit_price decimal(10,2) NULL,
            PRIMARY KEY (cart_id, product_id),
            FOREIGN KEY (cart_id) REFERENCES dbo.Cart(cart_id),
            FOREIGN KEY (product_id) REFERENCES dbo.Product(product_id)
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
            FOREIGN KEY (cart_id) REFERENCES dbo.Cart(cart_id),
            FOREIGN KEY (zone_id) REFERENCES dbo.Zone(zone_id),
            FOREIGN KEY (voucher_id) REFERENCES dbo.Voucher(voucher_id)
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
            FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
            FOREIGN KEY (business_id) REFERENCES dbo.Business(business_id),
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
            FOREIGN KEY (suborder_id) REFERENCES dbo.SubOrder(suborder_id),
            FOREIGN KEY (rider_id) REFERENCES dbo.Rider(rider_id)
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
            FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
            FOREIGN KEY (card_id) REFERENCES dbo.Card(card_id),
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
            FOREIGN KEY (suborder_id) REFERENCES dbo.SubOrder(suborder_id)
        );

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        IF ERROR_NUMBER() = 2714
            RETURN -2;
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
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

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
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH;
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.dropAllProceduresFunctionsViews
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @object_id int, @object_name nvarchar(517), @object_type char(2);
    DECLARE @statement nvarchar(max);

    BEGIN TRY
        BEGIN TRANSACTION;

        WHILE EXISTS
        (
            SELECT 1
            FROM sys.objects
            WHERE type IN ('P', 'PC', 'V', 'FN', 'IF', 'TF', 'FS', 'FT')
              AND is_ms_shipped = 0 AND object_id <> @@PROCID
        )
        BEGIN
            SET @object_id = NULL;

            SELECT TOP (1) @object_id = o.object_id,
                @object_name = QUOTENAME(SCHEMA_NAME(o.schema_id)) + '.' + QUOTENAME(o.name),
                @object_type = o.type
            FROM sys.objects AS o
            WHERE o.type IN ('P', 'PC', 'V', 'FN', 'IF', 'TF', 'FS', 'FT')
              AND o.is_ms_shipped = 0 AND o.object_id <> @@PROCID
              AND NOT EXISTS
              (
                  SELECT 1
                  FROM sys.sql_expression_dependencies AS d
                  WHERE d.referenced_id = o.object_id
                    AND d.referencing_id <> o.object_id
                    AND d.is_schema_bound_reference = 1
              )
            ORDER BY o.object_id;

            IF @object_id IS NULL
            BEGIN
                ROLLBACK TRANSACTION;
                RETURN -1;
            END;

            SET @statement = 'DROP ' + CASE
                WHEN @object_type IN ('P', 'PC') THEN 'PROCEDURE '
                WHEN @object_type = 'V' THEN 'VIEW '
                ELSE 'FUNCTION ' END + @object_name + ';';
            EXEC sys.sp_executesql @statement;
        END;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH;
END;
GO

-- mohamed mostafa hassan mohamed - 65-33784
CREATE PROCEDURE dbo.clearAllTables
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM dbo.Feedback;
        DELETE FROM dbo.Payment;
        DELETE FROM dbo.Delivery;
        DELETE FROM dbo.SubOrder;
        DELETE FROM dbo.Orders;
        DELETE FROM dbo.CartItem;
        DELETE FROM dbo.Cart;
        DELETE FROM dbo.Voucher;
        DELETE FROM dbo.Favorite_Product;
        DELETE FROM dbo.Favorite_Business;
        DELETE FROM dbo.Product;
        DELETE FROM dbo.Blacklist;
        DELETE FROM dbo.Pharmacy;
        DELETE FROM dbo.Restaurant;
        DELETE FROM dbo.Business_Phone;
        DELETE FROM dbo.Business;
        DELETE FROM dbo.Card;
        DELETE FROM dbo.Address;
        DELETE FROM dbo.Customer;
        DELETE FROM dbo.Rider;
        DELETE FROM dbo.Partner;
        DELETE FROM dbo.Admin;
        DELETE FROM dbo.User_Phone;
        DELETE FROM dbo.Users;
        DELETE FROM dbo.Zone;

        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Zone') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.Zone', RESEED, 0) WITH NO_INFOMSGS;
        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Users') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.Users', RESEED, 0) WITH NO_INFOMSGS;
        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Address') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.Address', RESEED, 0) WITH NO_INFOMSGS;
        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Card') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.Card', RESEED, 0) WITH NO_INFOMSGS;
        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Business') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.Business', RESEED, 0) WITH NO_INFOMSGS;
        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Product') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.Product', RESEED, 0) WITH NO_INFOMSGS;
        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Voucher') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.Voucher', RESEED, 0) WITH NO_INFOMSGS;
        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Cart') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.Cart', RESEED, 0) WITH NO_INFOMSGS;
        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Orders') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.Orders', RESEED, 0) WITH NO_INFOMSGS;
        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.SubOrder') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.SubOrder', RESEED, 0) WITH NO_INFOMSGS;
        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Delivery') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.Delivery', RESEED, 0) WITH NO_INFOMSGS;
        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Payment') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.Payment', RESEED, 0) WITH NO_INFOMSGS;
        IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Feedback') AND last_value IS NOT NULL)
            DBCC CHECKIDENT ('dbo.Feedback', RESEED, 0) WITH NO_INFOMSGS;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
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
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @business_id IS NULL OR @admin_id IS NULL
       OR @reason IS NULL OR LEN(LTRIM(RTRIM(@reason))) = 0
        RETURN -1;

    DECLARE @status varchar(20), @zone_id int;
    DECLARE @cancelled TABLE
    (
        suborder_id int PRIMARY KEY,
        order_id int,
        refund_amount decimal(19,2)
    );
    DECLARE @refunds TABLE
    (
        order_id int PRIMARY KEY,
        customer_id int,
        method varchar(20),
        refund_amount decimal(10,2)
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @status = status, @zone_id = zone_id
        FROM dbo.Business WITH (UPDLOCK, HOLDLOCK)
        WHERE business_id = @business_id;

        IF @status IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN -1;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Admin AS a WITH (HOLDLOCK)
            INNER JOIN dbo.Users AS u WITH (HOLDLOCK) ON u.user_id = a.admin_id
            WHERE a.admin_id = @admin_id AND u.account_status = 'Active'
              AND (a.role = 'Super Admin' OR (a.role = 'Zone Admin' AND a.zone_id = @zone_id))
        )
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN -3;
        END;

        IF @status <> 'Active'
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN -4;
        END;

        UPDATE dbo.Business
        SET status = 'Suspended', suspension_reason = @reason
        WHERE business_id = @business_id;

        UPDATE dbo.Product
        SET is_available = 0
        WHERE business_id = @business_id;

        UPDATE dbo.SubOrder WITH (UPDLOCK, HOLDLOCK)
        SET status = 'Cancelled'
        OUTPUT inserted.suborder_id, inserted.order_id,
            inserted.total_price + inserted.delivery_fee
        INTO @cancelled (suborder_id, order_id, refund_amount)
        WHERE business_id = @business_id AND status IN ('Placed', 'Assigned');

        UPDATE o
        SET status = CASE
            WHEN NOT EXISTS
                (SELECT 1 FROM dbo.SubOrder AS s WITH (HOLDLOCK)
                 WHERE s.order_id = o.order_id AND s.status <> 'Cancelled')
                THEN 'Cancelled'
            WHEN NOT EXISTS
                (SELECT 1 FROM dbo.SubOrder AS s WITH (HOLDLOCK)
                 WHERE s.order_id = o.order_id AND s.status NOT IN ('Cancelled', 'Delivered'))
                THEN 'Delivered'
            WHEN EXISTS
                (SELECT 1 FROM dbo.SubOrder AS s WITH (HOLDLOCK)
                 WHERE s.order_id = o.order_id AND s.status IN ('Picked Up', 'Delivered'))
                THEN 'In Progress'
            ELSE 'Placed' END
        FROM dbo.Orders AS o
        WHERE EXISTS (SELECT 1 FROM @cancelled AS c WHERE c.order_id = o.order_id);

        IF EXISTS
        (
            SELECT 1 FROM @cancelled AS c
            WHERE NOT EXISTS
                (SELECT 1 FROM dbo.Payment AS p WITH (UPDLOCK, HOLDLOCK)
                 WHERE p.order_id = c.order_id)
        )
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN -7;
        END;

        INSERT INTO @refunds (order_id, customer_id, method, refund_amount)
        SELECT o.order_id, cart.customer_id, p.method,
            CASE WHEN o.status = 'Cancelled'
                       OR c.refund_amount > p.amount - p.refunded_amount
                 THEN p.amount - p.refunded_amount
                 ELSE c.refund_amount END
        FROM
        (
            SELECT order_id, SUM(refund_amount) AS refund_amount
            FROM @cancelled
            GROUP BY order_id
        ) AS c
        INNER JOIN dbo.Orders AS o ON o.order_id = c.order_id
        INNER JOIN dbo.Cart AS cart ON cart.cart_id = o.cart_id
        INNER JOIN dbo.Payment AS p WITH (UPDLOCK, HOLDLOCK) ON p.order_id = o.order_id;

        UPDATE p
        SET refunded_amount = p.refunded_amount + r.refund_amount
        FROM dbo.Payment AS p
        INNER JOIN @refunds AS r ON r.order_id = p.order_id;

        UPDATE c
        SET wallet_balance = c.wallet_balance + r.refund_amount
        FROM dbo.Customer AS c
        INNER JOIN
        (
            SELECT customer_id, SUM(refund_amount) AS refund_amount
            FROM @refunds
            WHERE method <> 'Cash'
            GROUP BY customer_id
        ) AS r ON r.customer_id = c.customer_id;

        UPDATE v
        SET status = 'Unused'
        FROM dbo.Voucher AS v
        INNER JOIN dbo.Orders AS o ON o.voucher_id = v.voucher_id
        WHERE o.status = 'Cancelled'
          AND EXISTS (SELECT 1 FROM @cancelled AS c WHERE c.order_id = o.order_id);

        UPDATE o
        SET voucher_id = NULL
        FROM dbo.Orders AS o
        WHERE o.status = 'Cancelled'
          AND EXISTS (SELECT 1 FROM @cancelled AS c WHERE c.order_id = o.order_id);

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
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
    SET NOCOUNT ON;

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

    BEGIN TRY
        UPDATE dbo.Business
        SET status = 'Active', suspension_reason = NULL
        WHERE business_id = @business_id AND status = 'Suspended';

        IF @@ROWCOUNT = 0
            RETURN -4;
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
    SET NOCOUNT ON;

    IF @zone_name IS NULL OR LEN(LTRIM(RTRIM(@zone_name))) = 0
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
        IF ERROR_NUMBER() IN (2601, 2627)
            RETURN -2;
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
    SET NOCOUNT ON;

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

    BEGIN TRY
        UPDATE dbo.Zone
        SET delivery_fee = @new_fee
        WHERE zone_id = @zone_id;

        IF @@ROWCOUNT = 0
            RETURN -1;
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
    WITH report AS
    (
    SELECT z.zone_id, z.zone_name,
        TRY_CAST((SELECT COUNT_BIG(*) FROM dbo.Orders AS o
         WHERE o.zone_id = z.zone_id AND o.status <> 'Cancelled'
           AND CAST(o.order_date AS date) BETWEEN @from_date AND @to_date) AS int) AS number_of_orders,
        TRY_CAST((SELECT AVG(o.total_amount) FROM dbo.Orders AS o
              WHERE o.zone_id = z.zone_id AND o.status <> 'Cancelled'
                AND CAST(o.order_date AS date) BETWEEN @from_date AND @to_date)
             AS decimal(10,2)) AS avg_order_total,
        TRY_CAST(COALESCE((SELECT SUM(s.total_price) * 0.10
                       FROM dbo.Orders AS o
                       INNER JOIN dbo.SubOrder AS s ON s.order_id = o.order_id
                       WHERE o.zone_id = z.zone_id AND o.status <> 'Cancelled'
                         AND s.status <> 'Cancelled'
                         AND CAST(o.order_date AS date) BETWEEN @from_date AND @to_date), 0)
             AS decimal(10,2)) AS platform_commission
    FROM dbo.Zone AS z
    WHERE z.zone_id = @zone_id AND @from_date <= @to_date
    )
    SELECT zone_id, zone_name, number_of_orders, avg_order_total, platform_commission
    FROM report
    WHERE number_of_orders IS NOT NULL AND platform_commission IS NOT NULL
      AND (number_of_orders = 0 OR avg_order_total IS NOT NULL)
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
    WITH report AS
    (
    SELECT z.zone_name, b.business_type, TRY_CAST(COUNT_BIG(*) AS int) AS number_of_suborders,
        TRY_CAST(SUM(s.total_price) AS decimal(10,2)) AS gross_sales,
        TRY_CAST(SUM(s.delivery_fee) AS decimal(10,2)) AS delivery_fees,
        TRY_CAST(SUM(s.total_price) * 0.10 AS decimal(10,2)) AS platform_commission
    FROM dbo.Orders AS o
    INNER JOIN dbo.Zone AS z ON z.zone_id = o.zone_id
    INNER JOIN dbo.SubOrder AS s ON s.order_id = o.order_id
    INNER JOIN
    (
        SELECT business_id, CAST('Restaurant' AS varchar(20)) AS business_type
        FROM dbo.Restaurant
        UNION ALL
        SELECT business_id, CAST('Pharmacy' AS varchar(20)) AS business_type
        FROM dbo.Pharmacy
    ) AS b ON b.business_id = s.business_id
    WHERE CAST(o.order_date AS date) = @report_date AND s.status <> 'Cancelled'
    GROUP BY z.zone_id, z.zone_name, b.business_type
    )
    SELECT zone_name, business_type, number_of_suborders, gross_sales, delivery_fees, platform_commission
    FROM report
    WHERE NOT EXISTS
    (
        SELECT 1 FROM report
        WHERE number_of_suborders IS NULL OR gross_sales IS NULL
           OR delivery_fees IS NULL OR platform_commission IS NULL
    )
);
GO

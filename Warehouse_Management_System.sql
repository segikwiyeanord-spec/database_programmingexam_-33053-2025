/******************************************************************************
* UNIVERSITY OF LAY ADVENTISTS OF KIGALI
* PROJECT TITLE : WAREHOUSE MANAGEMENT SYSTEM
* COURSE        : DATABASE PROGRAMMING (DPR400210)
*
* STUDENT NAME  : Segikwiye Anord
* REG NO        : 33053/2025
*
* DESCRIPTION:
* Warehouse Management System developed using Oracle SQL and PL/SQL.
******************************************************************************/

SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- PART 1 : DATABASE DESIGN
--------------------------------------------------------------------------------

BEGIN EXECUTE IMMEDIATE 'DROP TABLE Orders CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE Products CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE Customers CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE Suppliers CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE Categories CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

--------------------------------------------------------------------------------
-- SUPPLIERS TABLE
--------------------------------------------------------------------------------

CREATE TABLE Suppliers
(
    Supplier_ID NUMBER PRIMARY KEY,
    Supplier_Name VARCHAR2(100) NOT NULL,
    Phone VARCHAR2(20),
    Email VARCHAR2(100)
);

--------------------------------------------------------------------------------
-- CATEGORIES TABLE
--------------------------------------------------------------------------------

CREATE TABLE Categories
(
    Category_ID NUMBER PRIMARY KEY,
    Category_Name VARCHAR2(100) NOT NULL
);

--------------------------------------------------------------------------------
-- CUSTOMERS TABLE
--------------------------------------------------------------------------------

CREATE TABLE Customers
(
    Customer_ID NUMBER PRIMARY KEY,
    Customer_Name VARCHAR2(100) NOT NULL,
    Phone VARCHAR2(20)
);

--------------------------------------------------------------------------------
-- PRODUCTS TABLE
--------------------------------------------------------------------------------

CREATE TABLE Products
(
    Product_ID NUMBER PRIMARY KEY,
    Product_Name VARCHAR2(100) NOT NULL,
    Category_ID NUMBER NOT NULL,
    Supplier_ID NUMBER NOT NULL,
    Unit_Price NUMBER(10,2),
    Quantity_In_Stock NUMBER DEFAULT 0,

    CONSTRAINT FK_Product_Category
    FOREIGN KEY(Category_ID)
    REFERENCES Categories(Category_ID),

    CONSTRAINT FK_Product_Supplier
    FOREIGN KEY(Supplier_ID)
    REFERENCES Suppliers(Supplier_ID)
);

--------------------------------------------------------------------------------
-- ORDERS TABLE
--------------------------------------------------------------------------------

CREATE TABLE Orders
(
    Order_ID NUMBER PRIMARY KEY,
    Customer_ID NUMBER NOT NULL,
    Product_ID NUMBER NOT NULL,
    Quantity NUMBER NOT NULL,
    Order_Date DATE DEFAULT SYSDATE,

    CONSTRAINT FK_Order_Customer
    FOREIGN KEY(Customer_ID)
    REFERENCES Customers(Customer_ID),

    CONSTRAINT FK_Order_Product
    FOREIGN KEY(Product_ID)
    REFERENCES Products(Product_ID)
);

--------------------------------------------------------------------------------
-- PART 2 : INSERT SAMPLE DATA
--------------------------------------------------------------------------------

INSERT INTO Suppliers VALUES
(101,'Kigali Electronics Ltd','0788123456','kigali@gmail.com');

INSERT INTO Suppliers VALUES
(102,'Tech Solutions Ltd','0788234567','tech@gmail.com');

INSERT INTO Suppliers VALUES
(103,'Global Furniture Ltd','0788345678','global@gmail.com');

INSERT INTO Categories VALUES
(1,'Electronics');

INSERT INTO Categories VALUES
(2,'Furniture');

INSERT INTO Categories VALUES
(3,'Computer Accessories');

INSERT INTO Customers VALUES
(1001,'John Doe','0788111111');

INSERT INTO Customers VALUES
(1002,'Alice Smith','0788222222');

INSERT INTO Customers VALUES
(1003,'Eric Niyonzima','0788333333');

INSERT INTO Products VALUES
(2001,'HP Laptop',1,101,1200,20);

INSERT INTO Products VALUES
(2002,'Dell Desktop',1,101,950,15);

INSERT INTO Products VALUES
(2003,'Office Chair',2,103,180,30);

INSERT INTO Products VALUES
(2004,'Wireless Mouse',3,102,25,50);

INSERT INTO Products VALUES
(2005,'Keyboard',3,102,35,40);

INSERT INTO Orders VALUES
(5001,1001,2001,2,SYSDATE);

INSERT INTO Orders VALUES
(5002,1002,2004,3,SYSDATE);

COMMIT;

--------------------------------------------------------------------------------
-- VERIFY DATA
--------------------------------------------------------------------------------

SELECT * FROM Suppliers;
SELECT * FROM Categories;
SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;

--------------------------------------------------------------------------------
-- PART 3 : ANONYMOUS BLOCK
--------------------------------------------------------------------------------

BEGIN

    INSERT INTO Products
    VALUES
    (
        2010,
        'Laser Printer',
        1,
        101,
        450,
        15
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE
    (
        'New Product Added Successfully'
    );

EXCEPTION

WHEN DUP_VAL_ON_INDEX THEN

    DBMS_OUTPUT.PUT_LINE
    (
        'Product Already Exists'
    );

WHEN OTHERS THEN

    DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

--------------------------------------------------------------------------------
-- FUNCTION : GET PRODUCT STOCK
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION Get_Product_Stock
(
    p_Product_ID NUMBER
)
RETURN NUMBER

IS

    v_stock NUMBER;

BEGIN

    SELECT Quantity_In_Stock

    INTO v_stock

    FROM Products

    WHERE Product_ID = p_Product_ID;

    RETURN v_stock;

EXCEPTION

WHEN NO_DATA_FOUND THEN

    RETURN -1;

END;
/

--------------------------------------------------------------------------------
-- TEST FUNCTION
--------------------------------------------------------------------------------

SELECT
Get_Product_Stock(2001)
AS Current_Stock
FROM Dual;

--------------------------------------------------------------------------------
-- STORED PROCEDURE : SELL PRODUCT
--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE Sell_Product
(
    p_Order_ID NUMBER,
    p_Customer_ID NUMBER,
    p_Product_ID NUMBER,
    p_Quantity NUMBER
)

IS

    v_stock NUMBER;

BEGIN

    SELECT Quantity_In_Stock

    INTO v_stock

    FROM Products

    WHERE Product_ID = p_Product_ID;

    IF v_stock >= p_Quantity THEN

        UPDATE Products

        SET Quantity_In_Stock =
        Quantity_In_Stock - p_Quantity

        WHERE Product_ID = p_Product_ID;

        INSERT INTO Orders
        (
            Order_ID,
            Customer_ID,
            Product_ID,
            Quantity,
            Order_Date
        )

        VALUES
        (
            p_Order_ID,
            p_Customer_ID,
            p_Product_ID,
            p_Quantity,
            SYSDATE
        );

        COMMIT;

        DBMS_OUTPUT.PUT_LINE
        (
            'Order Completed Successfully'
        );

    ELSE

        DBMS_OUTPUT.PUT_LINE
        (
            'Insufficient Stock'
        );

    END IF;

EXCEPTION

WHEN NO_DATA_FOUND THEN

    DBMS_OUTPUT.PUT_LINE
    (
        'Product Not Found'
    );

WHEN OTHERS THEN

    DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

--------------------------------------------------------------------------------
-- EXECUTE PROCEDURE
--------------------------------------------------------------------------------

BEGIN

    Sell_Product
    (
        6001,
        1001,
        2001,
        3
    );

END;
/

--------------------------------------------------------------------------------
-- VERIFY UPDATED STOCK
--------------------------------------------------------------------------------

SELECT *
FROM Products
WHERE Product_ID = 2001;

--------------------------------------------------------------------------------
-- VERIFY ORDER
--------------------------------------------------------------------------------

SELECT *
FROM Orders
WHERE Order_ID = 6001;

--------------------------------------------------------------------------------
-- PART 4 : WINDOW FUNCTIONS & REPORTS
--------------------------------------------------------------------------------

SELECT

    Product_ID,
    Product_Name,
    Quantity_In_Stock,

    RANK()
    OVER
    (
        ORDER BY Quantity_In_Stock DESC
    ) AS Stock_Rank

FROM Products;

--------------------------------------------------------------------------------
-- DENSE RANK
--------------------------------------------------------------------------------

SELECT

    Product_Name,
    Quantity_In_Stock,

    DENSE_RANK()
    OVER
    (
        ORDER BY Quantity_In_Stock DESC
    ) AS Dense_Rank

FROM Products;

--------------------------------------------------------------------------------
-- ROW NUMBER
--------------------------------------------------------------------------------

SELECT

    Product_Name,

    ROW_NUMBER()
    OVER
    (
        ORDER BY Product_Name
    ) AS Row_Num

FROM Products;

--------------------------------------------------------------------------------
-- INVENTORY REPORT
--------------------------------------------------------------------------------

SELECT

    P.Product_Name,
    P.Unit_Price,
    P.Quantity_In_Stock,

    (P.Unit_Price * P.Quantity_In_Stock)
    AS Inventory_Value

FROM Products P;

--------------------------------------------------------------------------------
-- TOTAL INVENTORY VALUE
--------------------------------------------------------------------------------

SELECT

SUM(Unit_Price * Quantity_In_Stock)
AS Total_Inventory_Value

FROM Products;

--------------------------------------------------------------------------------
-- LOW STOCK REPORT
--------------------------------------------------------------------------------

SELECT *

FROM Products

WHERE Quantity_In_Stock < 20;

--------------------------------------------------------------------------------
-- SALES REPORT
--------------------------------------------------------------------------------

SELECT

    O.Order_ID,
    C.Customer_Name,
    P.Product_Name,
    O.Quantity,
    O.Order_Date

FROM Orders O

JOIN Customers C
ON O.Customer_ID = C.Customer_ID

JOIN Products P
ON O.Product_ID = P.Product_ID;

--------------------------------------------------------------------------------
-- END OF PROJECT
--------------------------------------------------------------------------------

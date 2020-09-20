-- Alexandre Waymel 103083020
-- DROP DATABASE IF EXISTS TSQLA;
-- create database TSQLA;

Use TSQLA;
DROP TABLE IF EXISTS SALE;
DROP TABLE IF EXISTS PRODUCT;
DROP TABLE IF EXISTS CUSTOMER;
DROP TABLE IF EXISTS  LOCATION;
DROP SEQUENCE IF EXISTS SALE_SEQ;
DROP PROCEDURE IF EXISTS ADD_CUSTOMER;--Ques1
DROP PROCEDURE IF EXISTS DELETE_ALL_CUSTOMERS;--Ques2
DROP PROCEDURE IF EXISTS ADD_PRODUCT--Ques3
DROP PROCEDURE IF EXISTS DELETE_ALL_PRODUCTS;--Ques4
DROP PROCEDURE IF EXISTS GET_CUSTOMER_STRING;--Ques5
DROP PROCEDURE IF EXISTS GET_PROD_STRING;--Quest6
DROP PROCEDURE IF EXISTS UPD_CUST_SALESYTD;--Quest7
DROP PROCEDURE IF EXISTS  UPD_PROD_SALESYTD;--Quest8
DROP PROCEDURE IF EXISTS UPD_CUSTOMER_STATUS;--Quest9
DROP PROCEDURE IF EXISTS ADD_SIMPLE_SALE;--Quest10
DROP PROCEDURE IF EXISTS SUM_CUSTOMER_SALESYTD;--Quest11
DROP PROCEDURE IF EXISTS SUM_PRODUCT_SALESYTD;--Quest12
DROP PROCEDURE IF EXISTS GET_ALL_CUSTOMERS;--Quest13
DROP PROCEDURE IF EXISTS GET_ALL_PRODUCTS;--Quest14
DROP PROCEDURE IF EXISTS ADD_LOCATION;--Quest15
DROP PROCEDURE IF EXISTS ADD_COMPLEX_SALE;--Quest16
DROP PROCEDURE IF EXISTS GET_ALLSALES;--Quest17
DROP PROCEDURE IF EXISTS COUNT_PRODUCT_SALES;--Quest18
DROP PROCEDURE IF EXISTS DELETE_SALE;--Quest19 
DROP PROCEDURE IF EXISTS DELETE_ALL_SALES;--Quest20
DROP PROCEDURE IF EXISTS DELETE_CUSTOMER;--Quest21
DROP PROCEDURE IF EXISTS DELETE_PRODUCT;--Quest22

GO
CREATE SEQUENCE SALE_SEQ
    AS bigint 
    START WITH 1000000000000000000
    INCREMENT BY 1


CREATE TABLE CUSTOMER
(
    CUSTID INT,
    CUSTNAME NVARCHAR(100),
    SALES_YTD MONEY,
    STATUS NVARCHAR(7),
    PRIMARY KEY	(CUSTID)
);


CREATE TABLE PRODUCT
(
    PRODID INT,
    PRODNAME NVARCHAR(100),
    SELLING_PRICE MONEY,
    SALES_YTD MONEY,
    PRIMARY KEY	(PRODID)
);

CREATE TABLE SALE
(
    SALEID BIGINT,
    CUSTID INT,
    PRODID INT,
    QTY INT,
    PRICE MONEY,
    SALEDATE DATE,
    PRIMARY KEY 	(SALEID),
    FOREIGN KEY 	(CUSTID) REFERENCES CUSTOMER,
    FOREIGN KEY 	(PRODID) REFERENCES PRODUCT
);

CREATE TABLE LOCATION
(
    LOCID NVARCHAR(5),
    MINQTY INTEGER,
    MAXQTY INTEGER,
    PRIMARY KEY 	(LOCID),
    CONSTRAINT CHECK_LOCID_LENGTH CHECK (LEN(LOCID) = 5),
    CONSTRAINT CHECK_MINQTY_RANGE CHECK (MINQTY BETWEEN 0 AND 999),
    CONSTRAINT CHECK_MAXQTY_RANGE CHECK (MAXQTY BETWEEN 0 AND 999),
    CONSTRAINT CHECK_MAXQTY_GREATER_MIXQTY CHECK (MAXQTY >= MINQTY)
);

---------------------------------------------------------------------------------------------------
-----------------------------------     Question 1       ------------------------------------------
-----------------------------------     ADD_CUSTOMER     ------------------------------------------
---------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE ADD_CUSTOMER    @PCUSTID INT, @PCUSTNAME NVARCHAR(100) AS
BEGIN
    BEGIN TRY
        IF @PCUSTID < 1 OR @PCUSTID > 499            
            THROW 50020, 'Customer ID out of range', 1
        INSERT INTO CUSTOMER   (CUSTID, CUSTNAME, SALES_YTD, STATUS)  VALUES(@PCUSTID, @PCUSTNAME, 0, 'OK');
    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 2627
            THROW 50010, 'Duplicate customer ID', 1
        ELSE IF ERROR_NUMBER() = 50020
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
GO

---------------------------------------------------------------------------------------------------
-----------------------------------     Question 2       ------------------------------------------
-----------------------------------     DELETE_ALL_CUSTOMERS     ------------------------------------------
---------------------------------------------------------------------------------------------------


create PROCEDURE DELETE_ALL_CUSTOMERS AS
BEGIN
    begin try
        DELETE FROM CUSTOMER ;
        SELECT @@ROWCOUNT as NumbreCustomerDelete;
    END try 
    begin catch 
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    end CATCH
END;

GO

---------------------------------------------------------------------------------------------------
-----------------------------------     Question 3       ------------------------------------------
-----------------------------------     ADD_PRODUCT     -------------------------------------------
---------------------------------------------------------------------------------------------------
GO

CREATE PROCEDURE ADD_PRODUCT    @pprodid INT ,    @pprodname NVARCHAR(100),    @pprice MONEY AS
BEGIN
    BEGIN TRY
        if @pprodid < 1000 or @pprodid > 2500 
            THROW 50040, 'Product ID out of range', 1
        else if @pprice < 0 or @pprice > 999.99
            ThROW 50050, 'Price out of range',1
        INSERT INTO PRODUCT (PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) VALUES (@pprodid, @pprodname, @pprice, 0);
    END TRY
    BEGIN CATCH 
        if ERROR_NUMBER() = 2627
            THROW 50030, 'Duplicate product ID', 1
        ELSE IF ERROR_NUMBER() = 50040
            THROW 
        ELSE IF ERROR_NUMBER() = 50050
            THROW
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END;
    END CATCH;
END;
GO
---------------------------------------------------------------------------------------------------
-----------------------------------     Question 4       ------------------------------------------
-----------------------------------     DELETE_ALL_PRODUCTS    ------------------------------------
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE DELETE_ALL_PRODUCTS
AS
BEGIN
    begin try
        DELETE FROM PRODUCT ;
        select @@ROWCOUNT as NumbreOfProductDelete;
    END try 
    BEGIN CATCH 
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH
END;
GO
---------------------------------------------------------------------------------------------------
-----------------------------------     Question 5       ------------------------------------------
-----------------------------------     GET_CUSTOMER_STRING    ------------------------------------
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE GET_CUSTOMER_STRING   @pcustid INT,  @pReturnString NVARCHAR(1000) OUTPUT AS
BEGIN
    BEGIN TRY
        DECLARE  @CUSTNAME NVARCHAR(100), @SALES_YTD MONEY, @STATUS NVARCHAR(7);
        SELECT @CUSTNAME = CUSTNAME, @SALES_YTD = SALES_YTD, @STATUS = [STATUS]    FROM CUSTOMER  WHERE CUSTID = @pcustid;

        IF @@ROWCOUNT = 0
            THROW 50060, 'Customer ID not found',1

        SET @pReturnString = concat('Custid:', @pcustid, ' Name: ',  @CUSTNAME, ' Status: ', @STATUS, ' SalesYTD: ', @SALES_YTD);  
    END try
    BEGIN CATCH 
        IF ERROR_NUMBER() = 50060
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH
END;
GO
---------------------------------------------------------------------------------------------------
-----------------------------------     Question 6       ------------------------------------------
-----------------------------------     UPD_CUST_SALESYTD    ------------------------------------
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE UPD_CUST_SALESYTD    @pcustid Int,    @pamt Int AS
BEGIN
    BEGIN TRY
        IF (@pamt < -999.99 or @pamt > 999.99)
            THROW 50080,'Amount out of range', 1

        UPDATE CUSTOMER  SET SALES_YTD = @pamt WHERE CUSTID = @pcustid;
        IF @@ROWCOUNT = 0
            THROW 50070, 'Customer ID not found',1  
    END TRY
    BEGIN CATCH            
        IF ERROR_NUMBER() in (50080, 50070)
            THROW
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END; 
    END CATCH
END

GO
---------------------------------------------------------------------------------------------------
-----------------------------------     Question 7       ------------------------------------------
-----------------------------------     GET_PROD_STRING    ----------------------------------------
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE GET_PROD_STRING    @pprodid   Int,    @pReturnString    NVARCHAR(1000) OUTPUT AS
BEGIN
    BEGIN TRY
        DECLARE @PRONAME NVARCHAR(100), @SELLING_PRICE MONEY, @SALES_YTD MONEY;
        select @PRONAME = PRODNAME, @SELLING_PRICE = SELLING_PRICE, @SALES_YTD = @SALES_YTD FROM PRODUCT WHERE PRODID = @pprodid; 

        IF @@ROWCOUNT = 0
        THROW 50090, 'Product ID not found',1

        SET @pReturnString = CONCAT('Prodid: ', @pprodid, ' Name: ', @PRONAME, ' Price: ', @SELLING_PRICE, ' SalesYTD: ', @SALES_YTD);
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 50090
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH
END;
Go
---------------------------------------------------------------------------------------------------
-----------------------------------     Question 8      ------------------------------------------
-----------------------------------     UPD_PROD_SALESYTD    ----------------------------------------
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE UPD_PROD_SALESYTD    @pprodid INT,    @pamt INT AS
BEGIN
    BEGIN TRY
        IF (@pamt < -999.99 or @pamt > 999.99)
            THROW 50110,'Amount out of range', 1
        

        UPDATE PRODUCT SET SALES_YTD = @pamt WHERE PRODID = @pprodid;
        
        IF @@ROWCOUNT = 0
            THROW 50100, 'Product ID not found',1

    END TRY    
        BEGIN CATCH
        IF ERROR_NUMBER() in (50110, 50100)
            THROW
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END;
    END CATCH
END;

GO
---------------------------------------------------------------------------------------------------
-----------------------------------     Question 9     ------------------------------------------
-----------------------------------     UPD_CUSTOMER_STATUS    ----------------------------------------
--------------------------------------------------------------------------------------------------

CREATE PROCEDURE UPD_CUSTOMER_STATUS    @pcustid Int,    @pstatus NVARCHAR(7) AS
BEGIN
    BEGIN TRY
    
        if @pstatus like '%ok%' or @pstatus like '%SUSPEND%'
            UPDATE CUSTOMER SET [STATUS] = @pstatus where  CUSTID = @pcustid ;
        else 
            THROW 50130 , 'Invalid Status value', 1    
        if @@ROWCOUNT = 0
            THROW 50120, 'Customer ID not found', 1
        

    END TRY    
    BEGIN CATCH
        IF ERROR_NUMBER() in (50130, 50120) 
            THROW;
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END;
    END CATCH
END;
GO
---------------------------------------------------------------------------------------------------
-----------------------------------     Question 10     ------------------------------------------
-----------------------------------     ADD_SIMPLE_SALE    ----------------------------------------
--------------------------------------------------------------------------------------------------

CREATE PROCEDURE ADD_SIMPLE_SALE @pcustid int, @pprodid int, @pqty int AS
BEGIN
    begin TRY
        
        if @pqty < 1 or @pqty > 999
            THROW 50140, 'Sale Quantity outside valid range ', 1
        
        declare @STATUS NVARCHAR(7)
        SELECT @STATUS = [STATUS] FROM CUSTOMER WHERE custid = @pcustid
        
        IF @@ROWCOUNT = 0 
            THROW 50160, 'Customer ID not found', 1
        IF @STATUS LIKE '%suspend%'
            THROW 50150, 'Customer status is not OK', 1

        DECLARE @SELLING_PRICE MONEY;
        SELECT @SELLING_PRICE = SELLING_PRICE FROM PRODUCT WHERE PRODID = @pprodid

        IF @@ROWCOUNT = 0 
            THROW 50170, 'Product ID not found', 1
        set @SELLING_PRICE = @SELLING_PRICE * @pqty

        EXEC UPD_CUST_SALESYTD @pcustid = @pcustid, @pamt = @SELLING_PRICE ;
        EXEC UPD_PROD_SALESYTD @pprodid = @pprodid, @pamt =  @SELLING_PRICE ;

    END TRY 
    BEGIN CATCH
        IF ERROR_NUMBER() IN (50140, 50150, 50160, 50170)
            THROW;
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END;
    END CATCH
END

GO
---------------------------------------------------------------------------------------------------
-----------------------------------     Question 11     ------------------------------------------
-----------------------------------     SUM_CUSTOMER_SALESYTD   -----------------------------------
--------------------------------------------------------------------------------------------------

CREATE PROCEDURE SUM_CUSTOMER_SALESYTD
AS
BEGIN
    BEGIN TRY 
        SELECT SUM(SALES_YTD) as TOTAL_CUSTOMER_SALES_YTD from customer  
    END TRY 
    BEGIN CATCH
        BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END
    END CATCH
END 
GO
---------------------------------------------------------------------------------------------------
-----------------------------------     Question 12     ------------------------------------------
-----------------------------------     SUM_PRODUCT_SALESYTD    -----------------------------------
--------------------------------------------------------------------------------------------------

create procedure SUM_PRODUCT_SALESYTD
AS
BEGIN
    BEGIN TRY 
        SELECT SUM(SALES_YTD) as TOTAL_PRODUCT_SALES_YTD from PRODUCT
    END TRY 
    BEGIN CATCH
        BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END
    END CATCH
END 

GO
---------------------------------------------------------------------------------------------------
-----------------------------------     Question 13     ------------------------------------------
-----------------------------------     GET_ALL_CUSTOMERS    ----------------------------------------
--------------------------------------------------------------------------------------------------




CREATE PROCEDURE GET_ALL_CUSTOMERS  @POUTCUR CURSOR VARYING OUTPUT
AS
BEGIN
    BEGIN TRY
        set @POUTCUR = cursor for select *  from CUSTOMER AS SYS_REFCURSOR
        open @POUTCUR;
    END TRY
    BEGIN CATCH
        BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END
    END CATCH
END 
GO

---------------------------------------------------------------------------------------------------
-----------------------------------     Question 14    ------------------------------------------
-----------------------------------     GET_ALL_PRODUCTS    ----------------------------------------
---------------------------------------------------------------------------------------------------


CREATE PROCEDURE GET_ALL_PRODUCTS
    @POUTCUR CURSOR VARYING OUTPUT
AS
BEGIN
    BEGIN TRY
        set @POUTCUR = cursor for select * from PRODUCT AS SYS_REFCURSOR
        open @POUTCUR;
    END TRY
    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END
    END CATCH
END 
GO

------------------------------------------------------------------------------------------------
-----------------------------------     Question 15     ----------------------------------------
-----------------------------------     ADD_LOCATION    ----------------------------------------
------------------------------------------------------------------------------------------------


CREATE PROCEDURE ADD_LOCATION @ploccode nvarchar(5),@pminqty  Int,@pmaxqty   Int
AS
BEGIN
    BEGIN TRY
        INSERT INTO LOCATION  (LOCID, MINQTY ,MAXQTY)    VALUES  (@ploccode, @pminqty, @pmaxqty)
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 2627
            THROW 50180, '50180. Duplicate location ID', 1

        IF ERROR_MESSAGE() LIKE '%CHECK_LOCID_LENGTH%'
            THROW 50190, 'Location Code length invalid', 1

        IF ERROR_MESSAGE() LIKE '%CHECK_MINQTY_RANGE%'
            THROW 50200, 'Minimum Qty out of range', 1
            
        IF ERROR_MESSAGE() like '%CHECK_MAXQTY_RANGE%'
            THROW 50210, 'Maximum Qty out of range', 1

        IF ERROR_MESSAGE() like '%CHECK_MAXQTY_GREATER_MIXQTY%' 
            THROW 50220, 'Minimum Qty larger than Maximum Qty', 1
        
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END    
    END CATCH
END
GO

-------------------------------------------------------------------------------------------------
-----------------------------------     Question 16     -----------------------------------------
-----------------------------------     ADD_COMPLEX_SALE    -------------------------------------
-------------------------------------------------------------------------------------------------



GO

CREATE PROCEDURE ADD_COMPLEX_SALE   @pcustid Int, @pprodid  Int, @pqty Int, @pdate Nvarchar(8) 
AS
BEGIN 
    BEGIN TRY      

    --  check QTy
        if @pqty < 1 or @pqty > 999
            THROW 50230, 'Sale Quantity outside valid range ', 1

    --  check @pdate
        DECLARE @ckeckDate DATE = CONVERT(nvarchar(8), @pdate, 112)
    --  check STATUS AND @pcustid 
        DECLARE @STATUS NVARCHAR(7)
        SELECT @STATUS = [STATUS] FROM CUSTOMER WHERE CUSTID = @pcustid 
            IF @@ROWCOUNT = 0
                THROW 50260, 'Customer ID not found', 1

            IF @STATUS != 'OK' 
                THROW 50240, 'Customer status is not OK ', 1
    
    --  check @pprodid
        DECLARE @PRICE MONEY
        SELECT @PRICE = SELLING_PRICE FROM PRODUCT WHERE PRODID = @pprodid 
            IF @@ROWCOUNT = 0
                THROW 50270, 'Product ID not found', 1
        
        set @PRICE = @PRICE * @pqty 
    -- call  function QUESTION 6, 8
        EXEC UPD_PROD_SALESYTD @pprodid = @pprodid, @pamt = @PRICE
        EXEC UPD_CUST_SALESYTD @pcustid = @pcustid, @pamt = @PRICE

        INSERT INTO  SALE VALUES (NEXT VALUE FOR SALE_SEQ, @pcustid, @pprodid, @pqty, @PRICE, @ckeckDate);
    END TRY 
    BEGIN CATCH
        IF ERROR_NUMBER() IN (50230, 50260, 50240, 50270)
            THROW
        else IF ERROR_NUMBER() = 241
            THROW 50250, 'Date not valid', 1
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END
    END CATCH 
END 

GO

------------------------------------------------------------------------------------------------
-----------------------------------     Question 17     ----------------------------------------
-----------------------------------     GET_ALLSALES    ----------------------------------------
------------------------------------------------------------------------------------------------

CREATE PROCEDURE GET_ALLSALES  @POUTCUR CURSOR VARYING OUTPUT
AS
BEGIN
    BEGIN TRY
        set @POUTCUR = cursor for select * from SALE AS SYS_REFCURSOR
        open @POUTCUR;
    END TRY
    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END
    END CATCH
END 
GO

-------------------------------------------------------------------------------------------------
-----------------------------------     Question 18    ------------------------------------------
-----------------------------------     COUNT_PRODUCT_SALES    ----------------------------------
-------------------------------------------------------------------------------------------------

create procedure COUNT_PRODUCT_SALES  @pdays int AS
BEGIN
    BEGIN TRY 

        declare @datecheck date 
        SET @datecheck =  DATEADD(DAY, -@pdays, GETDATE()) 
        SELECT count(SALEID) as TotalProductSAle FROM SALE WHere SALEDATE  BETWEEN @datecheck  AND  GETDATE()

    END TRY 
    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END
    END CATCH
END 


GO  

---------------------------------------------------------------------------------------------------
-----------------------------------     Question 19     ------------------------------------------
-----------------------------------     DELETE_SALE    ----------------------------------------
--------------------------------------------------------------------------------------------------
CREATE PROCEDURE DELETE_SALE AS
BEGIN
    BEGIN TRY 
    DECLARE @MINSALEID bigINT, @PRICE MONEY, @QTY int, @PRODID int , @CUSTID INT, @TOTAL MONEY, @sale_qty INT
    
    SELECT @MINSALEID =  MIN(SALEID)  FROM SALE as DellectId 
        IF @MINSALEID IS NULL  
            THROW 50280, 'No Sale Rows Found',1

        select @QTY = QTY, @PRICE = PRICE, @CUSTID = CUSTID, @PRODID = PRODID from SALE WHERE SALEID = @MINSALEID
        
        SET @TOTAL = @QTY * @PRICE

        EXEC UPD_PROD_SALESYTD @pprodid = @PRODID, @pamt = @TOTAL
        EXEC UPD_CUST_SALESYTD @pcustid = @CUSTID, @pamt = @TOTAL
        
        DELETE FROM SALE WHERE SALEID = @MINSALEID
    end TRY
    BEGIN CATCH
        THROW
    END CATCH
END 


go  

---------------------------------------------------------------------------------------------------
-----------------------------------     Question 20     ------------------------------------------
-----------------------------------     DELETE_ALL_SALES    ----------------------------------------
--------------------------------------------------------------------------------------------------
CREATE PROCEDURE DELETE_ALL_SALES
AS
BEGIN 
    BEGIN TRY
    DELETE FROM SALE
    UPDATE CUSTOMER  SET SALES_YTD = 0;
    UPDATE PRODUCT  SET SALES_YTD = 0;
    END TRY
    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END
    END CATCH
END

GO
---------------------------------------------------------------------------------------------------
-----------------------------------     Question 21     ------------------------------------------
-----------------------------------     DELETE_CUSTOMER    ----------------------------------------
--------------------------------------------------------------------------------------------------
CREATE PROCEDURE DELETE_CUSTOMER @pCustid INT
AS
BEGIN 
    BEGIN TRY
        DELETE CUSTOMER WHERE CUSTID = @pCustid
            IF @@ROWCOUNT = 0
                THROW 50290, 'Customer ID not found', 1

    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 547 
            THROW 50300, 'Customer cannot be deleted as sales exist', 1
        IF ERROR_NUMBER() = 50290
            THROW
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END
    END CATCH
END 


GO
---------------------------------------------------------------------------------------------------
-----------------------------------     Question 22     ------------------------------------------
-----------------------------------     DELETE_PRODUCT    ----------------------------------------
--------------------------------------------------------------------------------------------------

CREATE PROCEDURE DELETE_PRODUCT @pProdid INT AS
BEGIN 
    BEGIN TRY 
        DELETE PRODUCT WHERE PRODID = @pProdid
            IF @@ROWCOUNT = 0
                THROW 50310, 'Product ID not found', 1
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 547 
            THROW 50310, 'Product cannot be deleted as sales exist', 1
        IF ERROR_NUMBER() = 50310
            THROW        
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END
    END CATCH
END 

GO
-----------------------------------------------------------------------------------------INSER INTO SESSION---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------INSER INTO SESSION ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------INSER INTO SESSION ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------INSER INTO SESSION---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------INSER INTO SESSION ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------INSER INTO SESSION ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------INSER INTO SESSION---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------INSER INTO SESSION ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------INSER INTO SESSION ---------------------------------------------------------------------------------------------

-- INSERT INTO SALE VALUES (1234567892, 3, 1020, 2, 50 ,'20200905');
-- INSERT INTO SALE VALUES (1234567890, 1, 1000, 2, 10 ,'20200917');
-- INSERT INTO SALE VALUES (1234567891, 2, 1010, 2, 25 ,'20200918');



-- INSERT INTO CUSTOMER VALUES (1, 'Alex', 500, 'ok');
-- INSERT INTO CUSTOMER VALUES (2, 'Miranda', 500, 'ok');
-- INSERT INTO CUSTOMER VALUES (3, 'Esmee', 500, 'ok');

-- INSERT INTO PRODUCT VALUES (1000,'crocodile liver ', 100.00, 0.00);
-- INSERT INTO PRODUCT VALUES (1010,'Lamb blader', 50.00, 0.00);
-- INSERT INTO PRODUCT VALUES (1020,'Cockscomb ', 10.00, 0.00);

-----------------------------------------------------------------------------------------TEST SESSION---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------TEST SESSION---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------TEST SESSION---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------TEST SESSION---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------TEST SESSION---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------TEST SESSION---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------TEST SESSION---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------TEST SESSION---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------TEST SESSION---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------TEST SESSION---------------------------------------------------------------------------------------------
PRINT '-----------------------------------------------------------------------------------------TEST SESSION--------------------------------------------------------------------------------------------- '
PRINT '-----------------------------------------------------------------------------------------TEST SESSION--------------------------------------------------------------------------------------------- '
PRINT '-----------------------------------------------------------------------------------------TEST SESSION--------------------------------------------------------------------------------------------- '
PRINT '-----------------------------------------------------------------------------------------TEST SESSION--------------------------------------------------------------------------------------------- '
PRINT '-----------------------------------------------------------------------------------------TEST SESSION--------------------------------------------------------------------------------------------- '
PRINT '-----------------------------------------------------------------------------------------TEST SESSION--------------------------------------------------------------------------------------------- '
PRINT '-----------------------------------------------------------------------------------------TEST SESSION--------------------------------------------------------------------------------------------- '
PRINT '-----------------------------------------------------------------------------------------TEST SESSION--------------------------------------------------------------------------------------------- '

--Q1 TEST "ADD_CUSTOMER"
PRINT '-------------------------------------------------------------------------------QUESTION 1 ADD_CUSTOMER--------------------------------------------------------------------------- ' 
GO 
PRINT 'Q1 TEST "ADD_CUSTOMER" for add a customer '
exec ADD_CUSTOMER @PCUSTID =1, @PCUSTNAME = 'alex'
go
PRINT 'Q1 TEST "ADD_CUSTOMER" for error Duplicate customer ID'
exec ADD_CUSTOMER @PCUSTID =1, @PCUSTNAME = 'alex'
GO
PRINT ' Q1 TEST  "ADD_CUSTOMER" FOR out of range'
exec ADD_CUSTOMER @PCUSTID = -20, @PCUSTNAME = 'alex'
exec ADD_CUSTOMER @PCUSTID = 1111111, @PCUSTNAME = 'alex'
GO


--Q2 "DELETE_ALL_CUSTOMERS"
PRINT '-------------------------------------------------------------------------------QUESTION 2 DELETE_ALL_CUSTOMERS--------------------------------------------------------------------------- ' 
PRINT 'Q2 TEST "DELETE_ALL_CUSTOMERS" FOR out of range'
EXEC DELETE_ALL_CUSTOMERS
GO



--Q3 "ADD_PRODUCT"
PRINT '-------------------------------------------------------------------------------QUESTION Q3 "ADD_PRODUCT"--------------------------------------------------------------------------- ' 
PRINT 'Q3 TEST "ADD_PRODUCT" for add product'
EXEC  ADD_PRODUCT    @pprodid = 2000, @pprodname  = 'Les couille de taureau',    @pprice = 250
go
PRINT 'Q3 TEST "ADD_PRODUCT" duplicated product'
EXEC  ADD_PRODUCT    @pprodid = 2000, @pprodname  = 'Les couille de taureau',    @pprice = 250
go
PRINT 'Q3 TEST "ADD_PRODUCT" Product ID out of range'
EXEC  ADD_PRODUCT    @pprodid = 999, @pprodname  = 'Cockscomb',    @pprice = 250
EXEC  ADD_PRODUCT    @pprodid = 2501, @pprodname  = 'Cockscomb',    @pprice = 250
go
PRINT 'Q3 TEST "ADD_PRODUCT" Price out of range'
EXEC  ADD_PRODUCT    @pprodid = 2499, @pprodname  = 'Cockscomb',    @pprice = 1000
EXEC  ADD_PRODUCT    @pprodid = 2500, @pprodname  = 'Cockscomb',    @pprice = -1
GO




-- Q4 "DELETE_ALL_PRODUCTS"
PRINT '-------------------------------------------------------------------------------QUESTION Q4 "DELETE_ALL_PRODUCTS"--------------------------------------------------------------------------- ' 
PRINT 'Q4 TEST "DELETE_ALL_PRODUCTS" for delete all product'
EXEC  DELETE_ALL_PRODUCTS
GO



--Q5 "GET_CUSTOMER_STRING"
PRINT '-------------------------------------------------------------------------------QUESTION Q5 "GET_CUSTOMER_STRING"--------------------------------------------------------------------------- ' 
INSERT INTO CUSTOMER VALUES (1, 'Alex', 500, 'ok');
PRINT 'Q5 TEST "GET_CUSTOMER_STRING" Get one customers details from customer table'
BEGIN 
    declare @Passstring  NVARCHAR(100) = '' 
    EXEC GET_CUSTOMER_STRING  @pcustid = 1, @pReturnString = @Passstring  OUTPUT  -- check Question 5 
    print @Passstring
END;
GO
PRINT 'Q5 TEST "GET_CUSTOMER_STRING" Customer ID not found'
BEGIN 
    declare @Passstring  NVARCHAR(100) = '' 
    EXEC GET_CUSTOMER_STRING  @pcustid = 2, @pReturnString = @Passstring  OUTPUT  -- check Question 5 
    print @Passstring
END;
GO



 
--Q6 "UPD_CUST_SALESYTD"
PRINT '-------------------------------------------------------------------------------QUESTION Q6 "UPD_CUST_SALESYTD"--------------------------------------------------------------------------- ' 
PRINT 'Q6 TEST "UPD_CUST_SALESYTD" Get one customers details from customer table'
EXEC UPD_CUST_SALESYTD @pcustid= 1, @pamt = 100
GO
PRINT 'Q6 TEST "UPD_CUST_SALESYTD" Customer ID not found '
EXEC UPD_CUST_SALESYTD @pcustid= 151, @pamt = 100 
GO
PRINT 'Q6 TEST " Amount out of range '
EXEC UPD_CUST_SALESYTD @pcustid= 1, @pamt = -1000 
EXEC UPD_CUST_SALESYTD @pcustid= 1, @pamt = 1000 
GO



--Q7"GET_PROD_STRING"
PRINT '-------------------------------------------------------------------------------QUESTION Q7"GET_PROD_STRING"--------------------------------------------------------------------------- ' 
INSERT INTO PRODUCT VALUES (1000,'crocodile liver ', 100.00, 0.00);
PRINT 'Q7 TEST "GET_PROD_STRING" Get one products details from product table'
BEGIN
    declare @PassstringProd  NVARCHAR(100) = ''
    EXEC GET_PROD_STRING @pprodid = 1000, @pReturnString = @PassstringProd output;
    print @PassstringProd
END 
GO
PRINT 'Q7 TEST "GET_PROD_STRING" Product ID not found'
BEGIN
    declare @PassstringProd  NVARCHAR(100) = ''
    EXEC GET_PROD_STRING @pprodid = 1020, @pReturnString = @PassstringProd output;
    print @PassstringProd
END 
GO



--Q8 "UPD_PROD_SALESYTD"
PRINT '-------------------------------------------------------------------------------QUESTION Q8 "UPD_PROD_SALESYTD"--------------------------------------------------------------------------- ' 
PRINT 'Q8 TEST "GET_PROD_STRING" Update product YTD'
EXEC UPD_PROD_SALESYTD @pprodid = 1000 ,@pamt = 10 
Go
PRINT 'Q8 TEST "GET_PROD_STRING" Product ID not found'
EXEC UPD_PROD_SALESYTD @pprodid = 1500 ,@pamt = 10 
GO
PRINT 'Q8 TEST "GET_PROD_STRING" Amount out of range'
EXEC UPD_PROD_SALESYTD @pprodid = 1000 ,@pamt = 10000000 
GO



--Q9 "UPD_CUSTOMER_STATUS"
PRINT '-------------------------------------------------------------------------------QUESTION Q9 "UPD_CUSTOMER_STATUS"--------------------------------------------------------------------------- ' 
GO
PRINT 'Q9 TEST "UPD_CUSTOMER_STATUS" Update one customer status value in the customer table'
EXEC UPD_CUSTOMER_STATUS @pcustid = 1, @pstatus = 'OK' 
GO
PRINT 'Q9 TEST "UPD_CUSTOMER_STATUS" Customer ID not found'
EXEC UPD_CUSTOMER_STATUS @pcustid = 120, @pstatus = 'OK' 
GO
PRINT 'Q9 TEST "UPD_CUSTOMER_STATUS" Customer ID not found'
EXEC UPD_CUSTOMER_STATUS @pcustid = 1, @pstatus = 'OdsfgK' 
GO


--Q10 "ADD_SIMPLE_SALE"
PRINT '-------------------------------------------------------------------------------QUESTION Q10 "ADD_SIMPLE_SALE"--------------------------------------------------------------------------- ' 
INSERT INTO CUSTOMER VALUES (2, 'Miranda', 500, 'SUSPEND');

PRINT 'Q10 TEST "ADD_SIMPLE_SALE" Update one customer s status value in the customer table'
EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 1000 ,@pqty = 2  
GO
PRINT 'Q10 TEST "ADD_SIMPLE_SALE" Sale Quantity outside valid range'
EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 1000 ,@pqty = -20
GO
PRINT 'Q10 TEST " Customer status is not OK'
EXEC ADD_SIMPLE_SALE @pcustid = 2, @pprodid = 1000 ,@pqty = 2 
Go
PRINT 'Q10 TEST " Customer ID not found'
EXEC ADD_SIMPLE_SALE @pcustid = 25, @pprodid = 1000 ,@pqty = 2
Go
PRINT 'Q10 TEST " Product ID not found'
EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 10 ,@pqty = 2
GO



--Q11 "SUM_CUSTOMER_SALESYTD"
PRINT '-------------------------------------------------------------------------------QUESTION Q11 "SUM_CUSTOMER_SALESYTD"--------------------------------------------------------------------------- ' 
PRINT 'Q11 TEST " SUM_CUSTOMER_SALESYTD'
EXEC SUM_CUSTOMER_SALESYTD 
GO



--Q12 "SUM_PRODUCT_SALESYTD"
PRINT '-------------------------------------------------------------------------------QUESTION Q12 "SUM_PRODUCT_SALESYTD"--------------------------------------------------------------------------- ' 
PRINT 'Q12 TEST " SUM_PRODUCT_SALESYTD'
EXEC SUM_PRODUCT_SALESYTD
GO




--Q13 "GET_ALL_CUSTOMERS"
PRINT '-------------------------------------------------------------------------------QUESTION Q13 "GET_ALL_CUSTOMERS"--------------------------------------------------------------------------- ' 
PRINT 'Q13 TEST " GET_ALL_CUSTOMERS'
begin
    DECLARE @CUSTID INT, @CUSTNAME NVARCHAR(100), @SALES_YTD MONEY, @STATUS NVARCHAR(7)
    DECLARE @passcurs CURSOR;

    exec GET_ALL_CUSTOMERS @POUTCUR = @passcurs OUTPUT;

    FETCH NEXT FROM @passcurs INTO @CUSTID, @CUSTNAME, @SALES_YTD, @STATUS
        WHILE (@@FETCH_STATUS = 0)
            BEGIN;
                PRINT (CONCAT('CUSTID=  ',@CUSTID, ' CUSTNAME=  ', @CUSTNAME, ' SALES_YTD=  ', @SALES_YTD, ' STATUS=  ',@STATUS))
                FETCH NEXT FROM @passcurs INTO @CUSTID, @CUSTNAME, @SALES_YTD, @STATUS
            END;
    CLOSE @passcurs;
    DEALLOCATE @passcurs;
END 
GO




--Q14 "GET_ALL_PRODUCTS"
PRINT '-------------------------------------------------------------------------------QUESTION Q14 "GET_ALL_PRODUCTS"--------------------------------------------------------------------------- ' 
PRINT 'Q14 TEST " GET_ALL_PRODUCTS'
BEGIN
    DECLARE @PRODID INT, @PRODNAME NVARCHAR(100), @SELLING_PRICE MONEY, @SALES_YTD MONEY
    DECLARE @passcurs CURSOR;
    exec GET_ALL_PRODUCTS @POUTCUR = @passcurs OUTPUT;
    FETCH NEXT FROM @passcurs INTO @PRODID, @PRODNAME, @SELLING_PRICE, @SALES_YTD
    WHILE (@@FETCH_STATUS = 0)
        BEGIN;
        PRINT (CONCAT('PRODID = ',@PRODID, 'PRODNAME=  ', @PRODNAME, 'SELLING_PRICE=  ', @SELLING_PRICE, 'SALES_YTD=  ', @SALES_YTD))
        FETCH NEXT FROM @passcurs INTO @PRODID, @PRODNAME, @SELLING_PRICE, @SALES_YTD
    END;
    CLOSE @passcurs;
    DEALLOCATE @passcurs;
END
GO


--Q15 "ADD_LOCATION"
PRINT '-------------------------------------------------------------------------------QUESTION Q15 "ADD_LOCATION"--------------------------------------------------------------------------- ' 
PRINT 'Q15 TEST " ADD_LOCATION" Adds a new row to the location table' 
EXEC ADD_LOCATION @ploccode = 'HFS51',@pminqty = 10, @pmaxqty = 50
Go
PRINT 'Q15 TEST " ADD_LOCATION" Duplicate location ID' 
EXEC ADD_LOCATION @ploccode = 'HFS52',@pminqty = 10, @pmaxqty = 50
Go
PRINT 'Q15 TEST " ADD_LOCATION" Location Code length invalid' 
EXEC ADD_LOCATION @ploccode = 'HF',@pminqty = 10, @pmaxqty = 50
Go
PRINT 'Q15 TEST " ADD_LOCATION" Minimum Qty out of range' 
EXEC ADD_LOCATION @ploccode = 'HFS52',@pminqty = -20, @pmaxqty = 50
Go
PRINT 'Q15 TEST " ADD_LOCATION" Minimum Qty out of range' 
EXEC ADD_LOCATION @ploccode = 'HFS52',@pminqty = 25, @pmaxqty = 9999999
Go
PRINT 'Q15 TEST " ADD_LOCATION"Minimum Qty larger than Maximum Qty'
EXEC ADD_LOCATION @ploccode = 'HFS52',@pminqty = 51, @pmaxqty = 50
Go







--Q16 "ADD_COMPLEX_SALE"
INSERT INTO PRODUCT VALUES (1010,'Lamb blader', 50.00, 0.00);
PRINT '-------------------------------------------------------------------------------QUESTION Q16 "ADD_COMPLEX_SALE"--------------------------------------------------------------------------- ' 
PRINT 'Q16 TEST "ADD_COMPLEX_SALE " Adds a complex sale to the database'
exec ADD_COMPLEX_SALE  @pcustid = 1, @pprodid = 1010, @pqty = 2, @pdate = "20200121"
Go
PRINT 'Q16 TEST "ADD_COMPLEX_SALE " Sale Quantity outside valid range'
exec ADD_COMPLEX_SALE  @pcustid = 1, @pprodid = 1010, @pqty = -2, @pdate = "20200121"
Go
PRINT 'Q16 TEST "ADD_COMPLEX_SALE " Customer status is not OK'
exec ADD_COMPLEX_SALE  @pcustid = 2, @pprodid = 1010, @pqty = 2, @pdate = "20200121"
Go
PRINT 'Q16 TEST "ADD_COMPLEX_SALE " . Date not valid'
exec ADD_COMPLEX_SALE  @pcustid = 1, @pprodid = 1010, @pqty = 2, @pdate = "2045200121"
Go
PRINT 'Q16 TEST "ADD_COMPLEX_SALE " . Customer ID not found'
exec ADD_COMPLEX_SALE  @pcustid = 111, @pprodid = 1010, @pqty = 2, @pdate = "20200121"
Go
PRINT 'Q16 TEST "ADD_COMPLEX_SALE " . Product ID not found'
exec ADD_COMPLEX_SALE  @pcustid = 1, @pprodid = 1060, @pqty = 2, @pdate = "20200121"
Go




--Q17 "GET_ALLSALES"
PRINT '-------------------------------------------------------------------------------QUESTION Q17 "GET_ALLSALES"--------------------------------------------------------------------------- ' 
PRINT 'Q17 TEST "GET_ALLSALES " . Get all customer details and return as a SYS_REFCURSOR'
Go
begin
    DECLARE @SALEID BIGINT,  @CUSTID INT,    @PRODID INT,    @QTY INT,    @PRICE MONEY,    @SALEDATE DATE
    DECLARE @passcurs CURSOR;
    exec GET_ALLSALES @POUTCUR = @passcurs OUTPUT;
    FETCH NEXT FROM @passcurs INTO @SALEID, @CUSTID, @PRODID, @QTY, @PRICE, @SALEDATE
        WHILE (@@FETCH_STATUS = 0)
            BEGIN;
                PRINT (CONCAT('SALEID = ',@SALEID,'CUSTID = ', @CUSTID, 'PRODID = ', @PRODID, 'QTY = ', @QTY, 'PRICE = ', @PRICE, 'SALEDATE = ', @SALEDATE))
                FETCH NEXT FROM @passcurs INTO @SALEID, @CUSTID, @PRODID, @QTY, @PRICE, @SALEDATE
            END;
    CLOSE @passcurs;
    DEALLOCATE @passcurs;
END
GO



--Q18 "COUNT_PRODUCT_SALES"
EXEC ADD_COMPLEX_SALE  @pcustid = 1, @pprodid = 1010, @pqty = 2, @pdate = "20200919"
PRINT '-------------------------------------------------------------------------------QUESTION Q18 "COUNT_PRODUCT_SALES"--------------------------------------------------------------------------- ' 
PRINT 'Q18 TEST " COUNT_PRODUCT_SALES "  Count and return the int of sales with nn days of current date'
exec COUNT_PRODUCT_SALES @pdays = 5
GO



--Q19  "DELETE_SALE"
PRINT '-------------------------------------------------------------------------------QUESTION Q19  "DELETE_SALE"--------------------------------------------------------------------------- ' 
INSERT INTO SALE VALUES (1234567891, 2, 1010, 2, 25 ,'20200918');
PRINT 'Q19 TEST " DELETE_SALE "  Delete a row from the SALE table'
EXEC DELETE_SALE
PRINT 'Q19 TEST " DELETE_SALE "  No Sale Rows Found'
EXEC DELETE_SALE
Go





--Q20 "DELETE_ALL_SALES"
PRINT '-------------------------------------------------------------------------------QUESTION Q20 "DELETE_ALL_SALES"--------------------------------------------------------------------------- ' 
PRINT 'Q20 TEST " DELETE_ALL_SALE "  Delete a row from the SALE table'
EXEC DELETE_ALL_SALES
Go


INSERT INTO CUSTOMER VALUES (1, 'Alex', 500, 'ok');
INSERT INTO CUSTOMER VALUES (3, 'Esmee', 500, 'ok');
INSERT INTO SALE VALUES (1234567891, 1, 1010, 2, 25 ,'20200918');

--Q21 "DELETE_CUSTOMER"
PRINT '-------------------------------------------------------------------------------QUESTION Q21 "DELETE_CUSTOMER"--------------------------------------------------------------------------- ' 
PRINT 'Q21 TEST " DELETE_CUSTOMER "  Delete a row from the Customer table'
EXEC DELETE_CUSTOMER @pCustid =  3
Go
PRINT 'Q21 TEST " DELETE_CUSTOMER "  Customer ID not found'
EXEC DELETE_CUSTOMER @pCustid =  30
Go
PRINT 'Q21 TEST " DELETE_CUSTOMER "  Customer cannot be deleted as sales exist'
EXEC DELETE_CUSTOMER @pCustid =  1
Go





---Q22 "DELETE_PRODUCT"
PRINT '-------------------------------------------------------------------------------QUESTION Q22 "DELETE_PRODUCT"--------------------------------------------------------------------------- ' 
PRINT 'Q22 TEST " DELETE_PRODUCT " Delete a row from the Product table'
EXEC DELETE_PRODUCT @pProdid = 1000
GO
PRINT 'Q22 TEST " DELETE_PRODUCT " Product ID not found'
EXEC DELETE_PRODUCT @pProdid = 3000
GO
PRINT 'Q22 TEST " DELETE_PRODUCT " Product cannot be deleted as sales exist'
EXEC DELETE_PRODUCT @pProdid = 1020
GO
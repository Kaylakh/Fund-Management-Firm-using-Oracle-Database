-------------------STOCK_A------------------

Create Table STOCK_A (Ticker_Symbol varchar(10) NOT NULL,
RISK VARCHAR(10),
INVESTMENT VARCHAR(10));



-----------------------------------------------------#1--Client Table--------------------------------------------


Create table Client(
Client_Id int PRIMARY KEY,
First_Name varchar2(50) NOT NULL,
Last_Name varchar2(50) NOT NULL,
Street varchar(255) NOT NULL,
Contact_Number Number(10) NOT NULL,
SSN varchar(10) NOT NULL UNIQUE,
email varchar2(80) NOT NULL CONSTRAINT email_format CHECK (REGEXP_LIKE (email, '^\w+(\.\w+)*+@\w+(\.\w+)+$')),
City varchar(20) NOT NULL,
State varchar(20) NOT NULL,
zip_code Number(5) NOT NULL);

---------------------------------------------------------------#9--Category Table--------------------------------------------------
create table Category(
Cat_ID varchar(10) PRIMARY KEY,
Category_Name varchar(25) NOT NULL,
Brokerage_Rate  int NOT NULL);

--#2---client strategy table--------------------------
Create table Client_strat(
Strategy_ID varchar(10) Primary key,
Cat_ID	varchar(10) NOT NULL,
Brand_value Varchar(10) NOT NULL,
Investment varchar(10) NOT NULL,
Parameter_Value int NOT NULL,
 FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID) );


--#3--Strategy_Category Table--------------------------------------
create table Strategy_Category(
Client_ID	   int NOT NULL  ,    
Cat_ID	       Varchar(10)  ,    
Strategy_ID	   Varchar(10),     
Brand_Value	   Varchar(10) NOT NULL ,    
Investment	   Varchar(10) NOT NULL ,    
Parameter_Value int NOT NULL,
 FOREIGN KEY(Strategy_ID) REFERENCES CLIENT_STRAT(STRATEGY_ID),
 FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID) );


--#4--Healthcare Table------------------------------------------
CREATE TABLE Healthcare (
  Stock_Name Varchar(255),
  Ticker_Symbol Varchar(10),
  Last_Value Float,
  Change_Value Float,
  Brand_Value Varchar(10),
  Cat_id Varchar(10),
 FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID) );
 


--#5--Energysector Table------------------------------------------
CREATE TABLE Energysector (
  Stock_Name Varchar(255),
  Ticker_Symbol Varchar(10),
  Last_Value Float,
  Change_Value Float,
  Brand_Value Varchar(10),
  Cat_id Varchar(10),
 FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID) );
 
--#6--Technology Table-----------------------------------------------
CREATE TABLE Technology (
 Stock_Name Varchar(255),
  Ticker_Symbol Varchar(10),
  Last_Value Float,
  Change_Value Float,
  Brand_Value Varchar(10),
  Cat_id Varchar(10),
 FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID) );


--#7--Industrials Table-------------------------------------------------
CREATE TABLE Industrials (
  Stock_Name Varchar(255),
  Ticker_Symbol Varchar(10),
  Last_Value Float,
  Change_Value Float,
  Brand_Value Varchar(10),
  Cat_id Varchar(10),
 FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID) );

--#8--ConsumerDiscretionary Table----------------------------------------
CREATE TABLE ConsumerDiscretionary (
  Stock_Name Varchar(255),
  Ticker_Symbol Varchar(10),
  Last_Value Float,
  Change_Value Float,
  Brand_Value Varchar(10),
  Cat_id Varchar(10),
 FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID) );




--#10--Stock_Parameter Table-------------------------------------
create table Stock_Parameter(
Ticker_Symbol varchar(10) NOT NULL,
Cat_ID varchar(10) NOT NULL,
News int NOT NULL,
Dividends_Announced int NOT NULL,
Product_Release int NOT NULL,
New_Contract int NOT NULL,
Employee_Layoff int NOT NULL,
Takeover int NOT NULL,
Mgmt_Changes int NOT NULL,
Scandals int NOT NULL,
EPS int NOT NULL,
PE_ratio int NOT NULL,
Exchange_rate int NOT NULL,
CONSTRAINT PK_SP PRIMARY KEY(TICKER_SYMBOL,CAT_ID),
 FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID) );

--#11--Client_Port  (Client Portfolio Table)----------------------
create table client_portf(
Client_Id int NOT NULL,
Category_Name varchar(25) NOT NULL,
Cat_ID	Varchar(10) NOT NULL,
 FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID),
 FOREIGN KEY(CLIENT_ID) REFERENCES CLIENT(CLIENT_ID));


--#12--Client_Category Table----------------------------------------
create table Client_Category ( 
Client_ID	   int NOT NULL  ,    
Cat_ID	       Varchar(10) NOT NULL ,
Brokerage_Rate  int NOT NULL,
 FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID),
 FOREIGN KEY(CLIENT_ID) REFERENCES CLIENT(CLIENT_ID),
 Primary key (CAT_ID,CLIENT_ID));


----------------------------#13--Mail Table------------------------------------------------------
create table mail(
Client_ID	   int,
v_from varchar2(80) default 'stockfundmgmt@gmail.com',
v_to varchar2(80) Not Null,
v_subject varchar2(80) default 'Accepted Stocks list',
v_cc varchar2(80) default 'Nil',
v_bcc varchar2(80) default 'admin@gmail.com',
FOREIGN KEY(Client_ID) REFERENCES CLIENT(Client_ID)
);



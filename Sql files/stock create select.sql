--------------------Stock Table---------------------------
Create table STOCK  as
(SELECT Stock_Name,Ticker_Symbol,Cat_Id,BRAND_VALUE,(LAST_VALUE + CHANGE_VALUE) as current_value
FROM Industrials 
union
SELECT Stock_Name,Ticker_Symbol,Cat_Id,BRAND_VALUE,(LAST_VALUE + CHANGE_VALUE) as current_value
FROM ConsumerDiscretionary  
union
SELECT Stock_Name,Ticker_Symbol,Cat_Id,BRAND_VALUE,(LAST_VALUE + CHANGE_VALUE) as current_value
FROM Healthcare  
union
SELECT Stock_Name,Ticker_Symbol,Cat_Id,BRAND_VALUE,(LAST_VALUE + CHANGE_VALUE) as current_value
FROM Energysector  
union
SELECT Stock_Name,Ticker_Symbol,Cat_Id,BRAND_VALUE,(LAST_VALUE + CHANGE_VALUE) as current_value
FROM Technology);

ALTER TABLE STOCK 
ADD (CONSTRAINT PK_TICKER_SYMBOL PRIMARY KEY(TICKER_SYMBOL),
 FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID) );
 
ALTER TABLE STOCK
ADD (RISK VARCHAR(10),
INVESTMENT VARCHAR(10));

------------------------------------------------------UPDATE STOCK------------------------------------------------------------
update stock s
set
Risk = (select a.risk from stock_a a where a.TICKER_SYMBOL = s.TICKER_SYMBOL ),
Investment = (select a.investment from stock_a a where a.TICKER_SYMBOL = s.TICKER_SYMBOL );

------------------------------------------------updating Values to low/moderate/high-----------------------------------
UPDATE STOCK
SET RISK =
    CASE WHEN risk < 10  THEN 'LOW' 
         WHEN risk < 20  THEN 'MODERATE'
    ELSE 'HIGH'
    END,
       INVESTMENT=
       CASE WHEN investment < 10 THEN 'LOW' 
         WHEN investment < 20  THEN 'MODERATE'
    ELSE 'HIGH'
    END;
  
UPDATE STOCK
SET BRAND_VALUE=
      CASE WHEN brand_value < 357130
 THEN 'LOW' 
         WHEN brand_value < 800000   THEN 'MODERATE'
    ELSE 'HIGH'
    END;

--#2--Evaluation Table-----------------------------------
create table evaluation as
(select Ticker_Symbol, (News+Dividends_Announced+Product_Release+New_Contract+Employee_Layoff+Takeover+Mgmt_Changes+Scandals+EPS+PE_Ratio+Exchange_Rate)as Parameter_Value
from Stock_Parameter);


ALTER TABLE EVALUATION
ADD CONSTRAINT FK_TICKER_SYMBOL1 FOREIGN KEY(Ticker_Symbol) REFERENCES STOCK(Ticker_Symbol);

commit;

---------------------------------------------------#1--Stock_Decision Table------------------------------------------------------
 
create table STOCK_DECISION as (
SELECT Rownum as Dec_ID, e.parameter_value,S.*
FROM STOCK S 
inner join evaluation E 
on E.ticker_symbol = S.ticker_symbol) ;

ALTER TABLE STOCK_DECISION
ADD (CONSTRAINT UK_TICKER_SYMBOL UNIQUE(TICKER_SYMBOL),
--CONSTRAINT PK_DECISION_ID PRIMARY KEY(Dec_ID) ,
 CONSTRAINT FK_TICKER_SYMBOL FOREIGN KEY(TICKER_SYMBOL) REFERENCES STOCK(TICKER_SYMBOL));
 
 --#3--Client_Stock_Match Table---------------------------
select * from Strategy_Category;

create table client_stock_match AS 
select concat('M0',rownum) as Match_ID,S.PARAMETER_VALUE,S.STOCK_NAME,S.TICKER_SYMBOL,S.Cat_ID,S.Brand_Value,S.Current_Value,S.Risk,S.Investment,C.Client_ID, St.Strategy_ID 
from STOCK_DECISION S 
inner join Client_Category C 
on S.Cat_ID = C.Cat_ID 
inner join Strategy_Category St
on C.Client_ID = St.Client_ID
and C.Cat_ID = St.Cat_ID
and S.Brand_Value = St.Brand_Value
and S.Investment = St.Investment
and S.Parameter_Value >= St.Parameter_Value
order by Match_ID,C.Cat_ID;


ALTER TABLE CLIENT_STOCK_MATCH
ADD (--CONSTRAINT PK_MATCH_ID PRIMARY KEY(Match_ID),
    CONSTRAINT UK_TICKER_SYMBOL2 UNIQUE(TICKER_SYMBOL,client_id));
    
  --  CONSTRAINT FK_CLIENT_ID FOREIGN KEY(CLIENT_ID) REFERENCES CLIENT(CLIENT_ID),
  --  CONSTRAINT FK_STRATEGY_ID FOREIGN KEY(STRATEGY_ID) REFERENCES Client_strat(STRATEGY_ID),
  --  FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID));
----------------------------------------------------#4--Client_Stock_Proposal Table----------------------------

Create table Client_Stock_Proposal as
select CC.Brokerage_Rate, CS.MATCH_ID, CS.Stock_Name, CS.Ticker_symbol, CS.Cat_Id, CS.Current_value, CS.Client_Id 
from client_stock_match CS 
inner join Client_Category CC 
on CC.Client_Id = CS.Client_Id 
and CS.Cat_Id = CC.Cat_Id;

ALTER TABLE Client_Stock_Proposal
ADD (CONSTRAINT FK1_CLIENT_ID FOREIGN KEY(CLIENT_ID) REFERENCES CLIENT(CLIENT_ID),
    --CONSTRAINT FK_MATCH_ID FOREIGN KEY(MATCH_ID) REFERENCES CLIENT_STOCK_MATCH(MATCH_ID),
    FOREIGN KEY(CAT_ID) REFERENCES CATEGORY(CAT_ID),
    FOREIGN KEY(Ticker_symbol) REFERENCES STOCK(Ticker_symbol));
    
-----------------------------PROPOSAL STATUS-----------------------------------------------------------
--#5--Proposal_Status Table------------------------------------

create table PROPOSAL_STATUS AS(
select concat('T0',rownum) as TRANS_ID,C.MATCH_ID,C.Client_Id,C.Ticker_symbol,SYSDATE AS TRANS_DATE
FROM client_stock_match C);


ALTER TABLE PROPOSAL_STATUS
ADD (
PRIMARY KEY(TRANS_ID),
    FOREIGN KEY(MATCH_ID) REFERENCES CLIENT_STOCK_MATCH(MATCH_ID)) ;

ALTER TABLE PROPOSAL_STATUS
ADD (NOOFSTOCKS NUMBER(4) default 0 ,
     STATUS VARCHAR(6) DEFAULT 'NIL');

ALTER TABLE PROPOSAL_STATUS     
     ADD CONSTRAINT CHECK_STATUS CHECK (STATUS IN ('ACCEPT','REJECT','NIL') AND
                                 ((STATUS = 'ACCEPT' and NOOFSTOCKS > 0) OR 
                                 (STATUS = 'REJECT' and NOOFSTOCKS = 0) OR
                                 (STATUS = 'NIL')));
--------------------IMPORTANT TO CREATE TREND USING TRANS DATE--------

update proposal_status SET TRANS_DATE =
CASE WHEN mod(TO_NUMBER(SUBSTR(TRANS_ID,2)),3)=0 Then TO_DATE('01-apr-19','dd-mon-yy')
     WHEN mod(TO_NUMBER(SUBSTR(TRANS_ID,2)),3)=1 Then TO_DATE('01-mar-19','dd-mon-yy')
     ELSE TO_DATE('01-feb-19','dd-mon-yy')
END;

-----------------------------STATUS UPDATE FOR PROPOSAL STATUS----

update proposal_status p SET p.STATUS = 
Case
   when (p.TRANS_DATE = TO_DATE('01-feb-19','dd-mon-yy') and mod(TO_NUMBER(SUBSTR(p.TRANS_ID,2)),2)=0) Then to_char('REJECT')
   when (p.TRANS_DATE = TO_DATE('01-mar-19','dd-mon-yy') and mod(TO_NUMBER(SUBSTR(p.TRANS_ID,2)),4)=0) Then to_char('REJECT')
   when (p.TRANS_DATE = TO_DATE('01-apr-19','dd-mon-yy') and mod(TO_NUMBER(SUBSTR(p.TRANS_ID,2)),9)=0 and mod(TO_NUMBER(SUBSTR(p.TRANS_ID,2)),2)=1 ) Then to_char('REJECT')
   ELSE to_char('NIL') 
END;

commit;

------------------------CREATING TRIGGER------------------------------
set serveroutput on
CREATE OR REPLACE TRIGGER T_Mail
AFTER UPDATE OF STATUS ON PROPOSAL_STATUS
FOR EACH ROW    
 WHEN(NEW.STATUS ='ACCEPT')
BEGIN
 INSERT INTO MAIL(V_TO,CLIENT_ID) 
 (SELECT C.EMAIL,C.CLIENT_ID
  FROM CLIENT C
  WHERE C.CLIENT_ID=:NEW.CLIENT_ID);
  if updating then
 DBMS_OUTPUT.PUT_LINE ('MAIL HAS BEEN SENT');
 end if;
END;
/

----------------------------------Updating STATUS TO ACCEPT and NOOFSSTOCKS------------------------------------
update proposal_status 
SET STATUS = 'ACCEPT', 
noofstocks = '2' 
where status = 'NIL';

--#6--Trans_Header Table---------------------------------------
create table TRANS_HEADER AS(
select p.TRANS_ID,c.client_id,c.Ticker_Symbol,c.Stock_Name,c.Cat_ID
from Client_Stock_Proposal c
inner join PROPOSAL_STATUS p
on p.MATCH_ID=c.MATCH_ID 
and p.STATUS='ACCEPT');

ALTER TABLE TRANS_HEADER
ADD CONSTRAINT FK_HTRANS_ID FOREIGN KEY(TRANS_ID) REFERENCES PROPOSAL_STATUS(TRANS_ID) ;

--#7--Trans_Detail Table------------------------------------------
create table TRANS_DETAIL AS
select p.TRANS_ID,c.Ticker_Symbol,c.Stock_Name,c.Cat_ID,p.NOOFSTOCKS,c.current_value,c.brokerage_rate,p.TRANS_DATE
from Client_Stock_Proposal c
inner join PROPOSAL_STATUS p
on p.MATCH_ID=c.MATCH_ID 
inner join TRANS_HEADER t
on t.client_id = c.client_id
and p.STATUS='ACCEPT';

ALTER TABLE TRANS_DETAIL
ADD CONSTRAINT FK_DTRANS_ID FOREIGN KEY(TRANS_ID) REFERENCES PROPOSAL_STATUS(TRANS_ID) ;


--#8--Trans_Deletion Table-------------------------------------------
create table TRANS_DELETION AS
select p.TRANS_ID,p.MATCH_ID,c.client_id,c.Ticker_Symbol,c.Stock_Name,p.TRANS_DATE
from Client_Stock_Proposal c
inner join PROPOSAL_STATUS p
on p.MATCH_ID = c.MATCH_ID 
and p.STATUS='REJECT';

ALTER TABLE TRANS_DElETION
ADD CONSTRAINT FK_TRANS_ID FOREIGN KEY(TRANS_ID) REFERENCES PROPOSAL_STATUS(TRANS_ID) ;

--#9--Profit Table----------------------------------------------------
create table PROFIT as
select concat('P0',rownum) as Profit_ID,c.client_id,c.Ticker_Symbol,c.Stock_Name,p.TRANS_ID,c.Brokerage_rate,p.noofstocks,c.Brokerage_rate*p.noofstocks as Profit_Amount
from Client_Stock_Proposal c
inner join PROPOSAL_STATUS p
on p.MATCH_ID = c.MATCH_ID ;

ALTER TABLE PROFIT
ADD CONSTRAINT PK_PROFIT_ID PRIMARY KEY(PROFIT_ID);

commit;

----------Update of Proposal_Status table by the Client:---------

UPDATE PROPOSAL_STATUS
SET NOOFSTOCKS='&NOOFSTOCKS',
    STATUS='&STATUS',
    TRANS_DATE=SYSDATE	
WHERE CLIENT_ID = '&CLIENT_ID'



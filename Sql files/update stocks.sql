select * from client_stock_match 
where ticker_symbol = 'AMD';

select * from strategy_category where cat_id = 'CI04';

---------------------------STOCK_UNMATCHED--------------------------------------------
select * from client_stock_match sd right outer join stock_decision s 
on s.ticker_symbol= sd.ticker_symbol 
where s.ticker_symbol not in (select ticker_symbol from client_stock_match);

---------------------------------------------------------------------------FORWARD PROPOGATE----------------------------------

update stock_decision set 
brand_value = 'LOW',
investment = 'LOW'
where ticker_symbol = 'MMM';

-------client_stock_match
INSERT INTO client_stock_match  
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
and s.ticker_symbol in (select s.ticker_symbol from client_stock_match sd right outer join stock_decision s 
on s.ticker_symbol= sd.ticker_symbol 
where s.ticker_symbol not in (select ticker_symbol from client_stock_match));

------client_stock_proposal
INSERT INTO Client_Stock_Proposal
select CC.Brokerage_Rate, CS.MATCH_ID, CS.Stock_Name, CS.Ticker_symbol, CS.Cat_Id, CS.Current_value, CS.Client_Id 
from client_stock_match CS 
inner join Client_Category CC 
on CC.Client_Id = CS.Client_Id 
and CS.Cat_Id = CC.Cat_Id
and cs.ticker_symbol in (select s.ticker_symbol from Client_Stock_Proposal sd right outer join stock_decision s 
on s.ticker_symbol= sd.ticker_symbol 
where s.ticker_symbol not in (select ticker_symbol from Client_Stock_Proposal));

----proposal_status
INSERT INTO PROPOSAL_STATUS 
select concat('T0',rownum) as TRANS_ID,C.MATCH_ID,C.Client_Id,C.Ticker_symbol,SYSDATE, 0, 'NIL'
FROM client_stock_match C 
where c.ticker_symbol in (select sd.ticker_symbol from client_stock_match sd left outer join PROPOSAL_STATUS s 
on s.ticker_symbol= sd.ticker_symbol 
where s.ticker_symbol not in (select ticker_symbol from client_stock_match));


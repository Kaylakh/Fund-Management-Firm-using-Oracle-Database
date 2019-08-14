grant create view to stock_new;
show user;
--#1---Report for Profit gained---------------
create view PROFIT_GAINED as 
select p.Trans_id as Transaction_ID,
       p.Stock_name as Stock_Name,
       p.Ticker_symbol as Stock_ID,
       p.client_id as Client_ID,
       p.noofstocks as No_of_stocks,
       p.profit_amount as Profit_gained,
       c.category_name as Stock_Category_name
from profit p
inner join stock s
on s.ticker_symbol=p.ticker_symbol
inner join category c
on c.cat_id=s.cat_id;

select * from profit_gained;

--#2---Report for proposal sent to the client
create view proposal_sent as
select CS.client_id as client_id,
       CS.stock_name,
       C.category_name,       
       CASE when CS.PARAMETER_VALUE >= 90 THEN 'EXTREMELY HIGH'
            when CS.PARAMETER_VALUE >= 80 THEN 'HIGH'
            when CS.PARAMETER_VALUE >= 70 THEN 'MODERATE'
            when CS.PARAMETER_VALUE >= 60 THEN 'LOW'
            ELSE 'EXTREMELY LOW' 
            END AS STOCK_PERFORMANCE
    from client_stock_match CS
    inner join CATEGORY C
    ON CS.CAT_ID = C.CAT_ID;
   
 select * from proposal_sent;  
--#3---accept/reject proposal status----        

create view status_report as
select p.trans_id as transaction_id,
       p.client_id,
       s.stock_name,
       To_char(p.trans_date,'MONTH') as transaction_month,      
       p.status as Client_status
from proposal_status p
inner join stock s
on s.ticker_symbol=p.ticker_symbol
order by p.status, p.trans_date ;
       
select * from status_report ;    

commit;

---------Total Profit Gained based on month and stock-------------------------
select p.stock_category_name, s.Transaction_month, sum(p.profit_gained) as Total_Profit_Gained 
from profit_gained p
inner join status_report s 
on p.Transaction_ID = s.Transaction_ID
group by p.stock_category_name,s.Transaction_month
order by p.stock_category_name;
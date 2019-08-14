select * from client_stock_match
where ticker_symbol='MMM';

select * from proposal_status
where ticker_symbol='LUV'

select * from trans_deletion
where ticker_symbol='LUV'

commit;

select * from all_tab_cols;
select * from user_tables;

select * from client;
select length(street),0.5*length(street),substr(street,1,0.5*length(street))
from client

----DataType-------------
select a.table_name, a.column_name, a.data_type from user_tables u inner join all_tab_cols a on a.table_name = u.table_name;

lter table client
---constraint disable-------------------------
alter table PROPOSAL_STATUS
disable constraint CHECK_STATUS;

select * from user_tables;


alter table healthcare
add  new_Stock_Name varchar(10)


update healthcare
set new_stock_name=select from stock_name;

select * from (
select stock_name,no_of_stocks,profit_gained
from profit_gained
order by profit_gained desc) where rownum<=10

select * from (
select stock_name,noofstocks,profit_amount
from profit
order by profit_amount desc)
where rownum<=10

select * from profit
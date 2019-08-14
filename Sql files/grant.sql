
grant all privilege to stock_new;
----------
create user stock_new identified by stock;

grant connect,resource to stock_new;


----Client Access-----

create user new_client identified by client;

grant connect to new_client;

grant select, update on stock_new.Proposal_Status to new_client;

grant select on  stock_new.CLIENT to new_client;

grant select on stock_new.Strategy_Category to new_client;

-----Boss access----------------------

create user boss identified by boss;

grant connect to boss;

grant select  on PROFIT_GAINED to boss;

grant select  on proposal_sent to boss;

grant select  on status_report to boss;
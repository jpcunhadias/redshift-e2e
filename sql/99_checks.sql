select count(*) as n_customers from stage.customers;
select count(*) as n_products  from stage.products;
select count(*) as n_orders    from stage.orders;

select * from stage.orders limit 5;

--== 5_Общая_выгрузка A, B - категорий на проверку (все модели, где выбранный каталог/поставщик не минимальный) ==

WITH delivery_cost as ( -- Высчитываем сумму доставки по каталогам в факте продаж. Если случаев подзаказа меньше 5 - высчитывается средняя стоимость доставки вообще
    select oi.catalog_id, count(distinct oi.id), case when count(distinct oi.id) < 10 then 
    (
        select avg(unit_delivery_price / (unit_price + unit_delivery_price)) as delivery_percent
        from order_service.order_item
    ) 
    else avg(oi.unit_delivery_price / (oi.unit_price + oi.unit_delivery_price)) end as delivery_percent
    from order_service.order_item oi
    group by catalog_id
),

catalog as (
    select ps.model_id, ps.catalog_id, ps.price * coalesce((1 + dc.delivery_percent), 1.11) as price_with_delivery, ps.price, ps.supplier_id, ps.category_id
    from default.price_snapshot ps
    left join delivery_cost dc on ps.catalog_id::int = dc.catalog_id::int
    where date = today() - 1
),

gmv as (
    WITH CumulativeData AS (
        SELECT 
            oi.model_id,
            sum(oi.quantity * (oi.unit_price + oi.unit_delivery_price)) gmv,
            count(distinct o.id) as counts,
            SUM(oi.quantity * (oi.unit_price + oi.unit_delivery_price)) * count(distinct o.id) AS rating,
            SUM(SUM(oi.quantity * (oi.unit_price + oi.unit_delivery_price)) * count(distinct o.id)) OVER () AS total
        FROM 
            order_service.order_item oi 
        JOIN 
            order_service.supplier_order so ON oi.supplier_order_id = so.id 
        JOIN 
            order_service.order o ON oi.order_id = o.id
        WHERE 
            so.system_status NOT IN ('CANCELED', 'DRAFT', 'DECLINED')
            AND so.create_ts > NOW() - INTERVAL '90 days'
        GROUP BY 
            oi.model_id
)
SELECT 
    model_id,
    gmv,
    rating,
    counts,
    CASE 
        WHEN SUM(rating) OVER (ORDER BY rating DESC) / total <= 0.8 THEN 'A'
        WHEN SUM(rating) OVER (ORDER BY rating DESC) / total <= 0.95 THEN 'B'
        ELSE 'C' 
    END AS category
FROM 
    CumulativeData
),

a as (
select 
    catalog.model_id, 
    dictGet('pim_catalog_model_dict', 'name', catalog.model_id) as model_name,
    CONCAT('https://maksmart.ru/product/', toString(catalog.model_id), '/') AS model_link,
    catalog.category_id,
    dictGet('pim_catalog_category_dict', 'name', catalog.category_id) as category_name,
    dictGet('pim_catalog_category_dict', 'top_name', catalog.category_id) as top_category_name,
    catalog.catalog_id, 
    catalog.supplier_id, 
    catalog.price, 
    catalog.price_with_delivery, 
    gmv.gmv, 
    gmv.counts,
    gmv.category,
    gmv.rating,
    CASE WHEN catalog.price_with_delivery = MIN(catalog.price_with_delivery) OVER (PARTITION BY catalog.model_id) THEN 1 ELSE 0 END AS is_minimum_price_with_delivery
    
from catalog
left join gmv on catalog.model_id = gmv.model_id
where gmv.category IN ('A', 'B')
order by gmv.rating desc
)
select * from a where is_minimum_price_with_delivery = 0
[[and a.catalog_id = {{catalog_id}}]] 
[[and a.supplier_id = {{supplier_id}}]]

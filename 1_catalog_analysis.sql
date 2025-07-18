--== 1_ABC_анализ ==
--== 2_ABC_анализ (общие данные, не фильтруется) ==
--== 3_ABC_анализ_разрез_групп ==


WITH delivery_cost as ( -- Высчитываем сумму доставки по каталогам в факте продаж. Если случаев подзаказа меньше 5 - высчитывается средняя стоимость доставки вообще
   SELECT 
        oi.catalog_id,
        CASE 
            WHEN COUNT(DISTINCT oi.id) < 10 THEN 0.11 -- 11% - средняя стоимость доставки каталогов. Устанавливается в случае малой информации для определения стоимости доставки отдельного каталога
            ELSE AVG(oi.unit_delivery_price / NULLIF((oi.unit_price + oi.unit_delivery_price), 0))
        END AS delivery_percent
    FROM order_service.order_item oi
    GROUP BY oi.catalog_id
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
            AND so.create_ts > NOW() - INTERVAL '180 days'
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
)

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
where 1 = 1
[[and catalog.supplier_id::int = {{supplier_id}}]]
[[and catalog.catalog_id::int = {{catalog_id}}]]
order by gmv.rating desc

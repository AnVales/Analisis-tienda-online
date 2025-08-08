-- previsualizar
select * from [datos_creados];

--  KPIs y métricas clave
-- beneficio total de las ventas
select SUM((Precio - CosteUnitario) * UnidadesVendidas) as Beneficios from [datos_creados];

-- margen por producto
select Producto, SUM(Precio - CosteUnitario) as MargenProducto from [datos_creados] group by Producto;

-- numero total de unidades vendidas
select Producto, SUM(UnidadesVendidas) as UnidadesVendidasTotales from [datos_creados] group by Producto;

-- productos mas rentables
select Producto, SUM((Precio - CosteUnitario) * UnidadesVendidas) as Beneficios from [datos_creados]
group by Producto
having SUM((Precio - CosteUnitario) * UnidadesVendidas) > (select AVG((Precio - CosteUnitario) * UnidadesVendidas) as Beneficio_Medio from [datos_creados])
ORDER BY Beneficios DESC;

-- beneficio medio por cliente
select Cliente_ID, AVG((Precio - CosteUnitario) * UnidadesVendidas) as Beneficio_Medio from [datos_creados]
group by Cliente_ID;

-- Análisis temporal
-- evolucion mensual de las ventas
SELECT 
  YEAR(Fecha) AS Año,
  MONTH(Fecha) AS Mes,
  Sum(UnidadesVendidas) as Unidades_Por_Mes from [datos_creados]

GROUP BY 
  YEAR(Fecha), MONTH(Fecha)

  order by Sum(UnidadesVendidas) desc;

-- evolucion mensual del beneficio
SELECT 
  YEAR(Fecha) AS Año,
  MONTH(Fecha) AS Mes,
  SUM((Precio - CosteUnitario) * UnidadesVendidas) AS BeneficioMensual

FROM 
  [datos_creados]

GROUP BY 
  YEAR(Fecha), MONTH(Fecha)

ORDER BY 
  Año, Mes;

-- comparar el total de unidades por año
Select SUM(UnidadesVendidas) AS UnidadesVendidas, 
YEAR(Fecha) AS Año
from [datos_creados]
GROUP BY YEAR(Fecha);

-- comparar el total de unidades por año y trimestre
SELECT 
  DATEPART(year, Fecha) AS Año,
  DATEPART(quarter, Fecha) AS Trimestre,
  SUM(UnidadesVendidas) AS TotalUnidades
FROM [datos_creados]
GROUP BY 
  DATEPART(year, Fecha),
  DATEPART(quarter, Fecha)
ORDER BY 
  Año, 
  Trimestre;

-- mes con mas beneficios
select TOP 1 SUM((Precio - CosteUnitario) * UnidadesVendidas) as Beneficios, MONTH(Fecha) as Mes, YEAR(Fecha) as Año from [datos_creados]
GROUP BY MONTH(Fecha), Year(Fecha)
ORDER BY SUM((Precio - CosteUnitario) * UnidadesVendidas) desc;

--  Validación de datos
-- detectar fechas sin datos o mal puestos
SELECT Fecha
FROM [datos_creados]
WHERE Fecha IS NULL

SELECT Fecha
FROM [datos_creados]
WHERE Fecha < '2000-01-01' OR Fecha > GETDATE();

-- productos con precio menor que el coste unitario
select Producto, CosteUnitario, Precio
from [datos_creados]
where Precio < CosteUnitario;

-- unidades vendidas = 0
select Producto, UnidadesVendidas
from [datos_creados]
where UnidadesVendidas = 0;

-- Clientes y productos
-- ¿Qué cliente ha comprado más (en unidades y en beneficio)?
select top 10 *
from [datos_creados]
order by UnidadesVendidas desc

select top 10 *, (Precio - CosteUnitario) * UnidadesVendidas as beneficio
from [datos_creados]
order by (Precio - CosteUnitario) * UnidadesVendidas desc;

-- ¿Qué producto ha generado más beneficio total?
select top 1 Producto, SUM((Precio - CosteUnitario) * UnidadesVendidas) as beneficio
from [datos_creados]
group by Producto
order by beneficio desc;

-- ¿Qué categoría tiene mejor margen medio absoluto?
select Categoría, AVG(Precio - CosteUnitario) as MargenMedio
from [datos_creados]
group by Categoría
order by MargenMedio desc;

-- ¿Qué categoría tiene mejor margen medio relativo?
SELECT Categoría, AVG( (Precio - CosteUnitario) * 1.0 / NULLIF(Precio, 0) ) AS MargenPorcentualMedio
FROM [datos_creados]
GROUP BY Categoría
ORDER BY MargenPorcentualMedio DESC;

-- ¿Qué ciudad genera más beneficio total?
select top 1 Ciudad, SUM((Precio - CosteUnitario) * UnidadesVendidas) as beneficios
from [datos_creados]
group by Ciudad
order by beneficios desc;

-- ¿Cuál tiene mejor margen medio?
select top 1 Ciudad, AVG((Precio - CosteUnitario) * UnidadesVendidas) as margen
from [datos_creados]
group by Ciudad
order by margen desc;

-- ¿Online es más rentable que físico?
select CanalVenta, SUM((Precio - CosteUnitario) * UnidadesVendidas) as beneficios
from [datos_creados]
group by CanalVenta
order by beneficios desc;

-- ¿Qué canal vende más unidades? 
select CanalVenta, SUM(UnidadesVendidas) as UnidadesTotales
from [datos_creados]
group by CanalVenta
order by UnidadesTotales desc;

-- ¿En qué ciudades el canal online supera al físico?
SELECT
  Ciudad, Unidades_Online, Unidades_Fisico
FROM (
  SELECT 
    Ciudad,
    SUM(CASE WHEN CanalVenta = 'Online' THEN UnidadesVendidas ELSE 0 END) AS Unidades_Online,
    SUM(CASE WHEN CanalVenta = 'Tienda física' THEN UnidadesVendidas ELSE 0 END) AS Unidades_Fisico
  FROM [datos_creados]
  GROUP BY Ciudad
) as datos
WHERE Unidades_Online > Unidades_Fisico
ORDER BY Unidades_Online - Unidades_Fisico DESC;

-- Producto más vendido en cada ciudad.
select Producto, Ciudad, SUM(UnidadesVendidas) as Más_Vendido from [datos_creados]
group by Producto, Ciudad
order by Ciudad asc;


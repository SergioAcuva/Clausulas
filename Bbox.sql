--1. ¿Cuál es la geometría de las Universidades?. Expresarla en formato WKT, WKB y GeoJSON.

SELECT GeometryType(geom) AS tipo_geometria
FROM universidades LIMIT 1;

SELECT ST_AsEWKT(geom) AS geometria_wkt
FROM universidades
LIMIT 1;

SELECT ST_AsEWKB(geom) AS geometria_wkb
FROM universidades
LIMIT 1;

SELECT ST_AsGeoJSON(geom) AS geometria_geojson
FROM universidades
LIMIT 1;

--2. ¿Cuáles son los barrios y las localidades que intersectan las estaciones Marly y Calle 45?

SELECT * 
FROM estaciones_marly_calle45;
							  
SELECT
    estaciones.gid AS id_estacion,
    estaciones.nombre_estacion,
    sector_catastral.scanombre,
    localidades.nombre
FROM estaciones_marly_calle45 AS estaciones
JOIN sector_catastral 
ON ST_Intersects(ST_Transform(estaciones.geom, 4326), ST_Transform(sector_catastral.geom, 4326))
JOIN localidades 
ON ST_Intersects(ST_Transform(estaciones.geom, 4326), ST_Transform(localidades.geom, 4326));

SELECT
    estaciones.gid AS id_estacion,
    estaciones.nombre_estacion,
    ST_AsText(estaciones.geom) AS geometria_estacion,
    sector_catastral.scanombre,
    ST_AsText(sector_catastral.geom) AS geometria_sector,
    localidades.nombre,
    ST_AsText(localidades.geom) AS geometria_localidad
FROM estaciones_marly_calle45 AS estaciones
JOIN sector_catastral 
ON ST_Intersects(ST_Transform(estaciones.geom, 4326), ST_Transform(sector_catastral.geom, 4326))
JOIN localidades 
ON ST_Intersects(ST_Transform(estaciones.geom, 4326), ST_Transform(localidades.geom, 4326));

--3. ¿Cuál es la distancia que existe entre estaciones consecutivas de transmilenio? (Por ejemplo entre Calle 34 y Calle 45, entre calle 45 y Marly, etc)

-- Distancia entre Calle 34 y Calle 45

SELECT
    ST_Distance(
        ST_Transform(estacion1.geom, 3116),
        ST_Transform(estacion2.geom, 3116)
    ) AS distancia_entre_estaciones,
	ST_MakeLine(ST_Transform(estacion1.geom, 3116), ST_Transform(estacion2.geom, 3116)) AS linea_entre_estaciones
FROM estaciones_calle34_calle45_marly AS estacion1
JOIN estaciones_calle34_calle45_marly AS estacion2 
ON estacion1.nombre_estacion = 'Calle 34' AND estacion2.nombre_estacion = 'Calle 45';

-- Distancia entre Calle 45 y Marly

SELECT
    ST_Distance(
        ST_Transform(estacion1.geom, 3116),
        ST_Transform(estacion2.geom, 3116)
    ) AS distancia_entre_estaciones,
	ST_MakeLine(ST_Transform(estacion1.geom, 4326), ST_Transform(estacion2.geom, 4326)) AS linea_entre_estaciones
FROM estaciones_calle34_calle45_marly AS estacion1
JOIN estaciones_calle34_calle45_marly AS estacion2 
ON estacion1.nombre_estacion = 'Calle 45' AND estacion2.nombre_estacion = 'Marly';


--4. ¿Qué vías se encuentran en un radio de 15 metros de la estación Calle 34 de Transmilenio?

SELECT
    via.mviccalzad,
	via.mvietiquet,
	via.name,
	via.mvisvia,
	via.geom
FROM malla_vial_integral_bogota_d_c AS via, 
	 estaciones_calle34_calle45_marly AS estacion
WHERE estacion.nombre_estacion = 'Calle 34' AND ST_DWithin(ST_Transform(estacion.geom, 3116), ST_Transform(via.geom, 3116), 15)
GROUP BY via.mviccalzad, via.mvietiquet, via.name, via.mvisvia, via.geom;


--5. ¿Cuáles estaciones del SITP se encuentran en un radio de 50 metros de las barberías?

SELECT DISTINCT
    paraderos.nombre_par AS nombre,
	ST_Transform(paraderos.geom, 4326) AS paraderos,
	ST_Transform(barberias.geom, 4326) AS barberias
FROM paraderos
JOIN barberias 
ON ST_DWithin(ST_Transform(paraderos.geom, 3116), ST_Transform(barberias.geom, 3116), 50);

--6. ¿Cuál es el barrio que tiene más hoteles?

SELECT
    sector_catastral.scanombre AS barrio,
    COUNT(hoteles.nombre) AS cantidad_hoteles,
	ST_Collect(ST_Transform(hoteles.geom, 4326)) AS geometria_hoteles,
	ST_Transform(sector_catastral.geom, 4326) AS geometria_barrio
FROM sector_catastral
JOIN hoteles 
ON ST_Within(ST_Transform(hoteles.geom, 3116), ST_Transform(sector_catastral.geom, 3116))
GROUP BY sector_catastral.scanombre, geometria_barrio
ORDER BY cantidad_hoteles DESC LIMIT 3;

--7. ¿Cuál es la universidad que tiene más panaderías cercanas?. Asumir un radio de 220m

SELECT
    universidades.nombre,
    COUNT(panaderia.gid) AS cantidad_panaderias,
	ST_Collect(ST_Transform(panaderia.geom, 4326)) AS geometria_panaderias,
	ST_Transform(universidades.geom, 4326) AS geometria_universidades
FROM universidades
JOIN panaderia ON ST_DWithin(ST_Transform(panaderia.geom, 3116), ST_Transform(universidades.geom, 3116), 220)
GROUP BY universidades.nombre, geometria_universidades
ORDER BY cantidad_panaderias DESC LIMIT 1;

--8. ¿Cuál es el colegio que tiene más tiendas de mascotas cercanas?. Asumir un radio de 220m

SELECT
    colegiosbboxbogota.nombre,
    COUNT(tiendas_de_mascotas.nombre) AS cantidad_tiendas_mascotas,
	ST_Collect(ST_Transform(tiendas_de_mascotas.geom, 4326)) AS geometria_tiendas_de_mascotas,
	ST_Transform(colegiosbboxbogota.geom, 4326) AS geometria_colegiosbboxbogota
FROM colegiosbboxbogota
JOIN tiendas_de_mascotas ON ST_DWithin(ST_Transform(colegiosbboxbogota.geom, 3116), tiendas_de_mascotas.geom, 220)
GROUP BY colegiosbboxbogota.nombre, geometria_colegiosbboxbogota
ORDER BY cantidad_tiendas_mascotas DESC LIMIT 1;

--9. ¿Cuál es el WKT de la Avenida Caracas?

SELECT 
	malla_vial_integral_bogota_d_c.mvinombre AS nombre,
	ST_AsEWKT(geom) AS geometria_wkt
FROM malla_vial_integral_bogota_d_c 
WHERE malla_vial_integral_bogota_d_c.mvinombre = 'AVENIDA CARACAS' LIMIT 1;



--10. ¿En qué barrio se encuentra cada restaurante vegetariano?

SELECT
    restaurantesvegetarianos.nombre AS nombre_restaurante_vegano,
    sector_catastral.scanombre,
	ST_Transform(sector_catastral.geom, 4326) AS geom_barrio,
	restaurantesvegetarianos.geom AS geom_restaurante_vegano
FROM restaurantesvegetarianos
JOIN sector_catastral ON ST_Within(restaurantesvegetarianos.geom, ST_Transform(sector_catastral.geom, 4326));

--11. ¿Cuál es la densidad de bares por barrio?

SELECT
    sector_catastral.scanombre AS barrio,
    COUNT(bares.gid) AS cantidad_bares,
    COUNT(bares.gid) / ST_Area(sector_catastral.geom) AS densidad_bares,
    ST_Centroid(sector_catastral.geom) AS centroide_por_area,
    ST_Centroid(ST_Collect(bares.geom)) AS centroide_ponderado
FROM sector_catastral
LEFT JOIN bares ON ST_Within(bares.geom, ST_Transform(sector_catastral.geom, 4326))
GROUP BY sector_catastral.scanombre, sector_catastral.geom
ORDER BY densidad_bares DESC LIMIT 7;


--12. ¿Cuál es la densidad de 5 categorías diferentes por barrio?

SELECT
    sector_catastral.scanombre AS barrio,
    COUNT(farmacias.gid) AS cantidad_farmacias,
    COUNT(farmacias.gid) / ST_Area(sector_catastral.geom) AS densidad_farmacias,
    ST_Centroid(sector_catastral.geom) AS centroide_barrio
FROM sector_catastral
JOIN farmacias ON ST_Within(farmacias.geom, ST_Transform(sector_catastral.geom, 4326))
GROUP BY sector_catastral.scanombre, sector_catastral.geom
ORDER BY densidad_farmacias DESC;





--13. ¿Cuáles son los barrios por los que circula la ruta K309?. La ruta del SITP debe expresarse como polilínea.

SELECT
    sector_catastral.scanombre AS barrio,
    ST_Intersection(ST_Transform(ruta_k309.geom, 4326), ST_Transform(sector_catastral.geom, 4326)) AS polilinea_ruta,
	sector_catastral.geom AS geom_barrio
FROM sector_catastral
JOIN ruta_k309 ON ST_Intersects(ST_Transform(ruta_k309.geom, 4326), ST_Transform(sector_catastral.geom, 4326));


--14. ¿Cuál es la densidad de colegios de los barrios por los que circula la ruta K309?

SELECT
    sector_catastral.scanombre AS barrio,
    COUNT(colegiosbboxbogota.gid) AS cantidad_colegios,
    COUNT(colegiosbboxbogota.gid) / ST_Area(ST_Transform(sector_catastral.geom, 4326)) AS densidad_colegios,
    ST_Centroid(sector_catastral.geom) AS centroide_barrio
FROM sector_catastral
JOIN colegiosbboxbogota ON ST_Within(ST_Transform(colegiosbboxbogota.geom, 4326), ST_Transform(sector_catastral.geom, 4326))
JOIN ruta_k309 ON ST_Within(ST_Transform(ruta_k309.geom, 4326), ST_Transform(sector_catastral.geom, 4326))
GROUP BY sector_catastral.scanombre, sector_catastral.geom
ORDER BY densidad_colegios DESC;


--15. ¿Cuáles estaciones de transmilenio se encuentran a un radio de 100 m de una categoría?

SELECT
    estacionestransmilenio.nombre_estacion,
    farmacias.nombre AS nombre_farmacias,
	ST_Transform(estacionestransmilenio.geom, 4326) AS geom_estaciones,
	ST_Transform(farmacias.geom, 4326) AS geom_farmacias
FROM estacionestransmilenio
JOIN farmacias ON ST_DWithin(ST_Transform(estacionestransmilenio.geom, 3116), ST_Transform(farmacias.geom, 3116), 100);


--16. ¿Qué barrio es el que tiene más hoteles/farmacias?

SELECT
    sector_catastral.scanombre AS barrio,
    COUNT(farmacias.nombre) AS cantidad_farmacias,
	ST_Collect(ST_Transform(farmacias.geom, 4326)) AS geometria_farmacias,
	ST_Transform(sector_catastral.geom, 4326) AS geometria_barrio
FROM sector_catastral
JOIN farmacias
ON ST_Within(ST_Transform(farmacias.geom, 3116), ST_Transform(sector_catastral.geom, 3116))
GROUP BY sector_catastral.scanombre, geometria_barrio
ORDER BY cantidad_farmacias DESC LIMIT 1;

--17. ¿Cuál es el SRID empleado en las geometrías de cada tabla?

SELECT f_table_name AS table_name, f_geometry_column AS geometry_column, srid
FROM geometry_columns
WHERE f_table_name IN ('barberias',
    'bares',
    'centroscomerciales',
    'colegiosbboxbogota',
    'estaciones_calle34_calle45_marly',
    'estaciones_marly_calle45',
    'estacionestransmilenio',
    'farmacias',
    'hospitalfinal',
    'hoteles',
    'iglesias',
	'localidades',
	'public.malla_vial_integral_bogota_d_c',
    'notarias',
    'panaderia',
    'paraderos',
    'parques',
    'restaurantesvegetarianos',
    'ruta_k309',
    'rutas_zonales_sitp',
    'salon_belleza',
    'sector_catastral',
    'tiendas_de_mascotas',
    'universidades',
	'veterinaria');

--18. ¿Cuáles son las características de la SRID empleada?

SELECT gc.f_table_name AS table_name,gc.f_geometry_column AS geometry_column,gc.srid,sr.auth_name,sr.auth_srid,sr.proj4text,sr.srtext
FROM geometry_columns gc
JOIN spatial_ref_sys sr 
ON gc.srid = sr.srid
WHERE gc.f_table_name IN ('barberias',
    'bares',
    'centroscomerciales',
    'colegiosbboxbogota',
    'estaciones_calle34_calle45_marly',
    'estaciones_marly_calle45',
    'estacionestransmilenio',
    'farmacias',
    'hospitalfinal',
    'hoteles',
    'iglesias',
	'localidades',
	'public.malla_vial_integral_bogota_d_c',
    'notarias',
    'panaderia',
    'paraderos',
    'parques',
    'restaurantesvegetarianos',
    'ruta_k309',
    'rutas_zonales_sitp',
    'salon_belleza',
    'sector_catastral',
    'tiendas_de_mascotas',
    'universidades',
	'veterinaria');
	
	
--19. ¿Cuáles son las coordenadas de cada una de las estaciones de transmilenio?. Expresarlas en 4326

SELECT
    nombre_estacion,
    ST_X(ST_Transform(geom, 4326)) AS longitud,
    ST_Y(ST_Transform(geom, 4326)) AS latitud,
	ST_Transform(geom, 4326) AS geom
FROM estacionestransmilenio;


--20. ¿Cuál es la longitud de todas las vías que existen en el bbox definido? En el SRID original y en 4326.

WITH bbox_geom AS (
    SELECT ST_Transform(geom, 4326) AS bbox_geom
    FROM bbox
)
SELECT
	mvietiquet AS nombre_via,
    ST_Length(vias.geom) AS longitud_original,
	ST_Length(ST_Transform(vias.geom, 3116)) AS longitud_3116,
    ST_Length(ST_Transform(vias.geom, 4326)) AS longitud_4326,
	ST_Transform(vias.geom, 4326) AS geom_vias,
	ST_Transform(bbox.geom, 4326) AS geom_bbox
FROM malla_vial_integral_bogota_d_c AS vias, bbox_geom, bbox
WHERE ST_Intersects(vias.geom, bbox_geom.bbox_geom);

--21. ¿Cuál es la distancia que existe entre el elemento “más al norte” y el elemento “más al sur” de cada categoría?

SELECT
    norte.nombre AS elemento_mas_al_norte,
    sur.nombre AS elemento_mas_al_sur,
    ST_Distance(
		ST_Transform(norte.geom, 3116), 
		ST_Transform(sur.geom, 3116)
	) AS distancia_entre_norte_y_sur,
	norte.geom AS geom_norte,
	sur.geom AS geom_sur
FROM (SELECT nombre, geom
     FROM barberias
     ORDER BY ST_Y(geom) DESC
     LIMIT 1) AS norte,
    (SELECT nombre, geom
     FROM barberias
     ORDER BY ST_Y(geom) ASC
     LIMIT 1) AS sur;


--22. ¿Cuántos instancias de cada tabla se encuentran en la intersección de dos círculos de radio 800m definidos desde el centroide del polígono de la Universidad ECCI Sede S y la Universidad Distrital Francisco José de Caldas Sede Calle 40?

SELECT
    ue.nombre AS universidad_ecci,
    ud.nombre AS universidad_distrital,
    b.nombre AS bares_dentro_de_la_intersección
FROM universidades AS ue, universidades AS ud, bares AS b
WHERE
    ue.nombre = 'Universidad Ecci' AND
    ud.nombre = 'Universidad Distrital Francisco Jose De Caldas' AND
    ST_Intersects(
        ST_Buffer(ST_Transform(ST_Centroid(ue.geom), 32618), 800),
        ST_Buffer(ST_Transform(ST_Centroid(ud.geom), 32618), 800)
    ) AND
    ST_Intersects(ST_Transform(b.geom, 32618), ST_Buffer(ST_Transform(ST_Centroid(ue.geom), 32618), 800)) AND
    ST_Intersects(ST_Transform(b.geom, 32618), ST_Buffer(ST_Transform(ST_Centroid(ud.geom), 32618), 800));

--23. ¿Cuál es la calle más cercana a cada centro comercial?

SELECT
  cc.nombre,
  mv.mvietiquet AS calle_mas_cercana,
  MIN(ST_Distance(ST_Transform(cc.geom, 3116), ST_Transform(mv.geom, 3116))) AS distancia,
  mv.geom AS geom_malla_vial,
  cc.geom AS geom_centros_comerciales
FROM centroscomerciales cc
CROSS JOIN LATERAL
  (
    SELECT
      mv.mvietiquet,
      mv.geom
    FROM malla_vial_integral_bogota_d_c mv
    ORDER BY ST_Transform(cc.geom, 3116) <-> ST_Transform(mv.geom, 3116)
    LIMIT 1
  ) AS mv
GROUP BY cc.nombre, mv.mvietiquet, mv.geom, cc.geom;


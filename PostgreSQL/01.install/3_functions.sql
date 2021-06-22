



--m_astext(mpoint) text
	


CREATE OR REPLACE FUNCTION public.m_astext(mgeometry)
    RETURNS text
    LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	points				text[];
	times				bigint[];
	mpid                integer;
	results				text;
	traj_prefix			text;
	typename			text;
	uritext				text;
	horizontalangle		double precision[];
	verticalangle		double precision[];
	direction2d			double precision[];
	direction3d			double precision[];
	distance			double precision[];
	
BEGIN
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
	sql := 'select type  from mgeometry_columns where f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO typename;
	mpid := f_mgeometry.moid;
	sql := 'select  datetimes from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
   	EXECUTE sql into times;
	
	IF (typename = 'mvideo' and times is not null) THEN
	sql := 'select geo from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    EXECUTE sql into points;
	sql := 'select  uri from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    EXECUTE sql into uritext;
	sql := 'select  horizontalangle from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    EXECUTE sql into horizontalangle;
	sql := 'select  verticalangle from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    EXECUTE sql into verticalangle;
	sql := 'select  direction2d from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    EXECUTE sql into direction2d;
	sql := 'select  direction3d from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    EXECUTE sql into direction3d;
	sql := 'select  distance from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    EXECUTE sql into distance;
	results := m_astext(points, times, uritext, horizontalangle, verticalangle, direction2d, direction3d, distance);
	ELSE
		IF (typename = 'mpoint' and times is not null) THEN
		sql := 'select geo from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    	EXECUTE sql into points;
		results := m_astext(points, times);
		END IF;
	END IF;
	return results;
END
$BODY$;
ALTER FUNCTION public.m_astext(mgeometry)
    OWNER TO postgres;
    
    
    

---m_tintersect(mpoint, period) bool


CREATE OR REPLACE FUNCTION public.m_tintersects(
	mgeometry,
	period)
	RETURNS bool
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	cnt					integer;
	res					bool;
BEGIN
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
	sql := 'select  mpid from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(f_mgeometry.moid)||
	' AND  ((lower(timerange) <= ($1.fromtime) AND upper(timerange) >= ($1.fromtime)) 
	OR (($1.fromtime) <= lower(timerange) AND $1.totime >= lower(timerange))) ' ;
		--ABCD---->  ACBD  ACDB  CABD CADB
		
	EXECUTE sql INTO cnt USING f_period;
		IF cnt > 0 THEN
			RETURN true;
		END IF;
	return false;
	return res;
END;
$BODY$;
ALTER FUNCTION public.m_tintersects(mgeometry, period)
    OWNER TO postgres;	
	
	
	

--m_sintersect(mpoint, geometry) bool

	CREATE OR REPLACE FUNCTION public.m_sintersects(
	mgeometry,
	geometry)
	RETURNS bool
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_geometry			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	points				geometry[];
	results				bool;
	spatials			geometry;
BEGIN
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
	sql := 'select geo from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||quote_literal(f_mgeometry.moid);
    EXECUTE sql into points;
	spatials := ST_MakeLine(points);
	results := st_intersects(spatials, f_geometry);
	return results;
END;
$BODY$;
ALTER FUNCTION public.m_sintersects(mgeometry, geometry)
    OWNER TO postgres;	
    
	
-----m_spatial(mgeometry)

	
CREATE OR REPLACE FUNCTION public.m_spatial(
	mgeometry)
	RETURNS geometry
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	points				geometry;
	spatials			geometry;
BEGIN
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
	sql := 'select st_union(geo::geometry[]) from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||quote_literal(f_mgeometry.moid);
    EXECUTE sql into spatials;
	return spatials;
END;
$BODY$;
ALTER FUNCTION public.m_spatial(mgeometry)
    OWNER TO postgres;	
	
	


----------------------m_time()

CREATE OR REPLACE FUNCTION public.m_time(
	mgeometry)
	RETURNS period
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	times				int8range;
	periods				text;
BEGIN
	sql := 'select f_mgeometry_segtable_name from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;	
	sql := 'select  timerange from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||quote_literal(f_mgeometry.moid);
   	EXECUTE sql into times;
	
	periods := '('||lower(times)-1||','||lower(times)||')';
	return periods::period;
END;
$BODY$;
ALTER FUNCTION public.m_time(mgeometry)
    OWNER TO postgres;	
		
		
		
		
-----------------------------m_tintersects_index
		
/*
	m_tintersects_noindex    basic with no index
*/

CREATE OR REPLACE FUNCTION public.m_tintersects_noindex(
	mgeometry,
	int8range)
	RETURNS bool
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	cnt					integer;
BEGIN
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
	sql := 'select  mpid from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(f_mgeometry.moid)||
	' AND  ((lower(timerange) <= lower($1) AND upper(timerange) >= lower($1)) 
	OR (lower($1) <= lower(timerange) AND upper($1) >= lower(timerange)))';		
	EXECUTE sql INTO cnt USING f_period;
		IF cnt > 0 THEN
			RETURN true;
		END IF;
	return false;
END;
$BODY$;
ALTER FUNCTION public.m_tintersects_noindex(mgeometry, int8range)
    OWNER TO postgres;	
	
/*
	m_tintersects with index 
*/	

CREATE OR REPLACE FUNCTION public.m_tintersects_index(
	mgeometry,
	int8range)
	RETURNS bool
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	cnt					integer;
	trantext			int8range;
BEGIN

	sql := 'select f_mgeometry_segtable_name from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
	--trantext := (f_period::text)::int8range;
	sql := 'select count(*) from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(f_mgeometry.moid) ||' AND timerange && $1;';
   	EXECUTE sql into cnt USING f_period;	
	IF (cnt > 0) then 
		RETURN true;
	END IF;
	RETURN false;
END;
$BODY$;
ALTER FUNCTION public.m_tintersects_index(mgeometry, int8range)
    OWNER TO postgres;	
	
/*   
   m_tintersects_materialized with index into temporal table
*/

CREATE OR REPLACE FUNCTION public.m_tintersects_materialized(
	mgeometry,
	int8range)
	RETURNS bool
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	cnt					integer;
	meta_key 			text;
	meta_value			text;
	sql_text			varchar;
	table_key			text;
	session_key 			text;
	session_value			text;
	tmp_table			text;
BEGIN
	---------------mgeometry table
	meta_key := 'temp.mgeometry.column';
	BEGIN
		meta_value := current_setting(meta_key);
		--RAISE NOTICE 'meta_value :%', meta_value;
	EXCEPTION when undefined_object then
		perform set_config(meta_key, '0', false);	     
		meta_value := current_setting(meta_key);
	END;	
	IF (meta_value = '0') THEN	
		perform set_config(meta_key, '1', false);
		table_key := 'temp_mgeometry_column';
		sql_text := 'CREATE  temporary TABLE '|| table_key || ' as ';
		sql_text := sql_text || ' SELECT * FROM mgeometry_columns';
		EXECUTE sql_text ;
	END IF;		
	 	sql :=  'select f_mgeometry_segtable_name  from temp_mgeometry_column where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
		EXECUTE sql INTO f_mgeometry_segtable_name;
	-----------temporal query	
	session_key := 'temp.intersects.column';
	BEGIN
		session_value := current_setting(session_key);
	EXCEPTION when undefined_object then
		perform set_config(session_key, '0', false);	     
		session_value := current_setting(session_key);
	END;
	IF (session_value = '0') THEN	
		perform set_config(session_key, '1', false);
		tmp_table := 'temp_table';
		sql_text := 'CREATE temporary TABLE ' ||tmp_table|| ' as ';
		sql_text := sql_text || ' SELECT DISTINCT mpid FROM ' || f_mgeometry_segtable_name;
		sql_text := sql_text || ' WHERE timerange && $1;';
		EXECUTE sql_text USING f_period;
	END IF;		
	
	sql_text := 'SELECT COUNT(*) FROM temp_table WHERE mpid = ' || f_mgeometry.moid;
	EXECUTE sql_text INTO cnt;	
		IF cnt > 0 THEN
			RETURN true;
		END IF;	
	return false;
	END;
$BODY$;
ALTER FUNCTION public.m_tintersects_materialized(mgeometry, int8range)
    OWNER TO postgres;	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		
-----------------------------m_sintersects_index
		

		
/*
	m_sintersects_noindex    basic with no index
*/

CREATE OR REPLACE FUNCTION public.m_sintersects_noindex(
	mgeometry,
	geometry)
	RETURNS bool
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_geometry			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	geos				text;
	res				bool;
BEGIN
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
	sql := 'select st_astext(st_union(st_makeline(geo::geometry[]))) from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(f_mgeometry.moid);
	EXECUTE sql INTO geos; 
	sql := 'select ' || m_intersects(geos, st_astext(f_geometry));
	EXECUTE sql INTO res; 
END;
$BODY$;
ALTER FUNCTION public.m_sintersects_noindex(mgeometry, geometry)
    OWNER TO postgres;	
	
/*
	m_sintersects with index 
*/	

CREATE OR REPLACE FUNCTION public.m_sintersects_index(
	mgeometry,
	geometry)
	RETURNS bool
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_geometry			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	res					bool;
	geos				geometry;
BEGIN
	sql := 'select f_mgeometry_segtable_name from mgeometry_columns where f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
	sql := 'select st_union(st_makeline(geo::geometry[])) from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(f_mgeometry.moid);
	EXECUTE sql INTO geos; 
	sql := 'select ' ||st_intersects(geos,f_geometry);
	EXECUTE sql INTO res USING f_geometry; 
	RETURN res;
END;
$BODY$;
ALTER FUNCTION public.m_sintersects_index(mgeometry, geometry)
    OWNER TO postgres;	
	
/*   
   m_sintersects_materialized with index into temporal table
*/

CREATE OR REPLACE FUNCTION public.m_sintersects_materialized(
	mgeometry,
	geometry)
	RETURNS bool
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_geometry			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	cnt					integer;
	meta_key 			text;
	meta_value			text;
	sql_text			varchar;
	table_key			text;
	session_key 			text;
	session_value			text;
	tmp_table			text;
BEGIN
	---------------mgeometry table
	meta_key := 'temp.mgeometry.spatial';
	BEGIN
		meta_value := current_setting(meta_key);
		--RAISE NOTICE 'meta_value :%', meta_value;
	EXCEPTION when undefined_object then
		perform set_config(meta_key, '0', false);	     
		meta_value := current_setting(meta_key);
	END;	
	IF (meta_value = '0') THEN	
		perform set_config(meta_key, '1', false);
		table_key := 'temp_mgeometry_spatial';
		sql_text := 'CREATE  temporary TABLE '|| table_key || ' as ';
		sql_text := sql_text || ' SELECT * FROM mgeometry_columns';
		EXECUTE sql_text ;
	END IF;		
	 	sql :=  'select f_mgeometry_segtable_name  from temp_mgeometry_column where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
		EXECUTE sql INTO f_mgeometry_segtable_name;
	-----------temporal query	
	session_key := 'temp.intersects.spatial';
	BEGIN
		session_value := current_setting(session_key);
	EXCEPTION when undefined_object then
		perform set_config(session_key, '0', false);	     
		session_value := current_setting(session_key);
	END;
	IF (session_value = '0') THEN	
		perform set_config(session_key, '1', false);
		tmp_table := 'temp_table_spatial';
		sql_text := 'CREATE temporary TABLE ' ||tmp_table|| ' as ';
		sql_text := sql_text || ' SELECT DISTINCT mpid FROM ' || f_mgeometry_segtable_name;
		sql_text := sql_text || ' WHERE st_intersects(st_makeline(geo::geometry[]),$1);';
		EXECUTE sql_text USING f_geometry;
	END IF;		
	
	sql_text := 'SELECT COUNT(*) FROM temp_table_spatial WHERE mpid = ' || f_mgeometry.moid;
	EXECUTE sql_text INTO cnt;	
		IF cnt > 0 THEN
			RETURN true;
		END IF;	
	return false;
	END;
$BODY$;
ALTER FUNCTION public.m_sintersects_materialized(mgeometry, geometry)
    OWNER TO postgres;	
	
	
	
	
	
	
	
	
	
	
	--------------------------------------------
		
/*
	m_intersects_noindex    basic with no index
*/

CREATE OR REPLACE FUNCTION public.m_intersects_noindex(
	mgeometry,
	geometry, int8range)
	RETURNS bool
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_geometry			alias for $2;
	f_period			alias for $3;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	geos				text;
	res				bool;
BEGIN
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
	sql := 'select st_astext(st_union(st_makeline(geo::geometry[]))) from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(f_mgeometry.moid) ||
	' AND  ((lower(timerange) <= lower($1) AND upper(timerange) >= lower($1)) 
	OR (lower($1) <= lower(timerange) AND upper($1) >= lower(timerange)))';	
	EXECUTE sql INTO geos USING f_period; 
	sql := 'select ' || m_intersects(geos, st_astext(f_geometry));
	EXECUTE sql INTO res; 
END;
$BODY$;
ALTER FUNCTION public.m_intersects_noindex(mgeometry, geometry, int8range)
    OWNER TO postgres;	
	
/*
	m_intersects with index 
*/	

CREATE OR REPLACE FUNCTION public.m_intersects_index(
	mgeometry,
	geometry, int8range)
	RETURNS bool
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_geometry			alias for $2;
	f_period			alias for $3;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	cnt					integer;
BEGIN
	sql := 'select f_mgeometry_segtable_name from mgeometry_columns where f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
	sql := 'select COUNT(*) from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(f_mgeometry.moid) ||' AND timerange && $1 AND ST_Intersects(st_makeline(geo::geometry[]), $2);';
	EXECUTE sql INTO cnt USING f_period, f_geometry; 
	IF (cnt > 0) then 
		RETURN true;
	END IF;
	RETURN false;
END;
$BODY$;
ALTER FUNCTION public.m_intersects_index(mgeometry, geometry, int8range)
    OWNER TO postgres;	
	
/*   
   m_intersects_materialized with index into temporal table
*/

CREATE OR REPLACE FUNCTION public.m_intersects_materialized(
	mgeometry,
	geometry, int8range)
	RETURNS bool
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_geometry			alias for $2;
	f_period			alias for $3;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	cnt					integer;
	meta_key 			text;
	meta_value			text;
	sql_text			varchar;
	table_key			text;
	session_key 			text;
	session_value			text;
	tmp_table			text;
BEGIN
	---------------mgeometry table
	meta_key := 'temp.mgeometry.st';
	BEGIN
		meta_value := current_setting(meta_key);
		--RAISE NOTICE 'meta_value :%', meta_value;
	EXCEPTION when undefined_object then
		perform set_config(meta_key, '0', false);	     
		meta_value := current_setting(meta_key);
	END;	
	IF (meta_value = '0') THEN	
		perform set_config(meta_key, '1', false);
		table_key := 'temp_mgeometry_st';
		sql_text := 'CREATE  temporary TABLE '|| table_key || ' as ';
		sql_text := sql_text || ' SELECT * FROM mgeometry_columns';
		EXECUTE sql_text ;
	END IF;		
	 	sql :=  'select f_mgeometry_segtable_name  from temp_mgeometry_column where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
		EXECUTE sql INTO f_mgeometry_segtable_name;
	-----------temporal query	
	session_key := 'temp.intersects.st';
	BEGIN
		session_value := current_setting(session_key);
	EXCEPTION when undefined_object then
		perform set_config(session_key, '0', false);	     
		session_value := current_setting(session_key);
	END;
	IF (session_value = '0') THEN	
		perform set_config(session_key, '1', false);
		tmp_table := 'temp_table_st';
		sql_text := 'CREATE temporary TABLE ' ||tmp_table|| ' as ';
		sql_text := sql_text || ' SELECT DISTINCT mpid FROM ' || f_mgeometry_segtable_name;
		sql_text := sql_text || ' WHERE timerange && $1 AND st_intersects(st_makeline(geo::geometry[]),$2);';
		EXECUTE sql_text USING f_period, f_geometry;
	END IF;		
	
	sql_text := 'SELECT COUNT(*) FROM temp_table_st WHERE mpid = ' || f_mgeometry.moid;
	EXECUTE sql_text INTO cnt;	
		IF cnt > 0 THEN
			RETURN true;
		END IF;	
	return false;
	END;
$BODY$;
ALTER FUNCTION public.m_intersects_materialized(mgeometry, geometry, int8range)
    OWNER TO postgres;	
	
	
	
	
	
	
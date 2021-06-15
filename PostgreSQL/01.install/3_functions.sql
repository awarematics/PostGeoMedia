



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
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
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
	times				bigint[];
	mpid                integer;
	results				text;
BEGIN
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
	mpid := f_mgeometry.moid;
	sql := 'select  datetimes from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
   	EXECUTE sql into times;
	results := m_tintersects(times, f_period::text);
	return results;
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
	points				text[];
	spatials			geometry;
BEGIN
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
	sql := 'select geo from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||quote_literal(f_mgeometry.moid);
    EXECUTE sql into points;

	spatials := ST_MakeLine(points);
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
		
	
CREATE OR REPLACE FUNCTION public.m_tintersects_index(
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
	mpid                integer;
	timerange			int8range;
	trajid				integer;
	results				boolean;
BEGIN

	sql := 'select f_segtableoid from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
	mpid := f_mgeometry.moid;
	sql := 'select timerange from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
   	EXECUTE sql into timerange;
	
	IF (timerange @> f_period.fromtime or timerange @> f_period.totime ) THEN
			RETURN true;
	ELSE
			RETURN false;
	END IF;
	RETURN results;
END;
$BODY$;
ALTER FUNCTION public.m_tintersects_index(mgeometry, period)
    OWNER TO postgres;		
	
	
CREATE OR REPLACE FUNCTION public.m_tintersects_index(
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
	times				bigint[];
	mpid                integer;
	timerange			int8range;
	trajid				integer;
	results				boolean;
	cnt					integer;
BEGIN

	sql := 'select f_segtableoid from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
	mpid := f_mgeometry.moid;
	sql := 'select timerange from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
   	EXECUTE sql into timerange;
	
	sql :='';
	IF (timerange @> f_period.fromtime or timerange @> f_period.totime ) THEN
		sql := sql || ' SELECT COUNT(*) from ' || (f_mgeometry_segtable_name) || ' mgeo';
		sql := sql || ' where mgeo.mpid = '|| f_mgeometry.moid || ' and m_tintersects(mgeo.datetimes, $1::text);';
   		EXECUTE sql INTO cnt using f_period;
	
		IF cnt > 0 THEN
			RETURN true;
		ELSE
			RETURN false;
		END IF;		
	END IF;
	RETURN results;
END;
$BODY$;
ALTER FUNCTION public.m_tintersects_index(mgeometry, period)
    OWNER TO postgres;		
	
	
	
		
-----------------------------m_sintersects_index
		


CREATE OR REPLACE FUNCTION public.m_sintersects_index(
	mgeometry,
	geometry)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT PARALLEL UNSAFE
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_geometry			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	mpid                integer;
	mbr			geometry;
	trajid				integer;
	results				boolean;
	cnt					integer;
BEGIN

	sql := 'select f_segtableoid from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
	mpid := f_mgeometry.moid;
	sql := 'select  mbr from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
   	EXECUTE sql into mbr;

	IF (mbr && f_geometry) THEN
		sql := ' SELECT COUNT(*) from ' || (f_mgeometry_segtable_name) || ' mgeo';
		sql := sql || ' where mgeo.mpid = '|| f_mgeometry.moid || ' and st_intersects(ST_MakeLine(mgeo.geo::geometry[]),$1);';
   		EXECUTE sql INTO cnt using f_geometry;
		IF cnt > 0 THEN
			RETURN true;
		ELSE
			RETURN false;
		END IF;		
	END IF;
	results := false;
	RETURN results;
END;
$BODY$;

ALTER FUNCTION public.m_sintersects_index(mgeometry, geometry)
    OWNER TO postgres;
		
		
	-----------------------------m_intersects_index	
	
CREATE OR REPLACE FUNCTION public.m_intersects_index(
	integer,
	integer)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT PARALLEL UNSAFE
AS $BODY$
DECLARE
	f_sid				alias for $1;
	f_tid				alias for $2;
	sql					text;
	cnt					integer;
BEGIN
	
	if(f_sid = f_tid) then
		return true;
		END IF;
	RETURN false;
END;
$BODY$;

ALTER FUNCTION public.m_intersects_index(integer, integer)
    OWNER TO postgres;






CREATE OR REPLACE FUNCTION public.m_tintersects_id(
	mgeometry,
	period)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT PARALLEL UNSAFE
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	mpid                integer;
	times				int8range;
	trajid				integer;
BEGIN

	sql := 'select f_segtableoid from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
	mpid := f_mgeometry.moid;
	sql := 'select  timerange from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
   	EXECUTE sql into times;

	IF (times && (f_period::text)::int8range) THEN
		RETURN mpid;
	END IF;
	return null;
END;
$BODY$;

ALTER FUNCTION public.m_tintersects_id(mgeometry, period)
    OWNER TO postgres;





CREATE OR REPLACE FUNCTION public.m_sintersects_id(
	mgeometry,
	geometry)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT PARALLEL UNSAFE
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_geometry			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	mpid                integer;
	mbr					geometry;
	trajid				integer;
BEGIN

	sql := 'select f_segtableoid from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
	mpid := f_mgeometry.moid;
	sql := 'select  mbr from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
   	EXECUTE sql into mbr;
	IF (mbr && f_geometry) THEN
	---------------id
		sql := 'SELECT mpid from ' || (f_mgeometry_segtable_name) || ' mgeo';
		sql := sql || ' where mgeo.mpid = '|| f_mgeometry.moid || ' A ND st_intersects(ST_MakeLine(mgeo.geo::geometry[]),$1)';
   		EXECUTE sql into mpid using f_geometry;
	END IF;
	RETURN null;
END;
$BODY$;

ALTER FUNCTION public.m_sintersects_id(mgeometry, geometry)
    OWNER TO postgres;

	
	



CREATE OR REPLACE FUNCTION public.m_sintersects(
	mgeometry,
	geometry,period)
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
	times				bigint[];
	mpid                integer;
	mbr			geometry;
	trajid				integer;
	results				boolean;
	cnt					integer;
BEGIN

	sql := 'select f_segtableoid from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
	mpid := f_mgeometry.moid;

		sql := ' SELECT COUNT(*) from ' || (f_mgeometry_segtable_name) || ' mgeo';
		sql := sql || ' where mgeo.mpid = '|| f_mgeometry.moid || ' and st_intersects(ST_MakeLine(mgeo.geo::geometry[]),$1) and m_tintersects($2,$3);';
   		EXECUTE sql INTO cnt using f_geometry, f_mgeometry, f_period;
	
		IF cnt > 0 THEN
			RETURN true;
		ELSE
			RETURN false;
		END IF;		
	results := false;
	RETURN results;
END;
$BODY$;
ALTER FUNCTION public.m_sintersects(mgeometry, geometry, period)
    OWNER TO postgres;		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
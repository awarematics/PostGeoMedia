



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
	trajid				integer;
	typename			text;
	uritext				text;
	horizontalangle		double precision[];
	verticalangle		double precision[];
	direction2d			double precision[];
	direction3d			double precision[];
	distance			double precision[];
	
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
	sql := 'select type  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO typename;
	mpid := f_mgeometry.moid;
	sql := 'select  datetimes from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
   	EXECUTE sql into times;
	
	IF (typename = 'mvideo' and times is not null) THEN
	sql := 'select geo::text[] from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
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
		sql := 'select geo::text[] from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
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
	trajid				integer;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
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
	
	
	
		
---m_tintersect(mpoint, long) bool

	
CREATE OR REPLACE FUNCTION public.m_tintersects(
	mgeometry,
	bigint)
	RETURNS bool
   LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_long				alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	times				bigint[];
	mpid                integer;
	periodstring		text;
	results				text;
	trajid				integer;	
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
	mpid := f_mgeometry.moid;
	sql := 'select  datetimes from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
   	EXECUTE sql into times;
	periodstring := '('||f_long||','||f_long||')';
	results := m_tintersects(times, periodstring);
	return results;
END;
$BODY$;
ALTER FUNCTION public.m_tintersects(mgeometry, bigint)
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
	points				text[];
	mpid                integer;
	results				text;
	spatials			text;
	trajid				integer;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
	mpid := f_mgeometry.moid;	
	sql := 'select geo::text[] from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    EXECUTE sql into points;

	spatials := m_spatial(points);
	results := st_intersects(spatials::geometry, f_geometry);

	return results;
END;
$BODY$;
ALTER FUNCTION public.m_sintersects(mgeometry, geometry)
    OWNER TO postgres;	
	

		
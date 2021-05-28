



--m_astext(mpoint) text
	
CREATE OR REPLACE FUNCTION public.m_astext(
	mgeometry)
    RETURNS SETOF text
    LANGUAGE 'plpgsql'	
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	trajid				integer;
	mpid                integer;
	results				text;
BEGIN
	 sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;	
	sql := 'select wkttraj from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RETURN QUERY EXECUTE sql;
END
$BODY$;
ALTER FUNCTION public.m_astext(mgeometry)
    OWNER TO postgres;
    
    
    
    
    
--m_times(mpoint, double/bigint) geometry    
  

CREATE OR REPLACE FUNCTION public.m_times(
	mgeometry, double precision)
    RETURNS setof geometry
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_double			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	trajid				integer;
	mpid                integer;
	res					int8range;
	results				text;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;	
		sql := 'select m_snapshot(wkttraj, ' || (f_double)::bigint ||') from ' || (f_mgeometry_segtable_name) ||' where mpid =' ||(mpid)|| ' AND timerange @>'|| (f_double)::bigint;
		EXECUTE sql into results;
    	RETURN QUERY SELECT st_geomfromtext(results);
END
$BODY$;
ALTER FUNCTION public.m_times(mgeometry, double precision)
    OWNER TO postgres;	


	

--m_tintersect(mpoint, period/bigint/double) bool


CREATE OR REPLACE FUNCTION public.m_tintersects(
	mgeometry,
	double precision)
    RETURNS setof bool
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_double			alias for $2;
	f_mgeometry_segtable_name	char(200);
	results				text;
	sql					text;
	trajid				integer;
	mpid                integer;
	res					geometry;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;	
	sql := 'select m_tintersects(wkttraj, ' || (f_double) ||') from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
	 RAISE info '%', sql;
    RETURN QUERY EXECUTE sql;
END
$BODY$;
ALTER FUNCTION public.m_tintersects(mgeometry, double precision)
    OWNER TO postgres;
		


CREATE OR REPLACE FUNCTION public.m_tintersects(
	mgeometry,
	period)
    RETURNS setof bool
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_double			alias for $2;
	f_mgeometry_segtable_name	char(200);
	results				text;
	sql					text;
	trajid				integer;
	mpid                integer;
	res					geometry;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;	
	sql := 'select m_tintersects(wkttraj, ' || quote_literal(f_double) ||') from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
	 RAISE info '%', sql;
    RETURN QUERY EXECUTE sql;
END
$BODY$;
ALTER FUNCTION public.m_tintersects(mgeometry, period)
    OWNER TO postgres;	

--m_sintersect(mpoint, geometry) bool

	
CREATE OR REPLACE FUNCTION public.m_sintersects(
	mgeometry,
	geometry)
    RETURNS setof boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_geometry		alias for $2;
	f_mgeometry_segtable_name	char(200);
	results				text;
	sql					text;
	trajid				integer;
	mpid                integer;
	res					geometry;
	temps				boolean;
	mbr					geometry;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid);
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;	
	
	sql := 'select mbr from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
	execute sql into mbr;
	IF(ST_Intersects(mbr, f_geometry)) THEN
		sql := 'select trajectory from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
		execute sql into res;
    	RETURN QUERY EXECUTE 'SELECT ' ||ST_Intersects(res, f_geometry);
	END IF;
END
$BODY$;
ALTER FUNCTION public.m_sintersects(mgeometry, geometry)
    OWNER TO postgres;	
	

	-----------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.m_dwithin(mgeometry, mgeometry, double precision)
RETURNS setof boolean AS 
$BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_mgeometry3			alias for $3;
	f_mgeometry_segtable_name	char(200);
	f_mgeometry_segtable_name2	char(200);
	sql					text;
	trajid				integer;
	trajid2				integer;
	mpid                integer;
	mpid2                integer;
	mpoint1				geometry;
	mpoint2				geometry;
	booldis				boolean;
	
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry1.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry1.moid;	


	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry2.segid);
	EXECUTE sql INTO trajid2;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid2 );
	EXECUTE sql INTO f_mgeometry_segtable_name2;
    mpid2 := f_mgeometry2.moid;	

	sql := 'select mbr from ' || (f_mgeometry_segtable_name2) ||' where mpid = ' ||(mpid2);
   	EXECUTE sql INTO mpoint2;
	sql := 'select mbr from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    EXECUTE sql INTO mpoint1;
	
	IF(mpoint1 && ST_expand(mpoint2, f_mgeometry3)) THEN		
    	RETURN QUERY select m_spatial(f_mgeometry1) && ST_expand(m_spatial(f_mgeometry2), f_mgeometry3);
	END IF;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
		

	

--m_mindistance(mpoint, mpoint) double


CREATE OR REPLACE FUNCTION public.m_mindistance(
	mgeometry,
	mgeometry)
    RETURNS setof double precision
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_mgeometry_segtable_name	char(200);
	f_mgeometry_segtable_name2	char(200);
	sql					text;
	trajid				integer;
	trajid2				integer;
	mpid                integer;
	mpid2                integer;
	mpoint1				geometry;
	mpoint2				geometry;
	mindouble			double precision;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry1.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry1.moid;	


	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry2.segid);
	EXECUTE sql INTO trajid2;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid2 );
	EXECUTE sql INTO f_mgeometry_segtable_name2;
    mpid2 := f_mgeometry2.moid;	

	IF(f_mgeometry1.moid != f_mgeometry2.moid) THEN
			sql := 'select trajectory from ' || (f_mgeometry_segtable_name2) ||' where mpid = ' ||(mpid2);
   			EXECUTE sql INTO mpoint2;
			sql := 'select trajectory from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    		EXECUTE sql INTO mpoint1;
    		RETURN QUERY select st_distance(mpoint1, mpoint2);
	END IF;
END
$BODY$;
ALTER FUNCTION public.m_mindistance(mgeometry, mgeometry)
    OWNER TO postgres;
	
	


--m_spatial(mpoint) geometry

    
CREATE OR REPLACE FUNCTION public.m_spatial(mgeometry)
RETURNS setof geometry AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry_segtable_name	char(200);
	results				text;
	sql					text;
	trajid				integer;
	mpid                integer;
	res					geometry;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;	
	sql := 'select ST_GeomFromText(m_spatial(wkttraj)) from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RETURN QUERY EXECUTE sql;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
		



--m_eventtime(mpoint,geom, double) double


	
CREATE OR REPLACE FUNCTION public.m_eventtime(
	mgeometry,
	geometry)
    RETURNS setof double precision
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_mgeometry_segtable_name	char(200);
	results				text;
	sql					text;
	trajid				integer;
	mpid                integer;
	res					geometry;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry1.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry1.moid;	
	sql := 'select m_eventtime(wkttraj, ' || st_astext(f_mgeometry2) ||') from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RETURN QUERY EXECUTE sql;
END
$BODY$;
ALTER FUNCTION public.m_eventtime(mgeometry, geometry)
    OWNER TO postgres;
		


CREATE OR REPLACE FUNCTION public.m_eventtime(
	mgeometry, mgeometry, 
	double precision)
    RETURNS setof double precision
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_distance			alias for $3;
	f_mgeometry_segtable_name1	char(200);
	f_mgeometry_segtable_name2	char(200);
	results				text;
	sql					text;
	trajid1				integer;
	mpid1                integer;
	trajid2				integer;
	mpid2                integer;
	res					geometry;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry1.segid);
	EXECUTE sql INTO trajid1;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid1);
	EXECUTE sql INTO f_mgeometry_segtable_name1;
    mpid1 := f_mgeometry1.moid;	
	
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry2.segid);
	EXECUTE sql INTO trajid2;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid2);
	EXECUTE sql INTO f_mgeometry_segtable_name2;
    mpid2 := f_mgeometry2.moid;	
	sql := 'select m_eventtime(a.wkttraj, b.wkttraj, '||(f_distance)||') from a.'||(f_mgeometry_segtable_name1)||' b.'||(f_mgeometry_segtable_name2)||' where a.mpid = '||(mpid1)||' AND b.mpid = '||(mpid2);
    RETURN QUERY EXECUTE sql;
END
$BODY$;
ALTER FUNCTION public.m_eventtime(mgeometry, mgeometry, double precision)
    OWNER TO postgres;


	


--m_eventposition(mpoint, geom, double) geometry
	

CREATE OR REPLACE FUNCTION public.m_eventposition(
	mgeometry,
	mgeometry, double precision)
    RETURNS setof geometry
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_distance			alias for $3;
	f_mgeometry_segtable_name1	char(200);
	f_mgeometry_segtable_name2	char(200);
	sql					text;
	trajid1				integer;
	mpid1                integer;
	trajid2				integer;
	mpid2                integer;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry1.segid);
	EXECUTE sql INTO trajid1;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid1);
	EXECUTE sql INTO f_mgeometry_segtable_name1;
    mpid1 := f_mgeometry1.moid;	
	
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry2.segid);
	EXECUTE sql INTO trajid2;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid2);
	EXECUTE sql INTO f_mgeometry_segtable_name2;
    mpid2 := f_mgeometry2.moid;	
	
	sql := 'select ST_GeomFromText(m_eventposition(a.wkttraj, b.wkttraj, '||(f_distance)||')) from a.'||(f_mgeometry_segtable_name1)||' b.'||(f_mgeometry_segtable_name2)||' where a.mpid = '||(mpid1)||' AND b.mpid = '||(mpid2);
    RETURN QUERY EXECUTE sql;
END
$BODY$;
ALTER FUNCTION public.m_eventposition(mgeometry, mgeometry, double precision)
    OWNER TO postgres;	
	
	
	


--m_slice(mpoint, period) text

CREATE OR REPLACE FUNCTION public.m_slice(
	mgeometry,
	period)
    RETURNS setof text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	trajid				integer;
	mpid                integer;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;	
	sql := 'select m_slice(wkttraj, '|| (f_period) ||') from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RETURN QUERY EXECUTE sql;
END
$BODY$;

ALTER FUNCTION public.m_slice(mgeometry, Period)
    OWNER TO postgres;




--m_timeatcummulative(mpoint) double

CREATE OR REPLACE FUNCTION public.m_timeatcummulative(mgeometry)
RETURNS setof double precision AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry_segtable_name	char(200);
	results				text;
	sql					text;
	trajid				integer;
	mpid                integer;
	res					geometry;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;	
	sql := 'select m_timeatcummulative(wkttraj) from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RETURN QUERY EXECUTE sql;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;




--m_passes(mpoint, geom) bool

CREATE OR REPLACE FUNCTION public.m_passes(
	mgeometry,
	geometry)
    RETURNS setof bool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_mgeometry_segtable_name	char(200);
	results				text;
	sql					text;
	trajid				integer;
	mpid                integer;
	res					geometry;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry1.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry1.moid;	
	sql := 'select m_passes(wkttraj, ' || st_astext(f_mgeometry2) ||') from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RETURN QUERY EXECUTE sql;
END
$BODY$;
ALTER FUNCTION public.m_passes(mgeometry, geometry)
    OWNER TO postgres;
    
    
    
--m_meets(mpoint, geom) bool

CREATE OR REPLACE FUNCTION public.m_meets(
	mgeometry,
	geometry)
    RETURNS setof bool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_mgeometry_segtable_name	char(200);
	results				text;
	sql					text;
	trajid				integer;
	mpid                integer;
	res					geometry;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry1.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry1.moid;	
	sql := 'select m_meets(wkttraj, ' || st_astext(f_mgeometry2) ||') from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RETURN QUERY EXECUTE sql;
END
$BODY$;
ALTER FUNCTION public.m_meets(mgeometry, geometry)
    OWNER TO postgres;



--m_insides(mpoint, geom) bool

CREATE OR REPLACE FUNCTION public.m_insides(
	mgeometry,
	geometry)
    RETURNS setof bool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_mgeometry_segtable_name	char(200);
	results				text;
	sql					text;
	trajid				integer;
	mpid                integer;
	res					geometry;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry1.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry1.moid;	
	sql := 'select m_insides(wkttraj, ' || st_astext(f_mgeometry2) ||') from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RETURN QUERY EXECUTE sql;
END
$BODY$;
ALTER FUNCTION public.m_insides(mgeometry, geometry)
    OWNER TO postgres;
    
    

--m_disjoints(mpoint, mpoint, period) 	

CREATE OR REPLACE FUNCTION public.m_disjoints(
	mgeometry,
	geometry)
    RETURNS setof bool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_mgeometry_segtable_name	char(200);
	results				text;
	sql					text;
	trajid				integer;
	mpid                integer;
	res					geometry;
BEGIN
	sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry1.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry1.moid;	
	sql := 'select m_disjoints(wkttraj, ' || st_astext(f_mgeometry2) ||') from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RETURN QUERY EXECUTE sql;
END
$BODY$;
ALTER FUNCTION public.m_disjoints(mgeometry, geometry)
    OWNER TO postgres;

	
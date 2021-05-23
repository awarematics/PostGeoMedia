
   
CREATE OR REPLACE FUNCTION public.m_astext(
	mpoint)
    RETURNS text
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
	points				text;
	times				text;
	results				text;
	mpoints				text;
	mgeometry_types		char(50);
BEGIN
	mgeometry_types := 'mpoint';
	if(f_mgeometry.t IS NULL) then
	 sql := 'select f_segtableoid  from mgeometry_columns where  f_segtableoid = ' ||quote_literal(f_mgeometry.segid);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;
	
	sql := 'select geo from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RAISE DEBUG '%', sql;
	 RAISE info '%', sql;
    EXECUTE sql INTO points;
	sql := 'select datetimes from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RAISE DEBUG '%', sql;
    EXECUTE sql INTO times;
	results := 'mpoint '|| points||';'||times;
	else 
	results := 'mpoint '|| quote_literal(f_mgeometry.geo)||';'||quote_literal(f_mgeometry.t);
	end if;
	mpoints := m_astext(results);	
	return mpoints;
END
$BODY$;

ALTER FUNCTION public.m_astext(mpoint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_passes(
	mpoint,
	geometry)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := ST_AsText(f_mgeometry2);
	res := m_passes(results, results2);
	return res;
END
$BODY$;

ALTER FUNCTION public.m_passes(mpoint, geometry)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_eventtime(
	mpoint,
	geometry)
    RETURNS bigint
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results					text;
	results2				text;
	results3				text;
	res						bool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := st_astext(f_mgeometry2);
	results3 := m_eventposition(results, results2);
	return results3;
END
$BODY$;

ALTER FUNCTION public.m_eventtime(mpoint, geometry)
    OWNER TO postgres;
	
	

CREATE OR REPLACE FUNCTION public.m_tintersects(
	mpoint,
	timestamp with time zone)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results					text;
	results2				text;
	res						bool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := 'Period (0, '||(extract(epoch from f_mgeometry2) * 1000)||')';
	res := m_tintersects(results, results2);
	return res;
END
$BODY$;

ALTER FUNCTION public.m_tintersects(mpoint, timestamp with time zone)
    OWNER TO postgres;
-------------------------------------------------------

CREATE OR REPLACE FUNCTION public.m_astext(stphoto)
RETURNS text AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
BEGIN
	IF (f_mgeometry.annotations IS NULL) THEN
	results := 'STPHOTO ('||(f_mgeometry.uri)||' '|| (f_mgeometry.width)||' '|| (f_mgeometry.height)||' ('|| ((f_mgeometry.fov))||') null'
	|| ' ('|| ((f_mgeometry.geo).pointx)||' '|| ((f_mgeometry.geo).pointy)||' '|| ((f_mgeometry.geo).pointz)||') '|| EXTRACT(EPOCH FROM (f_mgeometry.t))||')';
	ELSE
	results := 'STPHOTO ('||(f_mgeometry.uri)||' '|| (f_mgeometry.width)||' '|| (f_mgeometry.height)||' ('|| ((f_mgeometry.fov))||') '
	|| (f_mgeometry.annotations)||' ('|| ((f_mgeometry.geo).pointx)||' '|| ((f_mgeometry.geo).pointy)||' '|| ((f_mgeometry.geo).pointz)||') '|| EXTRACT(EPOCH FROM (f_mgeometry.t))||')';
	END IF;
	
	return results;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;	
	
---------------------------------------------------------
	
CREATE OR REPLACE FUNCTION public.M_tOverlaps(mpoint, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mpoints				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_toverlaps(results, f_period);
	RAISE INFO '%', mpoints;
	return mpoints;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	



CREATE OR REPLACE FUNCTION public.M_Slice(mpoint, character varying)
RETURNS mpoint AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mpoints				text;
	res					mpoint;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_slice(results, f_period);
	IF (mpoints	 != 'MPOINT ()') THEN
	res.moid :=  f_mgeometry.moid;
	res.t := regexp_split_to_array(mpointtime(mpoints),',') ::timestamp without time zone[];
	res.geo := regexp_split_to_array(mpointpoint(mpoints),';') ::mcoordinate[];		
	END IF;
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	


CREATE OR REPLACE FUNCTION public.M_Slice(mpoint, character varying, character varying)
RETURNS mpoint AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	f_polygon			alias for $3;
	results				text;
	mpoints				text;
	res					mpoint;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_slice(results, f_period, f_polygon);
	IF (mpoints	 != 'MPOINT ()') THEN
	res.moid :=  f_mgeometry.moid;
	res.t := regexp_split_to_array(mpointtime(mpoints),',') ::timestamp without time zone[];
	res.geo := regexp_split_to_array(mpointpoint(mpoints),';') ::mcoordinate[];		
	END IF;
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;


	
CREATE OR REPLACE FUNCTION public.M_tContains(mpoint, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mpoints				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_tcontains(results, f_period);
	RAISE INFO '%', mpoints;
	return mpoints;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;



	
CREATE OR REPLACE FUNCTION public.M_tEquals(mpoint, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mpoints				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_tequals(results, f_period);
	RAISE INFO '%', mpoints;
	return mpoints;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_tPrecedes(mpoint, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mpoints				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_tprecedes(results, f_period);
	RAISE INFO '%', mpoints;
	return mpoints;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_tSucceeds(mpoint, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mpoints				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_tsucceeds(results, f_period);
	RAISE INFO '%', mpoints;
	return mpoints;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
	
CREATE OR REPLACE FUNCTION public.M_tImmPrecedes(mpoint, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mpoints				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_timmprecedes(results, f_period);
	RAISE INFO '%', mpoints;
	return mpoints;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_tImmSucceeds(mpoint, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mpoints				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_timmsucceeds(results, f_period);
	RAISE INFO '%', mpoints;
	return mpoints;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
	
CREATE OR REPLACE FUNCTION public.M_tImmSucceeds(mpoint, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mpoints				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_timmsucceeds(results, f_period);
	RAISE INFO '%', mpoints;
	return mpoints;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	

CREATE OR REPLACE FUNCTION public.M_At(mpoint, integer )
RETURNS mpoint AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_num				alias for $2;
	results				text;
	mpoints				text;
	res					mpoint;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_at(results, f_num);
	IF (mpoints	 != 'MPOINT ()') THEN
	res.moid :=  f_mgeometry.moid;
	res.t := regexp_split_to_array(mpointtime(mpoints),',') ::timestamp without time zone[];
	res.geo := regexp_split_to_array(mpointpoint(mpoints),';') ::mcoordinate[];	
	END IF;
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
	
CREATE OR REPLACE FUNCTION public.M_NumOf(mpoint)
RETURNS integer AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
	res					integer;
BEGIN
	results := m_astext(f_mgeometry);
	res := m_numof(results);
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
CREATE OR REPLACE FUNCTION public.M_Time(mpoint)
RETURNS period AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
	res					text;
	per					period;
	Longs				bigint[];
BEGIN
	results := m_astext(f_mgeometry);
	res := m_time(results);
	RAISE INFO '%', res;
	res := regexp_replace(res, '\)','');
	res :=regexp_replace(res, '\(','');
	Longs := regexp_split_to_array(res,' ') ::bigint[];	
	per.fromtime :=  Longs[1];
	per.totime :=  Longs[2];
	return per;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_StartTime(mpoint)
RETURNS bigint AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
	res					bigint;
BEGIN
	results := m_astext(f_mgeometry);
	res := m_starttime(results);
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_EndTime(mpoint)
RETURNS bigint AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
	res					bigint;
BEGIN
	results := m_astext(f_mgeometry);
	res := m_endtime(results);
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.m_meet(
	mpoint,
	geometry,
	timestamp with time zone)
    RETURNS bool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_mgeometry3			alias for $3;
	results				text;
	results2				text;
	mbools				boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := ST_ASTEXT (f_mgeometry2);
	raise info '%', results2;
	mbools := m_menters(results, results2);
	
	return mbools;
END
$BODY$;

ALTER FUNCTION public.m_meet(mpoint, geometry, timestamp with time zone)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_mstayIn(
	mpoint,
	geometry)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results					text;
	results2				text;
	res						bool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := st_astext(f_mgeometry2);
	res := m_mstayIn(results, results2);
	return res;
END
$BODY$;

ALTER FUNCTION public.m_mstayIn(mpoint, geometry)
    OWNER TO postgres;

	
	
CREATE OR REPLACE FUNCTION public.m_bbox(
	mpoint)
    RETURNS geometry
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
	res					geometry;
BEGIN
	results := m_astext(f_mgeometry);
	res := ST_GeomFromText(m_bbox(results));
	return res;
END
$BODY$;

ALTER FUNCTION public.m_bbox(mpoint)
    OWNER TO postgres;
	
CREATE OR REPLACE FUNCTION public.M_Spatial(mpoint)
RETURNS geometry AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
	res					geometry;
BEGIN
	results := m_astext(f_mgeometry);
	res := ST_GeomFromText(m_spatial(results));
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	

CREATE OR REPLACE FUNCTION public.m_spatial(
	mpoint,
	timestamp with time zone)
    RETURNS geometry
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_instant			alias for $2;
	times				text;
	results				text;
	mpoints				text;
	res					geometry;
BEGIN
	results := m_astext(f_mgeometry);
	times := extract(epoch from f_instant)::bigint*1000;
	raise info '%', times;
	mpoints := m_snapshot(results, times);
	IF (mpoints	 != 'MPOINT ()') THEN
	res := ST_GeomFromText(mpoints);	
	END IF;
	return res;
END
$BODY$;

ALTER FUNCTION public.m_spatial(mpoint,timestamp with time zone)
    OWNER TO postgres;

	
	
	
CREATE OR REPLACE FUNCTION public.m_slice(
	mpoint,
	bigint)
    RETURNS mpoint
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	periods				text;
	results				text;
	mpoints				text;
	res					mpoint;
BEGIN
	results := m_astext(f_mgeometry);
	periods := 'Period ('||f_period||', '||f_period||')';
	mpoints := m_slice(results, periods);
	IF (mpoints	 != 'MPOINT ()') THEN
	res.moid :=  f_mgeometry.moid;
	res.t := regexp_split_to_array(mpointtime(mpoints),',') ::timestamp without time zone[];
	res.geo := regexp_split_to_array(mpointpoint(mpoints),';') ::mcoordinate[];		
	END IF;
	return res;
END
$BODY$;

ALTER FUNCTION public.m_slice(mpoint, bigint)
    OWNER TO postgres;
	
	
CREATE OR REPLACE FUNCTION public.M_Snapshot(mpoint, bigint)
RETURNS geometry AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_instant			alias for $2;
	results				text;
	mpoints				text;
	res					geometry;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_snapshot(results, f_instant);
	IF (mpoints	 != 'MPOINT ()') THEN
	res := ST_GeomFromText(mpoints);	
	END IF;
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;


	
CREATE OR REPLACE FUNCTION public.m_timeatcummulative(
	mpoint,
	double precision)
    RETURNS bigint
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mpoints				bigint;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_timeatcummulative(results, f_period);
	RAISE INFO '%', mpoints;
	return mpoints;
END
$BODY$;
ALTER FUNCTION public.m_timeatcummulative(mpoint, double precision)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_snaptogrid(
	mpoint,
	integer)
    RETURNS mpoint
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mpoints				text;
	res					mpoint;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_snaptogrid(results, f_period);
	res.moid :=  f_mgeometry.moid;
	res.t := regexp_split_to_array(mpointtime(mpoints),',') ::timestamp without time zone[];
	res.geo := regexp_split_to_array(mpointpoint(mpoints),';') ::mcoordinate[];	
	return res;
END
$BODY$;
ALTER FUNCTION public.m_snaptogrid(mpoint, integer)
    OWNER TO postgres;
	

CREATE OR REPLACE FUNCTION public.m_intersects(
	mpoint,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_intersects(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_intersects(mpoint, mpoint)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_tintersects(
	mpoint,
	character varying)
    RETURNS bool
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results					text;
	results2				text;
	res						bool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := (f_mgeometry2);
	res := m_tintersects(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_tintersects(mpoint, character varying)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_tintersects(
	mvideo,
	character varying)
    RETURNS bool
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results					text;
	results2				text;
	res						bool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := (f_mgeometry2);
	res := m_tintersects(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_tintersects(mvideo, character varying)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_inside(
	mpoint,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_inside(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_inside(mpoint, mpoint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_inside(
	stphoto,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mbools := m_inside(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry2.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_inside(stphoto, mpoint)
    OWNER TO postgres;
	
	
CREATE OR REPLACE FUNCTION public.m_inside(
	stphoto,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mbools := m_inside(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry2.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_inside(stphoto, mvideo)
    OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.m_inside(
	mvideo,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_inside(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_inside(mvideo, mvideo)
    OWNER TO postgres;
    
    
CREATE OR REPLACE FUNCTION public.m_inside(
	mpoint,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_inside(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_inside(mpoint, mvideo)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_overlaps(
	mpoint,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_overlaps(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_overlaps(mpoint, mpoint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_overlaps(
	stphoto,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mbools := m_overlaps(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry2.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_overlaps(stphoto, mpoint)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_overlaps(
	stphoto,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mbools := m_overlaps(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry2.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_overlaps(stphoto, mvideo)
    OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.m_overlaps(
	mvideo,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_overlaps(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_overlaps(mvideo, mvideo)
    OWNER TO postgres;
    
    
CREATE OR REPLACE FUNCTION public.m_overlaps(
	mpoint,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_overlaps(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_overlaps(mpoint, mvideo)
    OWNER TO postgres;
    
    
    
    

CREATE OR REPLACE FUNCTION public.m_menters(
	mpoint,
	character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_menters(results, f_mgeometry2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_menters(mpoint, character varying)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_mstayin(
	mpoint,
	character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_mstayin(results, f_mgeometry2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mstayin(mpoint, character varying)
    OWNER TO postgres;
    
CREATE OR REPLACE FUNCTION public.m_mstayin(
	mvideo,
	character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_mstayin(results, f_mgeometry2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mstayin(mpoint, character varying)
    OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.m_menters(
	mpoint,
	geometry)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := ST_AsText(f_mgeometry2);
	res := m_menters(results, results2);
	return res;
END
$BODY$;

ALTER FUNCTION public.m_menters(mpoint, geometry)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_mbypasses(
	mpoint,
	character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_mbypasses(results, f_mgeometry2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mbypasses(mpoint, character varying)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_mbypasses(
	mpoint,
	geometry)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := ST_AsText(f_mgeometry2);
	res := m_mbypasses(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mbypasses(mpoint, geometry)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_mleaves(
	mpoint,
	character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_mleaves(results, f_mgeometry2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mleaves(mpoint, character varying)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_mleaves(
	mpoint,
	geometry)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := ST_AsText(f_mgeometry2);
	res := m_mleaves(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mleaves(mpoint, geometry)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_mcrosses(
	mpoint,
	character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_mcrosses(results, f_mgeometry2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mcrosses(mpoint, character varying)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_mcrosses(
	mpoint,
	geometry)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := ST_AsText(f_mgeometry2);
	res := m_mcrosses(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mcrosses(mpoint, geometry)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_eventtime(
	mpoint,
	mpoint)
    RETURNS minstant
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	minstant			text;
	res					minstant;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	minstant := m_eventtime(results, results2);
	IF (minstant != 'NULL') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(minstanttime(minstant),',') ::timestamp without time zone[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_eventtime(mpoint, mpoint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_relationship(
	mpoint,
	mpoint)
    RETURNS mstring
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mstring			text;
	res					mstring;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mstring := m_relationship(results, results2);
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mstringtime(mstring),',') ::timestamp without time zone[];	
	res.mstrings := regexp_split_to_array(mstringstring(mstring),';') ::character varying[];	
	return res;
END
$BODY$;
ALTER FUNCTION public.m_relationship(mpoint, mpoint)
    OWNER TO postgres;
---------------------------------------


CREATE OR REPLACE FUNCTION public.m_meet(
	mpoint,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_meet(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_meet(mpoint, mpoint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_meet(
	mvideo,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_meet(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_meet(mvideo, mvideo)
    OWNER TO postgres;
    
    

CREATE OR REPLACE FUNCTION public.m_meet(
	stphoto,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mbools := m_meet(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry2.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_meet(stphoto, mpoint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_meet(
	stphoto,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mbools := m_meet(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry2.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_meet(stphoto, mvideo)
    OWNER TO postgres;
    
CREATE OR REPLACE FUNCTION public.m_meet(
	mpoint,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_meet(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_meet(mpoint, mvideo)
    OWNER TO postgres;
    -------------------------------------------


CREATE OR REPLACE FUNCTION public.m_disjoint(
	mpoint,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_disjoint(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_disjoint(mpoint, mpoint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_disjoint(
	mvideo,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_disjoint(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_disjoint(mvideo, mvideo)
    OWNER TO postgres;
    
CREATE OR REPLACE FUNCTION public.m_disjoint(
	stphoto,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mbools := m_disjoint(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry2.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_disjoint(stphoto, mpoint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_disjoint(
	stphoto,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mbools := m_disjoint(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry2.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_disjoint(stphoto, mvideo)
    OWNER TO postgres;
    
CREATE OR REPLACE FUNCTION public.m_disjoint(
	mpoint,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_disjoint(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_disjoint(mpoint, mvideo)
    OWNER TO postgres;
    -----------------------------------------------------


CREATE OR REPLACE FUNCTION public.m_equal(
	mpoint,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_equal(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_equal(mpoint, mpoint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_equal(
	mvideo,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_equal(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_equal(mvideo, mvideo)
    OWNER TO postgres;
    
    
	
CREATE OR REPLACE FUNCTION public.m_equal(
	stphoto,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mbools := m_equal(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry2.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_equal(stphoto, mvideo)
    OWNER TO postgres;
	
	
CREATE OR REPLACE FUNCTION public.m_equal(
	stphoto,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mbools := m_equal(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry2.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_equal(stphoto, mpoint)
    OWNER TO postgres;
    
CREATE OR REPLACE FUNCTION public.m_equal(
	mpoint,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_equal(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_equal(mpoint, mvideo)
    OWNER TO postgres;
    

CREATE OR REPLACE FUNCTION public.m_distance(
	mpoint,
	mpoint)
    RETURNS mdouble
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mdouble			text;
	res					mdouble;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mdouble := m_distance(results, results2);
	IF (mdouble != 'NULL') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(mdoubletime(mdouble),',') ::timestamp without time zone[];	
	res.doubles := regexp_split_to_array(mdoubledouble(mdouble),';') ::double precision[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_distance(mpoint, mpoint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_distance(
	stphoto,
	mpoint)
    RETURNS mdouble
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mdouble			text;
	res					mdouble;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mdouble := m_distance(results, results2);
	IF (mdouble != 'NULL') THEN
	res.moid :=  f_mgeometry2.moid;
	
	res.t := regexp_split_to_array(mdoubletime(mdouble),',') ::timestamp without time zone[];	
	res.doubles := regexp_split_to_array(mdoubledouble(mdouble),';') ::double precision[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_distance(stphoto, mpoint)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_distance(
	stphoto,
	mvideo)
    RETURNS mdouble
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mdouble			text;
	res					mdouble;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mdouble := m_distance(results, results2);
	IF (mdouble != 'NULL') THEN
	res.moid :=  f_mgeometry2.moid;
	
	res.t := regexp_split_to_array(mdoubletime(mdouble),',') ::timestamp without time zone[];	
	res.doubles := regexp_split_to_array(mdoubledouble(mdouble),';') ::double precision[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_distance(stphoto, mvideo)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_direction(
	mpoint)
    RETURNS mdouble
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	results				text;
	results2				text;
	mdouble			text;
	res					mdouble;
BEGIN
	results := m_astext(f_mgeometry1);
	mdouble := m_direction(results);
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mdoubletime(mdouble),',') ::timestamp without time zone[];	
	res.doubles := regexp_split_to_array(mdoubledouble(mdouble),';') ::double precision[];	
	return res;
END
$BODY$;
ALTER FUNCTION public.m_direction(mpoint)
    OWNER TO postgres;
	


CREATE OR REPLACE FUNCTION public.m_velocityattime(
	mpoint,
	bigint)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_instant			alias for $2;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_velocityattime(results, f_instant);
	if (res + 1 = 0.0)then res = null; end if;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_velocityattime(mpoint, bigint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_accelerationattime(
	mpoint,
	bigint)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_instant			alias for $2;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_accelerationattime(results, f_instant);
	if (res + 1 = 0.0)then res = null; end if;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_accelerationattime(mpoint, bigint)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_hausdorff(
	mpoint,
	mpoint)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_hausdorff(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_hausdorff(mpoint, mpoint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_lcss(
	mpoint,
	mpoint,
	double precision,
	double precision)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_theta			alias for $3;
	f_epsilon			alias for $4;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_lcss(results, results2, f_theta, f_epsilon);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_lcss(mpoint, mpoint, double precision, double precision)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_traclus(
	mpoint,
	mpoint)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_traclus(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_traclus(mpoint, mpoint)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.M_Lattice(mpoint, bigint)
RETURNS mpoint AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mpoints				text;
	res					mpoint;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_lattice(results, f_period);
	IF (mpoints	 != 'MPOINT ()') THEN
	res.moid :=  f_mgeometry.moid;
	res.t := regexp_split_to_array(mpointtime(mpoints),',') ::timestamp without time zone[];
	res.geo := regexp_split_to_array(mpointpoint(mpoints),';') ::mcoordinate[];		
	END IF;
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	

CREATE OR REPLACE FUNCTION public.m_mintersects(
	mpoint,
	character varying)
    RETURNS bool
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					bool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := f_mgeometry2;
	res := m_mintersects(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mintersects(mpoint, character varying)
    OWNER TO postgres;	
	


CREATE OR REPLACE FUNCTION public.m_distance(
	mpoint,
	character varying)
    RETURNS mdouble
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mdoubles				text;
	res					mdouble;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := f_mgeometry2;
	mdoubles := m_distance(results, results2);
	IF (mdoubles	 != 'NULL') THEN
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mdoubletime(mdoubles),',') ::timestamp without time zone[];
	res.doubles := regexp_split_to_array(mdoubledouble(mdoubles),';') ::double precision[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_distance(mpoint, character varying)
    OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.M_DWithin(
	mpoint, mpoint, double precision)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry2		alias for $2;
	f_within			alias for $3;
	bools				text;
	bools2				text;
	res				boolean;
BEGIN
	bools := m_astext(f_mgeometry);
	bools2 := m_astext(f_mgeometry2);
	res := m_dwithin(bools, bools2, f_within);
	return res;
END
$BODY$;
ALTER FUNCTION public.M_DWithin(mpoint, mpoint, double precision)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.M_DWithin(
	stphoto, mpoint, double precision)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry2		alias for $2;
	f_within			alias for $3;
	bools				text;
	bools2				text;
	res				boolean;
BEGIN
	bools := M_StToMv(m_astext(f_mgeometry));
	bools2 := m_astext(f_mgeometry2);
	res := m_dwithin(bools, bools2, f_within);
	return res;
END
$BODY$;
ALTER FUNCTION public.M_DWithin(stphoto, mpoint, double precision)
    OWNER TO postgres;
	
CREATE OR REPLACE FUNCTION public.M_DWithin(
	stphoto, mvideo, double precision)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry2		alias for $2;
	f_within			alias for $3;
	bools				text;
	bools2				text;
	res				boolean;
BEGIN
	bools := M_StToMv(m_astext(f_mgeometry));
	bools2 := m_astext(f_mgeometry2);
	res := m_dwithin(bools, bools2, f_within);
	return res;
END
$BODY$;
ALTER FUNCTION public.M_DWithin(stphoto, mvideo, double precision)
    OWNER TO postgres;
	
	
	
-------------------------------------------------------------------------------------------------------	


CREATE OR REPLACE FUNCTION public.m_astext(mvideo)
RETURNS text AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry_segtable_name	char(200);
	sql					text;
	trajid				integer;
	mpid                integer;
	uris				text;
	points				text;
	angles				text;
	directions			text;
	distances			text;
	times				text;
	results				text;
	mvideos				text;
	mgeometry_types		char(50);
	array_fovdis	double precision[];
	array_fovdir	double precision[];
	array_fovang	double precision[];
	i				integer;
	array_size		integer;
BEGIN
	mgeometry_types := 'mvideo';
	if(f_mgeometry.uri IS NULL) then
	 sql := 'select f_segtableoid  from mgeometry_columns where type = ' ||quote_literal(mgeometry_types);
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;
	
	sql := 'select uri from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RAISE DEBUG '%', sql;
    EXECUTE sql INTO uris;
	sql := 'select geo from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RAISE DEBUG '%', sql;
    EXECUTE sql INTO points;
	sql := 'select horizontalAngle from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RAISE DEBUG '%', sql;
    EXECUTE sql INTO angles;
	sql := 'select distance from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RAISE DEBUG '%', sql;
    EXECUTE sql INTO distances;
	sql := 'select direction2d from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RAISE DEBUG '%', sql;
    EXECUTE sql INTO directions;
	sql := 'select datetimes from ' || (f_mgeometry_segtable_name) ||' where mpid = ' ||(mpid);
    RAISE DEBUG '%', sql;
    EXECUTE sql INTO times;
	results := 'mvideo '||uris ||';'|| points||';'||angles||';'||distances||';'||directions||';'||times;
	RAISE INFO '%', sql;
	else 
	execute 'select array_upper( $1, 1 )'
	into array_size using f_mgeometry.frames;
	i := 1;
	WHILE( i <= array_size ) LOOP
		array_fovang[i] := ((f_mgeometry.frames)[i].framefov).horizontalAngle;
		array_fovdir[i] := ((f_mgeometry.frames)[i].framefov).direction2d;
		array_fovdis[i] := ((f_mgeometry.frames)[i].framefov).distance;
		i := i+1;
	END LOOP;
	results := 'mvideo '|| quote_literal(f_mgeometry.uri)||';'||quote_literal((f_mgeometry.mgeo).geo)||';'||quote_literal(array_fovang)||';'||quote_literal(array_fovdis)||';'||quote_literal(array_fovdir )||';'||quote_literal(f_mgeometry.startTime );
	end if;
	mvideos := m_astext(results);
	return mvideos;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;


		
CREATE OR REPLACE FUNCTION public.M_tOverlaps(mvideo, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mvideos				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_toverlaps(results, f_period);
	RAISE INFO '%', mvideos;
	return mvideos;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	




CREATE OR REPLACE FUNCTION public.M_Slice(mvideo, character varying)
RETURNS mvideo AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mvideos				text;
	res					mvideo;
	mgeo				mpoint;
	fov					fov;
	frame				frame[];
	aframe				frame;
	afov				fov;
	array_fovdis	double precision[];
	array_fovdir	double precision[];
	array_fovang	double precision[];
	i				integer;
	array_size		integer;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_slice(results, f_period);
	raise info '%', mvideos;
	IF (mvideos != 'MVIDEO ()') THEN
	res.moid :=  f_mgeometry.moid;
	res.uri := regexp_split_to_array(mvideouri(mvideos),';') ::character varying[];
	res.startTime := regexp_split_to_array(mvideotime(mvideos),',') ::timestamp without time zone[];
	mgeo.geo := regexp_split_to_array(mvideopoint(mvideos),';') ::mcoordinate[];	
	mgeo.t := regexp_split_to_array(mvideotime(mvideos),',') ::timestamp without time zone[];
	
	array_fovang :=regexp_split_to_array(mvideoangle(mvideos),';') ::double precision[];
	array_fovdir := regexp_split_to_array(mvideodirection(mvideos),';') ::double precision[];
	array_fovdis:= regexp_split_to_array(mvideodistance(mvideos),';') ::double precision[];
	
	execute 'select array_upper( $1, 1 )'
	into array_size using array_fovang;
	i := 1;
	WHILE( i <= array_size ) LOOP
		---
		fov.horizontalAngle := array_fovang[i];
		fov.direction2d := array_fovdir[i];
		fov.distance := array_fovdis[i];
		aframe.framefov := fov;
		aframe.fid := i;
		aframe.relativeTime := EXTRACT(EPOCH FROM (res.startTime[i]) ::timestamp without time zone) ;
		aframe.geo := mgeo.geo[i];
		frame[i] := aframe;
		afov.horizontalAngle :=  array_fovang[1];
		afov.direction2d := array_fovdir[1];
		afov.distance := array_fovdis[1];
		i := i+1;
	END LOOP;
	res.mgeo := mgeo;
	res.frames := frame;
	res.afov := afov;
	END IF;
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	





CREATE OR REPLACE FUNCTION public.M_Slice(mvideo, character varying, character varying)
RETURNS mvideo AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	f_polygon			alias for $3;
	results				text;
	mvideos				text;
	res					mvideo;
	mgeo				mpoint;
	fov					fov;
	frame				frame[];
	aframe				frame;
	afov				fov;
	array_fovdis	double precision[];
	array_fovdir	double precision[];
	array_fovang	double precision[];
	i				integer;
	array_size		integer;
BEGIN
	results := m_astext(f_mgeometry);raise info '%', results;
	mvideos := m_slice(results, f_period, f_polygon);
	raise info '%', mvideos;
	IF (mvideos != 'MVIDEO ()') THEN
	res.moid :=  f_mgeometry.moid;
	res.uri := regexp_split_to_array(mvideouri(mvideos),';') ::character varying[];
	res.startTime := regexp_split_to_array(mvideotime(mvideos),',') ::timestamp without time zone[];
	mgeo.geo := regexp_split_to_array(mvideopoint(mvideos),';') ::mcoordinate[];	
	mgeo.t := regexp_split_to_array(mvideotime(mvideos),',') ::timestamp without time zone[];
	
	array_fovang :=regexp_split_to_array(mvideoangle(mvideos),';') ::double precision[];
	array_fovdir := regexp_split_to_array(mvideodirection(mvideos),';') ::double precision[];
	array_fovdis:= regexp_split_to_array(mvideodistance(mvideos),';') ::double precision[];
	
	execute 'select array_upper( $1, 1 )'
	into array_size using array_fovang;
	i := 1;
	WHILE( i <= array_size ) LOOP
		---
		fov.horizontalAngle := array_fovang[i];
		fov.direction2d := array_fovdir[i];
		fov.distance := array_fovdis[i];
		aframe.framefov := fov;
		aframe.fid := i;
		aframe.relativeTime := EXTRACT(EPOCH FROM (res.startTime[i]) ::timestamp without time zone);
		aframe.geo := mgeo.geo[i];
		frame[i] := aframe;
		afov.horizontalAngle :=  array_fovang[1];
		afov.direction2d := array_fovdir[1];
		afov.distance := array_fovdis[1];
		i := i+1;
	END LOOP;
	res.mgeo := mgeo;
	res.frames := frame;
	res.afov := afov;
	END IF;
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;	
	
	
CREATE OR REPLACE FUNCTION public.M_tContains(mvideo, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mvideos				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_tcontains(results, f_period);
	RAISE INFO '%', mvideos;
	return mvideos;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;


CREATE OR REPLACE FUNCTION public.M_tEquals(mvideo, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mvideos				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_tequals(results, f_period);
	RAISE INFO '%', mvideos;
	return mvideos;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_tPrecedes(mvideo, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mvideos				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_tprecedes(results, f_period);
	RAISE INFO '%', mvideos;
	return mvideos;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_tSucceeds(mvideo, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mvideos				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_tsucceeds(results, f_period);
	RAISE INFO '%', mvideos;
	return mvideos;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_tImmPrecedes(mvideo, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mvideos				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_timmprecedes(results, f_period);
	RAISE INFO '%', mvideos;
	return mvideos;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_tImmSucceeds(mvideo, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mvideos				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_timmsucceeds(results, f_period);
	RAISE INFO '%', mvideos;
	return mvideos;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_tImmSucceeds(mvideo, character varying)
RETURNS boolean AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mvideos				boolean;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_timmsucceeds(results, f_period);
	RAISE INFO '%', mvideos;
	return mvideos;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_At(mvideo, integer )
RETURNS mvideo AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_num				alias for $2;
	results				text;
	mvideos				text;
	res					mvideo;
	mgeo				mpoint;
	fov					fov;
	frame				frame[];
	aframe				frame;
	afov				fov;
	array_fovdis	double precision[];
	array_fovdir	double precision[];
	array_fovang	double precision[];
	i				integer;
	array_size		integer;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_at(results, f_num);
	RAISE INFO '%', mvideos;
	IF (mvideos	 != 'MVIDEO ()') THEN
	res.moid :=  f_mgeometry.moid;
	res.uri := regexp_split_to_array(mvideouri(mvideos),';') ::character varying[];
	res.startTime := regexp_split_to_array(mvideotime(mvideos),',') ::timestamp without time zone[];
	mgeo.geo := regexp_split_to_array(mvideopoint(mvideos),';') ::mcoordinate[];	
	mgeo.t := regexp_split_to_array(mvideotime(mvideos),',') ::timestamp without time zone[];
	
	array_fovang :=regexp_split_to_array(mvideoangle(mvideos),';') ::double precision[];
	array_fovdir := regexp_split_to_array(mvideodirection(mvideos),';') ::double precision[];
	array_fovdis:= regexp_split_to_array(mvideodistance(mvideos),';') ::double precision[];
	
	execute 'select array_upper( $1, 1 )'
	into array_size using array_fovang;
	i := 1;
	WHILE( i <= array_size ) LOOP
		---
		fov.horizontalAngle := array_fovang[i];
		fov.direction2d := array_fovdir[i];
		fov.distance := array_fovdis[i];
		aframe.framefov := fov;
		aframe.fid := i;
		raise info '%', mvideotime(mvideos);
		aframe.relativeTime := EXTRACT(EPOCH FROM ((mvideotime(mvideos)) ::timestamp without time zone));
		aframe.geo := mgeo.geo[i];
		frame[i] := aframe;
		afov.horizontalAngle :=  array_fovang[1];
		afov.direction2d := array_fovdir[1];
		afov.distance := array_fovdis[1];
		i := i+1;
	END LOOP;
	res.mgeo := mgeo;
	res.frames := frame;
	res.afov := afov;
	END IF;
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
CREATE OR REPLACE FUNCTION public.M_NumOf(mvideo)
RETURNS integer AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
	res					integer;
BEGIN
	results := m_astext(f_mgeometry);
	res := m_numof(results);
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
CREATE OR REPLACE FUNCTION public.M_Time(mvideo)
RETURNS period AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
	res					text;
	per					period;
	Longs				bigint[];
BEGIN
	results := m_astext(f_mgeometry);
	res := m_time(results);
	RAISE INFO '%', res;
	res := regexp_replace(res, '\)','');
	res :=regexp_replace(res, '\(','');
	Longs := regexp_split_to_array(res,' ') ::bigint[];	
	per.fromtime :=  Longs[1];
	per.totime :=  Longs[2];
	return per;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_StartTime(mvideo)
RETURNS bigint AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
	res					bigint;
BEGIN
	results := m_astext(f_mgeometry);
	res := m_starttime(results);
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_EndTime(mvideo)
RETURNS bigint AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
	res					bigint;
BEGIN
	results := m_astext(f_mgeometry);
	res := m_endtime(results);
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_Spatial(mvideo)
RETURNS geometry AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
	res					geometry;
BEGIN
	results := m_astext(f_mgeometry);
	res := ST_GeomFromText(m_spatial(results));
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	
	
CREATE OR REPLACE FUNCTION public.M_Snapshot(mvideo, bigint)
RETURNS geometry AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_instant			alias for $2;
	results				text;
	mvideos				text;
	res					geometry;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_snapshot(results, f_instant);
	IF (mvideos	 != 'MVIDEO ()') THEN
	res := ST_GeomFromText(mvideos);	
	END IF;
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
	
	

CREATE OR REPLACE FUNCTION public.m_timeatcummulative(
	mvideo,
	double precision)
    RETURNS bigint
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mvideos				bigint;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_timeatcummulative(results, f_period);
	RAISE INFO '%', mvideos;
	return mvideos;
END
$BODY$;
ALTER FUNCTION public.m_timeatcummulative(mvideo, double precision)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_snaptogrid(
	mvideo,
	integer)
    RETURNS mvideo
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mvideos				text;
	res					mvideo;
	mgeo				mpoint;
	fov					fov;
	frame				frame[];
	aframe				frame;
	afov				fov;
	array_fovdis	double precision[];
	array_fovdir	double precision[];
	array_fovang	double precision[];
	i				integer;
	array_size		integer;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_snaptogrid(results, f_period);
	res.moid :=  f_mgeometry.moid;
	res.uri := regexp_split_to_array(mvideouri(mvideos),';') ::character varying[];
	res.startTime := regexp_split_to_array(mvideotime(mvideos),',') ::timestamp without time zone[];
	mgeo.geo := regexp_split_to_array(mvideopoint(mvideos),';') ::mcoordinate[];	
	mgeo.t := regexp_split_to_array(mvideotime(mvideos),',') ::timestamp without time zone[];
	
	array_fovang :=regexp_split_to_array(mvideoangle(mvideos),';') ::double precision[];
	array_fovdir := regexp_split_to_array(mvideodirection(mvideos),';') ::double precision[];
	array_fovdis:= regexp_split_to_array(mvideodistance(mvideos),';') ::double precision[];
	
	execute 'select array_upper( $1, 1 )'
	into array_size using array_fovang;
	i := 1;
	WHILE( i <= array_size ) LOOP
		---
		fov.horizontalAngle := array_fovang[i];
		fov.direction2d := array_fovdir[i];
		fov.distance := array_fovdis[i];
		aframe.framefov := fov;
		aframe.fid := i;
		raise info '%', mvideotime(mvideos);
		aframe.relativeTime := EXTRACT(EPOCH FROM ((res.startTime[i]) ::timestamp without time zone));
		aframe.geo := mgeo.geo[i];
		frame[i] := aframe;
		afov.horizontalAngle :=  array_fovang[1];
		afov.direction2d := array_fovdir[1];
		afov.distance := array_fovdis[1];
		i := i+1;
	END LOOP;
	res.mgeo := mgeo;
	res.frames := frame;
	res.afov := afov;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_snaptogrid(mvideo, integer)
    OWNER TO postgres;
	

CREATE OR REPLACE FUNCTION public.m_intersects(
	mvideo,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_intersects(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_intersects(mvideo, mvideo)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_menters(
	mvideo,
	character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_menters(results, f_mgeometry2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_menters(mvideo, character varying)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_menters(
	mvideo,
	geometry)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := ST_AsText(f_mgeometry2);
	res := m_menters(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_menters(mvideo, geometry)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_mbypasses(
	mvideo,
	character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_mbypasses(results, f_mgeometry2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mbypasses(mvideo, character varying)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_mbypasses(
	mvideo,
	geometry)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := ST_AsText(f_mgeometry2);
	res := m_mbypasses(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mbypasses(mvideo, geometry)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_mleaves(
	mvideo,
	character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_mleaves(results, f_mgeometry2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mleaves(mvideo, character varying)
    OWNER TO postgres;




CREATE OR REPLACE FUNCTION public.m_mleaves(
	mvideo,
	geometry)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := ST_AsText(f_mgeometry2);
	res := m_mleaves(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mleaves(mvideo, geometry)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_mcrosses(
	mvideo,
	character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_mcrosses(results, f_mgeometry2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mcrosses(mvideo, character varying)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_mcrosses(
	mvideo,
	geometry)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					boolean;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := ST_AsText(f_mgeometry2);
	res := m_mcrosses(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mcrosses(mvideo, geometry)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_eventtime(
	mvideo,
	mvideo)
    RETURNS minstant
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	minstant			text;
	res					minstant;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	minstant := m_eventtime(results, results2);
	IF (minstant != 'NULL') THEN
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(minstanttime(minstant),',') ::timestamp without time zone[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_eventtime(mvideo, mvideo)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_relationship(
	mvideo,
	mvideo)
    RETURNS mstring
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mstring			text;
	res					mstring;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mstring := m_relationship(results, results2);
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mstringtime(mstring),',') ::timestamp without time zone[];	
	res.mstrings := regexp_split_to_array(mstringstring(mstring),';') ::character varying[];	
	return res;
END
$BODY$;
ALTER FUNCTION public.m_relationship(mvideo, mvideo)
    OWNER TO postgres;


	
CREATE OR REPLACE FUNCTION public.m_relationship(
	mvideo,
	stphoto)
    RETURNS mstring
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mstring			text;
	res					mstring;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := M_StToMv(m_astext(f_mgeometry2));
	mstring := m_relationship(results, results2);
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mstringtime(mstring),',') ::timestamp without time zone[];	
	res.mstrings := regexp_split_to_array(mstringstring(mstring),';') ::character varying[];	
	return res;
END
$BODY$;
ALTER FUNCTION public.m_relationship(mvideo, stphoto)
    OWNER TO postgres;
	
	
	
	
CREATE OR REPLACE FUNCTION public.m_relationship(
	mpoint,
	stphoto)
    RETURNS mstring
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mstring			text;
	res					mstring;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := M_StToMv(m_astext(f_mgeometry2));
	mstring := m_relationship(results, results2);
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mstringtime(mstring),',') ::timestamp without time zone[];	
	res.mstrings := regexp_split_to_array(mstringstring(mstring),';') ::character varying[];	
	return res;
END
$BODY$;
ALTER FUNCTION public.m_relationship(mpoint, stphoto)
    OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.m_distance(
	mvideo,
	mvideo)
    RETURNS mdouble
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mdouble			text;
	res					mdouble;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mdouble := m_distance(results, results2);
	IF (mdouble != 'NULL') THEN
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mdoubletime(mdouble),',') ::timestamp without time zone[];	
	res.doubles := regexp_split_to_array(mdoubledouble(mdouble),';') ::double precision[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_distance(mvideo, mvideo)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_area(
	mvideo)
    RETURNS mdouble
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	results				text;
	results2				text;
	mdouble			text;
	res					mdouble;
BEGIN
	results := m_astext(f_mgeometry1);
	mdouble := m_area(results);
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mdoubletime(mdouble),',') ::timestamp without time zone[];	
	res.doubles := regexp_split_to_array(mdoubledouble(mdouble),';') ::double precision[];	
	return res;
END
$BODY$;
ALTER FUNCTION public.m_area(mvideo)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_direction(
	mvideo)
    RETURNS mdouble
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	results				text;
	results2				text;
	mdouble			text;
	res					mdouble;
BEGIN
	results := m_astext(f_mgeometry1);
	mdouble := m_direction(results);
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mdoubletime(mdouble),',') ::timestamp without time zone[];	
	res.doubles := regexp_split_to_array(mdoubledouble(mdouble),';') ::double precision[];	
	return res;
END
$BODY$;
ALTER FUNCTION public.m_direction(mvideo)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_velocityattime(
	mvideo,
	bigint)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_instant			alias for $2;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_velocityattime(results, f_instant);
	if (res + 1 = 0.0)then res = null; end if;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_velocityattime(mvideo, bigint)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_accelerationattime(
	mvideo,
	bigint)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_instant			alias for $2;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	res := m_accelerationattime(results, f_instant);
	if (res + 1 = 0.0)then res = null; end if;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_accelerationattime(mvideo, bigint)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_hausdorff(
	mvideo,
	mvideo)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_hausdorff(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_hausdorff(mvideo, mvideo)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_lcss(
	mvideo,
	mvideo,
	double precision,
	double precision)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_theta			alias for $3;
	f_epsilon			alias for $4;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_lcss(results, results2, f_theta, f_epsilon);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_lcss(mvideo, mvideo, double precision, double precision)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_lcvs(
	mvideo,
	mvideo,
	double precision)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_theta			alias for $3;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_lcvs(results, results2, f_theta);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_lcvs(mvideo, mvideo, double precision)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_traclus(
	mvideo,
	mvideo)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_traclus(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_traclus(mvideo, mvideo)
    OWNER TO postgres;

	
	


CREATE OR REPLACE FUNCTION public.M_ANY(
	mbool)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	mbools				text;
	results				text;
	bools				boolean;
BEGIN
	mbools := 'mbool '|| quote_literal(f_mgeometry.bools)||';'||quote_literal(f_mgeometry.t);
	results := m_astext(mbools);
	bools := m_any(results);
	RAISE INFO '%', bools;
	return bools;
END
$BODY$;
ALTER FUNCTION public.M_ANY(mbool)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.M_Max(
	mdouble)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	mdouble				text;
	res				double precision;
BEGIN
	mdouble := f_mgeometry.doubles;
	res := m_max(mdouble);
	return res;
END
$BODY$;
ALTER FUNCTION public.M_Max(mdouble)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.M_Max(
	mint)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	mint				text;
	res				integer;
BEGIN
	mint := f_mgeometry.ints ;
	res := m_max(mint);
	return res;
END
$BODY$;
ALTER FUNCTION public.M_Max(mint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.M_Min(
	mdouble)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	mdouble				text;
	res				double precision;
BEGIN
	mdouble := f_mgeometry.doubles;
	res := m_min(mdouble);
	return res;
END
$BODY$;
ALTER FUNCTION public.M_Min(mdouble)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.M_Min(
	mint)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	mint				text;
	res				integer;
BEGIN
	mint := f_mgeometry.ints;
	res := m_min(mint);
	return res;
END
$BODY$;
ALTER FUNCTION public.M_Min(mint)
    OWNER TO postgres;
	
	

CREATE OR REPLACE FUNCTION public.M_Avg(
	mdouble)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	mdouble				text;
	res				double precision;
BEGIN
	mdouble := f_mgeometry.doubles;
	res := m_avg(mdouble);
	return res;
END
$BODY$;
ALTER FUNCTION public.M_Avg(mdouble)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.M_Avg(
	mint)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	mint				text;
	res				integer;
BEGIN
	mint := f_mgeometry.ints;
	res := m_avg(mint);
	return res;
END
$BODY$;
ALTER FUNCTION public.M_Avg(mint)
    OWNER TO postgres;
	
	
	
CREATE OR REPLACE FUNCTION public.M_Avg(
	mdouble, character varying)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_duration		alias for $2;
	mdouble				text;
	f_slice			mdouble;
	res				double precision;
BEGIN
	f_slice := m_slice(f_mgeometry, f_duration);
	mdouble := f_slice.doubles;
	res := m_avg(mdouble);
	return res;
END
$BODY$;
ALTER FUNCTION public.M_Avg(mdouble, character varying)
    OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.M_Avg(
	mint, character varying)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	mint				text;
	f_duration			alias for $2;
	mdouble				text;
	f_slice				mdouble;
	res					double precision;
BEGIN
	f_slice := m_slice(f_mgeometry, f_duration);
	mint := f_slice.ints;
	res := m_avg(mint);
	return res;
END
$BODY$;
ALTER FUNCTION public.M_Avg(mint, character varying)
    OWNER TO postgres;
	


CREATE OR REPLACE FUNCTION public.m_dwithin(
	mvideo,
	mvideo,
	double precision)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry2		alias for $2;
	f_within			alias for $3;
	bools				text;
	bools2				text;
	res				boolean;
BEGIN
	bools := m_astext(f_mgeometry);
	bools2 := m_astext(f_mgeometry2);
	res := m_dwithin(bools, bools2, f_within);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_dwithin(mvideo, mvideo, double precision)
    OWNER TO postgres;




CREATE OR REPLACE FUNCTION public.M_Lattice(mvideo, bigint)
RETURNS mvideo AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	results				text;
	mvideos				text;
	res					mvideo;
	mgeo				mpoint;
	fov					fov;
	frame				frame[];
	aframe				frame;
	afov				fov;
	array_fovdis	double precision[];
	array_fovdir	double precision[];
	array_fovang	double precision[];
	i				integer;
	array_size		integer;
BEGIN
	results := m_astext(f_mgeometry);
	mvideos := m_lattice(results, f_period);
	raise info '%', mvideos;
	IF (mvideos != 'MVIDEO ()') THEN
	res.moid :=  f_mgeometry.moid;
	res.uri := regexp_split_to_array(mvideouri(mvideos),';') ::character varying[];
	res.startTime := regexp_split_to_array(mvideotime(mvideos),',') ::timestamp without time zone[];
	mgeo.geo := regexp_split_to_array(mvideopoint(mvideos),';') ::mcoordinate[];	
	mgeo.t := regexp_split_to_array(mvideotime(mvideos),',') ::timestamp without time zone[];
	
	array_fovang :=regexp_split_to_array(mvideoangle(mvideos),';') ::double precision[];
	array_fovdir := regexp_split_to_array(mvideodirection(mvideos),';') ::double precision[];
	array_fovdis:= regexp_split_to_array(mvideodistance(mvideos),';') ::double precision[];
	
	execute 'select array_upper( $1, 1 )'
	into array_size using array_fovang;
	i := 1;
	WHILE( i <= array_size ) LOOP
		---
		fov.horizontalAngle := array_fovang[i];
		fov.direction2d := array_fovdir[i];
		fov.distance := array_fovdis[i];
		aframe.framefov := fov;
		aframe.fid := i;
		raise info '%', mvideotime(mvideos);
		aframe.relativeTime := EXTRACT(EPOCH FROM ((res.startTime[i]) ::timestamp without time zone));
		aframe.geo := mgeo.geo[i];
		frame[i] := aframe;
		afov.horizontalAngle :=  array_fovang[1];
		afov.direction2d := array_fovdir[1];
		afov.distance := array_fovdis[1];
		i := i+1;
	END LOOP;
	res.mgeo := mgeo;
	res.frames := frame;
	res.afov := afov;
	END IF;
	return res;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;



CREATE OR REPLACE FUNCTION public.m_mintersects(
	mvideo,
	character varying)
    RETURNS bool
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					bool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := f_mgeometry2;
	res := m_mintersects(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_mintersects(mvideo, character varying)
    OWNER TO postgres;
	
	
	

CREATE OR REPLACE FUNCTION public.m_distance(
	mvideo,
	character varying)
    RETURNS mdouble
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mdoubles				text;
	res					mdouble;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := f_mgeometry2;
	mdoubles := m_distance(results, results2);
	IF (mdoubles	 != 'NULL') THEN
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mdoubletime(mdoubles),',') ::timestamp without time zone[];
	res.doubles := regexp_split_to_array(mdoubledouble(mdoubles),';') ::double precision[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_distance(mvideo, character varying)
    OWNER TO postgres;
	



CREATE OR REPLACE FUNCTION public.m_intersects(
	mpoint,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_intersects( results2, results);
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	return res;
END
$BODY$;
ALTER FUNCTION public.m_intersects(mpoint, mvideo)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_intersects(
	mvideo,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mbools := m_intersects(results, results2);	
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	return res;
END
$BODY$;
ALTER FUNCTION public.m_intersects(mvideo, mpoint)
    OWNER TO postgres;
	
		
	
CREATE OR REPLACE FUNCTION public.m_eventtime(
	mpoint,
	mvideo)
    RETURNS minstant
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	minstant			text;
	res					minstant;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	minstant := m_eventtime(results, results2);
	IF (minstant != 'NULL') THEN
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(minstanttime(minstant),',') ::timestamp without time zone[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_eventtime(mpoint, mvideo)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_eventtime(
	mvideo,
	mpoint)
    RETURNS minstant
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	minstant			text;
	res					minstant;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	minstant := m_eventtime(results, results2);
	IF (minstant != 'NULL') THEN
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(minstanttime(minstant),',') ::timestamp without time zone[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_eventtime(mvideo, mpoint)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_relationship(
	mvideo,
	mpoint)
    RETURNS mstring
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mstring			text;
	res					mstring;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mstring := m_relationship(results, results2);
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mstringtime(mstring),',') ::timestamp without time zone[];	
	res.mstrings := regexp_split_to_array(mstringstring(mstring),';') ::character varying[];	
	return res;
END
$BODY$;
ALTER FUNCTION public.m_relationship(mvideo, mpoint)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_relationship(
	mpoint,
	mvideo)
    RETURNS mstring
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mstring			text;
	res					mstring;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mstring := m_relationship(results2, results);
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mstringtime(mstring),',') ::timestamp without time zone[];	
	res.mstrings := regexp_split_to_array(mstringstring(mstring),';') ::character varying[];	
	return res;
END
$BODY$;
ALTER FUNCTION public.m_relationship(mpoint, mvideo)
    OWNER TO postgres;
	
	
	
CREATE OR REPLACE FUNCTION public.m_distance(
	mvideo,
	mpoint)
    RETURNS mdouble
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mdouble			text;
	res					mdouble;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mdouble := m_distance(results, results2);
	IF (mdouble != 'NULL') THEN
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mdoubletime(mdouble),',') ::timestamp without time zone[];	
	res.doubles := regexp_split_to_array(mdoubledouble(mdouble),';') ::double precision[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_distance(mvideo, mpoint)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_distance(
	mpoint,
	mvideo)
    RETURNS mdouble
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mdouble			text;
	res					mdouble;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mdouble := m_distance(results, results2);
	IF (mdouble != 'NULL') THEN
	res.moid :=  f_mgeometry1.moid;
	
	res.t := regexp_split_to_array(mdoubletime(mdouble),',') ::timestamp without time zone[];	
	res.doubles := regexp_split_to_array(mdoubledouble(mdouble),';') ::double precision[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_distance(mpoint, mvideo)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_dwithin(
	mpoint,
	mvideo,
	double precision)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry2		alias for $2;
	f_within			alias for $3;
	bools				text;
	bools2				text;
	res				boolean;
BEGIN
	bools := m_astext(f_mgeometry);
	bools2 := m_astext(f_mgeometry2);
	raise info '%', bools;
	res := m_dwithin(bools, bools2, f_within);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_dwithin(mpoint, mvideo, double precision)
    OWNER TO postgres;
	
	
CREATE OR REPLACE FUNCTION public.m_dwithin(
	mvideo,
	mpoint,
	double precision)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_mgeometry2		alias for $2;
	f_within			alias for $3;
	bools				text;
	bools2				text;
	res				boolean;
BEGIN
	bools := m_astext(f_mgeometry);
	bools2 := m_astext(f_mgeometry2);
	res := m_dwithin(bools, bools2, f_within);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_dwithin(mvideo, mpoint, double precision)
    OWNER TO postgres;

	
	

CREATE OR REPLACE FUNCTION public.m_hausdorff(
	mpoint,
	mvideo)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_hausdorff(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_hausdorff(mpoint, mvideo)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_hausdorff(
	mvideo,
	mpoint)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_hausdorff(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_hausdorff(mvideo, mpoint)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_lcss(
	mvideo,
	mpoint,
	double precision,
	double precision)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_theta			alias for $3;
	f_epsilon			alias for $4;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_lcss(results, results2, f_theta, f_epsilon);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_lcss(mvideo, mpoint, double precision, double precision)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_lcss(
	mpoint,
	mvideo,
	double precision,
	double precision)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_theta			alias for $3;
	f_epsilon			alias for $4;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_lcss(results, results2, f_theta, f_epsilon);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_lcss(mpoint, mvideo, double precision, double precision)
    OWNER TO postgres;




CREATE OR REPLACE FUNCTION public.m_traclus(
	mpoint,
	mvideo)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_traclus(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_traclus(mpoint, mvideo)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_traclus(
	mvideo,
	mpoint)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					double precision;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	res := m_traclus(results, results2);
	return res;
END
$BODY$;
ALTER FUNCTION public.m_traclus(mvideo, mpoint)
    OWNER TO postgres;
	


CREATE OR REPLACE FUNCTION public.m_intersects(
	stphoto,
	mpoint)
    RETURNS mbool
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mbools := m_intersects(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry2.moid;
	
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_intersects(stphoto, mpoint)
    OWNER TO postgres;
	
	
	
CREATE OR REPLACE FUNCTION public.m_intersects(
	stphoto,
	mvideo)
    RETURNS mbool
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	mbools				text;
	res					mbool;
BEGIN
	results := M_StToMv(m_astext(f_mgeometry1));
	results2 := m_astext(f_mgeometry2);
	mbools := m_intersects(results, results2);
	IF (mbools	 != 'MBOOL ()') THEN
	res.moid :=  f_mgeometry2.moid;
	
	res.t := regexp_split_to_array(mbooltime(mbools),',') ::timestamp without time zone[];
	res.bools := regexp_split_to_array(mboolbool(mbools),';') ::boolean[];	
	END IF;
	return res;
END
$BODY$;
ALTER FUNCTION public.m_intersects(stphoto, mvideo)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.M_StToMv(character varying)
RETURNS text AS 
$BODY$
DECLARE
	f_mgeometry			alias for $1;
	uris			text;
	t				timestamp without time zone;
	geo				mcoordinate;
	fov				fov;
	results				text;
BEGIN
	uris = split_part(split_part(split_part(f_mgeometry,'(',2), ')',1),' ',1);
	raise info '%', uris;
	fov.horizontalAngle = split_part(split_part(split_part(f_mgeometry,'(',4), ')',1),',', 1);
	raise info '%', fov.horizontalAngle;
	fov.direction2d = split_part(split_part(split_part(f_mgeometry,'(',4), ')',1),',', 3);
	raise info '%', fov.direction2d;
	fov.distance = split_part(split_part(split_part(f_mgeometry,'(',4), ')',1),',', 5);
	raise info '%', fov.distance;
	geo.pointx = split_part(split_part(split_part(f_mgeometry,'(',5), ')',1),' ',1);
	geo.pointy = split_part(split_part(split_part(f_mgeometry,'(',5), ')',1),' ',2);
	raise info '%', geo.pointx;
	t =  LongtoString(split_part(split_part(split_part(f_mgeometry,'(',5), ')',2),' ',2)::bigint);---TIMESTAMP without time zone 'epoch' + (split_part(split_part(split_part(f_mgeometry,'(',2), ')',1),' ',11)::bigint)* INTERVAL '1 second';
	results := 'mvideo '|| (uris)||'};{'||(geo)||'};{'||(fov.horizontalAngle )
	||'};{'||(fov.distance  )||'};{'||(fov.direction2d )||'};{'||(t);
	raise info '%', results;
	results := m_astext(results);
	return results;
END
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;	
	

	

CREATE OR REPLACE FUNCTION public.m_min(
	bigint)
    RETURNS double precision
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	mdouble				text;
	res				double precision;
BEGIN
	mdouble := f_mgeometry/1000;
	res := m_min(mdouble);
	return res;
END
$BODY$;

ALTER FUNCTION public.m_min(bigint)
    OWNER TO postgres;




CREATE OR REPLACE FUNCTION public.m_snapshot(
	mpoint,
	timestamp)
    RETURNS geometry
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_instant			alias for $2;
	times				bigint;
	results				text;
	mpoints				text;
	res					geometry;
BEGIN
	results := m_astext(f_mgeometry);
	times := extract(epoch from f_instant)::bigint*1000;
	mpoints := m_snapshot(results, times);
	IF (mpoints	 != 'MPOINT ()') THEN
	res := ST_GeomFromText(mpoints);	
	END IF;
	return res;
END
$BODY$;

ALTER FUNCTION public.m_snapshot(mpoint, timestamp)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_mintersects(
	mpoint,
	geometry)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				text;
	results2				text;
	res					bool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := ST_AsText(f_mgeometry2);
	res := m_mintersects(results, results2);
	return res;
END
$BODY$;

ALTER FUNCTION public.m_mintersects(mpoint, geometry)
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.m_mindistance(
	mpoint,
	mpoint)
    RETURNS double precision
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results				geometry;
	results2				geometry;
	mdouble				double precision;
BEGIN
	results := m_spatial(f_mgeometry1);
	results2 := m_spatial(f_mgeometry2);
	mdouble := st_distance(results, results2);
	
	return mdouble;
END
$BODY$;

ALTER FUNCTION public.m_mindistance(mpoint, mpoint)
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_min(
	double precision[])
    RETURNS double precision
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	mdouble				text;
	res				double precision;
BEGIN
	mdouble := f_mgeometry;
	
	res := m_min(mdouble);
	return res;
END
$BODY$;

ALTER FUNCTION public.m_min(double precision[])
    OWNER TO postgres;



CREATE OR REPLACE FUNCTION public.m_slice(
	mpoint,
	period)
    RETURNS mpoint
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_period			alias for $2;
	periods				text;
	results				text;
	mpoints				text;
	res					mpoint;
BEGIN
	results := m_astext(f_mgeometry);
	periods := 'Period ('||f_period.fromtime||', '||f_period.totime||')';
	mpoints := m_slice(results, periods);
	IF (mpoints	 != 'MPOINT ()') THEN
	res.moid :=  f_mgeometry.moid;
	res.t := regexp_split_to_array(mpointtime(mpoints),',') ::timestamp without time zone[];
	res.geo := regexp_split_to_array(mpointpoint(mpoints),';') ::mcoordinate[];		
	END IF;
	return res;
END
$BODY$;

ALTER FUNCTION public.m_slice(mpoint, Period)
    OWNER TO postgres;


	

CREATE OR REPLACE FUNCTION public.m_timeatcummulative(
	mpoint)
    RETURNS double precision
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	results				text;
	mpoints				bigint;
BEGIN
	results := m_astext(f_mgeometry);
	mpoints := m_timeatcummulative(results);
	RAISE INFO '%', mpoints;
	return mpoints;
END
$BODY$;

ALTER FUNCTION public.m_timeatcummulative(mpoint)
    OWNER TO postgres;



	
CREATE OR REPLACE FUNCTION public.m_eventtime(
	mpoint,
	mpoint,
	double precision)
    RETURNS minstant
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_mgeometry3			alias for $3;
	results				text;
	results2				text;
	minstant			text;
	res					minstant;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	minstant := m_eventtime(results, results2,f_mgeometry3);
	IF (minstant != 'NULL') THEN
	res.moid :=  f_mgeometry1.moid;
	res.t := regexp_split_to_array(minstanttime(minstant),',') ::timestamp without time zone[];	
	END IF;
	return res;
END
$BODY$;

ALTER FUNCTION public.m_eventtime(mpoint, mpoint, double precision)
    OWNER TO postgres;






CREATE OR REPLACE FUNCTION public.m_eventposition(
	mpoint,
	mpoint,
	double precision)
    RETURNS minstant
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	f_mgeometry3			alias for $3;
	results				text;
	results2				text;
	mpoint			text;
	mp			mpoint;
	res					minstant;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := m_astext(f_mgeometry2);
	mpoint := m_eventposition(results, results2,f_mgeometry3);
	IF (mpoint != 'NULL') THEN
	mp:= append_mpoint(mpoint);
	res := regexp_split_to_array(mp.geo) ::point[];	
	END IF;
	return res;
END
$BODY$;

ALTER FUNCTION public.m_eventposition(mpoint, mpoint, double precision)
    OWNER TO postgres;
	
	
	CREATE OR REPLACE FUNCTION public.append_mpoint(
	character varying)
    RETURNS mpoint
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	array_mpoint	alias for $1;
	array_time	timestamp without time zone[];
	array_point	mcoordinate[];
	res				mpoint;
BEGIN
	array_time = regexp_split_to_array(mpointtime(array_mpoint),',') ::timestamp without time zone[];
	array_point = regexp_split_to_array(mpointpoint(array_mpoint),';') ::mcoordinate[];	
	res :=(null,null,array_point,array_time );
	RETURN res;
END
$BODY$;

ALTER FUNCTION public.append_mpoint(character varying)
    OWNER TO postgres;
	
	
	
	

CREATE OR REPLACE FUNCTION public.m_tintersects(
	mpoint,
	period)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry1			alias for $1;
	f_mgeometry2			alias for $2;
	results					text;
	results2				text;
	res						bool;
BEGIN
	results := m_astext(f_mgeometry1);
	results2 := 'Period ('||f_mgeometry2.fromtime||', '||f_mgeometry2.totime||')';
	res := m_tintersects(results, results2);
	return res;
END
$BODY$;

ALTER FUNCTION public.m_tintersects(mpoint, period)
    OWNER TO postgres;
    
    
    
    
    
CREATE OR REPLACE FUNCTION public.m_slice(
	mpoint,
	bigint, bigint)
    RETURNS mpoint
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_start			alias for $2;
	f_end			alias for $3;
	periods				text;
	results				text;
	mpoints				text;
	res					mpoint;
BEGIN
	results := m_astext(f_mgeometry);
	periods := 'Period ('||f_start||', '||f_end||')';
	mpoints := m_slice(results, periods);
	IF (mpoints	 != 'MPOINT ()') THEN
	res.moid :=  f_mgeometry.moid;
	res.t := regexp_split_to_array(mpointtime(mpoints),',') ::timestamp without time zone[];
	res.geo := regexp_split_to_array(mpointpoint(mpoints),';') ::mcoordinate[];		
	END IF;
	return res;
END
$BODY$;

ALTER FUNCTION public.m_slice(mpoint, bigint, bigint)
    OWNER TO postgres;

    
	

CREATE OR REPLACE FUNCTION public.m_snapshot(
	mpoint,
	timestamp with time zone)
    RETURNS geometry
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
	f_mgeometry			alias for $1;
	f_instant			alias for $2;
	times				bigint;
	results				text;
	mpoints				text;
	res					geometry;
BEGIN
	results := m_astext(f_mgeometry);
	times := extract(epoch from f_instant)::bigint*1000;
	mpoints := m_snapshot(results, times);
	IF (mpoints	 != 'MPOINT ()') THEN
	res := ST_GeomFromText(mpoints);	
	END IF;
	return res;
END
$BODY$;

ALTER FUNCTION public.m_snapshot(mpoint, timestamp with time zone)
    OWNER TO postgres;




CREATE OR REPLACE FUNCTION public.deletemgeometrycolumn(
	character varying,
	character varying,
	character varying,
	character varying)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
DECLARE
    f_schema_name     alias for $1;
    f_table_name     alias for $2;
    f_column_name     alias for $3;
    new_type     alias for $4;
    real_schema name;
    sql text;
    table_oid text;
    temp_segtable_name text;
    f_mgeometry_segtable_name text;
    f_sequence_name    text;
BEGIN
    --verify SRID
    IF ( f_schema_name IS NOT NULL AND f_schema_name != '' ) THEN
        sql := 'SELECT nspname FROM pg_namespace ' ||
            'WHERE text(nspname) = ' || quote_literal(f_schema_name) ||
            'LIMIT 1';
        RAISE DEBUG '%', sql;
        EXECUTE sql INTO real_schema;

        IF ( real_schema IS NULL ) THEN
            RAISE EXCEPTION 'Schema % is not a valid schemaname', quote_literal(f_schema_name);
            RETURN 'fail';
        END IF;
    END IF;

    IF ( real_schema IS NULL ) THEN
        RAISE DEBUG 'Detecting schema';
        sql := 'SELECT n.nspname AS schemaname ' ||
            'FROM pg_catalog.pg_class c ' ||
              'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' ||
            'WHERE c.relkind = ' || quote_literal('r') ||
            ' AND n.nspname NOT IN (' || quote_literal('pg_catalog') || ', ' || quote_literal('pg_toast') || ')' ||
            ' AND pg_catalog.pg_table_is_visible(c.oid)' ||
            ' AND c.relname = ' || quote_literal(f_table_name);
        RAISE DEBUG '%', sql;
        EXECUTE sql INTO real_schema;

        IF ( real_schema IS NULL ) THEN
            RAISE EXCEPTION 'Table % does not occur in the search_path', quote_literal(f_table_name);
            RETURN 'fail';
        END IF;
    END IF;

    
-------------------------------------------mpoint	
 	IF (new_type = 'mpoint')
    THEN 
		-- Delete sequence
    	f_sequence_name = quote_ident(f_table_name) || '_' || quote_ident(f_column_name) || '_mpointid_seq';

    	sql := 'select f_sequence_name from mgeometry_columns where f_table_name = ' || quote_literal(f_table_name);
   	 	RAISE DEBUG '%', sql;
   	 	EXECUTE sql INTO f_sequence_name;

    	sql := 'DROP SEQUENCE IF EXISTS ' || quote_ident(f_sequence_name);
   		RAISE DEBUG '%', sql;
    	RAISE INFO '%', sql;
   		EXECUTE sql;    

    	-- Delete table columns
   		sql := 'ALTER TABLE ' || quote_ident(f_table_name) || ' DROP COLUMN '|| quote_ident(f_column_name);
    	RAISE DEBUG '%', sql;
    	EXECUTE sql;

		-- Delete seg_table
		
		sql := 'select f_mgeometry_segtable_name from mgeometry_columns where f_table_name = ' || quote_literal(f_table_name);
   	 	RAISE DEBUG '%', sql;
   	 	EXECUTE sql INTO temp_segtable_name;
		
		sql := 'DROP TABLE ' || quote_ident(temp_segtable_name);
   	 	RAISE DEBUG '%', sql;
   	 	EXECUTE sql;

    	sql := 'DELETE FROM mgeometry_columns WHERE
       	 f_table_catalog = ' || quote_literal('') ||
       	 ' AND f_table_schema = ' ||quote_literal(real_schema) ||
       	 ' AND f_table_name = ' || quote_literal(f_table_name) ||
       	 ' AND f_mgeometry_column = ' || quote_literal(f_column_name);
   		RAISE DEBUG '%', sql;
   		EXECUTE sql;
   	 	
    END IF;	
	-------------------------------------------mdouble		
    RETURN
        real_schema || '.' ||
        f_table_name || '.' || f_column_name ||
        ' TYPE:' || new_type ||
        ' ';
END;
$BODY$;

ALTER FUNCTION public.deletemgeometrycolumn(character varying, character varying, character varying, character varying)
    OWNER TO postgres;



	
select * from mgeometry_columns;

CREATE OR REPLACE FUNCTION public.append(
    mdouble,
    double precision [], timestamp without time zone [])
  RETURNS mdouble AS
$BODY$
DECLARE
    f_mgeometry            	alias for $1;
    tp                		alias for $2; 
 	timeline                alias for $3;
    f_mgeometry_segtable_name    char(200);
    mpid                	integer;
	segid                	integer;
    sql               		text;
	annotations				json;
	trajid				integer;
	mgeometry_types		char(50);
	mgeometry_inter		char(50);
BEGIN	
	mgeometry_types := 'mdouble';
	mgeometry_inter := 'linear' ;
    sql := 'select f_segtableoid  from mgeometry_columns where f_segtableoid = ' ||quote_literal(f_mgeometry.segid   );
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;
   	sql := 'select segid from ' || quote_ident(f_mgeometry_segtable_name) ||
                ' where mpid = ' || f_mgeometry.moid;
        RAISE DEBUG '%', sql;
        EXECUTE sql INTO segid;		
---array_cat(anyarray, anyarray)
	IF( segid IS NOT NULL) THEN
	 EXECUTE 'UPDATE ' || quote_ident(f_mgeometry_segtable_name) || 
                ' set datetimes = array_cat(datetimes, $2) , values = array_cat(values, $3) 
                where mpid = $4 and segid = $5 '
            USING tp, timeline, tp, mpid, segid; 
	sql := 'select row_to_json((SELECT d from (select datetimes, values, type, interpolation) d)) from  ' || quote_ident(f_mgeometry_segtable_name) ;
   		    RAISE DEBUG '%', sql;
			EXECUTE sql INTO annotations;
			
    EXECUTE 'update ' || quote_ident(f_mgeometry_segtable_name) || ' set annotations = ($4) WHERE mpid = $1'
    USING   mpid, tp, timeline,annotations;
	
	ELSE
    EXECUTE 'INSERT INTO ' || quote_ident(f_mgeometry_segtable_name) || '(mpid,segid,  datetimes, values, type, interpolation) 
	VALUES($1, 1, $3, $2, $4, $5)'
    USING mpid, tp, timeline, mgeometry_types, mgeometry_inter;
		
	sql := 'select row_to_json((SELECT d from (select datetimes,values, type,  interpolation) d)) from  ' || quote_ident(f_mgeometry_segtable_name) ;
   		RAISE DEBUG '%', sql;
   	 	EXECUTE sql INTO annotations;		
	EXECUTE 'update ' || quote_ident(f_mgeometry_segtable_name) || ' set annotations = ($4) WHERE mpid = $1'
    USING  mpid, tp, timeline, annotations;
	END IF;
    return f_mgeometry;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
ALTER FUNCTION public.append(mdouble, double precision [], timestamp without time zone [])
  OWNER TO postgres;
  
  
CREATE OR REPLACE FUNCTION public.append(
	mpoint,
	mcoordinate[],
	timestamp without time zone[])
    RETURNS mpoint
AS $BODY$
DECLARE
    f_mgeometry            	alias for $1;
    tp                		alias for $2;
 	timeline                alias for $3;
	segid                	integer;
    f_mgeometry_segtable_name    char(200);
    mpid               		integer;
    sql                		text;
	annotations				json;
	trajid					integer;
	mgeometry_types			char(50);
	mgeometry_inter			char(50);
BEGIN   
	mgeometry_types := 'mpoint';
	mgeometry_inter := 'linear' ;
	sql := 'select f_segtableoid  from mgeometry_columns where f_segtableoid = ' ||quote_literal(f_mgeometry.segid   );
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;
	   	sql := 'select segid from ' || quote_ident(f_mgeometry_segtable_name) ||
                ' where mpid = ' || f_mgeometry.moid;
        RAISE DEBUG '%', sql;
        EXECUTE sql INTO segid;	
	IF( segid IS NOT NULL) THEN
	 EXECUTE 'UPDATE ' || quote_ident(f_mgeometry_segtable_name) || 
                ' set datetimes = array_cat(datetimes, $2) , geo = array_cat(geo, $3) 
                where mpid = $4 and segid = $5 '
            USING tp, timeline, tp, mpid, segid; 
	sql := 'select row_to_json((SELECT d from (select datetimes,geo, type, interpolation) d)) from  ' || quote_ident(f_mgeometry_segtable_name) ;
   		    RAISE DEBUG '%', sql;
			EXECUTE sql INTO annotations;
			
    EXECUTE 'update ' || quote_ident(f_mgeometry_segtable_name) || ' set annotations = ($4) WHERE mpid = $1'
    USING   mpid, tp, timeline,annotations;
	
	ELSE
    EXECUTE 'INSERT INTO ' || quote_ident(f_mgeometry_segtable_name) || '(mpid, segid, datetimes, geo, type, interpolation) 
    VALUES($1, 1, $3, $2, $4, $5)'
    USING mpid, tp, timeline, mgeometry_types, mgeometry_inter;
	--get json ;
	sql := 'select row_to_json((SELECT d from (select datetimes,geo, type, interpolation ) d)) from  ' || quote_ident(f_mgeometry_segtable_name) ;
   	RAISE DEBUG '%', sql;
    EXECUTE sql INTO annotations;		
	EXECUTE 'update ' || quote_ident(f_mgeometry_segtable_name) || ' set annotations = ($4) WHERE mpid = $1'
    USING  mpid, tp, timeline, annotations;   
	END IF;
    return f_mgeometry;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
ALTER FUNCTION public.append(mpoint, mcoordinate[], timestamp without time zone[])
    OWNER TO postgres;
  




  
CREATE OR REPLACE FUNCTION public.append(
    mvideo,
    mcoordinate[], timestamp without time zone[], character varying[], double precision[], double precision[], double precision[], fov[])
  RETURNS mvideo AS
$BODY$
DECLARE
    f_mgeometry           	alias for $1;
    tp						alias for $2;
	timeline					alias for $3;	
	turi					alias for $4;	
	tdistance				alias for $5;	
	tdirection				alias for $6;
	tangle					alias for $7;
	tfov					alias for $8;
	segid                	integer;
    f_mgeometry_segtable_name    char(200);
    mpid                	integer;
    sql                		text;
	trajid					integer;
	annotations				json;
	mgeometry_types		char(50);
BEGIN   
	mgeometry_types := 'mvideo';
	sql := 'select f_segtableoid  from mgeometry_columns where f_segtableoid = ' ||quote_literal(f_mgeometry.segid   );
	EXECUTE sql INTO trajid;
	sql := 'select f_mgeometry_segtable_name  from mgeometry_columns where f_segtableoid = ' ||quote_literal(trajid );
	EXECUTE sql INTO f_mgeometry_segtable_name;
    mpid := f_mgeometry.moid;
	   	sql := 'select segid from ' || quote_ident(f_mgeometry_segtable_name) ||
                ' where mpid = ' || f_mgeometry.moid;
        RAISE DEBUG '%', sql;
        EXECUTE sql INTO segid;	
	IF( segid IS NOT NULL) THEN
	 EXECUTE 'UPDATE ' || quote_ident(f_mgeometry_segtable_name) || 
                ' set datetimes = array_cat(datetimes, $2) , geo = array_cat(geo, $3) 
                where mpid = $4 and segid = $5 '
            USING tp, timeline, tp, mpid, segid; 
	sql := 'select row_to_json((SELECT d from (select datetimes,geo,uri,fovs ) d)) from  ' || quote_ident(f_mgeometry_segtable_name) ;
   		    RAISE DEBUG '%', sql;
			EXECUTE sql INTO annotations;
			
    EXECUTE 'update ' || quote_ident(f_mgeometry_segtable_name) || ' set annotations = ($4) WHERE mpid = $1'
    USING   mpid, tp, timeline,annotations;
	
	ELSE
    EXECUTE 'INSERT INTO ' || quote_ident(f_mgeometry_segtable_name) || '(mpid, segid, datetimes, geo, uri, distance, direction2d, horizontalAngle, fovs, type) 
    VALUES($1, 1, $2, $3, $4, $5, $6, $7 , $8, $9)'
    USING mpid, timeline, tp, turi, tdistance, tdirection, tangle, tfov, mgeometry_types;
	--get json ;
	sql := 'select row_to_json((SELECT d from (select datetimes,geo,uri,fovs ) d)) from  ' || quote_ident(f_mgeometry_segtable_name) ;
   	RAISE DEBUG '%', sql;
    EXECUTE sql INTO annotations;		
	EXECUTE 'update ' || quote_ident(f_mgeometry_segtable_name) || ' set annotations = ($4) WHERE mpid = $1'
    USING  mpid, tp, timeline,annotations;
	END IF;
    return f_mgeometry;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
ALTER FUNCTION public.append(mvideo, mcoordinate[], timestamp without time zone[], character varying[], double precision[], double precision[], double precision[], fov[] )
    OWNER TO postgres;
	
	

  
CREATE OR REPLACE FUNCTION append(mdouble, character varying) RETURNS mdouble AS
$$
DECLARE
	c_trajectory	alias for $1;
	array_mdouble	alias for $2;	
	array_time	timestamp without time zone[];
	array_double	double precision[];
BEGIN
	array_double =regexp_split_to_array(mdoubledouble(array_mdouble),';')::double precision[];
	array_time = regexp_split_to_array(mdoubletime(array_mdouble),',') ::timestamp without time zone[];	
	execute 'select append( $1, $2, $3)'
	using c_trajectory, array_double,array_time;	
	RETURN c_trajectory;
END
$$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;


CREATE OR REPLACE FUNCTION append(mpoint, character varying) RETURNS mpoint AS
$$
DECLARE
	c_trajectory	alias for $1;
	array_mpoint	alias for $2;
	array_time	timestamp without time zone[];
	array_point	mcoordinate[];
BEGIN
	array_time = regexp_split_to_array(mpointtime(array_mpoint),',') ::timestamp without time zone[];
	array_point = regexp_split_to_array(mpointpoint(array_mpoint),';') ::mcoordinate[];	
	execute 'select append( $1, $2, $3 )'
	using c_trajectory, array_point,array_time;
	RETURN c_trajectory;
END
$$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;


  
  
CREATE OR REPLACE FUNCTION mcoordinate(
    double precision,
    double precision,
	double precision)
  RETURNS mcoordinate AS
$BODY$
DECLARE
    pointx        alias for $1;
    pointy        alias for $2;
	pointz        alias for $3;
    tp            mcoordinate;
BEGIN    
    tp.pointx := pointx;
    tp.pointy := pointy;
	tp.pointz := pointz;
    RETURN tp;
END
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
ALTER FUNCTION mcoordinate(double precision, double precision, double precision)
  OWNER TO postgres;

  
  
CREATE OR REPLACE FUNCTION append(mvideo, character varying) RETURNS mvideo AS
$$
DECLARE
	c_trajectory	alias for $1;
	array_mvideo	alias for $2;
	array_time		timestamp without time zone[];
	array_point		mcoordinate[];
	array_uri		character varying[];
	array_fovdis	double precision[];
	array_fovdir	double precision[];
	array_fovang	double precision[];
	array_fov		fov[];
	i				integer;
	array_size		integer;
	fovs			fov;
BEGIN
	array_time = regexp_split_to_array(mvideotime(array_mvideo),',') ::timestamp without time zone[];
	array_point = regexp_split_to_array(mvideopoint(array_mvideo),';') ::mcoordinate[];	
	array_uri = regexp_split_to_array(mvideouri(array_mvideo),';') ::character varying[];
	array_fovdis = regexp_split_to_array(mvideodistance(array_mvideo),';') ::double precision[];
	array_fovdir = regexp_split_to_array(mvideodirection(array_mvideo),';') ::double precision[];
	array_fovang = regexp_split_to_array(mvideoangle(array_mvideo),';') ::double precision[];
	execute 'select array_upper( $1, 1 )'
	into array_size using array_point;

	i := 1;
	WHILE( i <= array_size ) LOOP
		---fovs.geo := array_point[i];
		fovs.horizontalAngle := array_fovang[i];
		fovs.direction2d := array_fovdir[i];
		fovs.distance := array_fovdis[i];
		array_fov[i] = fovs;
		i := i+1;
	END LOOP;
	execute 'select append( $1, $2, $3, $4, $5, $6, $7, $8 )'
	using c_trajectory, array_point, array_time, array_uri, array_fovdis, array_fovdir, array_fovang, array_fov;		
	RETURN c_trajectory;
END
$$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;  




CREATE OR REPLACE FUNCTION public.append(
    stphoto,
    character varying)
  RETURNS stphoto AS
$BODY$
DECLARE
    c_trajectory	alias for $1;
	stphotostring	alias for $2;
	moid			oid;
	uris			text;
	width			integer;
	height			integer;
	t				timestamp without time zone;
	geo				mcoordinate;
	fov				fov;
	sql				text;
	st				stphoto;
BEGIN	

	uris = split_part(split_part(split_part(stphotostring,'(',2), ')',1),' ',1);
	raise info '%', uris;
	width = split_part(split_part(split_part(stphotostring,'(',2), ')',1),' ',2);
	height = split_part(split_part(split_part(stphotostring,'(',2), ')',1),' ',3);
	fov.horizontalAngle = split_part(split_part(split_part(stphotostring,'(',3), ')',1),' ',3);
	fov.direction2d = split_part(split_part(split_part(stphotostring,'(',3), ')',1),' ',1);
	fov.distance = split_part(split_part(split_part(stphotostring,'(',3), ')',1),' ',5);
	geo.pointx = split_part(split_part(split_part(stphotostring,'(',4), ')',1),' ',1);
	raise info '%', geo.pointx ;
	geo.pointy = split_part(split_part(split_part(stphotostring,'(',4), ')',1),' ',2);
	raise info '%', geo.pointy ;
	geo.pointz = 'NaN';
	raise info '%', geo.pointz ;
	t =  TIMESTAMP WITHOUT TIME ZONE 'epoch' + ((split_part(stphotostring,')',3))::bigint)* INTERVAL '1 second';
	st.uri = uris;
	st.fov =fov;
	st.t = t;
	st.geo = geo;
	st.width = width;
	st.height = height;
	st.moid := c_trajectory.moid;
	---EXECUTE 'update userstphotos set st = ($1) WHERE id = $2'
   --- USING   st, moid;
	raise info '%', st;
    return st;
END;
$BODY$ 
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
  



CREATE TYPE fov AS
(
   horizontalAngle double precision,
   verticalAngle double precision,
   direction2d double precision,
   direction3d double precision,
   distance double precision
);

CREATE TYPE mcoordinate AS
(
	pointx double precision,
	pointy double precision,
	pointz double precision
);

CREATE TYPE frame AS
(
   fid integer,
   relativeTime bigint,
   framefov fov,   
   geo      mcoordinate
);



CREATE TYPE mperiod AS
(
	moid oid,
	fromtime bigint[],
	totime bigint[]
);


CREATE TYPE period AS
(
	fromtime bigint,
	totime bigint
);


CREATE TYPE mdouble AS
(
	moid oid,
	segid  text,
	doubles double precision[],
	t timestamp without time zone[]
);

CREATE TYPE mpoint AS
(
	moid oid,
	segid  text,
	geo mcoordinate[],
	t timestamp without time zone[]
);

CREATE TYPE mbool AS
(
	moid oid,
	bools boolean[],
	t timestamp without time zone[]
);

CREATE TYPE mpolygon AS
(
	moid oid,
	polygons polygon[],
	t timestamp without time zone[]
);

CREATE TYPE mvideo AS
(
   moid oid,
   segid  text,
   uri text,
   annotations json[],
   mgeo mpoint, 
   startTime timestamp without time zone[],
   frames frame[],
   afov fov             
);

CREATE TYPE mphoto AS
(
	moid oid,
	uri text[],
	width integer,
	height integer,
	annotations json[],
	geo mpoint,
	fovs fov[]
);



CREATE TYPE stphoto AS
(
   moid oid,
   uri text,
   width integer,
   height integer,
   t timestamp without time zone,
   annotations json[],
   geo mcoordinate,
   fov FoV
);

CREATE TYPE mduration AS
(
	moid oid,
	duration bigint[]
);

CREATE TYPE minstant AS
(
	moid oid,
	t timestamp without time zone[]
);

CREATE TYPE mint AS
(
	moid oid,
	ints integer[]
);

CREATE TYPE mmultipoint AS
(
	moid oid,
	geo mcoordinate[],
	t timestamp without time zone[]
);

CREATE TYPE mstring AS
(
	moid oid,
	mstrings text[],
	t timestamp without time zone[]
);

CREATE TYPE mlinestring AS
(
	moid oid,
	mlinestrings text[],
	t timestamp without time zone[]
);

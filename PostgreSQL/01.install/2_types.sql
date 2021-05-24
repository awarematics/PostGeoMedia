

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
   relativeTime bigint,
   framefov fov,   
   geo      mcoordinate
);


CREATE TYPE period AS
(
	fromtime bigint,
	totime bigint
);


CREATE TYPE mpoint AS
(
	geo mcoordinate[],
	t bigint[]
);

CREATE TYPE mvideo AS
(
   uri text,
   annotations text[],
   mgeo mpoint, 
   startTime bigint[],
   frames frame[],
   afov fov             
);


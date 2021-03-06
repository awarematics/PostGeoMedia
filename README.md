
# MGeometry Java Library(MJL)


## Supported MGemoetry Types

	MPeriod :  MPERIOD ((1556911345 1556911346), (1556911346 1556911347), ...)
	
	MDuration :  MDURATION (1000, 1000, 1000, ...)
	
 	MInstant : MINSTANT (15569113450, 15569114450, 15569115450, ...)
	
	MInt :  MINT (2 1556911346, 3 1556911347, ...)
	// alternatively   MINT (2@1556911346, 3@1556911347, ...)
	
 	MBool :  MBOOL (ture 1000, false 1000, true ...)  
	// alternatively   MBOOL (ture@1000, false@1000, true ...)
	
 	MDouble : MDOUBLE (1743.6106216698727 1556811344, 1587.846969956488 1556911345 ...)
	
	MMultiPoint :  MMUltiPoint (((0 0) 1589302899, (1 1) 1589305899, ...) ...)

 	MString :  MSTRING (disjoint 1481480632123, meet 1481480637123 ...)

	MPoint :  MPOINT ((0.0 0.0) 1481480632123, (2.0 5.0) 1481480637123 ...)
	 
 	MLineString :  MLINESTRING ((-1 0, 0 0, 0 0.5, 5 5) 1481480632123, (0 0, -1 0) 1481480637123 ...)
	
 	MPolygon : MPOLYGON ((0 0, 1 1, 1 0, 0 0) 1000, (0 0, 1 1, 1 0, 0 0) 2000 ...)
	
	MVideo :  MVIDEO ('localhost:///tmp/drone/test1.mp4', MPOINT ((0.0 0.0) 1481480632123, (2.0 5.0) 1481480637123 ...), FRAME ((60 0 0.1 30 0 0), (60 0 0.1 30 0 0)...))
 	
	MPhoto :  MPHOTO (('localhost:///tmp/drone/test1.jpg' 200 200 60 0 0.1 30 0 0 'annotation' 'exif' 100 100) 1481480632123 ...)


## MGeometry SQL Real Examples

### Create TABLE examples with MVideo types

```

 create table bdd10k(
	carid integer primary key,
	carnumber varchar,
	model varchar,
	driver varchar
);

select addmgeometrycolumn('public', 'bdd10k', 'mpoint', 4326, 'mpoint', 2, 50);
select addmgeometrycolumn('public', 'bdd10k', 'mvideo', 4326, 'mvideo', 2, 50);

select * from bdd10k;

```


### Insert Examples 
```

insert into car values(1, '57NU2001', 'Optima', 'hongkd7');
insert into car values(2, '57NU2002', 'SonataYF', 'hongkd7');


``` 

### Append Examples 
```

UPDATE car 
SET    mpoint = append(mpoint, ('MPOINT ((200 200)@1180389003000, (203 208)@1180389004000)' ) 
WHERE  taxi_id = 1;

--default : MVIDEO is "MVIDEO_SIMPLE"
UPDATE car 
SET    mvideo = append(mvideo, ('MVDIDEO ((200 200)@1180389003000, (203 208)@1180389004000), 'http://u-gist/1.mp4') 
WHERE  taxi_id = 1;

UPDATE car 
SET    mvideo = append(mvideo, ('MVDIDEO_FULL ((200 200)@1180389003000, (203 208)@1180389004000),__________ 'http://u-gist/1.mp4') 
WHERE  taxi_id = 2;


```
### UDF Function Examples 
```

SELECT M_At('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 2);
	------>Return: MPOINT ((41.67 -73.81) 2000)

SELECT M_NumOf('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)');
	------>Return: 2

SELECT M_Time('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)');
	------>Return:(1504354462000,1504354501000)
	
SELECT M_Spatial('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)');
	------>Return: Geometry

SELECT M_StartTime('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)');
	------>Return:1504354462000

SELECT M_EndTime('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)');
	------>Return:1504354501000

SELECT M_Spatial('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)');
	------>Return:LINESTRING(40.77 -73.95,40.77 -73.96)

SELECT M_Snapshot('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 1000);
	------>Return:POINT(40.77 -73.95)

SELECT M_Slice('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 'Period (1100, 1200)');
	------>Return:(,,"{""(40.77,-73.95)"",""(40.77,-73.96)""}","{""2017-09-02 08:14:22"",""2017-09-02 08:14:23""}")

SELECT M_Lattice('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 2000);
	------>Return:(,,"{""(40.77,-73.95)""}","{""2017-09-02 08:14:22""}")

SELECT M_tOverlaps('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 'Period (1100, 2200)');
	------>Return: true
	

SELECT M_TimeAtCummulative('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 2);
	------>Return: 1504354471666

SELECT M_Slice('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 'Period (1000, 2000)');
	------>Return: 'MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)'

SELECT M_SnapToGrid('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 1);
	------>Return: 'MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)'

SELECT M_sEnters('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 'POLYGON ((39 -74, 39 -72, 43 -72, 43 -74, 39 -74))');
	------>Return:false

SELECT M_sBypasses('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 'POLYGON ((39 -74, 39 -72, 43 -72, 43 -74, 39 -74))');
	------>Return:false

SELECT M_sStayIn('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 'POLYGON ((39 -74, 39 -72, 43 -72, 43 -74, 39 -74))');
	------>Return:true

SELECT M_sLeaves('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 'POLYGON ((39 -74, 39 -72, 43 -72, 43 -74, 39 -74))');
	------>Return:false

SELECT M_sCrosses('MPOINT ((40.67 -73.83) 1000, (41.67 -73.81) 2000)', 'POLYGON ((39 -74, 39 -72, 43 -72, 43 -74, 39 -74))');
	------>Return:false 

### SELECT Examples 
--- 
SELECT carid, mpoint
FROM bdd10k;

---
SELECT carid, M_GEO2JSON(mpoint)
FROM bdd10k;

---
SELECT carid, M_AsText(mpoint)
FROM bdd10k;

---
SELECT carid, ST_AsText(m_spatial(mpoint))
FROM bdd10k;

---
SELECT carid, M_Time(mpoint)
FROM bdd10k;

``` 

### Range Queries

### Temporal Range Queries
```


-----basic temporal query no index  
explain analyze
select carid, mpoint, m_time(mpoint)
from bdd10k 
where m_tintersects_noindex(mpoint, '(1504010956999,1504012995999)'::int8range)
and carid <2000;

-----no temporary table with index
explain analyze
select carid, mpoint, m_time(mpoint)
from bdd10k
where m_tintersects_index(mpoint, '(1504010956999,1504012995999)'::int8range )
and carid <2000;


----- materialized
explain analyze
select carid, mpoint, m_time(mpoint)
from bdd10k 
where m_tintersects_materialized(mpoint, '(1504010956999,1504012995999)'::int8range)
and carid <2000;






```
---Spatial Range Queries

```


-----basic spatial query no index  
explain analyze
select carid, mpoint, m_spatial(mpoint)
from bdd10k 
where m_intersects_noindex(mpoint, 'LINESTRING(40 -73,40.7416693959765 -73.9897693321798,40.7416693959765 -73.9897693321798)'::geometry,  '(1414010956999,1504012995999)'::int8range)
and carid <8000;


-----no spatial table with index
explain analyze
select carid, mpoint, m_spatial(mpoint)
from bdd10k
where m_intersects_index(mpoint, 'LINESTRING(40 -73,40.7416693959765 -73.9897693321798,40.7416693959765 -73.9897693321798)'::geometry, '(1414010956999,1504012995999)'::int8range)
and carid <8000;



-----spatial table with materialized
explain analyze
select carid, mpoint, m_spatial(mpoint)
from bdd10k 
where m_intersects_materialized(mpoint, 'LINESTRING(40 -73,40.7416693959765 -73.9897693321798,40.7416693959765 -73.9897693321798)'::geometry, '(1414010956999,1504012995999)'::int8range)
and carid <8000;





```
### Spatial-temporal Range Queries
```




-----basic spatial query no index  
explain analyze
select carid, mpoint, m_spatial(mpoint)
from bdd10k 
where m_sintersects_noindex(mpoint, 'LINESTRING(40 -73,40.7416693959765 -73.9897693321798,40.7416693959765 -73.9897693321798)'::geometry)
and carid <2000;


-----no spatial table with index
explain analyze
select carid, mpoint, m_spatial(mpoint)
from bdd10k
where m_sintersects_index(mpoint, 'LINESTRING(40 -73,40.7416693959765 -73.9897693321798,40.7416693959765 -73.9897693321798)'::geometry)
and carid <2000;



-----spatial table with index
explain analyze
select carid, mpoint, m_spatial(mpoint)
from bdd10k 
where m_sintersects_materialized(mpoint, 'LINESTRING(40 -73,40.7416693959765 -73.9897693321798,40.7416693959765 -73.9897693321798)'::geometry)
and carid <10000;


```
### K Nearest Neighbor Query
```
SELECT m_knn(t.mpoint,'LINESTRING(40 -73,40.7416693959765 -73.9897693321798,40.7416693959765 -73.9897693321798)'::geometry,3)
FROM Trip t

SELECT m_knn(t.mpoint,p.geo,3)
FROM Trip t,POI p

SELECT m_knn(t1.traj,t2.traj,3)
FROM Trip t1,Trip t2

```
### Distance Join Queries (MGeometry to Geometry)
```

-----basic join query no index  

select carid from bdd100k_seg where m_mindistance_noindex(mpoint,'POINT (-73.9917157777343 40.7424697420008)'::geometry, 100.0);

-----join query with index  

select carid from bdd100k_seg where m_mindistance_index(mpoint,'POINT (-73.9917157777343 40.7424697420008)'::geometry, 100.0);

----- index with materialized

select carid from bdd100k_seg where m_mindistance_materialized(mpoint,'POINT (-73.9917157777343 40.7424697420008)'::geometry, 100.0);



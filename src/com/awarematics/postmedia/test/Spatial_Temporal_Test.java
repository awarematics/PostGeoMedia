package com.awarematics.postmedia.test;
import java.io.IOException;

import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.LineString;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.Polygon;
import org.locationtech.jts.io.ParseException;
import org.locationtech.jts.io.WKTReader;

import com.awarematics.postmedia.io.MWKTReader;
import com.awarematics.postmedia.mgeom.MGeometryFactory;
import com.awarematics.postmedia.types.mediamodel.MBool;
import com.awarematics.postmedia.types.mediamodel.MGeometry;
import com.awarematics.postmedia.types.mediamodel.MInstant;
import com.awarematics.postmedia.types.mediamodel.MPoint;
import com.awarematics.postmedia.types.mediamodel.MString;
import com.awarematics.postmedia.types.mediamodel.MVideo;

public class Spatial_Temporal_Test {

	public static void main(String[] args) throws IOException, ParseException, java.text.ParseException
	{		
		
		MGeometryFactory geometryFactory = new MGeometryFactory();
		MWKTReader reader = new MWKTReader(geometryFactory);	  		  
		
		MPoint mp = (MPoint)reader.read("MPOINT ((0 0) 1481480632123, (2 200) 1481480638000, (5 0) 1481480639123, (13 13) 1481480641123, (30 33) 1481480642556, (70 70) 1481480643223, (102 63) 1481480644123, (103 33) 1481480645556)");
		MPoint mp2 = (MPoint)reader.read("MPOINT ((0 2) 1481480633123, (2 0) 1481480638000, (5 0) 1481480639123, (13 13) 1481480641123, (30 33) 1481480642556, (63 50) 1481480643523, (102 70) 1481480644123, (103 333) 1481480645556)");
		
		MVideo mv = (MVideo)reader.read("MVIDEO (('localhost:///tmp/drone/test1.jpg' 60 0 0.1 30 0 0 'annotation' 'exif' 0 0) 1481480632123, ('localhost:///tmp/drone/test1.jpg' 60 0 0.1 30 0 0 'annotation' 'exif' 1 1) 1481480634123), ('localhost:///tmp/drone/test1.jpg' 60 0 0.1 30 0 0 'annotation' 'exif' 101.99 62.9) 1481480644123)");
		MVideo mv2 = (MVideo)reader.read("MVIDEO (('localhost:///tmp/drone/test1.jpg' 60 0 0.1 30 0 0 'annotation' 'exif' -0.0001 -0.0001) 1481480632123, ('localhost:///tmp/drone/test1.jpg' 60 0 0.1 30 0 0 'annotation' 'exif' 0.99 0.99) 1481480634123), ('localhost:///tmp/drone/test1.jpg' 60 0 0.1 30 0 0 'annotation' 'exif' 102 63) 1481480644123)");
		
	
		}
	
}
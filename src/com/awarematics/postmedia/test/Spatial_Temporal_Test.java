package com.awarematics.postmedia.test;

import java.io.IOException;
import org.locationtech.jts.geom.Geometry;
import org.locationtech.jts.io.ParseException;
import com.awarematics.postmedia.io.MWKTReader;
import com.awarematics.postmedia.mgeom.MGeometryFactory;
import com.awarematics.postmedia.types.mediamodel.FoV;
import com.awarematics.postmedia.types.mediamodel.Frame;
import com.awarematics.postmedia.types.mediamodel.MPoint;
import com.awarematics.postmedia.types.mediamodel.MVideo;

public class Spatial_Temporal_Test {

	public static void main(String[] args) throws IOException, ParseException, java.text.ParseException
	{		
		
		MGeometryFactory geometryFactory = new MGeometryFactory();
		MWKTReader reader = new MWKTReader(geometryFactory);	  		  
		
		MPoint mp = (MPoint)reader.read("MPOINT ((0 0) 1481480632123, (2 200) 1481480638000, (5 0) 1481480639123, (13 13) 1481480641123, (30 33) 1481480642556, (70 70) 1481480643223, (102 63) 1481480644123, (103 33) 1481480645556)");
		MPoint mp2 = (MPoint)reader.read("MPOINT ((0 2) 1481480633123, (2 0) 1481480638000, (5 0) 1481480639123, (13 13) 1481480641123, (30 33) 1481480642556, (63 50) 1481480643523, (102 70) 1481480644123, (103 333) 1481480645556)");
		
		MVideo mv = (MVideo)reader.read("MVIDEO (('localhost:///tmp/drone/test1.jpg', MPOINT ((0.0 0.0) 1481480632123, (2.0 200.0) 1481480638000, (5.0 0.0) 1481480639123, (13.0 13.0) 1481480641123, (30.0 33.0) 1481480642556, (70.0 70.0) 1481480643223, (102.0 63.0) 1481480644123, (103.0 33.0) 1481480645556), "
				+ "FRAME ((0 0 0 0 0), (0 0 0 0 0), (0 0 0 0 0), (0 0 0 0 0), (0 0 0 0 0), (0 0 0 0 0), (0 0 0 0 0), (0 0 0 0 0))");
		
		
		Geometry g = mp.spatial();
		MPoint mps = geometryFactory.createMPoint(g.getCoordinates(), mp.getTimes());
		
		double[] dir2d = {0, 0, 0, 0, 0, 0, 0, 0};
		double[] dir3d = {0, 0, 0, 0, 0, 0, 0, 0};
		double[] dis = {0, 0, 0, 0, 0, 0, 0, 0};
		double[] hangle = {0, 0, 0, 0, 0, 0, 0, 0};
		double[] vangle = {0, 0, 0, 0, 0, 0, 0, 0};

		Frame[] frame = new Frame[dis.length];
		for(int i = 0; i < dis.length; i++)
		{
			FoV fovs = new FoV();
			fovs.setDirection2d(dir2d[i]);
			fovs.setDirection3d(dir3d[i]);
			fovs.setDistance(dis[i]);
			fovs.setHorizontalAngle(hangle[i]);
			fovs.setVerticalAngle(vangle[i]);
			frame[i] = new Frame();
			frame[i].setFov(fovs);
			System.out.println(frame[i].getFov().toGeoString());
		}
		
		MVideo mvs = geometryFactory.createMVideo("urti", mps, null, null, frame[0].getFov(), frame);
		System.out.println(mvs.toGeoString());
		}
	/*
	//@Function
	public static String m_snapshot(String mgstring, double instant)
			throws ParseException, org.locationtech.jts.io.ParseException {
		MGeometryFactory geometryFactory = new MGeometryFactory();
		MWKTReader reader = new MWKTReader(geometryFactory);
		MGeometry mg1 = (MGeometry) reader.read(mgstring);
		if (mg1.startTime() > (long)instant && mg1.endTime() < (long)instant) {	
			return null;
		}
		return mg1.snapshot((long)instant).toText();
	}
	// @Function
		public static long M_StartTime(String mgstring) throws ParseException, org.locationtech.jts.io.ParseException {
			MGeometryFactory geometryFactory = new MGeometryFactory();
			MWKTReader reader = new MWKTReader(geometryFactory);
			MGeometry mg1 = (MGeometry) reader.read(mgstring);
			return mg1.startTime();
		}

	 
	// @Function
	 public static String useComplexTest(ResultSet mpoint)
			 throws SQLException
			 {
			   long base = mpoint.getLong(1);
			   String incbase = mpoint.getString(2);
			   return "Base = \"" + base +
			     "\", incbase = \"" + incbase + "\"";
			 }	 
	 
	
	//@Function
	public static boolean M_tIntersects(String mgstring, String periodstring)
			throws ParseException, org.locationtech.jts.io.ParseException {
		MGeometryFactory geometryFactory = new MGeometryFactory();
		MWKTReader reader = new MWKTReader(geometryFactory);
		MGeometry mg1 = (MGeometry) reader.read(mgstring);
		String from = periodstring.split(", ")[0].replace("(", "");
		String to = periodstring.split(", ")[1].replace(")", "");
		// 3 ways   contains  insides  intersects
		GeometryFactory geometryFactorys = new GeometryFactory();
		WKTReader readers = new WKTReader( geometryFactorys );
		LineString geometry1 = (LineString) readers.read("LINESTRING("+from+" 0, "+to+" 0)");
		LineString geometry2 = (LineString) readers.read("LINESTRING("+mg1.startTime()+" 0, "+mg1.endTime()+" 0)");
		if (geometry1.intersects(geometry2))
			return true;
		return false;
	}
	
	//@Function
	public static boolean M_tIntersects(String mgstring, double doublestring)
			throws ParseException, org.locationtech.jts.io.ParseException {
		MGeometryFactory geometryFactory = new MGeometryFactory();
		MWKTReader reader = new MWKTReader(geometryFactory);
		MGeometry mg1 = (MGeometry) reader.read(mgstring);
		if (mg1.startTime() <= doublestring && mg1.endTime() >= doublestring)
			return true;
		return false;
	}
	

	//--m_spatial(mpoint) geometry
	//@Function
	public static String M_Spatial(String mgstring) throws ParseException, org.locationtech.jts.io.ParseException {
		MGeometryFactory geometryFactory = new MGeometryFactory();
		MWKTReader reader = new MWKTReader(geometryFactory);
		MGeometry mg1 = (MGeometry) reader.read(mgstring);
		return mg1.spatial().toText();
	}
	//--m_eventtime(mpoint,geom, double) double
	//@Function
	public static double M_EventTime(String mgs1, String mgs2)
			throws ParseException, org.locationtech.jts.io.ParseException {
		MGeometryFactory geometryFactory = new MGeometryFactory();
		MWKTReader reader = new MWKTReader(geometryFactory);
		
		GeometryFactory geometryFactory2 = new GeometryFactory();
		WKTReader reader2 = new WKTReader(geometryFactory2);
		MGeometry mg1 = (MGeometry) reader.read(mgs1);
		Point mg2 = (Point) reader2.read(mgs2);
		if(mg1.spatial().intersects(mg2))
			for(int i =0;i<mg1.numOf();i++)
			{
				if(mg1.getCoords()[i].equals(mg2.getCoordinate()))
				{
					return (double)(mg1.getTimes()[i]);
				}
			}
		return 0;
	}
	
	//--m_eventtime(mpoint,geom, double) double
	//@Function
	public static double M_EventTime(String mgs1, String mgs2, double doubles)
			throws ParseException, org.locationtech.jts.io.ParseException {
		MGeometryFactory geometryFactory = new MGeometryFactory();
		MWKTReader reader = new MWKTReader(geometryFactory);
		MGeometry mg1 = (MGeometry) reader.read(mgs1);
		MGeometry mg2 = (MGeometry) reader.read(mgs2);
		GeometryFactory geometryFactory2 = new GeometryFactory();
		WKTReader reader2 = new WKTReader(geometryFactory2);
		Geometry geo2 = mg2.spatial();
		Geometry geo1 = mg1.spatial();
		if (geo1.isWithinDistance(geo2,doubles)) {
			for(int i =0;i<mg1.numOf();i++)
			{
				Point point = geometryFactory2.createPoint(new Coordinate(geo1.getCoordinates()[i]));
				if(point.isWithinDistance(geo2,doubles))
				{
					return (double)(mg1.getTimes()[i]);
				}
			}
		}
		
		return 0;
	}
	//--m_eventposition(mpoint, geom, double) geometry
	//@Function
	public static String m_eventposition(String mgs1, String mgs2, double doubles)
		throws ParseException, org.locationtech.jts.io.ParseException {
	MGeometryFactory geometryFactory = new MGeometryFactory();
	MWKTReader reader = new MWKTReader(geometryFactory);
	MGeometry mg1 = (MGeometry) reader.read(mgs1);
	MGeometry mg2 = (MGeometry) reader.read(mgs2);
	GeometryFactory geometryFactory2 = new GeometryFactory();
	WKTReader reader2 = new WKTReader(geometryFactory2);
	Geometry geo2 = mg2.spatial();
	Geometry geo1 = mg1.spatial();
	if (geo1.isWithinDistance(geo2,doubles)) {
		for(int i =0;i<mg1.numOf();i++)
		{
			Point point = geometryFactory2.createPoint(new Coordinate(geo1.getCoordinates()[i]));
			if(point.isWithinDistance(geo2,doubles))
			{
				return point.toText();
			}
		}
	}
	
	return null;
}
	//--m_slice(mpoint, period) mgeometry
	
	// @Function
	 public static String M_Slice(String mgstring, String periodstring)
				throws ParseException, org.locationtech.jts.io.ParseException, java.text.ParseException {
			MGeometryFactory geometryFactory = new MGeometryFactory();		
			MWKTReader reader = new MWKTReader(geometryFactory);
			MGeometry mg1 = (MGeometry) reader.read(mgstring);	
			String from = periodstring.split(",")[0].replace("[", "");
			String to = periodstring.split(",")[1].replace(")", "");
		
			GeometryFactory geometryFactorys = new GeometryFactory();
			WKTReader readers = new WKTReader( geometryFactorys );
			LineString geometry1 = (LineString) readers.read("LINESTRING("+from+" 0, "+to+" 0)");
			LineString geometry2 = (LineString) readers.read("LINESTRING("+mg1.startTime()+" 0, "+mg1.endTime()+" 0)");
			if (geometry1.intersects(geometry2))
					return mg1.slice(Long.parseLong(from), Long.parseLong(to)).toGeoString();

			return "null";
		} 

	//--m_timeatcummulative(mpoint) double
	// @Function
		public static double timeAtCummulativeDistance(String mgstring) throws ParseException, org.locationtech.jts.io.ParseException{
			MGeometryFactory geometryFactory = new MGeometryFactory();
			MWKTReader reader = new MWKTReader(geometryFactory);
			MGeometry mg1 = (MGeometry) reader.read(mgstring);

			double res =0;
			for (int i = 1; i < mg1.numOf()-1; i++) {
				res = res + mg1.calDistance(mg1.getCoords()[i], mg1.getCoords()[i + 1]);
			}
			System.out.println(res);		
			return res;
		}
	//--m_passes(mpoint, geom) bool
	 //@Function
		public static boolean m_passes(String mgs1, String mgs2)
				throws ParseException, org.locationtech.jts.io.ParseException {
			MGeometryFactory geometryFactory = new MGeometryFactory();
			GeometryFactory geometryFactorys = new GeometryFactory();
			MWKTReader reader = new MWKTReader(geometryFactory);
			WKTReader readers = new WKTReader(geometryFactorys);
			MGeometry mg1 = (MGeometry) reader.read(mgs1);
			Geometry mg2 = (Geometry) readers.read(mgs2);
			if (mg1.spatial().crosses(mg2))//
				return true;
			else
				return false;
		}
		
	//--m_meets(mpoint, geom) bool
	 //@Function
		public static boolean m_meets(String mgs1, String mgs2)
				throws ParseException, org.locationtech.jts.io.ParseException {
		 MGeometryFactory geometryFactory = new MGeometryFactory();
			GeometryFactory geometryFactorys = new GeometryFactory();
			MWKTReader reader = new MWKTReader(geometryFactory);
			WKTReader readers = new WKTReader(geometryFactorys);
			MGeometry mg1 = (MGeometry) reader.read(mgs1);
			Geometry mg2 = (Geometry) readers.read(mgs2);
			if (mg1.spatial().touches(mg2))//
				return true;
			else
				return false;
		}
	//--m_insides(mpoint, geom) bool
	// @Function
		public static boolean m_insides(String mgs1, String mgs2)
				throws ParseException, org.locationtech.jts.io.ParseException {
		 MGeometryFactory geometryFactory = new MGeometryFactory();
			GeometryFactory geometryFactorys = new GeometryFactory();
			MWKTReader reader = new MWKTReader(geometryFactory);
			WKTReader readers = new WKTReader(geometryFactorys);
			MGeometry mg1 = (MGeometry) reader.read(mgs1);
			Geometry mg2 = (Geometry) readers.read(mgs2);
			if (mg1.spatial().covers(mg2))//
				return true;
			else
				return false;
		}
	//--m_disjoints(mpoint, mpoint, period) 
	// @Function
		public static boolean m_disjoints(String mgs1, String mgs2)
				throws ParseException, org.locationtech.jts.io.ParseException {
		 MGeometryFactory geometryFactory = new MGeometryFactory();
			GeometryFactory geometryFactorys = new GeometryFactory();
			MWKTReader reader = new MWKTReader(geometryFactory);
			WKTReader readers = new WKTReader(geometryFactorys);
			MGeometry mg1 = (MGeometry) reader.read(mgs1);
			Geometry mg2 = (Geometry) readers.read(mgs2);
			if (mg1.spatial().disjoint(mg2))//
				return true;
			else
				return false;
		}
	*/
}
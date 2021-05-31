package com.awarematics.postmedia.operation;

import java.text.ParseException;
import java.util.Arrays;
import org.locationtech.jts.geom.*;
import org.locationtech.jts.io.WKTReader;
import com.awarematics.postmedia.algorithms.distance.MovingDistance;
import com.awarematics.postmedia.algorithms.similarity.MHausdorff;
import com.awarematics.postmedia.algorithms.similarity.MLCSS;
import com.awarematics.postmedia.algorithms.similarity.MLCVS;
import com.awarematics.postmedia.algorithms.similarity.MTrajHaus;
import com.awarematics.postmedia.io.MWKTReader;
import com.awarematics.postmedia.mgeom.MGeometryFactory;
import com.awarematics.postmedia.types.mediamodel.FoV;
import com.awarematics.postmedia.types.mediamodel.Frame;
import com.awarematics.postmedia.types.mediamodel.MBool;
import com.awarematics.postmedia.types.mediamodel.MDouble;
import com.awarematics.postmedia.types.mediamodel.MGeometry;
import com.awarematics.postmedia.types.mediamodel.MPoint;
import com.awarematics.postmedia.types.mediamodel.MVideo;
import org.postgresql.pljava.annotation.Function;



//--m_astext(mgeometry)
public class SpatialTemporalOP {
	@Function
	public static String m_astext(Geometry[] geometry, long[] time, String uri, double[] hangle, double[] vangle, double[] dir2d, double[] dir3d, double[] dis)
			throws ParseException, org.locationtech.jts.io.ParseException {
		
		MPoint mps = geometryFactory.createMPoint(geometry, time);
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
		}	
		MVideo mvs = geometryFactory.createMVideo(uri, mps, null, null, frame[0].getFov(), frame);		
		return mvs.toGeoString();
	}
	 
	@Function
	public static String m_astext(Geometry[] geometry, long[] time)
			throws ParseException, org.locationtech.jts.io.ParseException {
		
		MPoint mps = geometryFactory.createMPoint(geometry, time);
		return mps.toGeoString();
	}
}

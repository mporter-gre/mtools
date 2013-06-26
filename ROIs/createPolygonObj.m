function polygonObj = createPolygonObj(points, z, c, t, transform)
%polygonObj = createPolygonObj(points, z, c, t, transform)

polygonObj = pojos.PolygonData;
polygonObj.setPoints(points);
polygonObj.setTheZ(z);
polygonObj.setTheC(c);
polygonObj.setTheT(t);
polygonObj.setTransform(transform);
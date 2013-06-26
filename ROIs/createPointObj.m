function pointObj = createPointObj(x, y, z, c, t, transform)
%pointObj = createPointObj(x, y, z, c, t, transform)

pointObj = pojos.PointData;
pointObj.setX(x);
pointObj.setY(y);
pointObj.setTheZ(z);
pointObj.setTheC(c);
pointObj.setTheT(t);
pointObj.setTransform(transform);
function ellipseObj = createEllipseObj(x, y, z, c, t, radX, radY, transform)
%ellipseObj = createEllipseObj(x, y, z, c, t, radX, radY, transform)

ellipseObj = pojos.EllipseData;
ellipseObj.setX(x);
ellipseObj.setY(y);
ellipseObj.setTheZ(z);
ellipseObj.setTheC(c);
ellipseObj.setTheT(t);
ellipseObj.setRadiusX(radX);
ellipseObj.setRadiusY(radY);
ellipseObj.setTransform(transform);
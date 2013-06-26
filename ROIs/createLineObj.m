function lineObj = createLineObj(points, z, c, t, transform)
%lineObj = createLineObj(points, z, c, t, transform)

lineObj = pojos.LineData;
lineObj.setPoints(points);
lineObj.setTheZ(z);
lineObj.setTheC(c);
lineObj.setTheT(t);
lineObj.setTransform(transform);
function rectObj = createRectObj(x, y, z, t, width, height)
%rectObj = createRectObj(x, y, z, c, t, width, height, transform)

rectObj = pojos.RectangleData;
rectObj.setX(x);
rectObj.setY(y);
rectObj.setZ(z);
%rectObj.setC(c);
rectObj.setT(t);
rectObj.setWidth(width);
rectObj.setHeight(height);
%rectObj.setTransform(transform);
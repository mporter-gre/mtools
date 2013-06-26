function [xInd yInd] = ellipseCoords(ellipseVec)

centreX = ellipseVec(1);
centreY = ellipseVec(2);
radiusX = ellipseVec(3)/2;
radiusY = ellipseVec(4)/2;
rotAngle = ellipseVec(5);

increments = 0:pi/800:2*pi;

xu = radiusX*cos(increments);
yv = radiusY*sin(increments);

xx = xu*cos(-rotAngle) - yv*sin(-rotAngle);
yy = xu*sin(-rotAngle) + yv*cos(-rotAngle);

xInd = centreX + xx;
yInd = centreY + yy;

end
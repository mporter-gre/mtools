function [xInd, yInd] = ellipseCoords(ellipseVec)

% Copyright (C) 2013-2014 University of Dundee & Open Microscopy Environment.
% All rights reserved.
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

centreX = ellipseVec(1);
centreY = ellipseVec(2);
radiusX = ellipseVec(3);
radiusY = ellipseVec(4);
rotAngle = ellipseVec(5);

increments = 0:pi/1600:2*pi;

xu = radiusX*cos(increments);
yv = radiusY*sin(increments);

xx = xu*cos(-rotAngle) - yv*sin(-rotAngle);
yy = xu*sin(-rotAngle) + yv*cos(-rotAngle);

xInd = centreX + xx;
yInd = centreY + yy;

end

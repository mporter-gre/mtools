function ellipseObj = createEllipseObj(x, y, z, c, t, radX, radY, transform)
%ellipseObj = createEllipseObj(x, y, z, c, t, radX, radY, transform)

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

ellipseObj = pojos.EllipseData;
ellipseObj.setX(x);
ellipseObj.setY(y);
ellipseObj.setTheZ(z);
ellipseObj.setTheC(c);
ellipseObj.setTheT(t);
ellipseObj.setRadiusX(radX);
ellipseObj.setRadiusY(radY);
ellipseObj.setTransform(transform);
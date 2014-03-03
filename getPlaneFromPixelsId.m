function plane = getPlaneFromPixelsId(pixelsId, z, c, t)

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

global gateway;



pixels = gateway.getPixels(pixelsId);
rawPlane = gateway.getPlane(pixelsId, z, c , t);
rawPlaneTypecast = typecastMatrix(rawPlane, char(pixels.getPixelsType.getValue.getValue));
plane2D = reshape(rawPlaneTypecast, pixels.getSizeX.getValue, pixels.getSizeY.getValue);
plane = swapbytes(plane2D');

clear('rawPlane');
clear('rawPlaneTypecast');
clear('plane2D');

end

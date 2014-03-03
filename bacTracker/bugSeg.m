function imgOut = bugSeg(img)

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
    
imgEdge = edge(img, 'sobel');
imgEdgeBWA = bwareaopen(imgEdge, 15);
imgEdgeBWAHull = bwconvhull(imgEdgeBWA, 'objects', 8);

[imgSeg2D minValue] = seg2D(double(img), 0, 0, 10);

combinedEdgeHullSeg = imgEdge + imgEdgeBWAHull + logical(imgSeg2D);
combinedEdgeHullSegAmp = combinedEdgeHullSeg;
combinedEdgeHullSegAmp(combinedEdgeHullSeg>0) = combinedEdgeHullSeg(combinedEdgeHullSeg>0)+1000;
[segBWL minValue] = seg2D(combinedEdgeHullSegAmp, 0, 0, 10);

bugProps = regionprops(segBWL, 'majoraxis', 'minoraxis', 'eccentricity', 'area');

objectValues = unique(segBWL(segBWL>0));
numObjects = length(objectValues);

for thisObject = 1:numObjects
    major = bugProps(thisObject).MajorAxisLength;
    minor = bugProps(thisObject).MinorAxisLength;
    eccen = bugProps(thisObject).Eccentricity;
    area = bugProps(thisObject).Area;
    if major == 0 || minor == 0 || eccen < 0.3 || area < 40
        thisObjVal = objectValues(thisObject);
        segBWL(segBWL==thisObjVal) = 0;
    end
end

imgOut = segBWL;
function sortedShapes = sortROIShapes(roiShapes, sorting)
%By default ROI shapes are returned sorted by id. Sort them into Z by doing
%sortedShapes = sortROIShapes(roiShapes, sorting), where sorting is string
%'byZ', or by T using ('byT'). Sort by one then the other with strings
%'byZbyT' or 'byTbyZ'

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

if strcmpi(sorting, 'byZ')
    theZs = [];
    numShapes = roiShapes.numShapes;
    for thisShape = 1:numShapes
        theZs(thisShape) = roiShapes.(['shape' num2str(thisShape)]).getTheZ.getValue;
    end
    [Zs idx] = sort(theZs);
    for thisShape = 1:numShapes
        thisIdx = idx(thisShape);
        sortedShapes.(['shape' num2str(thisShape)]) = roiShapes.(['shape' num2str(thisIdx)]);
    end
    sortedShapes.shapeType = roiShapes.shapeType;
    sortedShapes.numShapes = roiShapes.numShapes;
end

if strcmpi(sorting, 'byT')
    theTs = [];
    numShapes = roiShapes.numShapes;
    for thisShape = 1:numShapes
        theTs(thisShape) = roiShapes.(['shape' num2str(thisShape)]).getTheT.getValue;
    end
    [Ts idx] = sort(theTs);
    for thisShape = 1:numShapes
        thisIdx = idx(thisShape);
        sortedShapes.(['shape' num2str(thisShape)]) = roiShapes.(['shape' num2str(thisIdx)]);
    end
    sortedShapes.shapeType = roiShapes.shapeType;
    sortedShapes.numShapes = roiShapes.numShapes;
end

if strcmpi(sorting, 'byTbyZ')
    theTs = [];
    numShapes = roiShapes.numShapes;
    for thisShape = 1:numShapes
        theTZ(thisShape,1) = roiShapes.(['shape' num2str(thisShape)]).getTheT.getValue;
        theTZ(thisShape,2) = roiShapes.(['shape' num2str(thisShape)]).getTheZ.getValue;
    end
    [listItems, idx] = sortrows(theTZ, [1,2]);
    for thisShape = 1:numShapes
        thisIdx = idx(thisShape);
        sortedShapes.(['shape' num2str(thisShape)]) = roiShapes.(['shape' num2str(thisIdx)]);
    end
    sortedShapes.shapeType = roiShapes.shapeType;
    sortedShapes.numShapes = roiShapes.numShapes;
end

if strcmpi(sorting, 'byZbyT')
    theTs = [];
    numShapes = roiShapes.numShapes;
    for thisShape = 1:numShapes
        theZT(thisShape,1) = roiShapes.(['shape' num2str(thisShape)]).getTheT.getValue;
        theZT(thisShape,2) = roiShapes.(['shape' num2str(thisShape)]).getTheZ.getValue;
    end
    [listItems, idx] = sortrows(theZT, [2,1]);
    for thisShape = 1:numShapes
        thisIdx = idx(thisShape);
        sortedShapes.(['shape' num2str(thisShape)]) = roiShapes.(['shape' num2str(thisIdx)]);
    end
    sortedShapes.shapeType = roiShapes.shapeType;
    sortedShapes.numShapes = roiShapes.numShapes;
end


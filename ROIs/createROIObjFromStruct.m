function ROI = createROIObjFromStruct(roiStruct)
%Re-build an ROI from a struct generated from getROIsFromImageId.m
%Do ROI = getROIsFromImageId(roiStruct)

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


numShapes = roiStruct.numShapes;
shapeType = roiStruct.shapeType;

ROI = omero.model.RoiI;

for thisShape = 1:numShapes
    
    oldShape = roiStruct.(['shape' num2str(thisShape)]);
    
    switch shapeType
        case 'rect'
            newShape = createRectangle(oldShape.getX.getValue, oldShape.getY.getValue, oldShape.getWidth.getValue, oldShape.getHeight.getValue);
            
        case 'ellipse'
            newShape = createEllipse(oldShape.getCx.getValue, oldShape.getCy.getValue, oldShape.getRx.getValue, oldShape.getRy.getValue);
            
        case 'line'
            newShape = createLine([oldShape.getX1.getValue, oldShape.getX2.getValue], [oldShape.getY1.getValue, oldShape.getY2.getValue]);
            
        case 'point'
            newShape = createPoint(oldShape.getCx.getValue, oldShape.getCy.getValue);
    end
    
    Z = oldShape.getTheZ.getValue;
    %C = oldShape.getTheC.getValue;
    T = oldShape.getTheT.getValue;
    tform = oldShape.getTransform;
    
    textVal = oldShape.getTextValue;
    if ~isempty(textVal)
        newShape.setTextValue(textVal);
    end
    %Copy the contents of the transform from the old shape, if any.
    if ~isempty(tform)
        newTform = omero.model.AffineTransformI;
        newTform.setA00(tform.getA00);
        newTform.setA10(tform.getA10);
        newTform.setA01(tform.getA01);
        newTform.setA11(tform.getA11);
        newTform.setA02(tform.getA02);
        newTform.setA12(tform.getA12);
        newShape.setTransform(newTform);
    end
    newShape.setTheZ(rint(Z));
    %newShape.setTheC(C);
    newShape.setTheT(rint(T));
    
    ROI.addShape(newShape);
    
end



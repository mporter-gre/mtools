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
            newShape = createEllipse(oldShape.getCx.getValue, oldShape.Cy.getValue, oldShape.Rx.getValue, oldShape.Ry.getValue);
            
        case 'line'
            newShape = createEllipse([oldShape.getX1.getValue, oldShape.X2.getValue], [oldShape.Y1.getValue, oldShape.Y2.getValue]);
            
        case 'point'
            newShape = createEllipse(oldShape.getCx.getValue, oldShape.Cy.getValue);
    end
    
    Z = oldShape.getTheZ.getValue;
    C = oldShape.getTheC.getValue;
    T = oldShape.getTheT.getValue;
    
    newShape.setTheZ(Z);
    newShape.setTheC(C);
    newShape.setTheT(T);
    
    ROI.addShape(newShape);
    
end



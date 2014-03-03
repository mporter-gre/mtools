function [meanConstants constantShapeIdx] = getAquisitionBleachingConstant(constantFiles, constantPaths, credentials)

global gateway;

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

%Let the user know what's going on...

scrsz = get(0,'ScreenSize');
fig1 = figure('Name','Processing...','NumberTitle','off','MenuBar','none','Position',[(scrsz(3)/2)-150 (scrsz(4)/2)-80 300 80]);
conditionText = uicontrol(fig1, 'Style', 'text', 'String', 'Calculating aquisition photobleaching factor', 'Position', [25 60 250 15]);
drawnow;

if iscell(constantFiles)
    numFiles = length(constantFiles);
else
    numFiles = 1;
end
constants = [];
constants{1} = [];
for thisFile = 1:numFiles
    fileText = uicontrol(fig1, 'Style', 'text', 'String', ['ROI file ', num2str(thisFile), ' of ' num2str(numFiles)], 'Position', [25 35 250 15]);
    drawnow;
    if iscell(constantFiles)
        [constantROIIdx{thisFile} constantShapeIdx{thisFile}] = readEllipseROIs([constantPaths constantFiles{thisFile}]);
        [pixelsId imageName] = getPixIdFromROIFile([constantPaths constantFiles{thisFile}], credentials{1}, credentials{3});
    else
        [constantROIIdx{thisFile} constantShapeIdx{thisFile}] = readEllipseROIs([constantPaths constantFiles]);
        [pixelsId imageName] = getPixIdFromROIFile([constantPaths constantFiles], credentials{1}, credentials{3});
    end
    pixelsId = str2double(pixelsId);
    pixels = gateway.getPixels(pixelsId);
    maxX = pixels.getSizeX.getValue;
    maxY = pixels.getSizeY.getValue;
    numT = length(unique(constantShapeIdx{thisFile}{1}.T));
    actualTList = unique(constantShapeIdx{thisFile}{1}.T);
    for thisT = 1:numT
        if length(constants) < thisT
            constants{thisT} = [];
        end
        thisPlane = getPlaneFromPixelsId(pixelsId, 0, 0, actualTList(thisT));
        numEllipses = length(constantROIIdx{thisFile});
        for thisEllipse = 1:numEllipses
            if strcmpi(constantShapeIdx{thisFile}{thisEllipse}.ROIName, 'Constant')
                constantIdx = thisEllipse;
                constantMask = zeros(maxY, maxX);
                [maskLocationsX maskLocationsY] = ellipseCoords([constantShapeIdx{thisFile}{thisEllipse}.X(thisT) constantShapeIdx{thisFile}{thisEllipse}.Y(thisT) constantShapeIdx{thisFile}{thisEllipse}.Width(thisT) constantShapeIdx{thisFile}{thisEllipse}.Height(thisT) constantShapeIdx{thisFile}{thisEllipse}.Angle(thisT)]);
                mapX = round(sub2ind([maxY maxX], maskLocationsX));
                mapY = round(sub2ind([maxY maxX], maskLocationsY));
                for thisLocation = 1:length(mapX)
                    constantMask(mapY(thisLocation), mapX(thisLocation)) = 1;
                end
                constantMaskFilled = imfill(constantMask, 'holes');
                constantROI = find(constantMaskFilled);
                constantShapeIdx{thisFile}{thisEllipse}.constantData(thisT) = mean(thisPlane(constantROI));
            end
            %for thisT = 1:length(unique(constantShapeIdx{thisFile}{thisEllipse}.T))
            %disp([thisFile thisEllipse thisT]);
                constantShapeIdx{thisFile}{thisEllipse}.constantNorm(thisT) = constantShapeIdx{thisFile}{thisEllipse}.constantData(thisT) / max(constantShapeIdx{thisFile}{thisEllipse}.constantData(:));
                constants{thisT} = [constants{thisT} constantShapeIdx{thisFile}{thisEllipse}.constantNorm(thisT)];
            %end
        end
    end
end

for thisT = 1:length(constants)
    meanConstants(thisT) = mean(constants{thisT});
end

close(fig1);

end

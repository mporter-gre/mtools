function [roiShapes indices] = FRAPMeasure(theImages, imageId, imageName, roiShapes, datasetName, pixels)
%Author Michael Porter

% Copyright (C) 2009-2014 University of Dundee.
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

global session;



pixelsId = pixels.getId.getValue;
maxX = pixels.getSizeX.getValue;
maxY = pixels.getSizeY.getValue;
fullT = pixels.getSizeT.getValue;

%This FRAP is done using 4 named ROI's that are propogated along all the
%time-points of the event to be measured. They are 1.FRAP, 2.Ref, 3.Base
%and 4.Whole. The average intensity of each ROI at each time-point must be
%tabulated, then calculations done to get FRAP-Pre, Ref-Pre, Whole-Pre,
%Whole-Post, FullRange, GapRatio. All of these are then used to find the
%normalised FRAP intensity, corrected for aquisition bleaching.

%Get the location and dimensions of each ROI
includeT = [];
excludeT = [];
numROI = length(roiShapes);
for thisT = 1:fullT
    thisPlane = getPlane(session, imageId, 0, 0, thisT-1);
    for thisROI = 1:numROI
        if strcmpi(char(roiShapes{thisROI}.shape1.getTextValue.getValue.getBytes'), 'FRAP')
            numShapes = roiShapes{thisROI}.numShapes;
            for thisShape = 1:numShapes
                TForThisShape = roiShapes{thisROI}.(['shape' num2str(thisShape)]).getTheT.getValue;
                if thisT == TForThisShape + 1
                    break;
                end
            end
            if thisT ~= TForThisShape + 1
                excludeT = [excludeT thisT];
            else
                includeT = [includeT thisT];
            end
            frapIdx = thisROI;
            frapMask = zeros(maxY, maxX);
            try
                cx = round(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getCx.getValue)+1;
                cy = round(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getCy.getValue)+1;
                rx = round(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getRx.getValue);
                ry = round(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getRy.getValue);

                [maskLocationsX maskLocationsY] = ellipseCoords([cx cy rx ry 0]); % roiShapes{thisROI}.(['shape' num2str(thisT)]).getAngle.getValue]);
            catch
                excludeT = [excludeT thisT];
                continue;
            end
            mapX = round(sub2ind([maxY maxX], maskLocationsX));
            mapY = round(sub2ind([maxY maxX], maskLocationsY));
            for thisLocation = 1:length(mapX)
                frapMask(mapY(thisLocation), mapX(thisLocation)) = 1;
            end
            frapMaskFilled = imfill(frapMask, 'holes');
            frapROI = find(frapMaskFilled);
            roiShapes{thisROI}.frapData(thisT) = mean(thisPlane(frapROI));
            planeInfo = getPlaneInfo(session, theImages, 0, 0, thisT-1);
            roiShapes{thisROI}.timestamp(thisT) = planeInfo.getDeltaT.getValue;
        end

        if strcmpi(char(roiShapes{thisROI}.shape1.getTextValue.getValue.getBytes'), 'Base')
            numShapes = roiShapes{thisROI}.numShapes;
            for thisShape = 1:numShapes
                TForThisShape = roiShapes{thisROI}.(['shape' num2str(thisShape)]).getTheT.getValue;
                if thisT == TForThisShape + 1
                    break;
                end
            end
            if thisT ~= TForThisShape + 1
                excludeT = [excludeT thisT];
            else
                includeT = [includeT thisT];
            end
            baseIdx = thisROI;
            baseMask = zeros(maxY, maxX);
            try
                cx = round(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getCx.getValue)+1;
                cy = round(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getCy.getValue)+1;
                rx = round(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getRx.getValue);
                ry = round(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getRy.getValue);
                transform = char(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getTransform.getValue.getBytes');
                if ~strcmp(transform, 'none')
                    if strncmp(transform, 'trans', 5)
                        closeBracket = findstr(transform, ')');
                        openBracket = findstr(transform, '(');
                        transformData = transform(openBracket+1:closeBracket-1);
                        spaceChar = findstr(transformData, ' ');
                        if isempty(spaceChar)
                            firstTranslate = str2double(transformData(1:end));
                            secondTranslate = 0;
                        else
                            firstTranslate = str2double(transformData(1:spaceChar-1));
                            secondTranslate = str2double(transformData(spaceChar+1:end));
                        end
                        cx = cx + firstTranslate;
                        cy = cy + secondTranslate;
                    else
                    end
                end
                [maskLocationsX maskLocationsY] = ellipseCoords([cx cy rx ry 0]);

            catch
                excludeT = [excludeT thisT];
                continue;
            end
            mapX = round(sub2ind([maxY maxX], maskLocationsX));
            mapY = round(sub2ind([maxY maxX], maskLocationsY));
            for thisLocation = 1:length(mapX)
                baseMask(mapY(thisLocation), mapX(thisLocation)) = 1;
            end
            baseMaskFilled = imfill(baseMask, 'holes');
            baseROI = find(baseMaskFilled);
            roiShapes{thisROI}.baseData(thisT) = mean(thisPlane(baseROI));
        end
        
        if strcmpi(char(roiShapes{thisROI}.shape1.getTextValue.getValue.getBytes'), 'Whole')
            numShapes = roiShapes{thisROI}.numShapes;
            for thisShape = 1:numShapes
                TForThisShape = roiShapes{thisROI}.(['shape' num2str(thisShape)]).getTheT.getValue;
                if thisT == TForThisShape + 1
                    break;
                end
            end
            if thisT ~= TForThisShape + 1
                excludeT = [excludeT thisT];
            else
                includeT = [includeT thisT];
            end
            wholeIdx = thisROI;
            wholeMask = zeros(maxY, maxX);
            try
                cx = round(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getCx.getValue)+1;
                cy = round(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getCy.getValue)+1;
                rx = round(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getRx.getValue);
                ry = round(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getRy.getValue);
                transform = char(roiShapes{thisROI}.(['shape' num2str(thisShape)]).getTransform.getValue.getBytes');
                if ~strcmp(transform, 'none')
                    if strncmp(transform, 'trans', 5)
                        closeBracket = findstr(transform, ')');
                        openBracket = findstr(transform, '(');
                        transformData = transform(openBracket+1:closeBracket-1);
                        spaceChar = findstr(transformData, ' ');
                        if isempty(spaceChar)
                            firstTranslate = str2double(transformData(1:end));
                            secondTranslate = 0;
                        else
                            firstTranslate = str2double(transformData(1:spaceChar-1));
                            secondTranslate = str2double(transformData(spaceChar+1:end));
                        end
                        cx = cx + firstTranslate;
                        cy = cy + secondTranslate;
                    else
                    end
                end
                [maskLocationsX maskLocationsY] = ellipseCoords([cx cy rx ry 0]);

            catch
                excludeT = [excludeT thisT];
                continue;
            end
            mapX = round(sub2ind([maxY maxX], maskLocationsX));
            mapY = round(sub2ind([maxY maxX], maskLocationsY));
            for thisLocation = 1:length(mapX)
                wholeMask(mapY(thisLocation), mapX(thisLocation)) = 1;
            end
            wholeMaskFilled = imfill(wholeMask, 'holes');
            wholeROI = find(wholeMaskFilled);
            roiShapes{thisROI}.wholeData(thisT) = mean(thisPlane(wholeROI));
        end
    end
end

includeT = unique(includeT);
excludeT = unique(excludeT);
correctT = setdiff(includeT, excludeT);

roiShapes{baseIdx}.baseData = roiShapes{baseIdx}.baseData(correctT);
roiShapes{wholeIdx}.wholeData = roiShapes{wholeIdx}.wholeData(correctT);
roiShapes{frapIdx}.frapData = roiShapes{frapIdx}.frapData(correctT);
roiShapes{frapIdx}.correctT = correctT;
fullT = length(correctT);

indices.frapIdx = frapIdx;
indices.baseIdx = baseIdx;
indices.wholeIdx = wholeIdx;

frapBleach = min(roiShapes{frapIdx}.frapData);
tBleach = find(roiShapes{frapIdx}.frapData == frapBleach);
preBleachRange = 1:tBleach-1;

frapPre = sum(roiShapes{frapIdx}.frapData(preBleachRange) - roiShapes{baseIdx}.baseData(preBleachRange)) / length(preBleachRange);
wholePre = sum(roiShapes{wholeIdx}.wholeData(preBleachRange) - roiShapes{baseIdx}.baseData(preBleachRange)) / length(preBleachRange);

for thisT = 1:fullT
    roiShapes{frapIdx}.frapNormCorr(thisT) = (wholePre / (roiShapes{wholeIdx}.wholeData(thisT) - roiShapes{baseIdx}.baseData(thisT))) * ((roiShapes{frapIdx}.frapData(thisT) - roiShapes{baseIdx}.baseData(thisT)) / frapPre);
end

roiShapes{frapIdx}.frapBleachNormCorr = min(roiShapes{frapIdx}.frapNormCorr);
roiShapes{frapIdx}.plateauNormCorr = mean(roiShapes{frapIdx}.frapNormCorr(end-5:end));
roiShapes{frapIdx}.plateauMinusBleachNormCorr = roiShapes{frapIdx}.plateauNormCorr - roiShapes{frapIdx}.frapBleachNormCorr;
roiShapes{frapIdx}.mobileFraction = roiShapes{frapIdx}.plateauMinusBleachNormCorr / (1 - roiShapes{frapIdx}.frapBleachNormCorr);
roiShapes{frapIdx}.immobileFraction = 1- roiShapes{frapIdx}.mobileFraction;
roiShapes{frapIdx}.halfMaxNormCorr = (roiShapes{frapIdx}.plateauMinusBleachNormCorr/2) + roiShapes{frapIdx}.frapBleachNormCorr;
roiShapes{frapIdx}.name = imageName;

%Define the T-half for this FRAP. In place of fitting an exact curve to the
%data, find the two time-points that the half Max of recovery sits between
%and find the T-half using a linear approximation between these two points.
%The T-half is this solved for halfMaxNormCorr - timestamp(tBleach)
for thisVal = tBleach:fullT
    if roiShapes{frapIdx}.halfMaxNormCorr < roiShapes{frapIdx}.frapNormCorr(thisVal)
        break;
    end
end
y1 = roiShapes{frapIdx}.frapNormCorr(thisVal-1);
y2 = roiShapes{frapIdx}.frapNormCorr(thisVal);
x1 = roiShapes{frapIdx}.timestamp(thisVal-1);
x2 = roiShapes{frapIdx}.timestamp(thisVal);
m1 = (y2-y1)/(x2-x1); %Gradient of the line
c1 = y1-m1*x1;  %Y-intercept
roiShapes{frapIdx}.Thalf = (roiShapes{frapIdx}.halfMaxNormCorr-c1)/m1-roiShapes{frapIdx}.timestamp(tBleach);

end

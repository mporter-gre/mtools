function [roiIdx roishapeIdx indices] = FLIPMeasure(filepath, filename, credentials, fileNum, numFiles, conditionNum, numConditions, meanConstants)
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

global gateway;

badImage = 0;
try
    [roiIdx roishapeIdx] = readEllipseROIs([filepath filename]);
catch
    helpdlg(['There was a problem opening the ROI file ', filename, ', please check this file and retry it.', 'Problem']);
    set(handles.beginAnalysisButton, 'Enable', 'on');
    badImage = 1;
    return;
end
% try
%     [client, session, gateway] = gatewayConnect(credentials{1}, credentials{2}, credentials{3});
% catch
%     helpdlg('Could not log you on to the server. Check your username and password');
%     set(handles.beginAnalysisButton, 'Enable', 'on');
%     badCredentials = 1;
%     return;
% end
try
    [pixelsId, imageName] = getPixIdFromROIFile([filepath filename], credentials{1}, credentials{3});
    [imageName remain] = strtok(filename, '.');
catch
    helpdlg('Reference to ', filename, ' could not be found in your roiFileMap.xml. Please re-save the ROI file in Insight and try analysis again.');
    set(handles.beginAnalysisButton, 'Enable', 'on');
    badImage = 1;
    return;
end

%Let the user know what's going on...
scrsz = get(0,'ScreenSize');
fig1 = figure('Name','Processing...','NumberTitle','off','MenuBar','none','Position',[(scrsz(3)/2)-150 (scrsz(4)/2)-80 300 80]);
conditionText = uicontrol(fig1, 'Style', 'text', 'String', ['Condition ', num2str(conditionNum), ' of ' num2str(numConditions)], 'Position', [25 60 250 15]);
fileText = uicontrol(fig1, 'Style', 'text', 'String', ['ROI file ', num2str(fileNum), ' of ' num2str(numFiles)], 'Position', [25 35 250 15]);
drawnow;


numROI = length(roiIdx);
pixelsId = str2double(pixelsId);
pixels = gateway.getPixels(pixelsId);
imageId = pixels.getImage.getId.getValue;
maxX = pixels.getSizeX.getValue;
maxY = pixels.getSizeY.getValue;
fullT = [];
for thisROI = 1:numROI
    fullT = [fullT length(roishapeIdx{1}.T)];
end
fullT = max(fullT);
planeInfoForPixels = gateway.findAllByQuery(['select info from PlaneInfo as info where pixels.id = ', num2str(pixelsId), ' and theZ = 0 and theC = 0 order by deltat']);

%This FLIP is done using 4 named ROI's that are propogated along all the
%time-points of the event to be measured. They are 1.FLIP, 2.Ref, 3.Base
%and 4.Constant. The 'Constant' ROIs will be read from separate movies and 
%analysed by getAquisitionBleachingConstant.m before running this script.
%All of these are then used to find the normalised FLIP intensity, 
%corrected for aquisition bleaching. There can be mulpitle FLIP ROIs per
%movie.

%Get the location and dimensions of each ROI
flipIdx = [];
includeT = [];
excludeT = [];
for thisT = 1:fullT
    thisPlane = getPlaneFromPixelsId(pixelsId, 0, 0, thisT-1);
    for thisROI = 1:numROI
        if ~isempty(findstr(lower(roishapeIdx{thisROI}.ROIName), 'flip'));
            flipIdx = [flipIdx thisROI];
            flipMask = zeros(maxY, maxX);
            try
                [maskLocationsX maskLocationsY] = ellipseCoords([roishapeIdx{thisROI}.X(thisT)+1 roishapeIdx{thisROI}.Y(thisT)+1 roishapeIdx{thisROI}.Width(thisT) roishapeIdx{thisROI}.Height(thisT) roishapeIdx{thisROI}.Angle(thisT)]);
            catch
                excludeT = [excludeT thisT];
                continue;
            end
            includeT = [includeT thisT];
            mapX = round(sub2ind([maxY maxX], maskLocationsX));
            mapY = round(sub2ind([maxY maxX], maskLocationsY));
            for thisLocation = 1:length(mapX)
                flipMask(mapY(thisLocation), mapX(thisLocation)) = 1;
            end
            flipMaskFilled = imfill(flipMask, 'holes');
            flipROI = find(flipMaskFilled);
            roishapeIdx{thisROI}.flipData(thisT) = mean(thisPlane(flipROI));
            roishapeIdx{thisROI}.timestamp(thisT) = planeInfoForPixels.get(roishapeIdx{thisROI}.T(thisT)).getDeltaT.getValue;
        end
        if strcmpi(roishapeIdx{thisROI}.ROIName, 'Ref')
            refIdx = thisROI;
            refMask = zeros(maxY, maxX);
            try
                [maskLocationsX maskLocationsY] = ellipseCoords([roishapeIdx{thisROI}.X(thisT)+1 roishapeIdx{thisROI}.Y(thisT)+1 roishapeIdx{thisROI}.Width(thisT) roishapeIdx{thisROI}.Height(thisT) roishapeIdx{thisROI}.Angle(thisT)]);
            catch
                excludeT = [excludeT thisT];
                continue
            end
            includeT = [includeT thisT];
            mapX = round(sub2ind([maxY maxX], maskLocationsX));
            mapY = round(sub2ind([maxY maxX], maskLocationsY));
            for thisLocation = 1:length(mapX)
                refMask(mapY(thisLocation), mapX(thisLocation)) = 1;
            end
            refMaskFilled = imfill(refMask, 'holes');
            refROI = find(refMaskFilled);
            roishapeIdx{thisROI}.refData(thisT) = mean(thisPlane(refROI));
        end
        if strcmpi(roishapeIdx{thisROI}.ROIName, 'Base')
            baseIdx = thisROI;
            baseMask = zeros(maxY, maxX);
            try
                [maskLocationsX maskLocationsY] = ellipseCoords([roishapeIdx{thisROI}.X(thisT)+1 roishapeIdx{thisROI}.Y(thisT)+1 roishapeIdx{thisROI}.Width(thisT) roishapeIdx{thisROI}.Height(thisT) roishapeIdx{thisROI}.Angle(thisT)]);
            catch
                excludeT = [excludeT thisT];
                continue;
            end
            includeT = [includeT thisT];
            mapX = round(sub2ind([maxY maxX], maskLocationsX));
            mapY = round(sub2ind([maxY maxX], maskLocationsY));
            for thisLocation = 1:length(mapX)
                baseMask(mapY(thisLocation), mapX(thisLocation)) = 1;
            end
            baseMaskFilled = imfill(baseMask, 'holes');
            baseROI = find(baseMaskFilled);
            roishapeIdx{thisROI}.baseData(thisT) = mean(thisPlane(baseROI));
        end
    end
end
includeT = unique(includeT);
excludeT = unique(excludeT);
correctT = setdiff(includeT, excludeT);
roishapeIdx{refIdx}.refData = roishapeIdx{refIdx}.refData(correctT);
roishapeIdx{baseIdx}.baseData = roishapeIdx{baseIdx}.baseData(correctT);
for thisFlip = 1:length(flipIdx)
    roishapeIdx{flipIdx(thisFlip)}.flipData = roishapeIdx{flipIdx(thisFlip)}.flipData(correctT);
end
meanConstants = meanConstants(correctT);

%Check that all the ROIs are present and correct.
if ~flipIdx
    msgbox(['Could not find any "FLIP" ROIs for image ', imageName]);
    badImage = 1;
    return;
end
if ~refIdx
    msgbox(['Could not find the "REF" ROI for image ', imageName]);
    badImage = 1;
    return;
end
if ~baseIdx
    msgbox(['Could not find the "BASE" ROI for image ', imageName]);
    badImage = 1;
    return;
end
flipIdx = unique(flipIdx);
indices.flipIdx = flipIdx;
indices.refIdx = refIdx;
indices.baseIdx = baseIdx;

flipBkg = roishapeIdx{refIdx}.refData - roishapeIdx{baseIdx}.baseData;
flipBkgCorr = (flipBkg .* meanConstants);
roishapeIdx{refIdx}.flipBkgNormCorr = flipBkgCorr / max(flipBkgCorr);
for thisFlip = flipIdx
    flipMinusBkg = roishapeIdx{thisFlip}.flipData - flipBkg;
    flipMinusBkgCorr = flipMinusBkg .* meanConstants;
    roishapeIdx{thisFlip}.flipNormCorr = flipMinusBkgCorr / max(flipMinusBkgCorr);
    roishapeIdx{thisFlip}.imageName = imageName;
end

close(fig1);

end

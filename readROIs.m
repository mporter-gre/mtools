function [roiIdx roishapeIdx] = readROIs(roifile)
%Point this to an ROI file to read out the ROI and ROIShapes in it. Will
%return roiIdx containing the indexes of the true ROIs and the T, Z, X, Y,
%Width and Height information for each ROI Shape withing each ROI.
%
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

%[filename filepath] = uigetfile('*.xml');
%Read the ROI xml file into a Matlab struct
xmlStruct = xml2struct(roifile);

%Get the ROI elements from the struct and store their index in roiIdx. Use
%these to get the roiShapes from the struct too.
roiIdx = [];
thisroishapeIdx = [];
counter = 1;
for i = 1:length(xmlStruct.children)
    if strcmp(xmlStruct.children(i).name, 'roi')
        roiIdx = [roiIdx i];
        numROIShapes = length(xmlStruct.children(i).children);
        for j = 1:numROIShapes
            if strcmp(xmlStruct.children(i).children(j).name, 'roishape')
                thisroishapeIdx = [thisroishapeIdx j];
            end
        end
        roishapeIdx{counter}.R = thisroishapeIdx;
        counter = counter + 1;
        thisroishapeIdx = [];
    end
end

%For each roishape fetch out the Z and T information and store it in the
%same struct as the roishape.R (R = ROI) index. Then dig deeper and get the
%svg data for the x and y (top?) corner of the ROI, and the width and
%height.
thisroishapeT = [];
thisroishapeZ = [];
thisroishapeX = [];
thisroishapeY = [];
thisroishapeWidth = [];
thisroishapeHeight = [];
for thisROIIdx = 1:length(roishapeIdx)
    for thisROIShapeIdx = 1:length(roishapeIdx{thisROIIdx}.R)
        thisroishapeT = [thisroishapeT str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).attributes(1).value)];
        thisroishapeZ = [thisroishapeZ str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).attributes(2).value)];
        
        for thisSVG = 1:length(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children)
            if strcmp(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).name, 'svg')
                for thisShape = 1:length(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children)
                    if strcmp(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).name, 'rect')
                        for thisShapeAttr = 1:length(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).attributes)
                            if strcmp(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).attributes(thisShapeAttr).name, 'x')
                                thisroishapeX = [thisroishapeX str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).attributes(thisShapeAttr).value)];
                            end
                            if strcmp(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).attributes(thisShapeAttr).name, 'y')
                                thisroishapeY = [thisroishapeY str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).attributes(thisShapeAttr).value)];
                            end
                            if strcmp(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).attributes(thisShapeAttr).name, 'width')
                                thisroishapeWidth = [thisroishapeWidth str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).attributes(thisShapeAttr).value)];
                            end
                            if strcmp(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).attributes(thisShapeAttr).name, 'height')
                                thisroishapeHeight = [thisroishapeHeight str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).attributes(thisShapeAttr).value)];
                            end
                        end
                    end
                end
            end
        end       
    end
    roishapeIdx{thisROIIdx}.T = thisroishapeT;
    roishapeIdx{thisROIIdx}.Z = thisroishapeZ;
    roishapeIdx{thisROIIdx}.X = thisroishapeX;
    roishapeIdx{thisROIIdx}.Y = thisroishapeY;
    roishapeIdx{thisROIIdx}.Width = thisroishapeWidth;
    roishapeIdx{thisROIIdx}.Height = thisroishapeHeight;
    thisroishapeT = [];
    thisroishapeZ = [];
    thisroishapeX = [];
    thisroishapeY = [];
    thisroishapeWidth = [];
    thisroishapeHeight = [];
end

clear xmlStruct;
        

end

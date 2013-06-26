function [roiIdx roishapeIdx] = readLineROIs(roifile)
%Point this to an ROI file to read out the ROI and ROIShapes in it. Will
%return roiIdx containing the indexes of the true ROIs and the T, Z, X, Y,
%Width and Height information for each ROI Shape withing each ROI.
%
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

%[filename filepath] = uigetfile('*.xml');
%Read the ROI xml file into a Matlab struct
xmlStruct = xml2struct(roifile);

%Get the ROI elements from the struct and store their index in roiIdx. Use
%these to get the roiShapes from the struct too.
roiIdx = [];
thisroishapeIdx = [];
counter = 1;
for i = 1:length(xmlStruct.children)
    if strcmpi(xmlStruct.children(i).name, 'roi')
        roiIdx = [roiIdx i];
        numROIShapes = length(xmlStruct.children(i).children);
        for j = 1:numROIShapes
            if strcmpi(xmlStruct.children(i).children(j).name, 'roishape')
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
%svg data for the x and y centres of the ROI, and the width and
%height. Since this is line we also need the angle, length and the
%name of the ROI.
thisroishapeT = [];
thisroishapeZ = [];
thisroishapeStartX = [];
thisroishapeStartY = [];
thisroishapeEndX = [];
thisroishapeEndY = [];
thisroishapeName = [];
thisroishapeAngle = [];
thisroishapeLength = [];
for thisROIIdx = 1:length(roishapeIdx)
    for thisROIShapeIdx = 1:length(roishapeIdx{thisROIIdx}.R)
        thisroishapeT = [thisroishapeT str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).attributes(1).value)];
        thisroishapeZ = [thisroishapeZ str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).attributes(2).value)];
        %Check if the ROI is an line.
        for thisSVG = 1:length(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children)
            if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).name, 'svg')
                for thisShape = 1:length(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children)
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).name, 'line')
                        roishapeIdx{thisROIIdx}.shape = 'line';
                    end
                end
            end
        end

        %Find the name of the ROI, measurementAngle, measurementLength and start/end stroke points from the Annotation section of the xml.
        for this3rdGen = 1:length(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children)
            if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).name, 'annotation')
                for thisAnnotation = 1:length(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children)
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).name, 'basicTextAnnotation')
                        thisroishapeName = xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).attributes(2).value;
                        if ~strcmp(thisroishapeName, ' ')
                            roishapeIdx{thisROIIdx}.ROIName = thisroishapeName;
                        end
                    end
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).name, 'measurementAngle')
                        thisroishapeAngle = str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).children(2).attributes(2).value);
                    end
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).name, 'measurementLength')
                        thisroishapeLength = str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).children(2).attributes(2).value);
                    end
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).name, 'measurementStartPointX')
                        thisroishapeStartX = str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).attributes(2).value);
                    end
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).name, 'measurementEndPointX')
                        thisroishapeEndX = str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).attributes(2).value);
                    end
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).name, 'measurementStartPointY')
                        thisroishapeStartY = str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).attributes(2).value);
                    end
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).name, 'measurementEndPointY')
                        thisroishapeEndY = str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).attributes(2).value);
                    end
                end
            end
        end

        roishapeIdx{thisROIIdx}.T(thisROIShapeIdx) = thisroishapeT;
        roishapeIdx{thisROIIdx}.Z(thisROIShapeIdx) = thisroishapeZ;
        roishapeIdx{thisROIIdx}.startX(thisROIShapeIdx) = thisroishapeStartX;
        roishapeIdx{thisROIIdx}.startY(thisROIShapeIdx) = thisroishapeStartY;
        roishapeIdx{thisROIIdx}.endX(thisROIShapeIdx) = thisroishapeEndX;
        roishapeIdx{thisROIIdx}.endY(thisROIShapeIdx) = thisroishapeEndY;
        roishapeIdx{thisROIIdx}.Angle(thisROIShapeIdx) = thisroishapeAngle;
        roishapeIdx{thisROIIdx}.Length(thisROIShapeIdx) = thisroishapeLength;

        thisroishapeT = [];
        thisroishapeZ = [];
        thisroishapeStartX = [];
        thisroishapeStartY = [];
        thisroishapeEndX = [];
        thisroishapeEndY = [];
    end


end

end
function [roiIdx roishapeIdx xmlStruct] = readEllipseROIs(roifile)
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
%height. Since this is ellipse we also need the angle of rotation and the
%name of the ROI.
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
        %Check if the ROI is an ellipse and get the rotation angle from the
        %transform if it exists. From the SVG section of the xml. 
        for thisSVG = 1:length(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children)
            if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).name, 'svg')
                for thisShape = 1:length(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children)
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).name, 'ellipse')
                        roishapeIdx{thisROIIdx}.shape = 'ellipse';
                        for thisShapeAttr = 1:length(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).attributes)
                            if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).attributes(thisShapeAttr).name, 'transform')
                                thisroishapeTransformMatrix = xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(thisSVG).children(thisShape).attributes(thisShapeAttr).value;
                                partText = thisroishapeTransformMatrix(8:end);
                                [firstPart theRest] = strtok(partText);
                                if str2double(firstPart) >0 && str2double(firstPart) <1
                                    rotAngle = acosd(str2double(firstPart)); %Get the angle in degress by taking the inverse cos (acosd) of the first part of the transformation matrix.
                                    continue;
                                else
                                    [firstPart theRest] = strtok(theRest);
                                    if str2double(firstPart) >0 && str2double(firstPart) <1
                                        rotAngle = asind(str2double(firstPart)); %Get the angle in degress by taking the inverse sin (asind) of the second part of the transformation matrix.
                                        continue;

                                    else
                                        [firstPart theRest] = strtok(theRest);
                                        if str2double(firstPart) >0 && str2double(firstPart) <1
                                            rotAngle = -asind(str2double(firstPart)); %Get the angle in degress by taking the negative inverse sin (-asind) of the third part of the transformation matrix.
                                            continue;

                                        else
                                            [firstPart theRest] = strtok(theRest, ')');
                                            if str2double(firstPart) >0 && str2double(firstPart) <1
                                                rotAngle = acosd(str2double(firstPart)); %Get the angle in degress by taking the inverse cos (acosd) of the forth part of the transformation matrix.
                                                continue;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        %Find the name of the ROI and the cx, cy etc. from the Annotation section of the xml.
        for this3rdGen = 1:length(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children)
            if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).name, 'annotation')
                for thisAnnotation = 1:length(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children)
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).name, 'basicTextAnnotation')
                        thisroishapeName = xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).attributes(2).value;
                        if ~strcmp(thisroishapeName, ' ')
                            roishapeIdx{thisROIIdx}.ROIName = thisroishapeName;
                        end
                    end
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).name, 'measurementCentreX')
                        thisroishapeX = str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).attributes(2).value);
                    end
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).name, 'measurementCentreY')
                        thisroishapeY = str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).attributes(2).value);
                    end
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).name, 'measurementWidth')
                        thisroishapeWidth = str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).attributes(2).value);
                    end
                    if strcmpi(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).name, 'measurementHeight')
                        thisroishapeHeight = str2double(xmlStruct.children(roiIdx(thisROIIdx)).children(roishapeIdx{thisROIIdx}.R(thisROIShapeIdx)).children(this3rdGen).children(thisAnnotation).attributes(2).value);
                    end
                end
            end
        end

        roishapeIdx{thisROIIdx}.T(thisROIShapeIdx) = thisroishapeT;
        roishapeIdx{thisROIIdx}.Z(thisROIShapeIdx) = thisroishapeZ;
        roishapeIdx{thisROIIdx}.X(thisROIShapeIdx) = thisroishapeX;
        roishapeIdx{thisROIIdx}.Y(thisROIShapeIdx) = thisroishapeY;
        roishapeIdx{thisROIIdx}.Width(thisROIShapeIdx) = thisroishapeWidth;
        roishapeIdx{thisROIIdx}.Height(thisROIShapeIdx) = thisroishapeHeight;
        if exist('rotAngle') %If the ellipse is circular then there may be no transform matrix and therefore no rotAngle. Insert a zero.
            roishapeIdx{thisROIIdx}.Angle(thisROIShapeIdx) = rotAngle;
        else
            roishapeIdx{thisROIIdx}.Angle(thisROIShapeIdx) = 0;
        end
        thisroishapeT = [];
        thisroishapeZ = [];
        thisroishapeX = [];
        thisroishapeY = [];
        thisroishapeWidth = [];
        thisroishapeHeight = [];
    end


end

end
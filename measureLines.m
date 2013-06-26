function [roiIdx roishapeIdx lineMeasurements] = measureLines(filepath, filename, credentials, fileNum, numFiles, conditionNum, numConditions, handles)
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

global gateway;

try
    [roiIdx roishapeIdx] = readLineROIs([filepath filename]);
catch
    helpdlg(['There was a problem opening the ROI file ', filename, ', please check this file and retry it.'], 'Problem');
    set(handles.beginAnalysisButton, 'Enable', 'on');
    badImage = 1;
    return;
end
try
    [pixelsId, roishapeIdx{1}.imageName] = getPixIdFromROIFile([filepath filename], credentials{1}, credentials{3});
    [roishapeIdx{1}.imageName remain] = strtok(filename, '.');
catch
    helpdlg(['Reference to ', filename, ' could not be found in your roiFileMap.xml. Please re-save the ROI file in Insight and try analysis again.']);
    set(handles.beginAnalysisButton, 'Enable', 'on');
    badImage = 1;
    return;
end

%Let the user know what's going on...
% scrsz = get(0,'ScreenSize');
% fig1 = figure('Name','Processing...','NumberTitle','off','MenuBar','none','Position',[(scrsz(3)/2)-150 (scrsz(4)/2)-80 300 80]);
% conditionText = uicontrol(fig1, 'Style', 'text', 'String', ['Condition ', num2str(conditionNum), ' of ' num2str(numConditions)], 'Position', [25 60 250 15]);
% fileText = uicontrol(fig1, 'Style', 'text', 'String', ['ROI file ', num2str(fileNum), ' of ' num2str(numFiles)], 'Position', [25 35 250 15]);
drawnow;

pixelsId = str2double(pixelsId);
pixels = gateway.getPixels(pixelsId);
fullT = pixels.getSizeT.getValue;
physX = pixels.getPhysicalSizeX.getValue;
physY = pixels.getPhysicalSizeY.getValue;

[queueIndices queueList] = lineSelector(roishapeIdx, pixels);
numMeasurements = length(queueIndices.ref);
numROI = length(roishapeIdx);

%Get the number and idices of Ref line ROI
% numROI = length(roiIdx);
% refT = [];
% for thisROI = 1:numROI
%     if strcmpi(roishapeIdx{thisROI}.ROIName, 'Ref')
%         refROIIdx = thisROI;
%         refT = unique(roishapeIdx{thisROI}.T);
%         numRefT = length(refT);
%     else
%         ROIT{thisROI} = unique(roishapeIdx{thisROI}.T);
%     end
% end

%For each refT, loop the other ROIs and calculate the relative angles. Also
%get the lengths. Store this in lineMeasurements{thisROI}{thisRefT}
for thisMeasurement = 1:numMeasurements;
    lineROIIdx = queueIndices.line(thisMeasurement);
    refROIIdx = queueIndices.ref(thisMeasurement);
    thisLineT = roishapeIdx{lineROIIdx}.T;
    for thisT = 1:length(thisLineT)
        if refROIIdx > numROI
            refGrad = 0;
            refAngleToHoriz = 0;
            roishapeIdx{refROIIdx}.ROIName = 'Horizontal';
        else
            refX1 = roishapeIdx{refROIIdx}.startX(thisT);
            refX2 = roishapeIdx{refROIIdx}.endX(thisT);
            refY1 = roishapeIdx{refROIIdx}.startY(thisT);
            refY2 = roishapeIdx{refROIIdx}.endY(thisT);
            refGrad = (refY2-refY1)/(refX2-refX1);
            refAngleToHoriz = sqrt(atand(refGrad)^2);
            if refAngleToHoriz > 90
                refAngleToHoriz = 180-refAngleToHoriz;
            end
        end
        
        %Get the sign of the gradient of the lines to know whether
        %to subtract the ref angle from 180.
        lineX1 = roishapeIdx{lineROIIdx}.startX(thisT);
        lineX2 = roishapeIdx{lineROIIdx}.endX(thisT);
        lineY1 = roishapeIdx{lineROIIdx}.startY(thisT);
        lineY2 = roishapeIdx{lineROIIdx}.endY(thisT);
        lineGrad = (lineY2-lineY1)/(lineX2-lineX1);
        lineAngleToHoriz = sqrt(atand(lineGrad)^2);
        if lineAngleToHoriz > 90
            lineAngleToHoriz = 180-lineAngleToHoriz;
        end
        
        if refGrad > 0 && lineGrad > 0 && lineGrad < refGrad
            lineMeasurements{thisMeasurement}.RelativeAngle(thisT) = refAngleToHoriz - lineAngleToHoriz;
        elseif refGrad > 0 && lineGrad > 0 && lineGrad > refGrad
            lineMeasurements{thisMeasurement}.RelativeAngle(thisT) = 180-(refAngleToHoriz + (180 - lineAngleToHoriz));
        elseif refGrad > 0 && lineGrad < 0
            lineMeasurements{thisMeasurement}.RelativeAngle(thisT) = 180-(refAngleToHoriz + lineAngleToHoriz);
        elseif refGrad < 0 && lineGrad < 0 && lineGrad > refGrad
            lineMeasurements{thisMeasurement}.RelativeAngle(thisT) = refAngleToHoriz - lineAngleToHoriz;
        elseif refGrad < 0 && lineGrad < 0 && lineGrad < refGrad
            lineMeasurements{thisMeasurement}.RelativeAngle(thisT) = 180-(refAngleToHoriz + (180-lineAngleToHoriz));
        elseif refGrad < 0 && lineGrad > 0
            lineMeasurements{thisMeasurement}.RelativeAngle(thisT) = 180-(refAngleToHoriz + lineAngleToHoriz);
        elseif refGrad == lineGrad
            lineMeasurements{thisMeasurement}.RelativeAngle(thisT) = 0;
        elseif refGrad == 0
            lineMeasurements{thisMeasurement}.RelativeAngle(thisT) = lineAngleToHoriz;
        elseif lineGrad == 0
            lineMeasurements{thisMeasurement}.RelativeAngle(thisT) = refAngleToHoriz;
        end
        
        if lineMeasurements{thisMeasurement}.RelativeAngle(thisT) > 90
            lineMeasurements{thisMeasurement}.RelativeAngle(thisT) = 180 - lineMeasurements{thisMeasurement}.RelativeAngle(thisT);
        end
        %round the angle to 2 decimal places
        lineMeasurements{thisMeasurement}.RelativeAngle(thisT) = round((lineMeasurements{thisMeasurement}.RelativeAngle(thisT)*100))/100;
        
        %calculate line length and round to 3 decimal places. Convert to um
        %if available.
        lineMeasurements{thisMeasurement}.Length(thisT) = sqrt(((lineX2-lineX1)*physX)^2 + ((lineY2-lineY1)*physY)^2);
        lineMeasurements{thisMeasurement}.Length(thisT) = round((lineMeasurements{thisMeasurement}.Length(thisT)*1000))/1000;
        
        lineMeasurements{thisMeasurement}.lineName = roishapeIdx{lineROIIdx}.ROIName;
        lineMeasurements{thisMeasurement}.refName = roishapeIdx{refROIIdx}.ROIName;
        lineMeasurements{thisMeasurement}.T(thisT) = roishapeIdx{lineROIIdx}.T(thisT);
        if physX == 1 && physY == 1
            lineMeasurements{thisMeasurement}.units = 'pixels';
        else
            lineMeasurements{thisMeasurement}.units = 'um';
        end
    end
end

%close(fig1);

end
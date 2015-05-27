function varargout = FRAPChooser(varargin)
% FRAPCHOOSER M-file for FRAPChooser.fig
%      FRAPCHOOSER, by itself, creates a new FRAPCHOOSER or raises the existing
%      singleton*.
%
%      H = FRAPCHOOSER returns the handle to a new FRAPCHOOSER or the handle to
%      the existing singleton*.
%
%      FRAPCHOOSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRAPCHOOSER.M with the given input arguments.
%
%      FRAPCHOOSER('Property','Value',...) creates a new FRAPCHOOSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FRAPChooser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FRAPChooser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FRAPChooser

% Last Modified by GUIDE v2.5 27-May-2015 12:30:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FRAPChooser_OpeningFcn, ...
                   'gui_OutputFcn',  @FRAPChooser_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before FRAPChooser is made visible.
function FRAPChooser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FRAPChooser (see VARARGIN)

% Choose default command line output for FRAPChooser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setappdata(handles.FRAPChooser, 'images', []);
setappdata(handles.FRAPChooser, 'imageIds', []);
setappdata(handles.FRAPChooser, 'imageNames', []);
setappdata(handles.FRAPChooser, 'roiShapes', []);
setappdata(handles.FRAPChooser, 'datasetNames', []);
setappdata(handles.FRAPChooser, 'pixels', []);

% UIWAIT makes FRAPChooser wait for user response (see UIRESUME)
uiwait(handles.FRAPChooser);


% --- Outputs from this function are returned to the command line.
function varargout = FRAPChooser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;

%close(hObject)


% --- Executes on button press in addDatasetsButton.
function addDatasetsButton_Callback(hObject, eventdata, handles)
% hObject    handle to addDatasetsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datasetChooser(handles, 'FRAPChooser');

%selectedDsNames = getappdata(handles.FRAPChooser, 'selectedDsNames');
selectedDsIds = getappdata(handles.FRAPChooser, 'selectedDsIds');

if isempty(selectedDsIds)
    set(handles.beginButton, 'Enable', 'off');
else
    set(handles.beginButton, 'Enable', 'on');
end


% --- Executes on button press in beginButton.
function beginButton_Callback(hObject, eventdata, handles)
% hObject    handle to beginButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedDsIds = getappdata(handles.FRAPChooser, 'selectedDsIds');
[images imageIds imageNames datasetNames] = getImageIdsAndNamesFromDatasetIds(selectedDsIds);
[imageIdxNoROIs roiShapes] = ROIImageCheck(imageIds, 'ellipse');
images = deleteElementFromJavaArrayList(imageIdxNoROIs, images);
imageIds = deleteElementFromVector(imageIdxNoROIs, imageIds);
imageNames = deleteElementFromCells(imageIdxNoROIs, imageNames);
roiShapes = deleteElementFromCells(imageIdxNoROIs, roiShapes);
datasetNames = deleteElementFromCells(imageIdxNoROIs, datasetNames);
numImages = images.size;
%Sort the ROI shapes by time point. The defaul 'byId' sorting can sometimes
%be in non-chronalogical order.
for thisImage = 1:numImages
    for thisROI = 1:length(roiShapes{thisImage})
        roiShapes{thisImage}{thisROI} = sortROIShapes(roiShapes{thisImage}{thisROI}, 'byT');
    end
end


for thisImage = 1:numImages
    theImage = images.get(thisImage-1);
    pixels{thisImage} = theImage.getPixels(0);
    %channelLabels{thisImage} = getChannelsFromPixels(pixels{thisImage});
end

% setappdata(handles.FRAPChooser, 'images', images);
% setappdata(handles.FRAPChooser, 'imageIds', imageIds);
% setappdata(handles.FRAPChooser, 'imageNames', imageNames);
% setappdata(handles.FRAPChooser, 'roiShapes', roiShapes);
% setappdata(handles.FRAPChooser, 'datasetNames', datasetNames);
% setappdata(handles.FRAPChooser, 'pixels', pixels);
%setappdata(handles.FRAPChooser, 'channelLabels', channelLabels);

%This taken from FRAPLaunchpad...
if isempty(images)
    return;
end

progBar = waitbar(0, 'Analysing...');
for thisImage = 1:numImages
    [roiShapes{thisImage} indices{thisImage}] = FRAPMeasure(images.get(thisImage-1), imageIds(thisImage), imageNames{thisImage}, roiShapes{thisImage}, datasetNames{thisImage}, pixels{thisImage});
    waitbar(thisImage/numImages, progBar);
end
close(progBar);

writeDataOut(roiShapes, indices, datasetNames);
gatewayDisconnect
delete(handles.FRAPChooser);




% 
% function FRAPChooser_CloseRequestFcn(hObject, eventdata, handles)
% % hObject    handle to FRAPChooser (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: delete(hObject) closes the figure
% 
% uiresume;

% 
% % --- Executes when user attempts to close FRAPChooser.
% function FRAPChooser_CloseRequestFcn(hObject, eventdata, handles)
% % hObject    handle to FRAPChooser (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: delete(hObject) closes the figure
% 
% gatewayDisconnect;
% uiresume;






function writeDataOut(roiShapes, indices, datasetNames)

numImages = length(roiShapes);
dataOut = [];
dataSummary = {'File Name', 'Dataset', 'T1/2', 'Mobile Fraction', 'Immobile Fraction'};

for thisImage = 1:numImages
    dataOut = [dataOut; {[roiShapes{thisImage}{indices{thisImage}.frapIdx}.name, ' Frap analysis. T1/2 = ', num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.Thalf), 's, mobile fraction = ', num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.mobileFraction), ', immobile fraction = ', num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.immobileFraction)],'','','','','',''}];
    dataOut = [dataOut; {'File Name', 'Dataset', 'Timestamp', 'Frap Intensities', 'Base Intensities', 'Whole Intensities', 'Frap Normalised Corrected';}];
    for thisTimestamp = 1:length(roiShapes{thisImage}{indices{thisImage}.frapIdx}.correctT)
        dataOut = [dataOut; {roiShapes{thisImage}{indices{thisImage}.frapIdx}.name datasetNames{thisImage} num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.timestamp(thisTimestamp))} roiShapes{thisImage}{indices{thisImage}.frapIdx}.frapData(thisTimestamp) roiShapes{thisImage}{indices{thisImage}.baseIdx}.baseData(thisTimestamp) roiShapes{thisImage}{indices{thisImage}.wholeIdx}.wholeData(thisTimestamp) roiShapes{thisImage}{indices{thisImage}.frapIdx}.frapNormCorr(thisTimestamp)];
    end
    dataOut = [dataOut; {' ',' ',' ',' ',' ',' ',' '}];
    dataSummary = [dataSummary; {roiShapes{thisImage}{indices{thisImage}.frapIdx}.name, datasetNames{thisImage}, num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.Thalf), num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.mobileFraction), num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.immobileFraction)}];
end



[saveFile savePath] = uiputfile('*.xls','Save Results','/FrapAnalysisResults.xls');

if isnumeric(saveFile) && isnumeric(savePath)
    return;
end

try
    xlswrite([savePath saveFile], dataOut, 'Data All Timepoints');
    xlswrite([savePath saveFile], dataSummary, 'Data Summary');
catch
    %If the xlswriter fails (no MSOffice installed, e.g.) then manually
    %create a .csv file. Turn every cell to string to make it easier.

    [rows cols] = size(dataOut);
    for thisRow = 1:rows
        for thisCol = 1:cols
            if isnumeric(dataOut{thisRow, thisCol})
                dataOut{thisRow, thisCol} = num2str(dataOut{thisRow, thisCol});
            end
        end
    end
    [rowsSummary colsSummary] = size(dataSummary);
    for thisRow = 1:rowsSummary
        for thisCol = 1:colsSummary
            if isnumeric(dataSummary{thisRow, thisCol})
                dataSummary{thisRow, thisCol} = num2str(dataSummary{thisRow, thisCol});
            end
        end
    end
    
    delete([savePath saveFile]); %Delete the .xls file and save again as .csv
    [savePart remain] = strtok(saveFile, '.');
    saveFile = [savePart '.csv'];
    saveFileSummary = [savePart 'Summary.csv'];
    
    %Write out DataOut to file
    fid = fopen([savePath saveFile], 'w');
    for thisRow = 1:rows
        for thisCol = 1:cols
            fprintf(fid, '%s', dataOut{thisRow, thisCol});
            fprintf(fid, '%s', ',');
        end
        fprintf(fid, '%s\n', '');
    end
    fclose(fid);
    
    %Write out dataSummary to file
    fid = fopen([savePath saveFileSummary], 'w');
    for thisRow = 1:rowsSummary
        for thisCol = 1:colsSummary
            fprintf(fid, '%s', dataSummary{thisRow, thisCol});
            fprintf(fid, '%s', ',');
        end
        fprintf(fid, '%s\n', '');
    end
    fclose(fid);

end

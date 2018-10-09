function varargout = eventTimer(varargin)
% EVENTTIMER M-file for eventTimer.fig
%      EVENTTIMER, by itself, creates a new EVENTTIMER or raises the existing
%      singleton*.
%
%      H = EVENTTIMER returns the handle to a new EVENTTIMER or the handle to
%      the existing singleton*.
%
%      EVENTTIMER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EVENTTIMER.M with the given input arguments.
%
%      EVENTTIMER('Property','Value',...) creates a new EVENTTIMER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eventTimer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eventTimer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eventTimer

% Last Modified by GUIDE v2.5 02-Dec-2010 15:20:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eventTimer_OpeningFcn, ...
                   'gui_OutputFcn',  @eventTimer_OutputFcn, ...
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


% --- Executes just before eventTimer is made visible.
function eventTimer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eventTimer (see VARARGIN)

% Choose default command line output for eventTimer
handles.output = hObject;

setappdata(handles.eventTimer, 'selectedDsNames', []);
setappdata(handles.eventTimer, 'selectedDsIds', []);
setappdata(handles.eventTimer, 'images', []);
setappdata(handles.eventTimer, 'imageIds', []);
setappdata(handles.eventTimer, 'imageNames', []);
setappdata(handles.eventTimer, 'roiShapes', []);
setappdata(handles.eventTimer, 'datasetNames', []);
setappdata(handles.eventTimer, 'pixels', []);
setappdata(handles.eventTimer, 'channelLabels', []);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eventTimer wait for user response (see UIRESUME)
uiwait(handles.eventTimer);


% --- Outputs from this function are returned to the command line.
function varargout = eventTimer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% varargout{1} = getappdata(handles.eventTimer, 'images');
% varargout{2} = getappdata(handles.eventTimer, 'imageIds');
% varargout{3} = getappdata(handles.eventTimer, 'imageNames');
% varargout{4} = getappdata(handles.eventTimer, 'roiShapes');
% varargout{5} = getappdata(handles.eventTimer, 'datasetNames');
% varargout{6} = getappdata(handles.eventTimer, 'pixels');
% varargout{7} = getappdata(handles.eventTimer, 'channelLabels');
% varargout{8} = get(handles.saveMasksCheck, 'Value');
% varargout{9} = [round(str2double(get(handles.framesStartText, 'String'))) round(str2double(get(handles.framesEndText, 'String')))];
% 
% close(hObject)
% drawnow


% --- Executes on button press in saveMasksCheck.
function saveMasksCheck_Callback(hObject, eventdata, handles)
% hObject    handle to saveMasksCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveMasksCheck

saveMasks = get(hObject, 'Value');
if saveMasks == 0
    set(handles.framesStartText, 'Enable', 'off');
    set(handles.framesEndText, 'Enable', 'off');
else
    answer = questdlg([{'You have chosen to save masks to the server.'},{'This may take some time, are you sure you want to do this?'}], 'Save masks?', 'Yes', 'No', 'Yes');
    if strcmp(answer, 'No')
        set(hObject, 'Value', 0);
        return;
    end
    set(handles.framesStartText, 'Enable', 'on');
    set(handles.framesEndText, 'Enable', 'on');
end
setappdata(handles.eventTimer, 'saveMasks', saveMasks);




function framesStartText_Callback(hObject, eventdata, handles)
% hObject    handle to framesStartText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framesStartText as text
%        str2double(get(hObject,'String')) returns contents of framesStartText as a double

result = str2double(get(hObject, 'String'));

if isnan(result)
    set(hObject, 'String', '0');
end


% --- Executes during object creation, after setting all properties.
function framesStartText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framesStartText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function framesEndText_Callback(hObject, eventdata, handles)
% hObject    handle to framesEndText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framesEndText as text
%        str2double(get(hObject,'String')) returns contents of framesEndText as a double

result = str2double(get(hObject, 'String'));

if isnan(result)
    set(hObject, 'String', '0');
end


% --- Executes during object creation, after setting all properties.
function framesEndText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framesEndText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in beginButton.
function beginButton_Callback(hObject, eventdata, handles)
% hObject    handle to beginButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global progBar

selectedDsIds = getappdata(handles.eventTimer, 'selectedDsIds');
[images imageIds imageNames datasetNames] = getImageIdsAndNamesFromDatasetIds(selectedDsIds);
[imageIdxNoROIs roiShapes] = ROIImageCheck(imageIds, 'rect');
images = deleteElementFromJavaArrayList(imageIdxNoROIs, images);
imageIds = deleteElementFromVector(imageIdxNoROIs, imageIds);
imageNames = deleteElementFromCells(imageIdxNoROIs, imageNames);
roiShapes = deleteElementFromCells(imageIdxNoROIs, roiShapes);
datasetNames = deleteElementFromCells(imageIdxNoROIs, datasetNames);
numImages = images.size;

if numImages == 0
    warndlg('There are no images with appropriate ROIs in the chosen datasets');
    return;
end

for thisImage = 1:numImages
    theImage = images.get(thisImage-1);
    pixels{thisImage} = theImage.getPixels(0);
    channelLabels{thisImage} = getChannelsFromPixels(pixels{thisImage});
end

setappdata(handles.eventTimer, 'images', images);
setappdata(handles.eventTimer, 'imageIds', imageIds);
setappdata(handles.eventTimer, 'imageNames', imageNames);
setappdata(handles.eventTimer, 'roiShapes', roiShapes);
setappdata(handles.eventTimer, 'datasetNames', datasetNames);
setappdata(handles.eventTimer, 'pixels', pixels);
setappdata(handles.eventTimer, 'channelLabels', channelLabels);

if isempty(images)
    return;
end

saveMasks = get(handles.saveMasksCheck, 'Value');
frames = [round(str2double(get(handles.framesStartText, 'String'))) round(str2double(get(handles.framesEndText, 'String')))];

numImages = length(imageIds);
for thisImage = 1:numImages
    if saveMasks == 1
        progBar = waitbar(0, ['Uploading mask for image ' num2str(thisImage)]);
    end
    [roiShapes{thisImage}] = eventTimerAndCrop(images.get(thisImage-1), imageIds(thisImage), imageNames{thisImage}, roiShapes{thisImage}, pixels{thisImage}, frames, channelLabels{thisImage}, saveMasks);
    if saveMasks == 1
        close(progBar);
    end
end
writeDataOut(roiShapes, datasetNames, selectedDsIds);
gatewayDisconnect;
delete(handles.eventTimer);



function writeDataOut(roiShapes, datasetNames, datasetIds)


mainHeader = {'Original Image', 'Mask Image', 'Dataset', 'ROI', 'Event Duration'};
dataOut = {'Original Image', 'Mask Image', 'Dataset', 'ROI', 'Event Duration'};

%Create the data structure for writing out to .xls

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
numImages = length(datasetNames);
for thisImage = 1:numImages
    %dataOut = [dataOut; {mainHeader}];
    numROI = length(roiShapes{thisImage});
    for thisROI = 1:numROI
       dataOut = [dataOut; {roiShapes{thisImage}{thisROI}.origName roiShapes{thisImage}{thisROI}.name datasetNames{thisImage} num2str(thisROI) roiShapes{thisImage}{thisROI}.deltaT}];
    end
    dataOut = [dataOut; {' ' ' ' ' ' ' ' ' '}];
end

[saveFile savePath] = uiputfile('*.xls','Save Results','/EventTimes.xls');

if isnumeric(saveFile) && isnumeric(savePath)
    return;
end

try
    xlswrite([savePath saveFile], dataOut, 'Event Times');
    attachResults(datasetIds, saveFile, savePath);
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
    delete([savePath saveFile]); %Delete the .xls file and save again as .csv
    dotIdx = findstr(saveFile, '.');
    newSaveFile = saveFile(1:dotIdx(end));
    newSaveFile = [newSaveFile 'csv'];
    fid = fopen([savePath newSaveFile], 'w');
    for thisRow = 1:rows
        for thisCol = 1:cols
            fprintf(fid, '%s', dataOut{thisRow, thisCol});
            fprintf(fid, '%s', ',');
        end
        fprintf(fid, '%s\n', '');
    end
    fclose(fid);
    attachResults(datasetIds, saveFile, savePath);
end


% --- Executes on button press in addDatasetsButton.
function addDatasetsButton_Callback(hObject, eventdata, handles)
% hObject    handle to addDatasetsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datasetChooser(handles, 'eventTimer');

%selectedDsNames = getappdata(handles.eventTimer, 'selectedDsNames');
selectedDsIds = getappdata(handles.eventTimer, 'selectedDsIds');

if isempty(selectedDsIds)
    set(handles.beginButton, 'Enable', 'off');
else
    set(handles.beginButton, 'Enable', 'on');
end
% 
% 
% function eventTimer_CloseRequestFcn(hObject, eventdata, handles)
% % hObject    handle to boxIt (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: delete(hObject) closes the figure
% 
% gatewayDisconnect;
% uiresume;




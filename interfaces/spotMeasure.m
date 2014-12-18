function varargout = spotMeasure(varargin)
% SPOTMEASURE MATLAB code for spotMeasure.fig
%      SPOTMEASURE, by itself, creates a new SPOTMEASURE or raises the existing
%      singleton*.
%
%      H = SPOTMEASURE returns the handle to a new SPOTMEASURE or the handle to
%      the existing singleton*.
%
%      SPOTMEASURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPOTMEASURE.M with the given input arguments.
%
%      SPOTMEASURE('Property','Value',...) creates a new SPOTMEASURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spotMeasure_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spotMeasure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spotMeasure

% Last Modified by GUIDE v2.5 17-Dec-2014 15:09:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spotMeasure_OpeningFcn, ...
                   'gui_OutputFcn',  @spotMeasure_OutputFcn, ...
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


% --- Executes just before spotMeasure is made visible.
function spotMeasure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spotMeasure (see VARARGIN)

% Choose default command line output for spotMeasure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spotMeasure wait for user response (see UIRESUME)
% uiwait(handles.spotMeasure);


% --- Outputs from this function are returned to the command line.
function varargout = spotMeasure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in chooseDatasetsBtn.
function chooseDatasetsBtn_Callback(hObject, eventdata, handles)
% hObject    handle to chooseDatasetsBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datasetChooser(handles, 'spotMeasure');

selectedDsIds = getappdata(handles.spotMeasure, 'selectedDsIds');
if isempty(selectedDsIds)
    return;
end
[images imageIds imageNames datasetNames] = getImageIdsAndNamesFromDatasetIds(selectedDsIds);
[imageIdxNoROIs roiShapes] = ROIImageCheck(imageIds, 'rect');
images = deleteElementFromJavaArrayList(imageIdxNoROIs, images);
imageIds = deleteElementFromVector(imageIdxNoROIs, imageIds);
imageNames = deleteElementFromCells(imageIdxNoROIs, imageNames);
roiShapes = deleteElementFromCells(imageIdxNoROIs, roiShapes);
datasetNames = deleteElementFromCells(imageIdxNoROIs, datasetNames);
numImages = images.size;

if numImages == 0
    errordlg('No images with ROIs found.', 'No Images');
    return;
end


for thisImage = 1:numImages
    theImage = images.get(thisImage-1);
    pixels{thisImage} = theImage.getPixels(0);
    channelLabels{thisImage} = getChannelsFromPixels(pixels{thisImage});
end


set(handles.measureBtn, 'Enable', 'on');
setappdata(handles.spotMeasure, 'imageIds', imageIds);
setappdata(handles.spotMeasure, 'imageNames', imageNames);
setappdata(handles.spotMeasure, 'roiShapes', roiShapes);
setappdata(handles.spotMeasure, 'channelLabels', channelLabels);
setappdata(handles.spotMeasure, 'pixels', pixels);
setappdata(handles.spotMeasure, 'datasetNames', datasetNames);

guidata(hObject, handles);



function minSizeTxt_Callback(hObject, eventdata, handles)
% hObject    handle to minSizeTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minSizeTxt as text
%        str2double(get(hObject,'String')) returns contents of minSizeTxt as a double

minSize = round(str2double(get(handles.hObject, 'String')));

if ~isnumeric(minSize)
    msgbox('The minimum object size must be a whole number');
    return;
end

setappdata(hanels.spotMeasure, 'minSize', minSize);


% --- Executes during object creation, after setting all properties.
function minSizeTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minSizeTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in measureBtn.
function measureBtn_Callback(hObject, eventdata, handles)
% hObject    handle to measureBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

imageIds = getappdata(handles.spotMeasure, 'imageIds');
imageNames = getappdata(handles.spotMeasure, 'imageNames');
roiShapes = getappdata(handles.spotMeasure, 'roiShapes');
c = get(handles.channelSelect, 'Value');
selectedDsIds = getappdata(handles.spotMeasure, 'selectedDsIds');
minSize = getappdata(handles.spotMeasure, 'minSize');
numImages = length(imageIds);

progBar = waitbar(0, 'Analysing images...');
for thisImage = 1:numImages
    waitbar(thisImage/numImages, progBar);
    imageId = imageIds(thisImage);
    imageName = imageNames{thisImage};
    dsId(thisImage) = matchDatasetAndImage(imageId, selectedDsIds);
    dataOut{thisImage} = measureSpotsInROI(imageId, imageName, dsId(thisImage), minSize, c-1);
end
close(progBar);

writeDataOut(dataOut, roiShapes, dsId, imageNames);


% --- Executes on selection change in channelSelect.
function channelSelect_Callback(hObject, eventdata, handles)
% hObject    handle to channelSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channelSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channelSelect


% --- Executes during object creation, after setting all properties.
function channelSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function thisDsId = matchDatasetAndImage(imageId, selectedDsIds)

global session

numDs = length(selectedDsIds);

for thisDs = 1:numDs
    thisDsId = selectedDsIds(thisDs);
    images = getImages(session, 'dataset', selectedDsIds(thisDs));
    for thisImage = 1:length(images)
        imageIds(thisImage) = images(thisImage).getId.getValue;
    end
    
    if ismember(imageId, imageIds)
        return;
    end
end


function writeDataOut(dataOut, roiShapes, dsId, imageNames)

global session

numImages = length(imageNames);
dataFinal = {'Image name', 'Dataset', 'ROI ID', 'Spot size'};

for thisImage = 1:numImages
    numROIs = length(dataOut{thisImage});
    dataset = getDatasets(session, dsId(thisImage));
    datasetName = char(dataset.getName.getValue.getBytes');
    for thisROI = 1:numROIs
        dataThisROI = dataOut{thisImage}{thisROI};
        sizesThisROI = [dataThisROI(:).Area]';
        numSpots = length(sizesThisROI);
        for thisSpot = 1:numSpots
            dataFinal{end+1,1} = imageNames{thisImage};
            dataFinal{end,2} = datasetName;
            dataFinal{end,3} = roiShapes{thisImage}{thisROI}.ROIId;
            dataFinal{end,4} = sizesThisROI(thisSpot);
        end
    end
end

[fileName, filePath] = uiputfile('*.xls', 'Choose a file name');

xlswrite([filePath fileName], dataFinal);













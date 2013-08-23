function varargout = boxIt(varargin)
% BOXIT M-file for boxit.fig
%      BOXIT, by itself, creates a new BOXIT or raises the existing
%      singleton*.
%
%      H = BOXIT returns the handle to a new BOXIT or the handle to
%      the existing singleton*.
%
%      BOXIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BOXIT.M with the given input arguments.
%
%      BOXIT('Property','Value',...) creates a new BOXIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before boxIt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to boxIt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help boxit

% Last Modified by GUIDE v2.5 23-Aug-2013 14:39:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @boxIt_OpeningFcn, ...
                   'gui_OutputFcn',  @boxIt_OutputFcn, ...
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


% --- Executes just before boxit is made visible.
function boxIt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to boxit (see VARARGIN)

global gateway;
warning off MATLAB:xlswrite:NoCOMServer
%Set up the play and pause buttons
startImage = imread('startImageImage.jpg', 'jpg');
playIcon = imread('playButton.png', 'png');
pauseIcon = imread('pauseButton.png', 'png');
arrowIcon = imread('arrowButton.png', 'png');
rectIcon = imread('rectButton.png', 'png');
deletePointIcon = imread('deletePointButton.png', 'png');
set(handles.playButton,'CDATA',playIcon);
set(handles.pauseButton,'CDATA',pauseIcon);
set(handles.arrowButton,'CDATA',arrowIcon);
set(handles.rectButton,'CDATA',rectIcon);
set(handles.deleteROIButton,'CDATA',deletePointIcon);

set(handles.boxIt, 'WindowButtonUpFcn', {@imageAnchor_ButtonUpFcn, handles});
axes(handles.imageAxes);
imshow(startImage);

% Choose default command line output for boxit
set(handles.boxIt, 'windowbuttonmotionfcn', {@windowButtonMotion, handles});
set(handles.boxIt, 'keypressfcn', {@currentWindowKeypress, handles});
handles.output = hObject;
sysUserHome = getenv('userprofile');

setappdata(handles.boxIt, 'username', varargin{1});
setappdata(handles.boxIt, 'server', varargin{2});
setappdata(handles.boxIt, 'recentreROI', 0);
setappdata(handles.boxIt, 'numT', 1);
setappdata(handles.boxIt, 'numZ', 1);
setappdata(handles.boxIt, 'zHeight', 0);
setappdata(handles.boxIt, 'modified', 0);
setappdata(handles.boxIt, 'currDir', pwd);
setappdata(handles.boxIt, 'zoomLevel', 1);
setappdata(handles.boxIt, 'zoomROIMinMax', []);
setappdata(handles.boxIt, 'setPoint', 0);
setappdata(handles.boxIt, 'selectedROI', []);
setappdata(handles.boxIt, 'showLabelText', 0);
setappdata(handles.boxIt, 'sizeXY', [512 512]);
setappdata(handles.boxIt, 'filePath', []);
setappdata(handles.boxIt, 'fileName', []);
setappdata(handles.boxIt, 'labelsPath', []);
setappdata(handles.boxIt, 'labelsName', []);
setappdata(handles.boxIt, 'flattenZ', 0);
setappdata(handles.boxIt, 'flattenT', 0);
setappdata(handles.boxIt, 'cancelledOpenImage', 0);
setappdata(handles.boxIt, 'savePath', sysUserHome);
setappdata(handles.boxIt, 'sysUserHome', sysUserHome);
set(handles.imageNameLabel, 'String', 'No File Open');
setZControls(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes boxit wait for user response (see UIRESUME)
uiwait(handles.boxIt);


% --- Outputs from this function are returned to the command line.
function varargout = boxIt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = 0;
%varargout{1} = handles.output;



% --- Executes on slider movement.
function tSlider_Callback(hObject, eventdata, handles)
% hObject    handle to tSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

t = round(get(hObject, 'Value'));
set(handles.tLabel, 'String', ['T = ' num2str(t)]);
getPlane(handles);
refreshDisplay(handles);


% --- Executes during object creation, after setting all properties.
function tSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function getPlane(handles, varargin)

numVarargs = size(varargin,2);
if numVarargs == 2
    thisZ = varargin{1};
    thisT = varargin{2};
end
pixelsId = getappdata(handles.boxIt, 'pixelsId');
numZ = getappdata(handles.boxIt, 'numZ');
playing = getappdata(handles.boxIt, 'playing');
selectedC = get(handles.channelSelect, 'Value')-1;
thisT = round(get(handles.tSlider, 'Value'))-1;
if numVarargs == 2
    %If movie is playing and user clicks the tSlider, get the t and z.
    try
        plane(:,:) = getPlaneFromPixelsId(pixelsId, thisZ, selectedC, thisT);
    catch
        thisZ = round(get(handles.zSlider, 'Value'))-1;
        thisT = round(get(handles.tSlider, 'Value'))-1;
        plane(:,:) = getPlaneFromPixelsId(pixelsId, thisZ, selectedC, thisT);
    end
else
    if numZ > 5
        downloadingBar = waitbar(0,'Downloading...');
    end
    for thisZ = 1:numZ
        plane(:,:,thisZ) = getPlaneFromPixelsId(pixelsId, thisZ-1, selectedC, thisT);
        if numZ > 5
            waitbar(thisZ/numZ)
        end
    end
    if numZ > 5
        close(downloadingBar)
    end
end
imageSize = size(plane);
setappdata(handles.boxIt, 'currentPlane', plane);
setappdata(handles.boxIt, 'imageSize', imageSize);



function setTControls(handles)

numT = getappdata(handles.boxIt, 'numT');
if numT > 1
    sliderSmallStep = 1/numT;
    set(handles.tSlider, 'Max', numT);
    set(handles.tSlider, 'Min', 1);
    set(handles.tSlider, 'SliderStep', [sliderSmallStep, sliderSmallStep*4]);
    set(handles.tSlider, 'Enable', 'on');
    set(handles.tSlider, 'Visible', 'on');
    set(handles.tSlider, 'Value', 1);
    set(handles.tLabel, 'String', 'T = 1');
    set(handles.tLabel, 'Visible', 'on');
    set(handles.playButton, 'Visible', 'on');
    set(handles.pauseButton, 'Visible', 'on');
else
    set(handles.tSlider, 'Enable', 'off');
    set(handles.tSlider, 'Value', 1);
    set(handles.tSlider, 'Visible', 'off');
    set(handles.tLabel, 'Visible', 'off');
    set(handles.playButton, 'Visible', 'off');
    set(handles.pauseButton, 'Visible', 'off');
end


function setZControls(handles)

numZ = getappdata(handles.boxIt, 'numZ');
defaultZ = getappdata(handles.boxIt, 'defaultZ');
if numZ > 1
    sliderSmallStep = 1/numZ;
    set(handles.zSlider, 'Max', numZ);
    set(handles.zSlider, 'Min', 1);
    set(handles.zSlider, 'SliderStep', [sliderSmallStep, sliderSmallStep*4]);
    set(handles.zSlider, 'Enable', 'on');
    set(handles.zSlider, 'Visible', 'on');
    set(handles.zSlider, 'Value', defaultZ);
    set(handles.zLabel, 'String', ['Z = ' num2str(defaultZ)]);
    set(handles.zLabel, 'Visible', 'on');
    set(handles.verifyZCheck, 'Enable', 'on');
else
    set(handles.zSlider, 'Enable', 'off');
    set(handles.zSlider, 'Value', 1);
    set(handles.zSlider, 'Visible', 'off')
    set(handles.zLabel, 'Visible', 'off');
    set(handles.verifyZCheck, 'Value', 0);
    set(handles.verifyZCheck, 'Enable', 'off');
end


% --- Executes on slider movement.
function zSlider_Callback(hObject, eventdata, handles)
% hObject    handle to zSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

z = round(get(hObject, 'Value'));
set(handles.zLabel, 'String', ['Z = ' num2str(z)]);
plane = getappdata(handles.boxIt, 'currentPlane');
zInHand = size(plane, 3);
if zInHand == 1
    thisT = round(get(handles.tSlider, 'Value'));
    getPlane(handles, z, thisT);
end
refreshDisplay(handles);



% --- Executes during object creation, after setting all properties.
function zSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function imageAnchor_ButtonDownFcn(hObject, eventdata, handles)

ROIs = getappdata(handles.boxIt, 'ROIs');
pointer = get(gcf, 'Pointer');
if getappdata(handles.boxIt, 'setPoint') == 1 && strcmp(pointer, 'crosshair')
    %setPoint(handles);
end
if getappdata(handles.boxIt, 'setPoint') == 0
    %deselectPoint(handles);
end

selectROI = getappdata(handles.boxIt, 'selectROI');
if selectROI == 1
    currentPoint = get(gca, 'CurrentPoint');
    for thisROI = 1:length(ROIs)
        thisROIXRange = int16(ROIs{thisROI}.rect(1):ROIs{thisROI}.rect(1)+ROIs{thisROI}.rect(3));
        thisROIYRange = int16(ROIs{thisROI}.rect(2):ROIs{thisROI}.rect(2)+ROIs{thisROI}.rect(4));
        %Maybe handle child ROIs differently - small ROI inside larger will not
        %be detected if drawn first.
        if ismember(currentPoint(1), thisROIXRange) && ismember(currentPoint(3), thisROIYRange)
            redrawROIs(handles);
            setappdata(handles.boxIt, 'selectedROI', thisROI);
            rectangle('Position',[ROIs{thisROI}.rect(1),ROIs{thisROI}.rect(2),ROIs{thisROI}.rect(3),ROIs{thisROI}.rect(4)], 'edgeColor', 'g', 'HitTest', 'off');
            set(handles.deleteROIButton, 'Enable', 'on');
        end
    end
    setappdata(handles.boxIt, 'selectROI', 0);
else
    set(handles.deleteROIButton, 'Enable', 'off');
    redrawROIs(handles);
end



function imageAnchor_ButtonUpFcn(hObject, eventdata, handles)

setappdata(handles.boxIt, 'deleteLock', 0);


function redrawImage(handles)

displayImage = double(getappdata(handles.boxIt, 'currentPlane'));
pixels = getappdata(handles.boxIt, 'pixels');
channelMin = getappdata(handles.boxIt, 'channelMin');
channelGlobalMax = getappdata(handles.boxIt, 'channelGlobalMax');
channelGlobalMaxScaled = getappdata(handles.boxIt, 'channelGlobalMaxScaled');
thisZ = round(get(handles.zSlider, 'Value'));
zInHand = size(displayImage, 3);

if zInHand == 1
    displayImage = displayImage./channelGlobalMax;
    displayImage = imadjust(displayImage, [channelMin channelGlobalMaxScaled], []);
    handles.imageHandle = imshow(displayImage);
else
    displayImage(:,:,thisZ) = displayImage(:,:,thisZ)./channelGlobalMax;
    displayImage(:,:,thisZ) = imadjust(displayImage(:,:,thisZ), [channelMin channelGlobalMaxScaled], []);
    handles.imageHandle = imshow(displayImage(:,:,thisZ));
end
set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
setappdata(handles.boxIt, 'thisImageHandle', handles.imageHandle);




function windowButtonMotion(hObject, eventdata, handles)

currentPoint = get(handles.imageAxes, 'CurrentPoint');
setappdata(handles.boxIt, 'currentPoint', currentPoint);
axesPosition = get(handles.imageAxes, 'Position');
sizeXY = getappdata(handles.boxIt, 'sizeXY');
xMod = axesPosition(3)/sizeXY(1);
yMod = axesPosition(4)/sizeXY(2);
if currentPoint(1) > 0 && currentPoint(1) <= (axesPosition(3) / xMod) && currentPoint(3) > 0 && currentPoint(3) <= (axesPosition(4) / yMod) && getappdata(handles.boxIt, 'setPoint') == 1
    set(gcf, 'Pointer', 'crosshair');
else
    set(gcf, 'Pointer', 'arrow');
end




% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

numT = getappdata(handles.boxIt, 'numT');
firstT = round(get(handles.tSlider, 'Value'));
if getappdata(handles.boxIt, 'playing') == 1
    return;
end
setappdata(handles.boxIt, 'interruptPlay', 0);
for thisT = firstT:numT
    interruptPlay = getappdata(handles.boxIt, 'interruptPlay');
    if interruptPlay == 1
        break;
    end
    setappdata(handles.boxIt, 'playing', 1);
    set(handles.tSlider, 'Value', thisT);
    set(handles.tLabel, 'String', ['T = ' num2str(thisT)]);
    thisZ = round(get(handles.zSlider, 'Value'));
    getPlane(handles, thisZ-1, thisT-1)
    redrawImage(handles);
    %refreshDisplay(handles);
    pause(0.05);
end
setappdata(handles.boxIt, 'playing', 0);
setappdata(handles.boxIt, 'interruptPlay', 0);



% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.boxIt, 'interruptPlay', 1);



function currentWindowKeypress(hObject, eventdata, handles)

currentKey = eventdata.Key;
if strcmp(currentKey, 'escape')
    setappdata(handles.boxIt, 'stopRecording', 1);
end
if strcmp(currentKey, 'f5')
    refreshDisplay(handles);
end
if strcmp(currentKey, 'delete')
    deleteROI(handles);
end



function mouseClick

robot = java.awt.Robot;
robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);


% --------------------------------------------------------------------
function viewMenu_Callback(hObject, eventdata, handles)
% hObject    handle to viewMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function fileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to fileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function openImageItem_Callback(hObject, eventdata, handles)
% hObject    handle to openImageItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gateway

modified = getappdata(handles.boxIt, 'modified');
if modified == 1
    answer = questdlg([{'The current set of ROIs has been modified.'} {'Discard changes and open a new image?'}], 'Discard Changes?', 'Yes', 'No', 'No');
    if strcmp(answer, 'No')
        return;
    end
end

imageId = getappdata(handles.boxIt, 'imageId');
ImageSelector(handles, 'boxIt');
cancelledOpenImage = getappdata(handles.boxIt, 'cancelledOpenImage');
if cancelledOpenImage == 1
    setappdata(handles.boxIt, 'cancelledOpenImage', 0);
    return;
end
newImageObj = getappdata(handles.boxIt, 'newImageObj');
newImageId = newImageObj.getId.getValue;
if newImageId == imageId
    return;
end
setappdata(handles.boxIt, 'theImage', newImageObj);
setappdata(handles.boxIt, 'imageId', newImageId);
loadNewImage(handles);

%This function replaces the current Image with the newImageObj selected in
%the previous function.
function loadNewImage(handles)
getMetadata(handles);
setControls(handles);
defaultZ = getappdata(handles.boxIt, 'defaultZ');
getPlane(handles, defaultZ, 0);
channel = get(handles.channelSelect, 'Value')-1;
pixels = getappdata(handles.boxIt, 'pixels');

%As part of loading the new image, the nextImageButton is disabled when the
%last image in any dataset is loaded.
global gateway;
imageId = getappdata(handles.boxIt, 'imageId');
dsId = getappdata(handles.boxIt, 'datasetId');
datasetId = java.util.ArrayList;
datasetId.add(java.lang.Long(dsId));
datasetContainer = omero.api.ContainerClass.Dataset;
images = gateway.getImages(datasetContainer,datasetId);
numImages = images.size;
for thisImage = 0:numImages-1
    imageIds(thisImage+1) = images.get(thisImage).getId.getValue;
end
imageIds = sort(imageIds);
for thisImage = 1:numImages
    if imageId == imageIds(thisImage);
        break;
    end
end
if thisImage < numImages
    set(handles.nextImageButton, 'enable', 'on')
else
    set(handles.nextImageButton, 'enable', 'off')
end

%As part of loading the new image, the prevImageButton is disabled when the
%last image in any dataset is loaded.
global gateway;
imageId = getappdata(handles.boxIt, 'imageId');
dsId = getappdata(handles.boxIt, 'datasetId');
datasetId = java.util.ArrayList;
datasetId.add(java.lang.Long(dsId));
datasetContainer = omero.api.ContainerClass.Dataset;
images = gateway.getImages(datasetContainer,datasetId);
numImages = images.size;
for thisImage = 0:numImages-1
    imageIds(thisImage+1) = images.get(thisImage).getId.getValue;
end
imageIds = sort(imageIds);
for thisImage = 1:numImages
    if imageId == imageIds(thisImage);
        break;
    end
end
if thisImage > 1
    set(handles.prevImageButton, 'enable', 'on')
else
    set(handles.prevImageButton, 'enable', 'off')
end

%aChange

%Get existing ROIs
% ROIs = getROIsFromImageId(newImageId);
% numROI = length(ROIs);
% ROIsToDelete = [];
% for thisROI = 1:numROI
%     shapeType{thisROI} = ROIs{thisROI}.shapeType;
%     if ~strcmpi(shapeType{thisROI}, 'rect')
%         ROIsToDelete = [ROIsToDelete thisROI];
%     end
% end
% ROIs = deleteElementFromCells(ROIsToDelete, ROIs);
    
[channelMin channelGlobalMax channelGlobalMaxScaled] = getChannelMinMax(pixels, channel);
setappdata(handles.boxIt, 'channelMin', channelMin);
setappdata(handles.boxIt, 'channelGlobalMax', channelGlobalMax);
setappdata(handles.boxIt, 'channelGlobalMaxScaled', channelGlobalMaxScaled);
setappdata(handles.boxIt, 'newImageObj', []);
setappdata(handles.boxIt, 'newImageId', []);
setappdata(handles.boxIt, 'ROIs', []);
setappdata(handles.boxIt, 'filePath', []);
setappdata(handles.boxIt, 'fileName', []);
setappdata(handles.boxIt, 'modified', 0);
setappdata(handles.boxIt, 'askToUpdateROIMapFile', 1);
setappdata(handles.boxIt, 'updatingROIMapFile', 0);
redrawImage(handles);
redrawROIs(handles);





% --------------------------------------------------------------------
function refreshItem_Callback(hObject, eventdata, handles)
% hObject    handle to refreshItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

refreshDisplay(handles);


function refreshDisplay(handles)

redrawImage(handles);
redrawROIs(handles);




% --- Executes during object creation, after setting all properties.
function roiSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function saveROIsItem_Callback(hObject, eventdata, handles)
% hObject    handle to saveROIsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ROIsToServer(handles);
msgbox('ROIs saved to server.', 'Saved', 'modal');
%ROIsToXml(handles);




% points = getappdata(handles.boxIt, 'points');
% if isempty(points)
%     warndlg('There are no points to save.', 'No points');
%     return;
% end
% filePath = getappdata(handles.boxIt, 'filePath');
% fileName = getappdata(handles.boxIt, 'fileName');
% if isempty(fileName)
%     [fileName filePath] = uiputfile('*.mat', 'Save labels');
%     if fileName == 0
%         return;
%     end
% end
% labelText = getappdata(handles.boxIt, 'labelText');
% labelColour = getappdata(handles.boxIt, 'labelColour');
% projectId = getappdata(handles.boxIt, 'projectId');
% datasetId = getappdata(handles.boxIt, 'datasetId');
% imageId = getappdata(handles.boxIt, 'imageId');
% 
% save([filePath fileName], 'points', 'projectId', 'datasetId', 'imageId', 'labelText', 'labelColour');
% setappdata(handles.boxIt, 'filePath', filePath);
% setappdata(handles.boxIt, 'fileName', fileName);
% setappdata(handles.boxIt, 'modified', 0);




% --------------------------------------------------------------------
function saveROIsAsItem_Callback(hObject, eventdata, handles)
% hObject    handle to saveROIsAsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

points = getappdata(handles.boxIt, 'points');
if isempty(points)
    warndlg('There are no points to save.', 'No points');
    return;
end
imageId = getappdata(handles.boxIt, 'imageId');
labelText = getappdata(handles.boxIt, 'labelText');
labelColour = getappdata(handles.boxIt, 'labelColour');
projectId = getappdata(handles.boxIt, 'projectId');
datasetId = getappdata(handles.boxIt, 'datasetId');
imageId = getappdata(handles.boxIt, 'imageId');

[fileName filePath] = uiputfile('*.mat', 'Save labels');

if fileName == 0
    return;
end

save([filePath fileName], 'points', 'points', 'projectId', 'datasetId', 'imageId', 'labelText', 'labelColour');
setappdata(handles.boxIt, 'filePath', filePath);
setappdata(handles.boxIt, 'fileName', fileName);
setappdata(handles.boxIt, 'modified', 0);



% --------------------------------------------------------------------
function quitItem_Callback(hObject, eventdata, handles)
% hObject    handle to quitItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.boxIt);



% --- Executes on button press in arrowButton.
function arrowButton_Callback(hObject, eventdata, handles)
% hObject    handle to arrowButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.boxIt, 'selectROI', 1);


% --- Executes on button press in rectButton.
function rectButton_Callback(hObject, eventdata, handles)
% hObject    handle to rectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

rect = getrect(handles.imageAxes);
setappdata(handles.boxIt, 'rect', rect);
segmentPatch(handles);



% --- Executes on button press in autoDrawButton.
function autoDrawButton_Callback(hObject, eventdata, handles)
% hObject    handle to autoDrawButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    


% --- Executes on selection change in channelSelect.
function channelSelect_Callback(hObject, eventdata, handles)
% hObject    handle to channelSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns channelSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channelSelect

getPlane(handles);
channel = get(hObject, 'Value')-1;
pixels = getappdata(handles.boxIt, 'pixels');
[channelMin channelGlobalMax channelGlobalMaxScaled] = getChannelMinMax(pixels, channel);
setappdata(handles.boxIt, 'channelMin', channelMin);
setappdata(handles.boxIt, 'channelGlobalMax', channelGlobalMax);
setappdata(handles.boxIt, 'channelGlobalMaxScaled', channelGlobalMaxScaled);
redrawImage(handles);






% --- Executes during object creation, after setting all properties.
function channelSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in deleteAll.
function deleteAll_Callback(hObject, eventdata, handles)
% hObject    handle to deleteAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = questdlg('Delete all of the ROIs?', 'Delete All?', 'Yes', 'No', 'No');
if strcmp(answer, 'No')
    return;
end
setappdata(handles.boxIt, 'ROIs', []);
redrawImage(handles);

% labelText = getappdata(handles.boxIt, 'labelText');
% labelColour = getappdata(handles.boxIt, 'labelColour');
% points = getappdata(handles.boxIt, 'points');
% labelIdx = get(handles.channelSelect, 'Value');
% labelSelectString = get(handles.channelSelect, 'String');
% numLabels = length(labelText);
% if strcmp(labelSelectString, 'Add a label')
%     return;
% end
% answer = questdlg([{'Are you sure you want to delete this label?'} {'All points with this label will be deleted too.'}], 'Delete label?', 'Yes', 'No', 'No');
% if strcmp(answer, 'No')
%     return;
% end
% if labelIdx == numLabels
%     if labelIdx == 1
%         newLabelText = [];
%         newLabelColour = [];
%         set(handles.channelSelect, 'ForegroundColor', 'k');
%         set(handles.channelSelect, 'String', 'Add a label');
%     else
%         for thisLabel = 1:numLabels-1
%             newLabelText{thisLabel} = labelText{thisLabel};
%             newLabelColour{thisLabel} = labelColour{thisLabel};
%         end
%         set(handles.channelSelect, 'Value', labelIdx-1);
%         set(handles.channelSelect, 'ForegroundColor', newLabelColour{labelIdx-1});
%         set(handles.channelSelect, 'String', newLabelText);
%     end
% else
%     for thisLabel = 1:numLabels-1
%         if thisLabel < labelIdx
%             newLabelText{thisLabel} = labelText{thisLabel};
%             newLabelColour{thisLabel} = labelColour{thisLabel};
%         else
%             newLabelText{thisLabel} = labelText{thisLabel+1};
%             newLabelColour{thisLabel} = labelColour{thisLabel+1};
%         end
%     end
%     if labelIdx ~= 1
%         set(handles.channelSelect, 'Value', labelIdx-1);
%         set(handles.channelSelect, 'ForegroundColor', newLabelColour{labelIdx-1});
%     else
%         set(handles.channelSelect, 'ForegroundColor', newLabelColour{1});
%     end
%     set(handles.channelSelect, 'String', newLabelText);
% end
% 
% %Now remove all the points from the points cell structre
% numPoints = length(points);
% newPoints = [];
% modifier = 0;
% copyPoints = [];
% for thisPoint = 1:numPoints
%     if strcmpi(points{thisPoint}.label, labelSelectString{labelIdx});
%         thePoint = points{thisPoint}.PointHandle;
%         api = iptgetapi(thePoint);
%         api.delete();
%     else
%         copyPoints = [copyPoints thisPoint];
%     end
% end
% counter = 1;
% for thisPoint = 1:numPoints
%     if ismember(thisPoint, copyPoints)
%         newPoints{counter} = points{thisPoint};
%         counter = counter + 1;
%     end
% end
% 
% setappdata(handles.boxIt, 'points', newPoints);
% setappdata(handles.boxIt, 'labelText', newLabelText);
% setappdata(handles.boxIt, 'labelColour', newLabelColour);



% --- Executes when user attempts to close boxIt.
function boxIt_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to boxIt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

modified = getappdata(handles.boxIt, 'modified');
if modified == 1
    answer = questdlg([{'The current set of points has been modified.'} {'Quit the application anyway?'}], 'Discard Changes?', 'Yes', 'No', 'No');
    if strcmp(answer, 'No')
        return;
    end
end
gatewayDisconnect;
delete(hObject);


function setPoint(handles)

points = getappdata(handles.boxIt, 'points');
labelColour = getappdata(handles.boxIt, 'labelColour');
currentPoint = getappdata(handles.boxIt, 'currentPoint');
labelString = get(handles.channelSelect, 'String');
if strcmp(labelString, 'Add a label')
    errordlg('You must add a label before setting points.', 'No labels');
    setappdata(handles.boxIt, 'setPoint', 0);
    return;
end
labelIdx = get(handles.channelSelect, 'Value');
label = labelString{labelIdx};
colour = labelColour{labelIdx};
thisZ = round(get(handles.zSlider, 'Value'));
thisT = round(get(handles.tSlider, 'Value'));
if iscell(points)
    currPoint = length(points)+1;
    thePoint = impoint(gca,currentPoint(1), currentPoint(3));
    set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
    points{currPoint}.label = label;
    points{currPoint}.Position = [currentPoint(1) currentPoint(3) thisZ thisT];
    points{currPoint}.PointHandle = thePoint;
    points{currPoint}.Colour = colour;
else
    thePoint = impoint(gca,currentPoint(1), currentPoint(3));
    set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
    points{1}.label = label;
    points{1}.Position = [currentPoint(1) currentPoint(3) thisZ thisT];
    points{1}.PointHandle = thePoint;
    points{1}.Colour = colour;
end

api = iptgetapi(thePoint);
fcn = makeConstrainToRectFcn('impoint', [currentPoint(1) currentPoint(1)], [currentPoint(3) currentPoint(3)]);
api.setPositionConstraintFcn(fcn);
api.setColor(colour);
iptaddcallback(thePoint, 'ButtonDownFcn', {@point_ButtonDownFcn, handles});
showLabels = getappdata(handles.boxIt, 'showLabelText');
if showLabels == 1
    api.setString(label);
end

setappdata(handles.boxIt, 'modified', 1);
setappdata(handles.boxIt, 'points', points);



function point_ButtonDownFcn(hObject, eventdata, handles)

setappdata(handles.boxIt, 'deleteLock', 1);
setPoint = getappdata(handles.boxIt, 'setPoint');
if setPoint == 1
    return;
end
deselectPoint(handles);
thePoint = get(gcf, 'CurrentObject');
points = getappdata(handles.boxIt, 'points');
numPoints = length(points);
for thisPoint = 1:numPoints
    if points{thisPoint}.PointHandle == thePoint
        colour = points{thisPoint}.Colour;
    end
end
api = iptgetapi(thePoint);
api.setColor('w');
set(handles.deleteROIButton, 'Enable', 'on');
setappdata(handles.boxIt, 'selectedPoint', thePoint);
setappdata(handles.boxIt, 'selectedOrigColour', colour);


function deselectPoint(handles)

thePoint = getappdata(handles.boxIt, 'selectedPoint');
colour = getappdata(handles.boxIt, 'selectedOrigColour');
if isempty(thePoint)
    return;
end
api = iptgetapi(thePoint);
api.setColor(colour);
setappdata(handles.boxIt, 'selectedPoint', []);
setappdata(handles.boxIt, 'selectedOrigColour', []);
set(handles.deleteROIButton, 'Enable', 'off');


function deleteROI(handles)

selectedROI = getappdata(handles.boxIt, 'selectedROI');
locked = getappdata(handles.boxIt, 'deleteLock');
if isempty(selectedROI) || locked == 1
    return;
end
ROIs = getappdata(handles.boxIt, 'ROIs');

numROIs = length(ROIs);
if numROIs == 1
    rmappdata(handles.boxIt, 'ROIs');
elseif selectedROI ~= numROIs
    for thisROI = selectedROI:numROIs-1
        ROIs{thisROI} = ROIs{thisROI+1};
    end
    for thisROI = 1:numROIs-1
        editedROIs{thisROI} = ROIs{thisROI};
    end
    setappdata(handles.boxIt, 'ROIs', editedROIs);
else
    for thisROI = 1:numROIs-1
        editedROIs{thisROI} = ROIs{thisROI};
    end
    setappdata(handles.boxIt, 'ROIs', editedROIs);
end

rmappdata(handles.boxIt, 'selectedROI');
setappdata(handles.boxIt, 'modified', 1);
set(handles.deleteROIButton, 'Enable', 'off');
refreshDisplay(handles);




% --------------------------------------------------------------------
function showLabelTextItem_Callback(hObject, eventdata, handles)
% hObject    handle to showLabelTextItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

showLabels = getappdata(handles.boxIt, 'showLabelText');

if showLabels == 0
    setappdata(handles.boxIt, 'showLabelText', 1);
    set(hObject, 'Checked', 'on');
else
    setappdata(handles.boxIt, 'showLabelText', 0);
    set(hObject, 'Checked', 'off');
end
refreshDisplay(handles);


% --------------------------------------------------------------------
function openPointsItem_Callback(hObject, eventdata, handles)
% hObject    handle to openPointsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gateway

modified = getappdata(handles.boxIt, 'modified');
if modified == 1
    answer = questdlg([{'The current set of points has been modified.'} {'Discard changes and open a new points file?'}], 'Discard Changes?', 'Yes', 'No', 'No');
    if strcmp(answer, 'No')
        return;
    end
end

[fileName filePath] = uigetfile('*.mat', 'Open labels.');
if fileName == 0
    return;
end
vars = load([filePath fileName]);
theImage = gateway.getImage(vars.imageId);
setappdata(handles.boxIt, 'points', vars.points);
setappdata(handles.boxIt, 'projectId', vars.projectId);
setappdata(handles.boxIt, 'datasetId', vars.datasetId);
setappdata(handles.boxIt, 'imageId', vars.imageId);
setappdata(handles.boxIt, 'theImage', theImage);
setappdata(handles.boxIt, 'labelText', vars.labelText)
setappdata(handles.boxIt, 'labelColour', vars.labelColour)
setappdata(handles.boxIt, 'filePath', filePath)
setappdata(handles.boxIt, 'fileName', fileName)
set(handles.channelSelect, 'String', vars.labelText);
set(handles.channelSelect, 'Value', 1);
getMetadata(handles);
refreshDisplay(handles);



% --------------------------------------------------------------------
function openLabelDefsItem_Callback(hObject, eventdata, handles)
% hObject    handle to openLabelDefsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

labelText = getappdata(handles.boxIt, 'labelText');
if ~isempty(labelText)
    answer = questdlg([{'Opening a previous label file will discard the'} {'current labels and points made. Continue?'}], 'Discard labels and points?', 'Yes', 'No', 'No');
    if strcmp(answer, 'No')
        return;
    end
end
[labelsName labelsPath] = uigetfile('*.mat', 'Load label definitions');
if labelsName == 0
    return;
end
vars = load([labelsPath labelsName]);
if ~isfield(vars, 'labelDefFile')
    warndlg('This does not appear to be a valid label definition file', 'File not valid');
    return;
end

setappdata(handles.boxIt, 'labelText', vars.labelText);
setappdata(handles.boxIt, 'labelColour', vars.labelColour);
setappdata(handles.boxIt, 'labelsPath', labelsPath);
setappdata(handles.boxIt, 'labelsName', labelsName);
setappdata(handles.boxIt, 'points', []);
set(handles.channelSelect, 'Value', 1);
set(handles.channelSelect, 'String', vars.labelText);
refreshDisplay(handles);




% --------------------------------------------------------------------
function saveLabelDefsItem_Callback(hObject, eventdata, handles)
% hObject    handle to saveLabelDefsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

labelsPath = getappdata(handles.boxIt, 'labelsPath');
labelsName = getappdata(handles.boxIt, 'labelsName');
labelText = getappdata(handles.boxIt, 'labelText');
labelColour = getappdata(handles.boxIt, 'labelColour');
labelDefFile = 'labelDefFile';

if isempty(labelText)
    warndlg('There are no labels to save', 'No labels');
    return;
end
if isempty(labelsName)
    [labelsName labelsPath] = uiputfile('*.mat', 'Save label definitions');
    if labelsName == 0
        return;
    end
end

save([labelsPath labelsName], 'labelText', 'labelColour', 'labelDefFile')
setappdata(handles.boxIt, 'labelsPath', labelsPath);
setappdata(handles.boxIt, 'labelsName', labelsName);



% --------------------------------------------------------------------
function saveLabelDefsAsItem_Callback(hObject, eventdata, handles)
% hObject    handle to saveLabelDefsAsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

labelsPath = getappdata(handles.boxIt, 'labelsPath');
labelsName = getappdata(handles.boxIt, 'labelsName');
labelText = getappdata(handles.boxIt, 'labelText');
labelColour = getappdata(handles.boxIt, 'labelColour');

if isempty(labelText)
    warndlg('There are no labels to save', 'No labels');
    return;
end

[labelsName labelsPath] = uiputfile('*.mat', 'Save label definitions');
if labelsName == 0
    return;
end

save([labelsPath labelsName], 'labelText', 'labelColour')
setappdata(handles.boxIt, 'labelsPath', labelsPath);
setappdata(handles.boxIt, 'labelsName', labelsName);



function getMetadata(handles)

global gateway
global session

theImage = getappdata(handles.boxIt, 'theImage');
if isempty(theImage)
    return;
end
imageId = theImage.getId.getValue;
pixels = gateway.getPixelsFromImage(imageId);
pixels = pixels.get(0);
pixelsId = pixels.getId.getValue;

numC = pixels.getSizeC.getValue;
numT = pixels.getSizeT.getValue;
numZ = pixels.getSizeZ.getValue;
sizeX = pixels.getSizeX.getValue;
sizeY = pixels.getSizeY.getValue;
renderingSettings = session.getRenderingSettingsService.getRenderingSettings(pixelsId);
defaultT = renderingSettings.getDefaultT.getValue + 1;
defaultZ = renderingSettings.getDefaultZ.getValue + 1;
imageName = char(theImage.getName.getValue.getBytes');

setappdata(handles.boxIt, 'imageId', imageId);
setappdata(handles.boxIt, 'imageName', imageName);
setappdata(handles.boxIt, 'pixels', pixels)
setappdata(handles.boxIt, 'pixelsId', pixelsId)
setappdata(handles.boxIt, 'numC', numC);
setappdata(handles.boxIt, 'numT', numT);
setappdata(handles.boxIt, 'numZ', numZ);
setappdata(handles.boxIt, 'defaultT', defaultT);
setappdata(handles.boxIt, 'defaultZ', defaultZ);
setappdata(handles.boxIt, 'zoomLevel', 1);
setappdata(handles.boxIt, 'zoomROIMinMax', []);
setappdata(handles.boxIt, 'sizeXY', [sizeX sizeY]);




% --------------------------------------------------------------------
function flattenZItem_Callback(hObject, eventdata, handles)
% hObject    handle to flattenZItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

flattenZ = getappdata(handles.boxIt, 'flattenZ');

if flattenZ == 0
    setappdata(handles.boxIt, 'flattenZ', 1);
    set(hObject, 'Checked', 'on');
else
    setappdata(handles.boxIt, 'flattenZ', 0);
    set(hObject, 'Checked', 'off');
end
refreshDisplay(handles);


% --------------------------------------------------------------------
function flattenTItem_Callback(hObject, eventdata, handles)
% hObject    handle to flattenTItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

flattenT = getappdata(handles.boxIt, 'flattenT');

if flattenT == 0
    setappdata(handles.boxIt, 'flattenT', 1);
    set(hObject, 'Checked', 'on');
else
    setappdata(handles.boxIt, 'flattenT', 0);
    set(hObject, 'Checked', 'off');
end
refreshDisplay(handles);


% --------------------------------------------------------------------
function analysisMenu_Callback(hObject, eventdata, handles)
% hObject    handle to analysisMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function analysePointsItem_Callback(hObject, eventdata, handles)
% hObject    handle to analysePointsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

points = getappdata(handles.boxIt, 'points');
if isempty(points)
    warndlg('No points to analyse.', 'No points');
    return;
end
imageName = getappdata(handles.boxIt, 'imageName');
summaryByImage = pointsSummaryByImage(points, imageName);
summaryByT = pointsSummaryByT(points, imageName, handles);
summaryByZ = pointsSummaryByZ(points, imageName, handles);
[fileName filePath] = uiputfile('*.xls', 'Save data');
if fileName == 0
    return;
end
try
    xlswrite([filePath fileName], summaryByImage, 'Summary by Image');
catch
    [fileName remain] = strtok(fileName, '.');
    delete([filePath fileName]);
    manualCSV(summaryByImage, filePath, [fileName '_SummaryByImage']);
end
try
    xlswrite([filePath fileName], summaryByT, 'Summary by T');
catch
    manualCSV(summaryByImage, filePath, [fileName '_summaryByT']);
end
try
    xlswrite([filePath fileName], summaryByZ, 'Summary by Z');
catch
    manualCSV(summaryByImage, filePath, [fileName '_summaryByZ']);
end





% --------------------------------------------------------------------
function batchAnalysisItem_Callback(hObject, eventdata, handles)
% hObject    handle to batchAnalysisItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gateway;

warning('off', 'MATLAB:xlswrite:AddSheet');
setappdata(handles.boxIt, 'conditions', []);
setappdata(handles.boxIt, 'conditionsPaths', []);
setappdata(handles.boxIt, 'conditionsFiles', []);

batchChooser(handles);

conditions = getappdata(handles.boxIt, 'conditions');
conditionsPaths = getappdata(handles.boxIt, 'conditionsPaths');
conditionsFiles = getappdata(handles.boxIt, 'conditionsFiles');
analyseIndividualFiles = getappdata(handles.boxIt, 'analyseIndividualFiles');
numConditions = length(conditions);
numSteps = 1;
for thisCondition = 1:numConditions
    numFilesThisCondition = length(conditionsFiles{thisCondition});
    for thisFile = 1:numFilesThisCondition
        numSteps = numSteps + 1;
    end
end


if isempty(conditions)
    return;
end
[fileName filePath] = uiputfile('*.xls', 'Save batch data');
if fileName == 0
    return;
end
waitbarHandle = waitbar(0,'Analysing...');
thisStep = 1;
for thisCondition = 1:numConditions
    numFilesThisCondition = length(conditionsFiles{thisCondition});
    for thisFile = 1:numFilesThisCondition
        waitbar(thisStep/(numSteps+1));
        thisStep = thisStep + 1;
        [points{thisCondition}{thisFile} imageId{thisCondition}{thisFile}] = getPointsAndImageId([conditionsPaths{thisCondition} conditionsFiles{thisCondition}{thisFile}]);
        if analyseIndividualFiles == 1
            imageObj = gateway.getImage(imageId{thisCondition}{thisFile});
            imageNameFull = char(imageObj.getName.getValue.getBytes');
            [imageName remain] = strtok(imageNameFull, '.');
            summaryByImage = pointsSummaryByImage(points{thisCondition}{thisFile}, imageName);
            summaryByT = pointsSummaryByT(points{thisCondition}{thisFile}, imageName, handles);
            summaryByZ = pointsSummaryByZ(points{thisCondition}{thisFile}, imageName, handles);
            try
                xlswrite([filePath fileName], summaryByImage, 'Summary by Image');
            catch
                [fileName remain] = strtok(fileName, '.');
                delete([filePath fileName]);
                manualCSV(summaryByImage, filePath, [fileName '_SummaryByImage']);
            end
            try
                xlswrite([filePath fileName], summaryByT, 'Summary by T');
            catch
                manualCSV(summaryByImage, filePath, [fileName '_summaryByT']);
            end
            try
                xlswrite([filePath fileName], summaryByZ, 'Summary by Z');
            catch
                manualCSV(summaryByImage, filePath, [fileName '_summaryByZ']);
            end
        end
    end
end

batchSummary = batchPointsSummary(points, handles);
batchSummaryByT = batchPointsSummaryByT(points, handles);
batchSummaryByZ = batchPointsSummaryByZ(points, handles);
waitbar(1);
try
    xlswrite([filePath fileName], batchSummary, 'Batch Summary');
catch
    [fileName remain] = strtok(fileName, '.');
    manualCSV(summaryByImage, filePath, [fileName 'batchSummary']);
end
try
    xlswrite([filePath fileName], batchSummaryByT, 'Batch Summary By T');
catch
    manualCSV(summaryByImage, filePath, [fileName 'batchSummaryByT']);
end
try
    xlswrite([filePath fileName], batchSummaryByZ, 'Batch Summary By Z');
catch
    manualCSV(summaryByImage, filePath, [fileName 'batchSummaryByZ']);
end
close(waitbarHandle);
warndlg('Analysis complete', 'Complete');




function imageSummary = pointsSummaryByImage(points, imageName)

numPoints = length(points);

for thisPoint = 1:numPoints
    labels{thisPoint} = points{thisPoint}.label;
end
uniqueLabels = unique(labels);
numLabels = length(uniqueLabels);
labelCounter(1:numLabels) = 0;
labelLine = [];
counterLine = [];
totalLine = [];
percentLine = [];
for thisLabel = 1:numLabels
    for thisPoint = 1:numPoints
        if strcmp(points{thisPoint}.label, uniqueLabels{thisLabel})
            labelCounter(thisLabel) = labelCounter(thisLabel) + 1;
        end
    end
    if thisLabel == 1
        titleLine = {imageName};
    else
        titleLine = [titleLine {''}];
    end
    labelLine = [labelLine {uniqueLabels{thisLabel}}];
    counterLine = [counterLine {num2str(labelCounter(thisLabel))}];
    totalLine = [totalLine labelCounter(thisLabel)];
end
for thisLabel = 1:numLabels
    percentLine = [percentLine {[num2str((totalLine(thisLabel)/(sum(totalLine))*100)), '%']}];
end

imageSummary = [titleLine; labelLine; counterLine; percentLine];



function summaryByT = pointsSummaryByT(points, imageName, handles)

numPoints = length(points);
numT = getappdata(handles.boxIt, 'numT');

for thisPoint = 1:numPoints
    labels{thisPoint} = points{thisPoint}.label;
end
uniqueLabels = unique(labels);
numLabels = length(uniqueLabels);
labelCounter(1:numLabels) = 0;
labelLine = [];
counterLine = [];
counterBlock = [];
tCounter(numT, numLabels) = 0;
for thisT = 1:numT
    for thisLabel = 1:numLabels
        for thisPoint = 1:numPoints
            currPoint = points{thisPoint}; % = [currentPoint(1) currentPoint(3) thisZ thisT];
            if strcmp(currPoint.label, uniqueLabels{thisLabel})
                pointT = currPoint.Position(4);
                if thisT == pointT
                    tCounter(thisT, thisLabel) = tCounter(thisT, thisLabel) + 1;
                end
            end
        end
    end
end

for thisT = 1:numT
    if thisT == 1
        titleLine = {imageName};
        labelLine = {''};
    end
    counterLine = {['T:', num2str(thisT)]};
    
    for thisLabel = 1:numLabels
        if thisT == 1
            labelLine = [labelLine {uniqueLabels{thisLabel}}];
            titleLine = [titleLine {''}];
        end
        counterLine = [counterLine {num2str(tCounter(thisT, thisLabel))}];
    end
    counterBlock = [counterBlock; counterLine];
end

summaryByT = [titleLine; labelLine; counterBlock];



function summaryByZ = pointsSummaryByZ(points, imageName, handles)

numPoints = length(points);
numZ = getappdata(handles.boxIt, 'numZ');

for thisPoint = 1:numPoints
    labels{thisPoint} = points{thisPoint}.label;
end
uniqueLabels = unique(labels);
numLabels = length(uniqueLabels);
labelCounter(1:numLabels) = 0;
labelLine = [];
counterLine = [];
counterBlock = [];
zCounter(numZ, numLabels) = 0;
for thisZ = 1:numZ
    for thisLabel = 1:numLabels
        for thisPoint = 1:numPoints
            currPoint = points{thisPoint}; % = [currentPoint(1) currentPoint(3) thisZ thisT];
            if strcmp(currPoint.label, uniqueLabels{thisLabel})
                pointZ = currPoint.Position(3);
                if thisZ == pointZ
                    zCounter(thisZ, thisLabel) = zCounter(thisZ, thisLabel) + 1;
                end
            end
        end
    end
end

for thisZ = 1:numZ
    if thisZ == 1
        titleLine = {imageName};
        labelLine = {''};
    end
    counterLine = {['Z:', num2str(thisZ)]};
    
    for thisLabel = 1:numLabels
        if thisZ == 1
            labelLine = [labelLine {uniqueLabels{thisLabel}}];
            titleLine = [titleLine {''}];
        end
        counterLine = [counterLine {num2str(zCounter(thisZ, thisLabel))}];
    end
    counterBlock = [counterBlock; counterLine];
end

summaryByZ = [titleLine; labelLine; counterBlock];



function [points imageId] = getPointsAndImageId(fileNamePath)

vars = load(fileNamePath);
points = vars.points;
imageId = vars.imageId;


function batchSummary = batchPointsSummary(points, handles)

conditions = getappdata(handles.boxIt, 'conditions');
if isempty(conditions)
    return;
end
counter = 1;
numConditions = length(points);
for thisCondition = 1:numConditions
    numFiles = length(points{thisCondition});
    for thisFile = 1:numFiles
        numPoints = length(points{thisCondition}{thisFile});

        for thisPoint = 1:numPoints
            labels{counter} = points{thisCondition}{thisFile}{thisPoint}.label;
            counter = counter + 1;
        end
    end
end
uniqueLabels = unique(labels);
numLabels = length(uniqueLabels);
labelCounter(numLabels, numConditions) = 0;
labelLine = [];
counterLine = [];
totalLine = [];
percentLine = [];
summaryBlock = [];

for thisLabel = 1:numLabels
    for thisCondition = 1:numConditions
        numFiles = length(points{thisCondition});
        for thisFile = 1:numFiles
            numPoints = length(points{thisCondition}{thisFile});
            for thisPoint = 1:numPoints
                if strcmp(points{thisCondition}{thisFile}{thisPoint}.label, uniqueLabels{thisLabel})
                    labelCounter(thisLabel, thisCondition) = labelCounter(thisLabel, thisCondition) + 1;
                end
            end
        end
    end
end

for thisLabel = 1:numLabels
    if thisLabel == 1
        labelLine = [{''} {uniqueLabels{thisLabel}}];
    else
        labelLine = [labelLine {uniqueLabels{thisLabel}}];
    end
end

for thisCondition = 1:numConditions
    for thisLabel = 1:numLabels
        if thisLabel == 1
            counterLine = {conditions{thisCondition}};
        end
        counterLine = [counterLine {num2str(labelCounter(thisLabel, thisCondition))}];
    end
    summaryBlock = [summaryBlock; counterLine];
end

batchSummary = [labelLine; summaryBlock;];



function batchSummaryByT = batchPointsSummaryByT(points, handles)

conditions = getappdata(handles.boxIt, 'conditions');
if isempty(conditions)
    return;
end
counter = 1;
numConditions = length(points);
for thisCondition = 1:numConditions
    numFiles = length(points{thisCondition});
    for thisFile = 1:numFiles
        numPoints = length(points{thisCondition}{thisFile});
        for thisPoint = 1:numPoints
            labels{counter} = points{thisCondition}{thisFile}{thisPoint}.label;
            counter = counter + 1;
        end
    end
end
%Get the maximum time point from all points made.
maxT = 1;
for thisCondition = 1:numConditions
    numFiles = length(points{thisCondition});
    for thisFile = 1:numFiles
        numPoints = length(points{thisCondition}{thisFile});
        for thisPoint = 1:numPoints
            currPoint = points{thisCondition}{thisFile}{thisPoint}; % = [currentPoint(1) currentPoint(3) thisZ thisT];
            pointT = currPoint.Position(4);
            if pointT > maxT
                maxT = pointT;
            end
        end
    end
end

%Gather the data before making the output cell.
uniqueLabels = unique(labels);
numLabels = length(uniqueLabels);
counterBlock = [];
for thisCondition = 1:numConditions
    tConditionCounter{thisCondition}(maxT, numLabels) = 0;
end
for thisLabel = 1:numLabels
    for thisCondition = 1:numConditions
        tFileCounter(1:maxT, 1:numLabels) = 0;
        numFiles = length(points{thisCondition});
        for thisFile = 1:numFiles
            numPoints = length(points{thisCondition}{thisFile});
            tCounter(1:maxT, 1:numLabels) = 0;
            for thisPoint = 1:numPoints
                currPoint = points{thisCondition}{thisFile}{thisPoint}; % = [currentPoint(1) currentPoint(3) thisZ thisT];
                for thisT = 1:maxT
                    if strcmp(currPoint.label, uniqueLabels{thisLabel})
                        pointT = currPoint.Position(4);
                        if thisT == pointT
                            tCounter(thisT, thisLabel) = tCounter(thisT, thisLabel) + 1;
                        end
                    end
                end
                
            end
            tFileCounter = tFileCounter + tCounter;
        end
        tConditionCounter{thisCondition} = tConditionCounter{thisCondition} + tFileCounter;
    end
end

emptyLine = [];
for thisLabel = 1:numLabels+1
    emptyLine = [emptyLine {''}];
end

batchSummaryByT = [];
for thisCondition = 1:numConditions
    counterBlock = [];
    labelLine = {conditions{thisCondition}};
    for thisLabel = 1:numLabels
        labelLine = [labelLine {uniqueLabels{thisLabel}}];
    end
    for thisT = 1:maxT
        counterLine = {['T:', num2str(thisT)]};
        for thisLabel = 1:numLabels
            counterLine = [counterLine {num2str(tConditionCounter{thisCondition}(thisT, thisLabel))}];
        end
        counterBlock = [counterBlock; counterLine];
    end
    batchSummaryByT = [batchSummaryByT; labelLine; counterBlock; emptyLine; emptyLine];
end



function batchSummaryByZ = batchPointsSummaryByZ(points, handles)

conditions = getappdata(handles.boxIt, 'conditions');
if isempty(conditions)
    return;
end
counter = 1;
numConditions = length(points);
for thisCondition = 1:numConditions
    numFiles = length(points{thisCondition});
    for thisFile = 1:numFiles
        numPoints = length(points{thisCondition}{thisFile});
        for thisPoint = 1:numPoints
            labels{counter} = points{thisCondition}{thisFile}{thisPoint}.label;
            counter = counter + 1;
        end
    end
end
%Get the maximum Z section from all points made.
maxZ = 1;
for thisCondition = 1:numConditions
    numFiles = length(points{thisCondition});
    for thisFile = 1:numFiles
        numPoints = length(points{thisCondition}{thisFile});
        for thisPoint = 1:numPoints
            currPoint = points{thisCondition}{thisFile}{thisPoint}; % = [currentPoint(1) currentPoint(3) thisZ thisT];
            pointZ = currPoint.Position(3);
            if pointZ > maxZ
                maxZ = pointZ;
            end
        end
    end
end

%Gather the data before making the output cell.
uniqueLabels = unique(labels);
numLabels = length(uniqueLabels);
counterBlock = [];
for thisCondition = 1:numConditions
    zConditionCounter{thisCondition}(maxZ, numLabels) = 0;
end
for thisLabel = 1:numLabels
    for thisCondition = 1:numConditions
        zFileCounter(1:maxZ, 1:numLabels) = 0;
        numFiles = length(points{thisCondition});
        for thisFile = 1:numFiles
            numPoints = length(points{thisCondition}{thisFile});
            zCounter(1:maxZ, 1:numLabels) = 0;
            for thisPoint = 1:numPoints
                currPoint = points{thisCondition}{thisFile}{thisPoint}; % = [currentPoint(1) currentPoint(3) thisZ thisT];
                for thisZ = 1:maxZ
                    if strcmp(currPoint.label, uniqueLabels{thisLabel})
                        pointZ = currPoint.Position(3);
                        if thisZ == pointZ
                            zCounter(thisZ, thisLabel) = zCounter(thisZ, thisLabel) + 1;
                        end
                    end
                end
                
            end
            zFileCounter = zFileCounter + zCounter;
        end
        zConditionCounter{thisCondition} = zConditionCounter{thisCondition} + zFileCounter;
    end
end

emptyLine = [];
for thisLabel = 1:numLabels+1
    emptyLine = [emptyLine {''}];
end

batchSummaryByZ = [];
for thisCondition = 1:numConditions
    counterBlock = [];
    labelLine = {conditions{thisCondition}};
    for thisLabel = 1:numLabels
        labelLine = [labelLine {uniqueLabels{thisLabel}}];
    end
    for thisZ = 1:maxZ
        counterLine = {['Z:', num2str(thisZ)]};
        for thisLabel = 1:numLabels
            counterLine = [counterLine {num2str(zConditionCounter{thisCondition}(thisZ, thisLabel))}];
        end
        counterBlock = [counterBlock; counterLine];
    end
    batchSummaryByZ = [batchSummaryByZ; labelLine; counterBlock; emptyLine; emptyLine];
end


% --- Executes on button press in deleteROIButton.
function deleteROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

deleteROI(handles)



function segmentPatch(handles)

global fig1;
global ROIText;

ROIs = getappdata(handles.boxIt, 'ROIs');
rect = getappdata(handles.boxIt, 'rect');
plane = double(getappdata(handles.boxIt, 'currentPlane'));
verifyZ = get(handles.verifyZCheck, 'Value');
thisZ = round(get(handles.zSlider, 'Value'));
thisT = round(get(handles.tSlider, 'Value'));
numZ = getappdata(handles.boxIt, 'numZ');
numROIs = length(ROIs);
zInHand = size(plane, 3);
if zInHand < numZ
    getPlane(handles);
    plane = double(getappdata(handles.boxIt, 'currentPlane'));
end
zHeight = str2double(get(handles.zHeightText, 'String'));
if zHeight ~= 0
    zHeight = floor(zHeight/2);
    minZ = thisZ - zHeight;
    maxZ = thisZ + zHeight;
    patchZ = round(zHeight/2)+minZ-1;
    if minZ < 1
        minZ = 1;
    end
    if maxZ > numZ
        maxZ = numZ;
    end
else
    minZ = 1;
    maxZ = numZ;
    patchZ = thisZ;
end
sizePlane = size(plane);
xStart = int16(rect(1));
yStart = int16(rect(2));
xEnd = int16(rect(1)+rect(3));
yEnd = int16(rect(2)+rect(4));
if xStart < 1
    xStart = 1;
end
if yStart < 1
    yStart = 1;
end
if xEnd > sizePlane(2)
    xEnd = sizePlane(2);
end
if yEnd > sizePlane(1)
    yEnd = sizePlane(1);
end
zCounter = 1;
for z = minZ:maxZ
    patch(:,:,zCounter) = plane(yStart:yEnd, xStart(1):xEnd, z);
    zCounter = zCounter + 1;
end
patchSize = size(patch);
[maskStack minValue] = seg3D(patch, 0, 0, 1);
maskStackBWL = bwlabeln(maskStack);
if zHeight ~= 0
    masksThisZ = unique(maskStackBWL(:,:,zHeight));
else
    masksThisZ = unique(maskStackBWL(:,:,thisZ));
end
masksThisZ = masksThisZ(2:end);
numMasksThisZ = length(masksThisZ);
if numMasksThisZ > 1
    if zHeight ~= 0
        boxItObjectChooser(handles, maskStack(:,:,zHeight));
    else
        boxItObjectChooser(handles, maskStack(:,:,thisZ));
    end
    objectValue = getappdata(handles.boxIt, 'objectValue');
else
    objectValue = masksThisZ;
end
if isempty(objectValue)
    return;
end
zRange = [];
xRange = [];
yRange = [];

if verifyZ == 1
    scrsz = get(0,'ScreenSize');
    fig1 = figure('Name','Choose z-sections...','NumberTitle','off','MenuBar','none','Position',[(scrsz(3)/2)-150 (scrsz(4)/2)-180 300 80]);
    ROIText = uicontrol(fig1, 'Style', 'text', 'Position', [25 40 250 15]);
    [startZ stopZ] = zChooser((maskStackBWL==objectValue));
    zRange = startZ:stopZ;
    zRange = zRange + (minZ-1);
    close(fig1);
else
    for z = 1:zCounter-1
        if find(maskStackBWL(:,:,z) == objectValue)
            zRange = [zRange (z + minZ - 1)];
        end
    end
end
for x = 1:patchSize(2)
    if find(maskStackBWL(:,x,(zRange-minZ+1)) == objectValue)
        xRange = [xRange (x + rect(1))];
    end
end
for y = 1:patchSize(1)
    if find(maskStackBWL(y,:,(zRange-minZ+1)) == objectValue)
        yRange = [yRange (y + rect(2))];
    end
end



rect(1) = xRange(1)-2;
rect(2) = yRange(1)-2;
rect(3) = length(xRange);
rect(4) = length(yRange);

ROIs{end+1}.rect = rect;
ROIs{end}.zRange = zRange;
ROIs{end}.numShapes = length(zRange);
ROIs{end}.t = thisT;
ROIs{end}.id = numROIs + 1;
ROIs{end}.ROIId = 0;
setappdata(handles.boxIt, 'ROIs', ROIs);
redrawROIs(handles);


function redrawROIs(handles)

ROIs = getappdata(handles.boxIt, 'ROIs');
numROIs = length(ROIs);
thisZ = round(get(handles.zSlider, 'Value'));
thisT = round(get(handles.tSlider, 'Value'));
for thisROI = 1:numROIs
    rect = ROIs{thisROI}.rect;
    zRange = ROIs{thisROI}.zRange;
    t = ROIs{thisROI}.t;
    if ismember(thisZ, zRange) && t == thisT
        rectangle('Position', rect, 'edgecolor', 'white', 'HitTest', 'off');
    end
end
        

function ROIsToXml(handles)

ROIs = getappdata(handles.boxIt, 'ROIs');
savePath = getappdata(handles.boxIt, 'savePath');
xmlStruct = load('newXmlStruct.mat');
ROIProforma = load('ROIProforma.mat');
rectProforma = load('rectProforma.mat');
xmlStruct = xmlStruct.newXmlStruct;
ROIProforma = ROIProforma.ROIProforma;
rectProforma = rectProforma.rectProforma;

newXmlStruct = xmlStruct;
numROIs = length(ROIs);
for thisROI = 1:numROIs
    newROI = ROIProforma;
    newROI.attributes(1).value = num2str(ROIs{thisROI}.id); %ROI id.
    numROIZ = length(ROIs{thisROI}.zRange);
    for thisROIZ = 1:numROIZ
        roiShape = rectProforma;
        %Fill out the 'annotation' section.
        roiShape.attributes(1).value = num2str(ROIs{thisROI}.t-1); %t
        roiShape.attributes(2).value = num2str(ROIs{thisROI}.zRange(thisROIZ)-1); %z
        roiShape.children(2).children(2).attributes(2).value = num2str(round(ROIs{thisROI}.rect(1) + (ROIs{thisROI}.rect(3)/2))); %cx
        roiShape.children(2).children(4).attributes(2).value = num2str(round(ROIs{thisROI}.rect(2) + (ROIs{thisROI}.rect(4)/2))); %cy
        roiShape.children(2).children(6).attributes(2).value = num2str(ROIs{thisROI}.rect(4)); %Height
        roiShape.children(2).children(8).attributes(2).value = num2str((ROIs{thisROI}.rect(3)*2)+(ROIs{thisROI}.rect(4)*2)); %Perimeter
        roiShape.children(2).children(10).attributes(2).value = num2str(ROIs{thisROI}.rect(3)*ROIs{thisROI}.rect(4)); %Area
        roiShape.children(2).children(12).attributes(2).value = num2str(ROIs{thisROI}.rect(3)); %Width
        %Fill out the 'svg' section.
        roiShape.children(4).children(2).attributes(6).value = num2str(ROIs{thisROI}.rect(4)); %Height
        roiShape.children(4).children(2).attributes(14).value = num2str(ROIs{thisROI}.rect(3)); %Width
        roiShape.children(4).children(2).attributes(15).value = num2str(ROIs{thisROI}.rect(1)); %x
        roiShape.children(4).children(2).attributes(16).value = num2str(ROIs{thisROI}.rect(2)); %y
        %Fill out the 'svg text' section.
        roiShape.children(4).children(4).attributes(8).value = num2str(ROIs{thisROI}.rect(1)); %x
        roiShape.children(4).children(4).attributes(9).value = num2str(ROIs{thisROI}.rect(2)); %y
        %Add this roiShape to the current ROI.
        newROI.children((thisROIZ*2)-1) = ROIProforma.children(1);
        newROI.children(thisROIZ*2) = roiShape;
    end
    %Attach roi to xmlStruct.
    newXmlStruct.children((thisROI*2)+ 1) = xmlStruct.children(4).children(1);
    newXmlStruct.children((thisROI*2)+ 2) = newROI;
end

%Create the document and write the xml.
imageNameFull = getappdata(handles.boxIt, 'imageName');
imageNameScanned = textscan(imageNameFull, '%s', 'Delimiter', '/');
imageNameNoPaths = imageNameScanned{1}{end};
[imageName remain] = strtok(imageNameNoPaths, '.');
imageNameXml = [imageName '.xml'];
[fileName filePath] = uiputfile('*.xml','Save ROI File', [savePath imageNameXml]);
if fileName == 0
    return;
end
DocNode = struct2xml(newXmlStruct);
xmlwrite([filePath fileName], DocNode);
setappdata(handles.boxIt, 'savePath', filePath);
setappdata(handles.boxIt, 'saveFileName', fileName);

%Update RoiMapFile
answer = questdlg([{'Would you like to have these ROIs viewable in OMERO.insight?'} {'Any previous ROI file will be unlinked from the image'}], 'Show ROIs in OMERO.insight?', 'Yes', 'No', 'No');
if strcmp(answer, 'Yes')
    server = getappdata(handles.boxIt, 'server');
    username = getappdata(handles.boxIt, 'username');
    pixelsId = getappdata(handles.boxIt, 'pixelsId');
    filePath = getappdata(handles.boxIt, 'savePath');
    fileName = getappdata(handles.boxIt, 'saveFileName');
    updateROIMapFile(username, server, pixelsId, [filePath fileName]);
end
setappdata(handles.boxIt, 'modified', 0);
        



function zHeightText_Callback(hObject, eventdata, handles)
% hObject    handle to zHeightText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zHeightText as text
%        str2double(get(hObject,'String')) returns contents of zHeightText as a double

zHeight = get(hObject, 'String');
if isnan(str2double(zHeight)) || isempty(zHeight);
    oldZHeight = getappdata(handles.boxIt, 'zHeight');
    set(hObject, 'String', oldZHeight);
else
    setappdata(handles.boxIt, 'zHeight', zHeight);
end


% --- Executes during object creation, after setting all properties.
function zHeightText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zHeightText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in verifyZCheck.
function verifyZCheck_Callback(hObject, eventdata, handles)
% hObject    handle to verifyZCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of verifyZCheck


function setControls(handles)

pixels = getappdata(handles.boxIt, 'pixels');
imageName = getappdata(handles.boxIt, 'imageName');
channelLabel = getSegChannel(pixels);
set(handles.channelSelect, 'String', channelLabel);
set(handles.channelSelect, 'Value', 1);
set(handles.imageNameLabel, 'String', imageName);
setTControls(handles);
setZControls(handles);


function ROIsToServer(handles)
global session

iUpdate = session.getUpdateService;

ROIs = getappdata(handles.boxIt, 'ROIs');
theImage = getappdata(handles.boxIt, 'theImage');
numROIs = length(ROIs);
for thisROI = 1:numROIs
    if ROIs{thisROI}.ROIId > 0 %Don't re-save ROIs. If it has a server id then skip it out.
        continue;
    end
    ROIObj = pojos.ROIData;
    ROIObj.setImage(theImage);
    numShapes = ROIs{thisROI}.numShapes;
    for thisShape = 1:numShapes
        shapeObj = createRectObj(ROIs{thisROI}.rect(1), ROIs{thisROI}.rect(2), ROIs{thisROI}.zRange(thisShape)-1, 0, ROIs{thisROI}.rect(3), ROIs{thisROI}.rect(4));
        ROIObj.addShapeData(shapeObj);
    end
    savedROI = iUpdate.saveAndReturnObject(ROIObj.asIObject);
    ROIs{thisROI}.ROIId = savedROI.getId.getValue;
end
setappdata(handles.boxIt, 'ROIs', ROIs);



% --- Executes on button press in nextImageButton.
% This button enables the user to open the next image in the dataset.
function nextImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%The gateway function enables nextImageButton to communicate with the OMERO 
%server. This is a global variable and therefore it is declared at the
%start.
global gateway

%Declaration of the current image ID variables: The image, project and
%dataset IDs are stored in the application data.
imageId = getappdata (handles.boxIt, 'imageId');
projectId = getappdata(handles.boxIt, 'projectId');
dsId = getappdata(handles.boxIt, 'datasetId');
datasetId = java.util.ArrayList;
datasetId.add(java.lang.Long(dsId));
datasetContainer = omero.api.ContainerClass.Dataset;

%An ArrayList of images in the current dataset is retrieved from the OMERO 
%server.
images = gateway.getImages(datasetContainer,datasetId);

%The number of images in the dataset is determined and the associated
%image IDs are loaded and sorted them from smallest to largest.
numImages = images.size;
for thisImage = 0:numImages-1
    imageIds(thisImage+1) = images.get(thisImage).getId.getValue;
end
imageIds = sort(imageIds);

%The position of the current image in the datset is determined.
for thisImage = 1:numImages
    if imageId == imageIds(thisImage);
        break;
    end
end

%After making sure that the current image is not the last image in the
%dataset, a new variable is created that stores the image ID and  associated
%with the next imge in the dataset.
if thisImage < numImages
    newImageId = imageIds(thisImage +1);
else
    set(hObject, 'enable', 'off')
    warndlg('There is no "Next Image".');
    return;
end
newImageObj = gateway.getImage(newImageId);

%The application data of the next replace the application data of the open
%image so that the next image becomes the current image.
setappdata(handles.boxIt, 'theImage', newImageObj);
setappdata(handles.boxIt, 'imageId', newImageId);

%The next image in the datasetis loaded into the Box It window.
loadNewImage(handles);





% --- Executes on button press in prevImageButton.
function prevImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to prevImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gateway

imageId = getappdata (handles.boxIt, 'imageId');
projectId = getappdata(handles.boxIt, 'projectId');
dsId = getappdata(handles.boxIt, 'datasetId');
datasetId = java.util.ArrayList;
datasetId.add(java.lang.Long(dsId));
datasetContainer = omero.api.ContainerClass.Dataset;

%An ArrayList of images in the current dataset is retrieved from the OMERO 
%server.
images = gateway.getImages(datasetContainer,datasetId);

%The number of images in the dataset is determined and the associated
%image IDs are loaded and sorted them from smallest to largest.
numImages = images.size;
for thisImage = 0:numImages-1
    imageIds(thisImage+1) = images.get(thisImage).getId.getValue;
end
imageIds = sort(imageIds);

%The position of the current image in the datset is determined.
for thisImage = 1:numImages
    if imageId == imageIds(thisImage);
        break;
    end
end

%After making sure that the current image is not the first image in the
%dataset, a new variable is created that stores the image ID and  associated
%with the next imge in the dataset.
%The imageIds array is created in Matlab and indexes from 1. Therefore, the
%first image in the dataset has the index 1.
if thisImage > 1
     newImageId = imageIds(thisImage -1);
else
    set(hObject, 'enable', 'off')
    warndlg('There is no "Previous Image".');
    return;
end
newImageObj = gateway.getImage(newImageId);

%The application data of the next replace the application data of the open
%image so that the next image becomes the current image.
setappdata(handles.boxIt, 'theImage', newImageObj);
setappdata(handles.boxIt, 'imageId', newImageId);

%The next image in the datasetis loaded into the Box It window.
loadNewImage(handles);

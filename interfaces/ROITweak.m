function varargout = ROITweak(varargin)
% ROITWEAK M-file for roitweak.fig
%      ROITWEAK, by itself, creates a new ROITWEAK or raises the existing
%      singleton*.
%
%      H = ROITWEAK returns the handle to a new ROITWEAK or the handle to
%      the existing singleton*.
%
%      ROITWEAK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROITWEAK.M with the given input arguments.
%
%      ROITWEAK('Property','Value',...) creates a new ROITWEAK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROITweak_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROITweak_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roitweak

% Last Modified by GUIDE v2.5 12-Aug-2013 17:28:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROITweak_OpeningFcn, ...
                   'gui_OutputFcn',  @ROITweak_OutputFcn, ...
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


% --- Executes just before roitweak is made visible.
function ROITweak_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roitweak (see VARARGIN)

global gateway;
%Set up the play and pause buttons
startImage = imread('startImage.jpg', 'jpg');
playIcon = imread('playButton.png', 'png');
pauseIcon = imread('pauseButton.png', 'png');
zoomInIcon = imread('zoomInButton.png', 'png');
zoomOutIcon = imread('zoomOutButton.png', 'png');
set(handles.playButton,'CDATA',playIcon);
set(handles.pauseButton,'CDATA',pauseIcon);
set(handles.zoomInButton,'CDATA',zoomInIcon);
set(handles.zoomOutButton,'CDATA',zoomOutIcon);
axes(handles.imageAxes);
imshow(startImage);

% Choose default command line output for roitweak
set(handles.ROITweak, 'windowbuttonmotionfcn', {@windowButtonMotion, handles});
set(handles.ROITweak, 'keypressfcn', {@currentWindowKeypress, handles});
%set(handles.recordROIButton,'keypressfcn','eval(get(gcbf,''keypressfcn''))');
handles.output = hObject;

alertTextLong = [{'Position cursor.'} {'Playback in 5'} {'"Esc" to abort'}];

setappdata(handles.ROITweak, 'username', varargin{1});
setappdata(handles.ROITweak, 'server', varargin{2});
setappdata(handles.ROITweak, 'recentreROI', 0);
setappdata(handles.ROITweak, 'numT', 1);
setappdata(handles.ROITweak, 'numZ', 1);
setappdata(handles.ROITweak, 'modified', 0);
setappdata(handles.ROITweak, 'currDir', pwd);
setappdata(handles.ROITweak, 'zoomLevel', 1);
setappdata(handles.ROITweak, 'stopRecording', 1);
setappdata(handles.ROITweak, 'alertTextLong', alertTextLong);
setappdata(handles.ROITweak, 'ROIsToUpdate', []);
set(handles.imageNameLabel, 'String', 'No File Open');
set(handles.tSlider, 'Enable', 'off');
setZSlider(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes roitweak wait for user response (see UIRESUME)
uiwait(handles.ROITweak);


% --- Outputs from this function are returned to the command line.
function varargout = ROITweak_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
varargout{1} = [];


% --- Executes on button press in setAnchorButton.
function setAnchorButton_Callback(hObject, eventdata, handles)
% hObject    handle to setAnchorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(gcf,'Pointer','fleur');
setAnchor = 1;
setappdata(handles.ROITweak, 'setAnchor', setAnchor);
setappdata(handles.ROITweak, 'setAlignment', 0);



% --- Executes on button press in recordROIButton.
function recordROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to recordROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

recordCentreMode(handles, 'ROITweak');
recordMode = getappdata(handles.ROITweak, 'recordMode');
frameDelay = str2double(get(handles.delayText, 'String'));
thisZ = round(get(handles.zSlider, 'Value'));
set(handles.alertText, 'Visible', 'on');
firstT = str2double(get(handles.startTText, 'String'));
lastT = str2double(get(handles.endTText, 'String'));
set(handles.tSlider, 'Value', firstT);
set(handles.tLabel, 'String', ['T = ' num2str(firstT)]);
setappdata(handles.ROITweak, 'rotationView', 0);
getThePlane(handles, thisZ-1, firstT-1)
redrawImage(handles);
setappdata(handles.ROITweak, 'stopRecording', 0);
setappdata(handles.ROITweak, 'trapPointer', 1);
set(0,'currentFigure',handles.ROITweak)
figure(handles.ROITweak);
if strcmp(recordMode, 'clickMode')
    alertStr = [{'Click to move to'} {'next timepoint'} {'"Esc" to abort'}];
    set(handles.alertText, 'String', alertStr);
    set(handles.alertText, 'Enable', 'on');
else
    for i = 5:-1:0
        alertStr = getappdata(handles.ROITweak, 'alertTextLong');
        alertStr{2}(end) = num2str(i);
        set(handles.alertText, 'String', alertStr);
        stopRecording = getappdata(handles.ROITweak, 'stopRecording');
        if stopRecording == 1
            set(handles.alertText, 'Visible', 'off');
            redrawROIs(handles);
            setappdata(handles.ROITweak, 'trapPointer', 0);
            set(gcf,'Pointer','arrow');
            set(handles.alertText, 'Visible', 'off');
            break;
        end
        pause(1);
    end
end
%Make sure the window is activated
%mouseClick;
set(gcf,'Pointer','crosshair');
for thisT = firstT:lastT
    set(gcf,'Pointer','crosshair');
    if thisT == firstT
        setROICentre(handles);
    end
    stopRecording = getappdata(handles.ROITweak, 'stopRecording');
    if stopRecording == 1
        set(handles.alertText, 'Visible', 'off');
        redrawROIs(handles);
        setappdata(handles.ROITweak, 'trapPointer', 0);
        set(gcf,'Pointer','arrow');
        break;
    end
    getThePlane(handles, thisZ-1, thisT-1)
    redrawImage(handles);
    set(handles.tSlider, 'Value', thisT);
    set(handles.tLabel, 'String', ['T = ' num2str(thisT)]);
    if strcmp(recordMode, 'clickMode')
        uiwait;
    else
        pause(frameDelay);
    end
    setROICentre(handles);
    %redrawROIs(handles)
end
set(gcf,'Pointer','arrow');
refreshDisplay(handles);
alertStr = get(handles.alertText, 'String');
alertStr{2}(end) = num2str(5);
set(handles.alertText, 'String', alertStr);
set(handles.alertText, 'Visible', 'off');
setappdata(handles.ROITweak, 'trapPointer', 0);
    
    



function delayText_Callback(hObject, eventdata, handles)
% hObject    handle to delayText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delayText as text
%        str2double(get(hObject,'String')) returns contents of delayText as a double


% --- Executes during object creation, after setting all properties.
function delayText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delayText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function tSlider_Callback(hObject, eventdata, handles)
% hObject    handle to tSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

z = round(get(handles.zSlider, 'Value'));
t = round(get(hObject, 'Value'));
set(handles.tLabel, 'String', ['T = ' num2str(t)]);
getThePlane(handles, z-1, t-1);
redrawImage(handles);
redrawROIs(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function tSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function getThePlane(handles, z, t)
global session

imageId = getappdata(handles.ROITweak, 'imageId');
pixelsId = getappdata(handles.ROITweak, 'pixelsId');
pixels = getappdata(handles.ROITweak, 'pixels');
numC = getappdata(handles.ROITweak, 'numC');
for thisC = 1:numC
    plane(:,:,thisC) = getPlane(session, imageId, z, thisC-1, t); %getPlaneFromPixelsId(pixelsId, z, thisC-1, t);
end
renderedImage = createRenderedImage(plane, pixels);
imageSize = size(renderedImage);
setappdata(handles.ROITweak, 'renderedImage', renderedImage);
setappdata(handles.ROITweak, 'imageSize', imageSize);




function setTSlider(handles)

numT = getappdata(handles.ROITweak, 'numT');
if numT == 1
    set(handles.tSlider, 'Max', numT);
    set(handles.tSlider, 'Min', 0);
    set(handles.tSlider, 'Value', 1);
    set(handles.tSlider, 'Enable', 0);
else
    sliderSmallStep = 1/numT;
    set(handles.tSlider, 'Max', numT);
    set(handles.tSlider, 'Min', 1);
    set(handles.tSlider, 'Value', 1);
    set(handles.tSlider, 'SliderStep', [sliderSmallStep, sliderSmallStep*4]);
    set(handles.tSlider, 'Enable', 'on');
    set(handles.tLabel, 'String', 'T = 1');
end



function setZSlider(handles)

numZ = getappdata(handles.ROITweak, 'numZ');
if numZ > 1
    sliderSmallStep = 1/numZ;
    set(handles.zSlider, 'Max', numZ);
    set(handles.zSlider, 'Min', 1);
    set(handles.zSlider, 'Value', 1);
    set(handles.zSlider, 'SliderStep', [sliderSmallStep, sliderSmallStep*4]);
    set(handles.zLabel, 'String', 'Z = 1');
else
    set(handles.zSlider, 'Enable', 'off');
    set(handles.zSlider, 'Value', 1);
end


% --- Executes on slider movement.
function zSlider_Callback(hObject, eventdata, handles)
% hObject    handle to zSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

z = round(get(hObject, 'Value'));
t = round(get(handles.tSlider, 'Value'));
set(handles.zLabel, 'String', ['Z = ' num2str(z)]);
axes(handles.imageAxes);
getThePlane(handles, z-1, t-1);
redrawImage(handles);
redrawROIs(handles);
guidata(hObject, handles);




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

recentreROI = getappdata(handles.ROITweak, 'recentreROI');
if recentreROI == 1
    setROICentre(handles);
    setappdata(handles.ROITweak, 'recentreROI', 0);
    refreshDisplay(handles);
else
    recordMode = getappdata(handles.ROITweak, 'recordMode');
    if strcmp(recordMode, 'clickMode')
        uiresume
    end
end
set(gcf,'Pointer','arrow');




function redrawROIs(handles)

roiShapes = getappdata(handles.ROITweak, 'roiShapes');

%xmlStruct = getappdata(handles.ROITweak, 'xmlStruct');
thisZ = round(get(handles.zSlider, 'Value'));
thisT = round(get(handles.tSlider, 'Value'));
roiSelectString = get(handles.roiSelect, 'String');
roiSelectValue = get(handles.roiSelect, 'Value');
ROIIds = getappdata(handles.ROITweak, 'ROIIds');
ROIIdx = getappdata(handles.ROITweak, 'ROIIdx');
ROIShapes = getappdata(handles.ROITweak, 'ROIShapes');
ROICount = getappdata(handles.ROITweak, 'ROICount');
zoomLevel = getappdata(handles.ROITweak, 'zoomLevel');
zoomROICentre = getappdata(handles.ROITweak, 'zoomROICentre');
playing = getappdata(handles.ROITweak, 'playing');
rTransX = getappdata(handles.ROITweak, 'rTransX');
rTransY = getappdata(handles.ROITweak, 'rTransY');

if strcmp(roiSelectString{roiSelectValue}, 'All')
    %for thisROI = 1:length(roiSelectString);
    ROIsToDraw = ROIIdx;
    %end
else
    ROIsToDraw = ROIIdx(roiSelectValue-1);
end

numROIs = length(ROIsToDraw);
for thisROI = 1:numROIs
    thisROIIdx = ROIsToDraw(thisROI);
    if numROIs > 1
        thisROIShape = ROIShapes{thisROI};
    else
        if ROICount == 1
            thisROIShape = ROIShapes{1};
        else
            thisROIShape = ROIShapes{roiSelectValue-1};
        end
    end
    %First the ellipses:
    if strcmpi(thisROIShape, 'ellipse')
        numShapes = roiShapes{thisROIIdx}.numShapes;
        for thisShape = 1:numShapes
            shapeT = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheT.getValue;
            shapeZ = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheZ.getValue;
            if shapeT == thisT-1 && shapeZ == thisZ-1
                cx = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getCx.getValue)+1;
                cy = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getCy.getValue)+1;
                rx = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getRx.getValue);
                ry = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getRy.getValue);
                %                 transform = char(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTransform.getValue.getBytes');
                %                 if ~strcmp(transform, 'none') || ~isempty(transform)
                %                     if strncmp(transform, 'trans', 5)
                %                         closeBracket = findstr(transform, ')');
                %                         openBracket = findstr(transform, '(');
                %                         transformData = transform(openBracket+1:closeBracket-1);
                %                         spaceChar = findstr(transformData, ' ');
                %                         if isempty(spaceChar)
                %                             firstTranslate = str2double(transformData(1:end));
                %                             secondTranslate = 0;
                %                         else
                %                             firstTranslate = str2double(transformData(1:spaceChar-1));
                %                             secondTranslate = str2double(transformData(spaceChar+1:end));
                %                         end
                %                         cx = cx + firstTranslate;
                %                         cy = cy + secondTranslate;
                %                         else
                %                     end
                %                 end
                %                 if strncmp(transform, 'matrix', 6)
                %                     affMat = parseAffineMatrix(transform);
                %                     coords = [cx cy 0]
                %                     coords = coords * affMat'
                %                     cx = coords(1);
                %                     cy = coords(2);
                % %                     cx = cx + affMat(1,3);
                % %                     cy = cy + affMat(2,3);
                %
                %                     %cx = cx + transX;
                %                     %cy = cy + transY;
                %               end
                
            end
        end
        if zoomLevel ~=1
            if playing == 1
                topLeftZoom = getappdata(handles.ROITweak, 'zoomMinMax');
                zoomX = topLeftZoom(1);
                zoomY = topLeftZoom(2);
                cx = round(cx-zoomX);
                cy = round(cy-zoomY);
            else
                cx = round(zoomROICentre(1));
                cy = round(zoomROICentre(2));
            end
        end
        [xInd yInd] = ellipseCoords([cx cy rx*rTransX ry*rTransY 0]);
        line(xInd, yInd, 'Color', 'w');
    end
    
    
    
    %Then the rectangles:
    if strcmpi(thisROIShape, 'rect')
        numShapes = roiShapes{thisROIIdx}.numShapes;
        for thisShape = 1:numShapes
            shapeT = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheT.getValue;
            shapeZ = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheZ.getValue;
            if shapeT == thisT-1 && shapeZ == thisZ-1
                x = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getX.getValue+1;
                y = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getY.getValue+1;
                width = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getWidth.getValue;
                height = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getHeight.getValue;
                
            end
        end
        %x = cx - round(width/2);
        %y = cy - round(height/2);
        if zoomLevel ~=1
            if playing == 1
                topLeftZoom = getappdata(handles.ROITweak, 'zoomMinMax');
                zoomX = topLeftZoom(1);
                zoomY = topLeftZoom(2);
                x = round(x-zoomX);
                y = round(y-zoomY);
            else
                x = round(zoomROICentre(1));
                y = round(zoomROICentre(2));
            end
        end
        rectangle('Position', [x y width height], 'edgecolor', 'white');
    end
    
    %Then the points:
    if strcmpi(thisROIShape, 'point')
        numShapes = roiShapes{thisROIIdx}.numShapes;
        for thisShape = 1:numShapes
            shapeT = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheT.getValue;
            shapeZ = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheZ.getValue;
            if shapeT == thisT-1 && shapeZ == thisZ-1
                cx = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getCx.getValue+1;
                cy = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getCy.getValue+1;
                
            end
        end
        if zoomLevel ~=1
            if playing == 1
                topLeftZoom = getappdata(handles.ROITweak, 'zoomMinMax');
                zoomX = topLeftZoom(1);
                zoomY = topLeftZoom(2);
                cx = round(cx-zoomX);
                cy = round(cy-zoomY);
            else
                cx = round(zoomROICentre(1));
                cy = round(zoomROICentre(2));
            end
        end
        point = impoint(handles.imageAxes, cx, cy);
    end
end
    






function redrawImage(handles)

zoomLevel = getappdata(handles.ROITweak, 'zoomLevel');
if zoomLevel > 1
    zoomImage(handles);
else
    displayImage = getappdata(handles.ROITweak, 'renderedImage');
    handles.imageHandle = imshow(displayImage);
    set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
    setappdata(handles.ROITweak, 'thisImageHandle', handles.imageHandle);
end



function windowButtonMotion(hObject, eventdata, handles)

currentPoint = get(handles.imageAxes, 'CurrentPoint');
setappdata(handles.ROITweak, 'currentPoint', currentPoint);



%trapPointer = getappdata(handles.ROITweak, 'trapPointer');

% if trapPointer == 1
%     windowPosition = get(handles.ROITweak, 'Position');
%     axesPosition = get(handles.imageAxes, 'Position');
%     minX = axesPosition(1);
%     minY = axesPosition(2);
%     maxX = minX + axesPosition(3);
%     maxY = minY + axesPosition(4);
%     if currentPoint(3) > maxY
%         set(0, 'PointerLocation', [(currentPoint(1) + windowPosition(1)-1) (maxY + windowPosition(2)-1)]);
%     end
%     if currentPoint(1) > maxX
%         set(0, 'PointerLocation', [(maxX + windowPosition(1)-1) (currentPoint(3) + windowPosition(2)-1)]);
%     end
%     if currentPoint(1) < minX
%         set(0, 'PointerLocation', [(minX + windowPosition(1)-1) (currentPoint(3) + windowPosition(2)-1)]);
%     end
%     if currentPoint(3) < minY
%         set(0, 'PointerLocation', [(currentPoint(1) + windowPosition(1)-1) (minY + windowPosition(2)-1)]);
%     end
% end




function startTText_Callback(hObject, eventdata, handles)
% hObject    handle to startTText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startTText as text
%        str2double(get(hObject,'String')) returns contents of startTText as a double

tRange = getappdata(handles.ROITweak, 'tRange');
startT = str2double(get(hObject, 'String'));
endT = str2double(get(handles.endTText, 'String'));
if isnan(startT) || startT < tRange(1) || startT >= endT
    startT = tRange(1);
    set(hObject, 'String', num2str(startT));
end

refreshDisplay(handles);



% --- Executes during object creation, after setting all properties.
function startTText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startTText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endTText_Callback(hObject, eventdata, handles)
% hObject    handle to endTText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endTText as text
%        str2double(get(hObject,'String')) returns contents of endTText as a double

tRange = getappdata(handles.ROITweak, 'tRange');
numT = getappdata(handles.ROITweak, 'numT');
startT = str2double(get(handles.startTText, 'String'));
endT = str2double(get(hObject, 'String'));
if isnan(endT) || endT > tRange(2) || endT <= startT
    endT = tRange(2);
    set(hObject, 'String', num2str(endT));
end

refreshDisplay(handles);



% --- Executes during object creation, after setting all properties.
function endTText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endTText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if getappdata(handles.ROITweak, 'playing') == 1
    return;
end
numT = getappdata(handles.ROITweak, 'numT');
firstT = round(get(handles.tSlider, 'Value'));
frameDelay = str2double(get(handles.delayText, 'String'));
%alignPos = getappdata(handles.ROITweak, 'alignPos');
%rotationView = getappdata(handles.ROITweak, 'rotationView');
%includeROI = getappdata(handles.ROITweak, 'includeROI');
if frameDelay < 0.01
    frameDelay = 0.01;
end
%setappdata(handles.ROITweak, 'interruptPlay', 0);
for thisT = firstT:numT
    interruptPlay = getappdata(handles.ROITweak, 'interruptPlay');
    if interruptPlay == 1
        break;
    end
    setappdata(handles.ROITweak, 'playing', 1);
    set(handles.tSlider, 'Value', thisT);
    set(handles.tLabel, 'String', ['T = ' num2str(thisT)]);
    thisZ = round(get(handles.zSlider, 'Value'));
    getThePlane(handles, thisZ-1, thisT-1)
    
    refreshDisplay(handles);
%     redrawImage(handles);
%     redrawRect(handles);
%     redrawAnchor(handles);
%     redrawAlign(handles);
    %drawnow expose;
    pause(frameDelay)
end
setappdata(handles.ROITweak, 'playing', 0);
setappdata(handles.ROITweak, 'interruptPlay', 0);



% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.ROITweak, 'interruptPlay', 1);



function currentWindowKeypress(hObject, eventdata, handles)

currentKey = eventdata.Key;
if strcmp(currentKey, 'escape')
    setappdata(handles.ROITweak, 'stopRecording', 1);
end
if strcmp(currentKey, 'f5')
    refreshDisplay(handles);
end


function recordROIButtonKeypress(hObject, eventdata, handles)

currentKey = eventdata.Key;
if strcmp(currentKey, 'escape')
    setappdata(handles.ROITweak, 'stopRecording', 1);
end
if strcmp(currentKey, 'f5')
    refreshDisplay(handles);
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
function clearMenu_Callback(hObject, eventdata, handles)
% hObject    handle to clearMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function openImageItem_Callback(hObject, eventdata, handles)
% hObject    handle to openImageItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gateway;
global session;

% currDir = getappdata(handles.ROITweak, 'currDir');
% modified = getappdata(handles.ROITweak, 'modified');
% if modified == 1
%     answer = questdlg([{'The current ROI set has been modified.'} {'Discard changes and open a new file?'}], 'Discard Changes?', 'Yes', 'No', 'No');
%     if strcmp(answer, 'No')
%         return;
%     end
% end
% [fileName filePath] = uigetfile('*.xml', 'Select an ROI file to open', currDir);
% if fileName == 0
%     return;
% end
% xmlStruct = xml2struct([filePath fileName]);
% username = getappdata(handles.ROITweak, 'username');
% server = getappdata(handles.ROITweak, 'server');
% [pixelsId imageName] = getPixIdFromROIFile([filePath fileName], username, server);
% if isempty(pixelsId)
%     warndlg([{'This ROI file is not linked to an image in your Omero account.    '} {'You can link it by opening it in Insight''s measurement tool and saving it again'}], 'No Image ID Found');
%     return;
% end
ImageSelector(handles, 'ROITweak', 1);
theImage = getappdata(handles.ROITweak, 'newImageObj');
imageId = theImage.getId.getValue;
pixels = theImage.getPixels(0);
pixelsId = pixels.getId.getValue;
imageName = char(theImage.getName.getValue.getBytes');
roiShapes = getROIsFromImageId(imageId);
numC = pixels.getSizeC.getValue;
numT = pixels.getSizeT.getValue;
numZ = pixels.getSizeZ.getValue;
sizeX = pixels.getSizeX.getValue;
sizeY = pixels.getSizeY.getValue;
rTransX = 1;
rTransY = 1;
if sizeX ~= 512
    rTransX = 512/sizeX;
end
if sizeY ~= 512
    rTransY = 512/sizeY;
end
renderingSettings = session.getRenderingSettingsService.getRenderingSettings(pixelsId);
defaultT = renderingSettings.getDefaultT.getValue + 1;
defaultZ = renderingSettings.getDefaultZ.getValue + 1;

%setappdata(handles.ROITweak, 'xmlStruct', xmlStruct);
%setappdata(handles.ROITweak, 'filePathName', [filePath fileName]);
setappdata(handles.ROITweak, 'pixels', pixels)
setappdata(handles.ROITweak, 'pixelsId', pixelsId)
setappdata(handles.ROITweak, 'numC', numC);
setappdata(handles.ROITweak, 'numT', numT);
setappdata(handles.ROITweak, 'numZ', numZ);
setappdata(handles.ROITweak, 'defaultT', defaultT);
setappdata(handles.ROITweak, 'defaultZ', defaultZ);
setappdata(handles.ROITweak, 'roiShapes', roiShapes);
setappdata(handles.ROITweak, 'imageId', imageId);
setappdata(handles.ROITweak, 'ROIsToUpdate', []);
setappdata(handles.ROITweak, 'rTransX', rTransX);
setappdata(handles.ROITweak, 'rTransY', rTransY);
%setappdata(handles.ROITweak, 'currDir', filePath);

set(handles.imageNameLabel, 'String', imageName);
setTSlider(handles);
setZSlider(handles);
set(handles.tSlider, 'Value', defaultT);
set(handles.tLabel, 'String', ['T = ' num2str(defaultT)]);
set(handles.zSlider, 'Value', defaultZ);
set(handles.zLabel, 'String', ['Z = ' num2str(defaultZ)]);
set(handles.roiSelect, 'Value', 1);
set(handles.recentreROIButton, 'Enable', 'off');
set(handles.recordROIButton, 'Enable', 'off');

getThePlane(handles, defaultZ-1, defaultT-1);
redrawImage(handles);
getROIIds(handles);
populateROISelect(handles);
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




% --- Executes on selection change in roiSelect.
function roiSelect_Callback(hObject, eventdata, handles)
% hObject    handle to roiSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns roiSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roiSelect

roiSelectIdx = get(hObject, 'Value');
setappdata(handles.ROITweak, 'zoomLevel', 1);
if roiSelectIdx > 1
    set(handles.recentreROIButton, 'Enable', 'on');
    set(handles.recordROIButton, 'Enable', 'on');
    tRange = getTRange(handles, roiSelectIdx);
    set(handles.startTText, 'String', num2str(tRange(1)));
    set(handles.startTText, 'Enable', 'on');
    set(handles.endTText, 'String', num2str(tRange(2)));
    set(handles.endTText, 'Enable', 'on');
    set(handles.zoomInButton, 'Enable', 'on');
    set(handles.zoomOutButton, 'Enable', 'on');
else
    set(handles.recentreROIButton, 'Enable', 'off');
    set(handles.recordROIButton, 'Enable', 'off');
    set(handles.startTText, 'String', '');
    set(handles.startTText, 'Enable', 'off');
    set(handles.endTText, 'String', '');
    set(handles.endTText, 'Enable', 'off');
    set(handles.zoomInButton, 'Enable', 'off');
    set(handles.zoomOutButton, 'Enable', 'off');
end
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


function getROIIds(handles)

roiShapes = getappdata(handles.ROITweak, 'roiShapes');
numROIs = length(roiShapes);
%xmlStruct = getappdata(handles.ROITweak, 'xmlStruct');
%numROIs = floor(length(xmlStruct.children)-1)/2;
ROICounter = 1;
for thisROI = 1:numROIs
%     ROIType = xmlStruct.children(thisROI*2+2).children(2).children(4).children(2).name;
    ROIType = roiShapes{thisROI}.shapeType;
    if strcmpi(ROIType, 'rect') || strcmpi(ROIType, 'ellipse') || strcmpi(ROIType, 'point')
        ROIIds{ROICounter} = num2str(thisROI); %xmlStruct.children(thisROI*2+2).attributes.value;
        ROIIdx(ROICounter) = thisROI;
        ROIShapes{ROICounter} = ROIType;
        ROICounter = ROICounter + 1;
    end
end
setappdata(handles.ROITweak, 'ROIIds', ROIIds);
setappdata(handles.ROITweak, 'ROIIdx', ROIIdx);
setappdata(handles.ROITweak, 'ROIShapes', ROIShapes);
setappdata(handles.ROITweak, 'ROICount', numROIs);


function populateROISelect(handles)

ROIIds = getappdata(handles.ROITweak, 'ROIIds');
ROIIdStr{1} = 'All';
for thisROI = 1:length(ROIIds)
    ROIIdStr{thisROI+1} = ROIIds{thisROI};
end
set(handles.roiSelect, 'String', ROIIdStr);


% --- Executes on button press in recentreROIButton.
function recentreROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to recentreROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(gcf,'Pointer','crosshair');
setappdata(handles.ROITweak, 'recentreROI', 1);
redrawImage(handles);


function tRange = getTRange(handles, roiSelectIdx)

roiShapes = getappdata(handles.ROITweak, 'roiShapes');
ROIIdx = getappdata(handles.ROITweak, 'ROIIdx');
selectedROI = get(handles.roiSelect, 'Value')-1;
numShapes = roiShapes{selectedROI}.numShapes;
tList = [];
for thisShape = 1:numShapes
    tList = [tList roiShapes{selectedROI}.(['shape' num2str(thisShape)]).getTheT.getValue];
end
tRange(1) = min(tList) + 1;
tRange(2) = max(tList) + 1;
setappdata(handles.ROITweak, 'tRange', tRange);


function setROICentre(handles)

roiShapes = getappdata(handles.ROITweak, 'roiShapes');
%xmlStruct = getappdata(handles.ROITweak, 'xmlStruct');
ROIIdx = getappdata(handles.ROITweak, 'ROIIdx');
zoomLevel = getappdata(handles.ROITweak, 'zoomLevel');
rTransX = getappdata(handles.ROITweak, 'rTransX');
rTransY = getappdata(handles.ROITweak, 'rTransY');
ROIsToUpdate = getappdata(handles.ROITweak, 'ROIsToUpdate');

if zoomLevel > 1
    topLeftZoom = getappdata(handles.ROITweak, 'zoomMinMax');
    zoomROICentre = getappdata(handles.ROITweak, 'zoomROICentre');
    zoomX = topLeftZoom(1);
    zoomY = topLeftZoom(2);
else
    topLeftZoom = 0;
    zoomX = 0;
    zoomY = 0;
end
roiSelectValue = get(handles.roiSelect, 'Value');
thisROIIdx = ROIIdx(roiSelectValue-1);
[~, ROIUpdateLoc] = ismember(thisROIIdx, ROIsToUpdate);
if ROIUpdateLoc == 0
    ROIsToUpdate = [ROIsToUpdate thisROIIdx];
end
thisT = round(get(handles.tSlider, 'Value'));
thisZ = round(get(handles.zSlider, 'Value'));
currentPoint = round(get(handles.imageAxes, 'CurrentPoint'));

numShapes = roiShapes{thisROIIdx}.numShapes;
for thisShape = 1:numShapes
    thisShapeType = roiShapes{thisROIIdx}.shapeType;
    shapeT = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheT.getValue;
    shapeZ = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheZ.getValue;
    if shapeT == thisT-1 && shapeZ == thisZ-1
        if strcmpi(thisShapeType, 'rect')
            cx = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getX.getValue);
            cy = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getY.getValue);
            width = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getWidth.getValue;
            height = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getHeight.getValue;
        else
            cx = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getCx.getValue);
            cy = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getCy.getValue);
        end
        try
            transform = char(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTransform.getValue.getBytes');
        catch
            transform = 'none';
        end
        transX = currentPoint(1) - cx;
        transY = currentPoint(3) - cy;
        updatedTransform = updateTransform(transform, 'translate', [], [], [], num2str(transX), num2str(transY));
        break;
    end
end


%For server-side ROIs:
updatedTransform = 'none';
roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).setTransform(omero.rtypes.rstring(updatedTransform))
if strcmpi(thisShapeType, 'rect')
    roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).setX(omero.rtypes.rdouble(zoomX + currentPoint(1)-1-round(width/2)));
    roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).setY(omero.rtypes.rdouble(zoomY + currentPoint(3)-1-round(height/2)));
else
    roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).setCx(omero.rtypes.rdouble(zoomX + currentPoint(1)-1));
    roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).setCy(omero.rtypes.rdouble(zoomY + currentPoint(3)-1));
end

  
setappdata(handles.ROITweak, 'zoomROICentre', [currentPoint(1) currentPoint(3)]);
setappdata(handles.ROITweak, 'modified', 1);
setappdata(handles.ROITweak, 'roiShapes', roiShapes);
setappdata(handles.ROITweak, 'ROIsToUpdate', ROIsToUpdate);


% --------------------------------------------------------------------
function saveItem_Callback(hObject, eventdata, handles)
% hObject    handle to saveItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global session
global iUpdate
global roiService

ROIsToUpdate = getappdata(handles.ROITweak, 'ROIsToUpdate');
if isempty(ROIsToUpdate)
    return;
end

imageId = getappdata(handles.ROITweak, 'imageId');
roiShapes = getappdata(handles.ROITweak, 'roiShapes');
roiResult = roiService.findByImage(imageId, []);
rois = roiResult.rois;
%roiResult = roiService.findByImage(imageId, []);
%rois = roiResult.rois;

% if ~isjava(roiService)
%     roiService = session.getRoiService;
% end
if ~isjava(iUpdate)
    iUpdate = session.getUpdateService;
end


%numROI = length(roiShapes);
for thisROI = ROIsToUpdate
    thisROIId = roiShapes{thisROI}.ROIId;
    wrongROI = 1;
    while wrongROI == 1
        roiObj = rois.get(thisROI-1);
        roiObjId = roiObj.getId.getValue;
        if roiObjId == thisROIId
            roiObj.clearShapes();
            wrongROI = 0;
        end
    end
    wrongROI = 1;
    %roiObjOldShapes = roiObj.copyShapes(); %This need to be a java list.
    numShapes = roiShapes{thisROI}.numShapes;
    %roiShapes{thisROI} = rmfield(roiShapes{thisROI}, {'shapeType' 'numShapes'});
    for thisShape = 1:numShapes
        if roiShapes{thisROI}.(['shape' num2str(thisShape)]).getStrokeWidth.getValue == 0
            roiShapes{thisROI}.(['shape' num2str(thisShape)]).setStrokeWidth(omero.rtypes.rint(1));
        end
        roiObj.addShape(roiShapes{thisROI}.(['shape' num2str(thisShape)]));
        
        %roiShapes = getROIsFromImageId(imageId);
%         shapeObj = roiShapes{thisROI}.(['shape' num2str(thisShape)]);
%         roiObj
%         roiObj.setShape(shapeObj);
    end
    iUpdate.saveAndReturnObject(roiObj);
end
roiShapes = getROIsFromImageId(imageId);
setappdata(handles.ROITweak, 'roiShapes', roiShapes);
setappdata(handles.ROITweak, 'ROIsToUpdate', []);
setappdata(handles.ROITweak, 'modified', 0);
%iUpdate.saveObject(roiObj.asIObject)


% xmlStruct = getappdata(handles.ROITweak, 'xmlStruct');
% if isempty(xmlStruct)
%     errordlg('There are no ROIs to save', 'Error');
%     return;
% end
% answer = questdlg([{'Overwrite the original ROI file?'} {'New positions will show in Insight'}], 'Overwrite Data?', 'Yes', 'No', 'Yes');
% if strcmp(answer, 'Yes')
%     filePathName = getappdata(handles.ROITweak, 'filePathName');
%     %delete(filePathName);
%     DocNode = struct2xml(xmlStruct);
%     xmlwrite(filePathName, DocNode);
%     setappdata(handles.ROITweak, 'modified', 0);
% end


% --------------------------------------------------------------------
function saveAsItem_Callback(hObject, eventdata, handles)
% hObject    handle to saveAsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xmlStruct = getappdata(handles.ROITweak, 'xmlStruct');
currDir = getappdata(handles.ROITweak, 'currDir');
if isempty(xmlStruct)
    errordlg('There are no ROIs to save', 'Error');
    return;
end
answer = questdlg([{'To use this new file in analysis it must be'} {'opened and saved again within Insight.'} {'Do you want to continue?'}], 'Save As... New File?', 'Yes', 'No', 'Yes');
if strcmp(answer, 'Yes')
    [fileName filePath] = uiputfile('*.xml', 'Save As...', currDir);
else
    return;
end
if fileName == 0
    return;
end
DocNode = struct2xml(xmlStruct);
xmlwrite([filePath fileName], DocNode);
setappdata(handles.ROITweak, 'filePathName', [filePath fileName]);
setappdata(handles.ROITweak, 'modified', 0);


% --------------------------------------------------------------------
function quitItem_Callback(hObject, eventdata, handles)
% hObject    handle to quitItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.ROITweak);



% --- Executes on button press in zoomInButton.
function zoomInButton_Callback(hObject, eventdata, handles)
% hObject    handle to zoomInButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


zoomLevel = getappdata(handles.ROITweak, 'zoomLevel');
setappdata(handles.ROITweak, 'zoomMinMax', []);
zoomLevel = zoomLevel + 1;
if zoomLevel == 4
    return;
else
    setappdata(handles.ROITweak, 'zoomLevel', zoomLevel);
    zoomImage(handles);
    redrawROIs(handles);
end



% --- Executes on button press in zoomOutButton.
function zoomOutButton_Callback(hObject, eventdata, handles)
% hObject    handle to zoomOutButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.ROITweak, 'zoomLevel', 1);
setappdata(handles.ROITweak, 'zoomDifference', [0 0]);
setappdata(handles.ROITweak, 'zoomMinMax', []);
refreshDisplay(handles)


function ROITweakCloseReq(hObject, eventdata, handles)

modified = getappdata(handles.ROITweak, 'modified');
if modified == 1
    answer = questdlg([{'The current ROI set has been modified'} {'Discard changes and close the application?'}], 'Discard Changes?', 'Yes', 'No', 'No');
    if strcmp(answer, 'No')
        return;
    end
end
gatewayDisconnect;
delete(handles.ROITweak);


function [cx cy] = getROICentre(handles)

roiShapes = getappdata(handles.ROITweak, 'roiShapes');
%xmlStruct = getappdata(handles.ROITweak, 'xmlStruct');
ROIIdx = getappdata(handles.ROITweak, 'ROIIdx');
ROIShapes = getappdata(handles.ROITweak, 'ROIShapes');
roiSelectValue = get(handles.roiSelect, 'Value');
thisT = round(get(handles.tSlider, 'Value'));
thisZ = round(get(handles.zSlider, 'Value'));
thisROIIdx = ROIIdx(roiSelectValue-1);
%thisROIShape = ROIShapes{thisROIIdx-1};

%First the ellipses:
% if strcmpi(thisROIShape, 'ellipse')
numShapes = roiShapes{thisROIIdx}.numShapes;
for thisShape = 1:numShapes
    shapeT = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheT.getValue;
    shapeZ = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheZ.getValue;
    if shapeT == thisT-1 && shapeZ == thisZ-1
        cx = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getCx.getValue);
        cy = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getCy.getValue);
        transform = char(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTransform.getValue.getBytes');
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
    end
end
%                 
%                 
% numROIShapes = length(xmlStruct.children(thisROIIdx).children);
% for thisROIShape = 2:2:numROIShapes
%     if thisT == str2double(xmlStruct.children(thisROIIdx).children(thisROIShape).attributes(1).value)+1;
%         numFields = length(xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children);
%         for thisField = 1:numFields
%             thisFieldName = xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children(thisField).name;
%             if strcmpi(thisFieldName, 'measurementCentreX')
%                 cx = str2double(xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children(thisField).attributes(2).value)+1;
%             elseif strcmpi(thisFieldName, 'measurementCentreY')
%                 cy = str2double(xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children(thisField).attributes(2).value)+1;
%             end
%         end
%     end
% end

% %Then the rectangles:
% if strcmpi(thisROIShape, 'rect')
%     numROIShapes = length(xmlStruct.children(thisROIIdx).children);
%     for thisROIShape = 2:2:numROIShapes
%         if thisT == str2double(xmlStruct.children(thisROIIdx).children(thisROIShape).attributes(1).value)+1;
%             numFields = length(xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children);
%             for thisField = 1:numFields
%                 thisFieldName = xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children(thisField).name;
%                 if strcmpi(thisFieldName, 'measurementCentreX')
%                     cx = str2double(xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children(thisField).attributes(2).value);
%                 elseif strcmpi(thisFieldName, 'measurementCentreY')
%                     cy = str2double(xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children(thisField).attributes(2).value);
%                 elseif strcmpi(thisFieldName, 'measurementWidth')
%                     width = str2double(xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children(thisField).attributes(2).value);
%                 elseif strcmpi(thisFieldName, 'measurementHeight')
%                     height = str2double(xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children(thisField).attributes(2).value);
%                 end
%             end
%             x = cx - round(width/2);
%             y = cy - round(height/2);
%             rectangle('Position', [x y width height], 'edgecolor', 'white');
%         end
%     end
% end
% 
% %Then the points:
% if strcmpi(thisROIShape, 'point')
%     numROIShapes = length(xmlStruct.children(thisROIIdx).children);
%     for thisROIShape = 2:2:numROIShapes
%         if thisT == str2double(xmlStruct.children(thisROIIdx).children(thisROIShape).attributes(1).value)+1;
%             numFields = length(xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children);
%             for thisField = 1:numFields
%                 thisFieldName = xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children(thisField).name;
%                 if strcmpi(thisFieldName, 'measurementCentreX')
%                     cx = str2double(xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children(thisField).attributes(2).value);
%                 elseif strcmpi(thisFieldName, 'measurementCentreY')
%                     cy = str2double(xmlStruct.children(thisROIIdx).children(thisROIShape).children(2).children(thisField).attributes(2).value);
%                 end
%             end
%             point = impoint(handles.imageAxes, cx, cy);
%             api = iptgetapi(point);
%             fcn = makeConstrainToRectFcn('impoint', [cx cx], [cy cy]);
%             api.setPositionConstraintFcn(fcn);
%         end
%     end
% end

function zoomImage(handles)

zoomLevel = getappdata(handles.ROITweak, 'zoomLevel');
zoomMinMax = getappdata(handles.ROITweak, 'zoomMinMax');
stopRecording = getappdata(handles.ROITweak, 'stopRecording');
renderedImage = getappdata(handles.ROITweak, 'renderedImage');
if ~isempty(zoomMinMax) && stopRecording == 0
    minZoomX = zoomMinMax(1);
    minZoomY = zoomMinMax(2);
    maxZoomX = zoomMinMax(3);
    maxZoomY = zoomMinMax(4);
    cxcy = getappdata(handles.ROITweak, 'zoomROICentre');
    cx = cxcy(1);
    cy = cxcy(2);
else
    [ROIx ROIy] = getROICentre(handles);
    [imageHeight imageWidth imageRGB] = size(renderedImage);
    maxZoomX = round(ROIx + (imageWidth/(2*zoomLevel)));
    maxZoomY = round(ROIy + (imageHeight/(2*zoomLevel)));
    minZoomX = round(ROIx - (imageWidth/(2*zoomLevel)));
    minZoomY = round(ROIy - (imageHeight/(2*zoomLevel)));

    cx = imageWidth/(zoomLevel*2)+2;
    cy = imageHeight/(zoomLevel*2)+2;

    if maxZoomX > imageWidth
        xDiff = maxZoomX - imageWidth;
        cx = cx + xDiff;
        maxZoomX = imageWidth;
        minZoomX = round(maxZoomX-(imageWidth/(zoomLevel)));
    end
    if maxZoomY > imageHeight
        yDiff = maxZoomY - imageHeight;
        cy = cy + yDiff;
        maxZoomY = imageHeight;
        minZoomY = round(maxZoomY-(imageHeight/(zoomLevel)));
    end
    if minZoomX <= 0
        cx = cx + minZoomX;
        minZoomX = 1;
        maxZoomX = round(minZoomX+(imageWidth/(zoomLevel)));
    end
    if minZoomY <= 0
        cy = cy + minZoomY;
        minZoomY = 1;
        maxZoomY = round(minZoomY+(imageHeight/(zoomLevel)));
    end
end

zoomImage = renderedImage(minZoomY:maxZoomY, minZoomX:maxZoomX,:);
handles.imageHandle = imshow(zoomImage);
set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
setappdata(handles.ROITweak, 'thisImageHandle', handles.imageHandle);
setappdata(handles.ROITweak, 'zoomROICentre', [cx cy]);
setappdata(handles.ROITweak, 'zoomMinMax', [minZoomX minZoomY maxZoomX maxZoomY]);
stopRecording = getappdata(handles.ROITweak, 'stopRecording');
recentreROI = getappdata(handles.ROITweak, 'recentreROI');
if stopRecording == 1 && recentreROI ~= 1
    redrawROIs(handles);
end

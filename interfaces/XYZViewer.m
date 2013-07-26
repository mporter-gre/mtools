function varargout = XYZViewer(varargin)
% XYZVIEWER M-file for XYZViewer.fig
%      XYZVIEWER, by itself, creates a new XYZVIEWER or raises the existing
%      singleton*.
%
%      H = XYZVIEWER returns the handle to a new XYZVIEWER or the handle to
%      the existing singleton*.
%
%      XYZVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in XYZVIEWER.M with the given input arguments.
%
%      XYZVIEWER('Property','Value',...) creates a new XYZVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before XYZViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to XYZViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help XYZViewer

% Last Modified by GUIDE v2.5 24-Aug-2012 18:37:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @XYZViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @XYZViewer_OutputFcn, ...
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


% --- Executes just before XYZViewer is made visible.
function XYZViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to XYZViewer (see VARARGIN)

% Choose default command line output for XYZViewer
handles.output = hObject;
handles.pixels = varargin{1};
if strcmp(class(handles.pixels), 'java.util.ArrayList');
    handles.pixels = handles.pixels.get(0);
end
setappdata(handles.XYZViewer, 'cached', 0);
handles.pixelsId = handles.pixels.getId.getValue;
handles.numC = handles.pixels.getSizeC.getValue;
handles.numT = handles.pixels.getSizeT.getValue;
handles.numZ = handles.pixels.getSizeZ.getValue;
handles.sizeX = handles.pixels.getSizeX.getValue;
handles.sizeY = handles.pixels.getSizeY.getValue;
imageId = handles.pixels.getImage.getId.getValue;
rTransX = 512/handles.sizeX;
rTransY = 512/handles.sizeY;
transZ = 60/handles.numZ;
try
    roiShapes = getROIsFromImageId(imageId);
catch
    roiShapes = [];
end
setTSlider(handles);
set(handles.downloadingLabel, 'Visible', 'on');
getPlanes(handles, 0)
set(handles.downloadingLabel, 'Visible', 'off');
set(handles.tText, 'String', ['T = 1/' num2str(handles.numT)]);

x = round(handles.sizeX/2);
y = round(handles.sizeY/2);
z = round(handles.numZ/2);
setappdata(handles.XYZViewer, 'x', x);
setappdata(handles.XYZViewer, 'y', y);
setappdata(handles.XYZViewer, 'z', z);
setappdata(handles.XYZViewer, 't', 0);
setappdata(handles.XYZViewer, 'roiShapes', roiShapes);
setappdata(handles.XYZViewer, 'rTransX', rTransX);
setappdata(handles.XYZViewer, 'rTransY', rTransY);
setappdata(handles.XYZViewer, 'transZ', transZ);
displayImages(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes XYZViewer wait for user response (see UIRESUME)
uiwait(handles.XYZViewer);


% --- Outputs from this function are returned to the command line.
function varargout = XYZViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;
varargout{1} = [];


% --- Executes on slider movement.
function tSlider_Callback(hObject, eventdata, handles)
% hObject    handle to tSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(hObject, 'Enable', 'off');
set(handles.downloadingLabel, 'Visible', 'on');
drawnow;
t = round(get(hObject, 'Value'));
getPlanes(handles, t-1);
displayImages(handles);
set(hObject, 'Enable', 'on');
set(handles.downloadingLabel, 'Visible', 'off');
set(handles.tText, 'String', ['T = ' num2str(t) '/' num2str(handles.numT)]);



% --- Executes during object creation, after setting all properties.
function tSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function setTSlider(handles)

numT = handles.numT;
if numT == 1
    set(handles.tSlider, 'enable', 'off');
    return;
end
sliderSmallStep = 1/numT;
set(handles.tSlider, 'Max', numT);
set(handles.tSlider, 'Min', 1);
set(handles.tSlider, 'Value', 1);
set(handles.tSlider, 'SliderStep', [sliderSmallStep, sliderSmallStep*4]);
%set(handles.tLabel, 'String', 'T = 1');



function getPlanes(handles, t)
t = round(t);

cached = getappdata(handles.XYZViewer, 'cached');
if cached == 0
    pixelsId = handles.pixelsId;
    numC = handles.numC;
    numZ = handles.numZ;
    for thisZ = 1:numZ
        for thisC = 1:numC
            plane(:,:,thisC) = getPlaneFromPixelsId(pixelsId, thisZ-1, thisC-1, t);
            %renderedImage(:,:,thisZ) = getPlaneFromPixelsId(pixelsId, thisZ-1, thisC-1, t);
        end
        renderedImage{thisZ} = createRenderedImage(plane, handles.pixels);
    end
else
    fileVar = load('cacheFile', ['t' num2str(t)]);
    renderedImage = fileVar.(['t' num2str(t)]);
end
    
setappdata(handles.XYZViewer, 'renderedImage', renderedImage);


function displayImages(handles)

renderedImage = getappdata(handles.XYZViewer, 'renderedImage');
x = getappdata(handles.XYZViewer, 'x');
y = getappdata(handles.XYZViewer, 'y');
z = getappdata(handles.XYZViewer, 'z');

%grayImage = zeros(handles.sizeY, handles.sizeX, handles.numZ);
for thisZ = 1:handles.numZ;
    %grayImage(:,:,thisZ) = rgb2gray(renderedImage{thisZ});
    YZImage(:,thisZ,:) = renderedImage{thisZ}(:,x,:); %grayImage(:,x, thisZ);
    XZImage(thisZ,:,:) = renderedImage{thisZ}(y,:,:); %grayImage(y,:, thisZ);
end
if size(YZImage(1,:,1)) < 60
    YZImage = imresize(YZImage, [512 60]);
end
if size(XZImage(:,1,1)) < 60
    XZImage = imresize(XZImage, [60 512]);
end

axes(handles.imageAxes);
handles.imageHandle = imshow(renderedImage{z});
%redrawROIs(handles, 'XY');
set(handles.imageHandle, 'ButtonDownFcn', {@image_ButtonDownFcn, handles});

axes(handles.YZAxes);
handles.YZHandle = imshow(YZImage);
%redrawROIs(handles, 'YZ');

axes(handles.XZAxes);
handles.XZHandle = imshow(XZImage);
%redrawROIs(handles, 'XZ');




function image_ButtonDownFcn(hObject, eventdata, handles)

currentPoint = get(handles.imageAxes, 'CurrentPoint');
% point = impoint(gca,currentPoint(1), currentPoint(3));
% api = iptgetapi(point);
% %Stop the user manually moving the point.
% fcn = makeConstrainToRectFcn('impoint', [currentPoint(1) currentPoint(1)], [currentPoint(3) currentPoint(3)]);
% api.setPositionConstraintFcn(fcn);
setappdata(handles.XYZViewer, 'x', int32(currentPoint(1)));
setappdata(handles.XYZViewer, 'y', int32(currentPoint(3)));
displayImages(handles);


% --- Executes on button press in cacheBtn.
function cacheBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cacheBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = questdlg('Cache this image to file?', 'Cache file?', 'Yes', 'No', 'Yes');
if strcmp(answer, 'Yes')
    delete('cacheFile.mat');
    fileHeader = 'Cache file for XYZViewer';
    save('cacheFile', 'fileHeader');
    sizeX = handles.sizeX;
    sizeY = handles.sizeY;
    numZ = handles.numZ;
    numT = handles.numT;
    set(handles.tSlider, 'Enable', 'off');
    set(handles.cacheBtn, 'Enable', 'off');
    drawnow;
    progBar = waitbar(0, 'Downloading...');

    for thisT = 1:numT
        getPlanes(handles, thisT-1);
        renderedImage.(['t' num2str(thisT-1)]) = getappdata(handles.XYZViewer, 'renderedImage');
        save('cacheFile', '-append', '-struct', 'renderedImage');
        clear('renderedImage');
        waitbar(thisT/numT, progBar);
    end
    close(progBar);
    set(handles.tSlider, 'Enable', 'on');
    %currentT = get(handles.tSlider, 'Value');
    tSlider_Callback(hObject, eventdata, handles)
    setappdata(handles.XYZViewer, 'cached', 1);
end
        
        
function redrawROIs(handles, dim)

roiShapes = getappdata(handles.XYZViewer, 'roiShapes');

%xmlStruct = getappdata(handles.ROITweak, 'xmlStruct');
%thisZ = round(get(handles.zSlider, 'Value'));
thisT = round(get(handles.tSlider, 'Value'));
%roiSelectString = get(handles.roiSelect, 'String');
%roiSelectValue = get(handles.roiSelect, 'Value');
%ROIIds = getappdata(handles.XYZViewer, 'ROIIds');
%ROIIdx = getappdata(handles.XYZViewer, 'ROIIdx');
ROIShapes = getappdata(handles.XYZViewer, 'ROIShapes');
%ROICount = getappdata(handles.XYZViewer, 'ROICount');
thisROIIdx = 1;
%zoomLevel = getappdata(handles.ROITweak, 'zoomLevel');
%zoomROICentre = getappdata(handles.ROITweak, 'zoomROICentre');
%playing = getappdata(handles.ROITweak, 'playing');
%rTransX = getappdata(handles.ROITweak, 'rTransX');
%rTransY = getappdata(handles.ROITweak, 'rTransY');
rTransX = getappdata(handles.XYZViewer, 'rTransX');
rTransY = getappdata(handles.XYZViewer, 'rTransY');
transZ = getappdata(handles.XYZViewer, 'transZ');

% if strcmp(roiSelectString{roiSelectValue}, 'All')
%     %for thisROI = 1:length(roiSelectString);
%         ROIsToDraw = ROIIdx;
%     %end
% else
%     ROIsToDraw = ROIIdx(roiSelectValue-1);
% end

%numROIs = length(ROIsToDraw);
% for thisROI = 1:numROIs
%     thisROIIdx = ROIsToDraw(thisROI);
%     if numROIs > 1
%         thisROIShape = ROIShapes{thisROI};
%     else
%         if ROICount == 1
%             thisROIShape = ROIShapes{1};
%         else
%             thisROIShape = ROIShapes{roiSelectValue-1};
%         end
%     end
    %First the ellipses:
    %if strcmpi(thisROIShape, 'ellipse')
    numShapes = roiShapes{thisROIIdx}.numShapes;
    if strcmp(dim, 'XY')
        
        for thisShape = 1:numShapes
            shapeT = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheT.getValue;
            
            if shapeT == thisT-1 %&& shapeZ == thisZ-1
                cx = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getCx.getValue)+1;
                cy = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getCy.getValue)+1;
                rx = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getRx.getValue);
                ry = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getRy.getValue);

%                 continue;
            end
        end
%     end
    
    [xInd yInd] = ellipseCoords([cx cy rx*rTransX ry*rTransY 0]);
    line(xInd, yInd, 'Color', 'w');
    
    end
    
    if strcmp(dim, 'YZ')
        for thisShape = 1:numShapes
            shapeT = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheT.getValue;
            
            if shapeT == thisT-1
                shapeZ = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheZ.getValue;
                cy = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getCy.getValue)+1;
                ry = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getRy.getValue);
                yRange = (cy-ry:cy+ry).*rTransY;
                xRange(1:length(yRange)) = shapeZ*transZ;
                line(xRange, yRange, 'Color', 'w');
                %line((1:100), (101:200), 'Color', 'w');
            end
        end
    end
    
    if strcmp(dim, 'XZ')
        for thisShape = 1:numShapes
            shapeT = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheT.getValue;
            
            if shapeT == thisT-1
                shapeZ = roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getTheZ.getValue;
                cx = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getCx.getValue)+1;
                rx = round(roiShapes{thisROIIdx}.(['shape' num2str(thisShape)]).getRx.getValue);
                xRange = (cx-rx:cx+rx).*rTransX;
                yRange(1:length(xRange)) = shapeZ*transZ;
                line(xRange, yRange, 'Color', 'w');
            end
        end
    end
%end
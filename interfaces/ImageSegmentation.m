function varargout = ImageSegmentation(varargin)
% IMAGESEGMENTATION M-file for ImageSegmentation.fig
%      IMAGESEGMENTATION, by itself, creates a new IMAGESEGMENTATION or raises the existing
%      singleton*.
%
%      H = IMAGESEGMENTATION returns the handle to a new IMAGESEGMENTATION or the handle to
%      the existing singleton*.
%
%      IMAGESEGMENTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGESEGMENTATION.M with the given input arguments.
%
%      IMAGESEGMENTATION('Property','Value',...) creates a new IMAGESEGMENTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageSegmentation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageSegmentation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageSegmentation

% Last Modified by GUIDE v2.5 17-Jun-2013 12:01:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageSegmentation_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageSegmentation_OutputFcn, ...
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


% --- Executes just before ImageSegmentation is made visible.
function ImageSegmentation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageSegmentation (see VARARGIN)

% Choose default command line output for ImageSegmentation
handles.output = hObject;
handles.remember = [];
handles.rememberScope = [];
handles.sigmaChanged = 0;
segmentationType = [];
patchMax = [];
lowestValue = [];
handles.loadingImage = importdata('loadingImage.JPG');
setappdata(handles.ImageSegmentation, 'patchMax', patchMax);
setappdata(handles.ImageSegmentation, 'lowestValue', lowestValue);
setappdata(handles.ImageSegmentation, 'segmentationType', 'Otsu');

handles.parentHandles = varargin{1};
handles.credentials = varargin{2};
ids = varargin{3};
guidata(hObject, handles);

if isempty(ids)
    set(handles.imageSelect, 'String', 'Choose datasets from File menu'); %handles.imageNames);
    set(handles.channelSelect, 'String', 'Channel'); %handles.channelLabel{1});
    uiwait(handles.ImageSegmentation);
else
    setappdata(handles.ImageSegmentation, 'selectedDsIds', ids);
    setAnalysisQueue(handles)
    imageSelect_Callback(handles.imageSelect, eventdata, handles);
    uiwait(handles.ImageSegmentation);
end





% UIWAIT makes ImageSegmentation wait for user response (see UIRESUME)
% uiwait(handles.ImageSegmentation);


% --- Outputs from this function are returned to the command line.
function varargout = ImageSegmentation_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = get(handles.channelSelect, 'Value');


%Check which channels have been selected for measurement
measureList = [];
measureAroundList = [];
checkSelected = get(handles.measureCheck1, 'Value');
if checkSelected == 1
    measureList = [measureList 1];
end
checkSelected = get(handles.measureCheck2, 'Value');
if checkSelected == 1
    measureList = [measureList 2];
end
checkSelected = get(handles.measureCheck3, 'Value');
if checkSelected == 1
    measureList = [measureList 3];
end
checkSelected = get(handles.measureCheck4, 'Value');
if checkSelected == 1
    measureList = [measureList 4];
end

checkSelected = get(handles.measureAroundCheck1, 'Value');
if checkSelected == 1
    measureAroundList = [measureAroundList 1];
end
checkSelected = get(handles.measureAroundCheck2, 'Value');
if checkSelected == 1
    measureAroundList = [measureAroundList 2];
end
checkSelected = get(handles.measureAroundCheck3, 'Value');
if checkSelected == 1
    measureAroundList = [measureAroundList 3];
end
checkSelected = get(handles.measureAroundCheck4, 'Value');
if checkSelected == 1
    measureAroundList = [measureAroundList 4];
end
varargout{2} = measureList;
varargout{3} = measureAroundList;
varargout{4} = str2double(get(handles.featherText, 'String'));
varargout{5} = get(handles.saveMaskCheck, 'Value');
varargout{6} = get(handles.verifyZCheck, 'Value');
groupObjects = get(handles.groupObjectsRadio, 'Value');
if groupObjects == 1
    varargout{7} = 1;
else
    varargout{7} = 0;
end
varargout{8} = str2double(get(handles.minSizeText, 'String'));
varargout{9} = getappdata(handles.ImageSegmentation, 'selectedSegType');
if strcmpi(varargout{9}, 'Otsu')
    varargout{10} = 0;
elseif strcmpi(varargout{9}, 'Absolute')
    varargout{10} = str2double(get(handles.thresholdText, 'String'));
elseif strcmpi(varargout{9}, 'Sigma')
    varargout{10} = str2double(get(handles.sigmaLabel, 'String'));
end
varargout{11} = getappdata(handles.ImageSegmentation, 'imageIds');
varargout{12} = getappdata(handles.ImageSegmentation, 'imageNames');
varargout{13} = getappdata(handles.ImageSegmentation, 'roiShapes');
varargout{14} = getappdata(handles.ImageSegmentation, 'channelLabels');
varargout{15} = getappdata(handles.ImageSegmentation, 'pixels');
varargout{16} = getappdata(handles.ImageSegmentation, 'datasetNames');

if strcmp(get(handles.annulusCheck, 'Enable'), 'on') && get(handles.annulusCheck, 'Value') == 1
    varargout{17} = str2double(get(handles.annulusText, 'String'));
    varargout{18} = str2double(get(handles.gapText, 'String'));
else
    varargout{17} = 0;
    varargout{18} = 0;
end


close(hObject)
drawnow;



% --- Executes on selection change in imageSelect.
function imageSelect_Callback(hObject, eventdata, handles)
% hObject    handle to imageSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

displayLoadingImage(handles);
segPatches = [];
selectedImageIdx = get(hObject, 'Value');
channelLabels = getappdata(handles.ImageSegmentation, 'channelLabels');
handles.numChannels = length(channelLabels{selectedImageIdx});
roiShapes = getappdata(handles.ImageSegmentation, 'roiShapes');
numROI = length(roiShapes{selectedImageIdx});
for thisROI = 1:numROI
    segPatches{thisROI}{handles.numChannels} = [];
end
setappdata(handles.ImageSegmentation, 'segPatches', segPatches);
displayImage(handles);
showChannelCheckBoxes(handles);
segmentROI(handles);
drawROIs(handles);
guidata(hObject, handles);



% Hints: contents = get(hObject,'String') returns imageSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imageSelect


% --- Executes during object creation, after setting all properties.
function imageSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channelSelect.
function channelSelect_Callback(hObject, eventdata, handles)
% hObject    handle to channelSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

displayLoadingImage(handles);
segmentROI(handles);

% Hints: contents = get(hObject,'String') returns channelSelect contents as cell array
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



function minSizeText_Callback(hObject, eventdata, handles)
% hObject    handle to minSizeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of minSizeText as text
%        str2double(get(hObject,'String')) returns contents of minSizeText as a double


% --- Executes during object creation, after setting all properties.
function minSizeText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minSizeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function featherText_Callback(hObject, eventdata, handles)
% hObject    handle to featherText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of featherText as text
%        str2double(get(hObject,'String')) returns contents of featherText as a double


% --- Executes during object creation, after setting all properties.
function featherText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to featherText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in measureCheck1.
function measureCheck1_Callback(hObject, eventdata, handles)
% hObject    handle to measureCheck1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureCheck1


% --- Executes on button press in measureCheck2.
function measureCheck2_Callback(hObject, eventdata, handles)
% hObject    handle to measureCheck2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureCheck2


% --- Executes on button press in measureCheck3.
function measureCheck3_Callback(hObject, eventdata, handles)
% hObject    handle to measureCheck3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureCheck3


% --- Executes on button press in measureCheck4.
function measureCheck4_Callback(hObject, eventdata, handles)
% hObject    handle to measureCheck4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureCheck4


% --- Executes on button press in measureAroundCheck1.
function measureAroundCheck1_Callback(hObject, eventdata, handles)
% hObject    handle to measureAroundCheck1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureAroundCheck1
enableAnnulus(handles)


% --- Executes on button press in measureAroundCheck2.
function measureAroundCheck2_Callback(hObject, eventdata, handles)
% hObject    handle to measureAroundCheck2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureAroundCheck2
enableAnnulus(handles)


% --- Executes on button press in measureAroundCheck3.
function measureAroundCheck3_Callback(hObject, eventdata, handles)
% hObject    handle to measureAroundCheck3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureAroundCheck3
enableAnnulus(handles)


% --- Executes on button press in measureAroundCheck4.
function measureAroundCheck4_Callback(hObject, eventdata, handles)
% hObject    handle to measureAroundCheck4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureAroundCheck4
enableAnnulus(handles)


% --- Executes on button press in rememberCheck.
function rememberCheck_Callback(hObject, eventdata, handles)
% hObject    handle to rememberCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rememberCheck


% --- Executes on button press in saveMaskCheck.
function saveMaskCheck_Callback(hObject, eventdata, handles)
% hObject    handle to saveMaskCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveMaskCheck


% --- Executes on button press in verifyZCheck.
function verifyZCheck_Callback(hObject, eventdata, handles)
% hObject    handle to verifyZCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of verifyZCheck


% --- Executes on slider movement.
function thresholdSlider_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Update the threshold text box and re-run segmentation.
%displayLoadingImage(handles);
sliderThreshold = round(get(hObject, 'Value'));
set(handles.thresholdText, 'String', num2str(sliderThreshold));
set(handles.absoluteThresholdLabel, 'String', num2str(sliderThreshold));
useOtsu = get(handles.otsuThresholdRadio, 'Value');

if useOtsu == 1
    set(handles.absoluteThresholdRadio, 'Value', 1);
end
patches = getappdata(handles.ImageSegmentation, 'patches');
sigmaMultiplier = getSigmaMultiplier(handles, patches);
set(handles.sigmaLabel, 'String', num2str(sigmaMultiplier));

handles.sigmaChanged = 1;
guidata(hObject, handles);

%resegment(handles);


% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function thresholdSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function zSlider_Callback(hObject, eventdata, handles)
% hObject    handle to zSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

segPatches = getappdata(handles.ImageSegmentation, 'segPatches');
selectedZ = round(get(hObject, 'Value'));
set(hObject, 'Value', selectedZ);
set(handles.zLabel, 'String', ['Z = ' num2str(selectedZ)]);
selectedChannel = get(handles.channelSelect, 'Value');
selectedROI = getappdata(handles.ImageSegmentation, 'selectedROI');
axes(handles.segAxes)
groupObjects = get(handles.groupObjectsRadio, 'Value');
if groupObjects == 0
    handles.segHandle = imshow(segPatches{selectedROI}{selectedChannel}(:,:,selectedZ), [0 max(max(max(segPatches{selectedROI}{selectedChannel})))]);
else
    handles.segHandle = imshow(segPatches{selectedROI}{selectedChannel}(:,:,selectedZ));
end

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function zSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function thresholdText_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Update the thresholdSlider to the new values

currThreshold = str2double(get(hObject, 'String'));
if isnan(currThreshold)
    return;
end

updateThresholdSlider(handles);

useSigma = get(handles.sigmaThresholdRadio, 'Value');
useOtsu = get(handles.otsuThresholdRadio, 'Value');
if useOtsu == 1
    set(handles.absoluteThresholdRadio, 'Value', 1);
end
patches = getappdata(handles.ImageSegmentation, 'patches');
sigmaMultiplier = getSigmaMultiplier(handles, patches);
set(handles.sigmaLabel, 'String', num2str(sigmaMultiplier));
handles.sigmaChanged = 1;
guidata(hObject, handles);

%Delete the segPatch and re-do the segmentation.
% displayLoadingImage(handles);
% resegment(handles)

% Hints: get(hObject,'String') returns contents of thresholdText as text
%        str2double(get(hObject,'String')) returns contents of thresholdText as a double


% --- Executes during object creation, after setting all properties.
function thresholdText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rememberThresholdingCheck.
function rememberThresholdingCheck_Callback(hObject, eventdata, handles)
% hObject    handle to rememberThresholdingCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rememberThresholdingCheck


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)
% hObject    handle to okButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Check to see if a channel has been selected for measurement.
measureSelected = 0;
checkSelected = get(handles.measureCheck1, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
checkSelected = get(handles.measureCheck2, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
checkSelected = get(handles.measureCheck3, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
checkSelected = get(handles.measureCheck4, 'Value');
if checkSelected == 1
    measureSelected = 1;
end

checkSelected = get(handles.measureAroundCheck1, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
checkSelected = get(handles.measureAroundCheck2, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
checkSelected = get(handles.measureAroundCheck3, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
checkSelected = get(handles.measureAroundCheck4, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
handles.saveMask = get(handles.saveMaskCheck, 'Value');
handles.verifyZ = get(handles.verifyZCheck, 'Value');

if ~measureSelected
    helpdlg('Select a channel to measure.', 'Error');
    return;
end

channelChoice = get(handles.channelSelect, 'Value');
handles.remember = 1; %get(handles.rememberCheck, 'Value');
handles.rememberScope = 'all'; %get(get(handles.rememberPanel, 'SelectedObject'), 'Tag');

guidata(hObject, handles);
uiresume;


function displayImage(handles)
%Display the default Z of the selected image, rendered.
global session;
selectedImageIdx = get(handles.imageSelect, 'Value');
pixelsList = getappdata(handles.ImageSegmentation, 'pixels');
pixels = pixelsList{selectedImageIdx};
pixelsId = pixels.getId.getValue;
imageId = pixels.getImage.getId.getValue;
renderService = session.getRenderingSettingsService;
renderDef = renderService.getRenderingSettings(pixelsId);
defaultZ = renderDef.getDefaultZ.getValue;
numC = pixels.getSizeC.getValue;
numX = pixels.getSizeX.getValue;
numY = pixels.getSizeY.getValue;
penTablet = zeros(numY, numX);
setappdata(handles.ImageSegmentation, 'penTablet', penTablet);
planes = zeros(numY, numX, numC);
for thisC = 1:numC
   planes(:,:,thisC) = getPlane(session, imageId, defaultZ, thisC-1, 0);
end
renderedImage = createRenderedImage(planes, pixels);
axes(handles.imageAxes)
handles.imageHandle = imshow(renderedImage);
guidata(handles.imageAxes, handles);
set(handles.imageAxes, 'Box', 'off');
set(handles.segAxes, 'Box', 'off');
set(handles.imageHandle, 'ButtonDownFcn', {@penTablet_ButtonDownFcn, handles});


function drawROIs(handles)
%Draw the rectangular ROIs on the image. Highlight the selected ROI in
%green, the others in white. Fill in the penTablet with ROI numbers within
%their areas.

selectedImageIdx = get(handles.imageSelect, 'Value');
selectedROI = getappdata(handles.ImageSegmentation, 'selectedROI');
roiShapes = getappdata(handles.ImageSegmentation, 'roiShapes');
penTablet = getappdata(handles.ImageSegmentation, 'penTablet');
numROI = length(roiShapes{selectedImageIdx});
axes(handles.imageAxes);

for thisROI = 1:numROI
    X = round(roiShapes{selectedImageIdx}{thisROI}.shape1.getX.getValue);
    Y = round(roiShapes{selectedImageIdx}{thisROI}.shape1.getY.getValue);
    
    if X < 1
        X = 1;
    end
    if Y < 1
        Y = 1;
    end
    width = round(roiShapes{selectedImageIdx}{thisROI}.shape1.getWidth.getValue);
    height = round(roiShapes{selectedImageIdx}{thisROI}.shape1.getHeight.getValue);
    if thisROI == selectedROI
        line([X X], [Y, Y+height], 'color', 'green');
        line([X X+width], [Y Y], 'color', 'green');
        line([X+width X+width], [Y Y+height], 'color', 'green');
        line([X X+width], [Y+height Y+height], 'color', 'green');
        penTablet(Y:Y+height, X:X+width) = thisROI;
    else
        line([X X], [Y, Y+height], 'color', 'white');
        line([X X+width], [Y Y], 'color', 'white');
        line([X+width X+width], [Y Y+height], 'color', 'white');
        line([X X+width], [Y+height Y+height], 'color', 'white');
        penTablet(Y:Y+height, X:X+width) = thisROI;
    end
end
setappdata(handles.ImageSegmentation, 'penTablet', penTablet);



function showChannelCheckBoxes(handles)
%Set the correct channel measurement check boxes for the selected image.

selectedImageIdx = get(handles.imageSelect, 'Value');
channelLabels = getappdata(handles.ImageSegmentation, 'channelLabels');
numChannels = length(channelLabels{selectedImageIdx});

switch numChannels
    case 1
        set(handles.measureCheck1, 'String', channelLabels{selectedImageIdx}(1));
        set(handles.measureCheck1, 'Visible', 'on');
        set(handles.measureAroundCheck1, 'String', channelLabels{selectedImageIdx}(1));
        set(handles.measureAroundCheck1, 'Visible', 'on');
    case 2
        set(handles.measureCheck1, 'String', channelLabels{selectedImageIdx}(1));
        set(handles.measureCheck1, 'Visible', 'on');
        set(handles.measureCheck2, 'String', channelLabels{selectedImageIdx}(2));
        set(handles.measureCheck2, 'Visible', 'on');
        set(handles.measureAroundCheck1, 'String', channelLabels{selectedImageIdx}(1));
        set(handles.measureAroundCheck1, 'Visible', 'on');
        set(handles.measureAroundCheck2, 'String', channelLabels{selectedImageIdx}(2));
        set(handles.measureAroundCheck2, 'Visible', 'on');
    case 3
        set(handles.measureCheck1, 'String', channelLabels{selectedImageIdx}(1));
        set(handles.measureCheck1, 'Visible', 'on');
        set(handles.measureCheck2, 'String', channelLabels{selectedImageIdx}(2));
        set(handles.measureCheck2, 'Visible', 'on');
        set(handles.measureCheck3, 'String', channelLabels{selectedImageIdx}(3));
        set(handles.measureCheck3, 'Visible', 'on');
        set(handles.measureAroundCheck1, 'String', channelLabels{selectedImageIdx}(1));
        set(handles.measureAroundCheck1, 'Visible', 'on');
        set(handles.measureAroundCheck2, 'String', channelLabels{selectedImageIdx}(2));
        set(handles.measureAroundCheck2, 'Visible', 'on');
        set(handles.measureAroundCheck3, 'String', channelLabels{selectedImageIdx}(3));
        set(handles.measureAroundCheck3, 'Visible', 'on');
    case 4
        set(handles.measureCheck1, 'String', channelLabels{selectedImageIdx}(1));
        set(handles.measureCheck1, 'Visible', 'on');
        set(handles.measureCheck2, 'String', channelLabels{selectedImageIdx}(2));
        set(handles.measureCheck2, 'Visible', 'on');
        set(handles.measureCheck3, 'String', channelLabels{selectedImageIdx}(3));
        set(handles.measureCheck3, 'Visible', 'on');
        set(handles.measureCheck4, 'String', channelLabels{selectedImageIdx}(4));
        set(handles.measureCheck4, 'Visible', 'on');
        set(handles.measureAroundCheck1, 'String', channelLabels{selectedImageIdx}(1));
        set(handles.measureAroundCheck1, 'Visible', 'on');
        set(handles.measureAroundCheck2, 'String', channelLabels{selectedImageIdx}(2));
        set(handles.measureAroundCheck2, 'Visible', 'on');
        set(handles.measureAroundCheck3, 'String', channelLabels{selectedImageIdx}(3));
        set(handles.measureAroundCheck3, 'Visible', 'on');
        set(handles.measureAroundCheck4, 'String', channelLabels{selectedImageIdx}(4));
        set(handles.measureAroundCheck4, 'Visible', 'on');
end


function segmentROI(handles)
global session
%Segment the ROI chosen on the image. (ROI 1 at app launch)

disableControls(handles);
segPatches = getappdata(handles.ImageSegmentation, 'segPatches');
selectedImageIdx = get(handles.imageSelect, 'Value');
selectedROI = getappdata(handles.ImageSegmentation, 'selectedROI');
selectedChannel = get(handles.channelSelect, 'Value')-1;
featherSize = str2double(get(handles.featherText, 'String'));
minSize = str2double(get(handles.minSizeText, 'String'));
groupObjects = get(handles.groupObjectsRadio, 'Value');
useOtsu = get(handles.otsuThresholdRadio, 'Value');
useAbsolute = get(handles.absoluteThresholdRadio, 'Value');
useSigma = get(handles.sigmaThresholdRadio, 'Value');
if useOtsu == 1
    selectedSegType = 'Otsu';
elseif useAbsolute == 1
    selectedSegType = 'Absolute';
elseif useSigma == 1
    selectedSegType = 'Sigma';
end
setappdata(handles.ImageSegmentation, 'selectedSegType', selectedSegType);

roiShapes = getappdata(handles.ImageSegmentation, 'roiShapes');
pixelsList = getappdata(handles.ImageSegmentation, 'pixels');
pixels = pixelsList{selectedImageIdx};
pixelsId = pixels.getId.getValue;
imageId = pixels.getImage.getId.getValue;
X = round(roiShapes{selectedImageIdx}{selectedROI}.shape1.getX.getValue+1);
Y = round(roiShapes{selectedImageIdx}{selectedROI}.shape1.getY.getValue+1);
numROIZ = roiShapes{selectedImageIdx}{selectedROI}.numShapes;
Z = [];
for thisROIZ = 1:numROIZ
    thisZ = roiShapes{selectedImageIdx}{selectedROI}.(['shape' num2str(thisROIZ)]).getTheZ.getValue;
    Z = [Z thisZ];
end
width = roiShapes{selectedImageIdx}{selectedROI}.shape1.getWidth.getValue-1;
height = roiShapes{selectedImageIdx}{selectedROI}.shape1.getHeight.getValue-1;

maxX = pixels.getSizeX.getValue;
maxY = pixels.getSizeY.getValue;
ROIMaxX = X+width;
ROIMaxY = Y+height;

if X < 1
    X = 1;
end
if Y < 1
    Y = 1;
end
if ROIMaxX > maxX
    ROIMaxX = maxX;
end
if ROIMaxY > maxY
    ROIMaxY = maxY;
end
indices.X = X:ROIMaxX;
indices.Y = Y:ROIMaxY;
patches = zeros(ROIMaxY-Y+1, ROIMaxX-X+1, numROIZ);
%download the Zs for this ROI if needed. Check if segmentation type
%is the same as before
segmentationType = getappdata(handles.ImageSegmentation, 'segmentationType');
% if ~isempty(segmentationType{selectedROI}{selectedChannel+1})
%     if ~strcmp(segmentationType{selectedROI}{selectedChannel+1}, selectedSegType)
%         segPatches{selectedROI}{selectedChannel+1} = [];
%     end
% end

lowestValue = getappdata(handles.ImageSegmentation, 'lowestValue');
if isempty(segPatches{selectedROI}{selectedChannel+1})
    counter = 1;
    for ROIZ = Z;
        plane = getPlane(session, imageId, ROIZ, selectedChannel, 0);
        patches(:,:,counter) = plane(indices.Y, indices.X);
        counter = counter + 1;
    end

    patchMax = getappdata(handles.ImageSegmentation, 'patchMax');
    if ROIZ > 1
        patchMax{selectedROI}{selectedChannel+1} = max(max(max(patches)));
    else
        patchMax{selectedROI}{selectedChannel+1} = max(max(patches));
    end
    setappdata(handles.ImageSegmentation, 'patchMax', patchMax);
    %Insist on separate objects, alter the appearance at display time
    %instead.
    if useOtsu == 1
        [segPatches{selectedROI}{selectedChannel+1} lowestValue(selectedROI,selectedChannel+1)] = seg3D(patches, featherSize, 0, minSize);
        sigmaMultiplier = getSigmaMultiplier(handles, patches);
        set(handles.sigmaLabel, 'String', num2str(sigmaMultiplier));
        %segmentationType{selectedROI}{selectedChannel+1} = 'Otsu';
        %setappdata(handles.ImageSegmentation, 'segmentationType', segmentationType);
    elseif useAbsolute == 1
        threshold = str2double(get(handles.thresholdText, 'String'));
        [segPatches{selectedROI}{selectedChannel+1} lowestValue(selectedROI,selectedChannel+1)] = seg3DThresh(patches, featherSize, 0, threshold, minSize, patchMax{selectedROI}{selectedChannel+1});
        sigmaMultiplier = getSigmaMultiplier(handles, patches);
        set(handles.sigmaLabel, 'String', num2str(sigmaMultiplier));
        %segmentationType{selectedROI}{selectedChannel+1} = 'Absolute';
        %setappdata(handles.ImageSegmentation, 'segmentationType', segmentationType);
    elseif useSigma == 1
        if handles.sigmaChanged == 1
            sigmaMultiplier = getSigmaMultiplier(handles, patches);
        else
            sigmaMultiplier = str2double(get(handles.sigmaLabel, 'String'));
        end
        threshold = getSigmaThreshold(patches, sigmaMultiplier);
        set(handles.sigmaLabel, 'String', num2str(sigmaMultiplier));
        [segPatches{selectedROI}{selectedChannel+1} lowestValue(selectedROI,selectedChannel+1)] = seg3DThresh(patches, featherSize, 0, threshold, minSize, patchMax{selectedROI}{selectedChannel+1});
        %segmentationType{selectedROI}{selectedChannel+1} = 'Sigma';
        %setappdata(handles.ImageSegmentation, 'segmentationType', segmentationType);
    end
    setappdata(handles.ImageSegmentation, 'segPatches', segPatches);
    setappdata(handles.ImageSegmentation, 'lowestValue', lowestValue);
end

set(handles.thresholdText, 'String', num2str(lowestValue(selectedROI,selectedChannel+1)));
set(handles.absoluteThresholdLabel, 'String', num2str(lowestValue(selectedROI,selectedChannel+1)));


%Draw the segPatches depending on groupObject settings. Display the middle
%Z of the ROI stack
middleROIZ = round(numROIZ/2);
axes(handles.segAxes)
if groupObjects == 0 && max(max(segPatches{selectedROI}{selectedChannel+1}(:,:,middleROIZ))) ~= 0
    handles.segHandle = imshow(segPatches{selectedROI}{selectedChannel+1}(:,:,middleROIZ), [0 max(max(max(segPatches{selectedROI}{selectedChannel+1})))]);
else
    handles.segHandle = imshow(segPatches{selectedROI}{selectedChannel+1}(:,:,middleROIZ));
end

%Update the zSlider settings for this ROI.
if numROIZ > 1
    sliderSmallStep = 1/numROIZ;
    set(handles.zSlider, 'Max', numROIZ);
    set(handles.zSlider, 'Min', 1);
    set(handles.zSlider, 'Value', middleROIZ);
    set(handles.zSlider, 'Enable', 'on');
    set(handles.zSlider, 'SliderStep', [sliderSmallStep, sliderSmallStep*4]);
    set(handles.zLabel, 'String', ['Z = ' num2str(middleROIZ)]);
else
    set(handles.zSlider, 'Min', 0.9);
    set(handles.zSlider, 'Max', 1);
    set(handles.zSlider, 'Value', 1);
    set(handles.zSlider, 'Enable', 'off');
    set(handles.zLabel, 'String', 'Z = 1');
end

guidata(handles.segAxes, handles);
setappdata(handles.ImageSegmentation, 'patches', patches);
updateThresholdSlider(handles);

enableControls(handles)




function segAxes_CreateFcn(hObject, eventdata, handles)

axis off;


function imageAxes_CreateFcn(hObject, eventdata, handles)

axis off;


function penTablet_ButtonDownFcn(hObject, eventdata, handles)
%Detect if user clicked inside an ROI, and segment it. Also redraw ROIs to
%show the new selection. If an ROI is currently being segmented then don't
%action this.

isEnabled = get(handles.imageSelect, 'Enable');
if strcmp(isEnabled, 'on')
    currentPoint = get(handles.imageAxes, 'CurrentPoint');
    penTablet = getappdata(handles.ImageSegmentation, 'penTablet');
    X = round(currentPoint(1));
    Y = round(currentPoint(4));
    selectedROI = penTablet(Y,X);
    if selectedROI ~= 0
        displayLoadingImage(handles);
        setappdata(handles.ImageSegmentation, 'selectedROI', selectedROI);
        guidata(hObject, handles);
        drawROIs(handles);
        drawnow;
        segmentROI(handles);
    end
end


function disableControls(handles)
%Disable the controls while the ROI wis being segmented. Stops crashes if
%user changes things at this point.

set(handles.imageSelect, 'Enable', 'off');
set(handles.channelSelect, 'Enable', 'off');
set(handles.groupObjectsRadio, 'Enable', 'off');
set(handles.separateObjectsRadio, 'Enable', 'off');
set(handles.minSizeText, 'Enable', 'off');
set(handles.featherText, 'Enable', 'off');
set(handles.thresholdText, 'Enable', 'off');
set(handles.thresholdSlider, 'Enable', 'off');
set(handles.zSlider, 'Enable', 'off');
set(handles.okButton, 'Enable', 'off');
set(handles.previewButton, 'Enable', 'off');
drawnow;


function enableControls(handles)
%Enable the controls after the ROI has been segmented. 

set(handles.imageSelect, 'Enable', 'on');
set(handles.channelSelect, 'Enable', 'on');
set(handles.groupObjectsRadio, 'Enable', 'on');
set(handles.separateObjectsRadio, 'Enable', 'on');
set(handles.minSizeText, 'Enable', 'on');
set(handles.featherText, 'Enable', 'on');
set(handles.thresholdText, 'Enable', 'on');
set(handles.thresholdSlider, 'Enable', 'on');
set(handles.zSlider, 'Enable', 'on');
set(handles.okButton, 'Enable', 'on');
set(handles.previewButton, 'Enable', 'on');
drawnow


function groupObjectsRadio_Callback(hObject, eventdata, handles)

selectedROI = getappdata(handles.ImageSegmentation, 'selectedROI');
selectedChannel = get(handles.channelSelect, 'Value');
selectedZ = round(get(handles.zSlider, 'Value'));
segPatches = getappdata(handles.ImageSegmentation, 'segPatches');
axes(handles.segAxes);
handles.segHandle = imshow(segPatches{selectedROI}{selectedChannel}(:,:,selectedZ));


function separateObjectsRadio_Callback(hObject, eventdata, handles)

selectedROI = getappdata(handles.ImageSegmentation, 'selectedROI');
selectedChannel = get(handles.channelSelect, 'Value');
selectedZ = round(get(handles.zSlider, 'Value'));
segPatches = getappdata(handles.ImageSegmentation, 'segPatches');
axes(handles.segAxes);
handles.segHandle = imshow(segPatches{selectedROI}{selectedChannel}(:,:,selectedZ), [0 max(max(max(segPatches{selectedROI}{selectedChannel})))]);


function updateThresholdSlider(handles)

selectedROI = getappdata(handles.ImageSegmentation, 'selectedROI');
selectedChannel = get(handles.channelSelect, 'Value');
textThreshold = str2double(get(handles.thresholdText, 'String'));
patchMax = getappdata(handles.ImageSegmentation, 'patchMax');

%Make sure slider isn't broken by large values from the text box.
if textThreshold > patchMax{selectedROI}{selectedChannel}
    textThreshold = patchMax{selectedROI}{selectedChannel};
    set(handles.thresholdText, 'String', num2str(textThreshold));
    set(handles.absoluteThresholdLabel, 'String', num2str(textThreshold));
end

thresholdStep = 1/patchMax{selectedROI}{selectedChannel};

set(handles.thresholdSlider, 'Max', patchMax{selectedROI}{selectedChannel});
set(handles.thresholdSlider, 'Min', 0);
set(handles.thresholdSlider, 'Value', textThreshold);
set(handles.thresholdSlider, 'Enable', 'on');
set(handles.thresholdSlider, 'SliderStep', [thresholdStep, thresholdStep*4]);


function resegment(handles)
segPatches = getappdata(handles.ImageSegmentation, 'segPatches');
selectedROI = getappdata(handles.ImageSegmentation, 'selectedROI');
selectedChannel = get(handles.channelSelect, 'Value');
segPatches{selectedROI}{selectedChannel} = [];
setappdata(handles.ImageSegmentation, 'segPatches', segPatches);
segmentROI(handles)



function displayLoadingImage(handles)

axes(handles.segAxes);
imshow(handles.loadingImage);
drawnow;


function sigmaMultiplier = getSigmaMultiplier(handles, patches)
%calculate the sigma multiplier and set it to 3 decimal places.

linearPatch = reshape(patches, 1, []);
patchMean = mean(linearPatch);
patchStDev = std(linearPatch);
thresholdText = str2double(get(handles.thresholdText, 'String'));
sigmaMultiplier = (patchMean - thresholdText) / patchStDev;
sigmaMultiplier = round((sigmaMultiplier*1000))/1000;


% --- Executes on button press in resetOtsuButton.
function resetOtsuButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetOtsuButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.sigmaChanged = 1;
set(handles.otsuThresholdRadio, 'Value', 1);
guidata(hObject, handles);
resegment(handles);


% --------------------------------------------------------------------
function fileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to fileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function chooseDatasetsItem_Callback(hObject, eventdata, handles)
% hObject    handle to chooseDatasetsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datasetChooser(handles, 'ImageSegmentation');
setAnalysisQueue(handles);
imageSelect_Callback(handles.imageSelect, eventdata, handles);



% --- Executes on button press in previewButton.
function previewButton_Callback(hObject, eventdata, handles)
% hObject    handle to previewButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Delete the current segmentation from segPatches, and re-run segmentROI
displayLoadingImage(handles);
segPatches = getappdata(handles.ImageSegmentation, 'segPatches');
selectedROI = getappdata(handles.ImageSegmentation, 'selectedROI');
selectedChannel = get(handles.channelSelect, 'Value');
segPatches{selectedROI}{selectedChannel} = [];
setappdata(handles.ImageSegmentation, 'segPatches', segPatches);
segmentROI(handles)


% --- Executes on button press in annulusCheck.
function annulusCheck_Callback(hObject, eventdata, handles)
% hObject    handle to annulusCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of annulusCheck

enableAnnulusGapText(handles)



function annulusText_Callback(hObject, eventdata, handles)
% hObject    handle to annulusText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of annulusText as text
%        str2double(get(hObject,'String')) returns contents of annulusText as a double

annulusSize = str2double(get(hObject, 'String'));
if isnan(annulusSize) || annulusSize < 1
    set(hObject, 'String', '1');
else
    set(hObject, 'String', num2str(round(annulusSize)));
end



% --- Executes during object creation, after setting all properties.
function annulusText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to annulusText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function enableAnnulus(handles)

measureAround1 = get(handles.measureAroundCheck1, 'Value');
measureAround2 = get(handles.measureAroundCheck2, 'Value');
measureAround3 = get(handles.measureAroundCheck3, 'Value');
measureAround4 = get(handles.measureAroundCheck4, 'Value');

measureAround = measureAround1 + measureAround2 + measureAround3 + measureAround4;

if measureAround == 0
    set(handles.annulusCheck, 'Value', 0);
    set(handles.annulusCheck, 'Enable', 'off');
else
    set(handles.annulusCheck, 'Enable', 'on'); 
end
enableAnnulusGapText(handles)

function enableAnnulusGapText(handles)

useAnnulus = get(handles.annulusCheck, 'Value');

if useAnnulus == 0
    set(handles.annulusText, 'Enable', 'off');
    set(handles.annulusLabel, 'Enable', 'off');
    set(handles.annulusPixelsLabel, 'Enable', 'off');
    set(handles.gapText, 'Enable', 'off');
    set(handles.gapLabel, 'Enable', 'off');
else
    set(handles.annulusText, 'Enable', 'on');
    set(handles.annulusLabel, 'Enable', 'on');
    set(handles.annulusPixelsLabel, 'Enable', 'on');
    set(handles.gapText, 'Enable', 'on');
    set(handles.gapLabel, 'Enable', 'on');
end


function gapText_Callback(hObject, eventdata, handles)
% hObject    handle to gapText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gapText as text
%        str2double(get(hObject,'String')) returns contents of gapText as a double

gapSize = str2double(get(hObject, 'String'));
if isnan(gapSize) || gapSize < 0
    set(hObject, 'String', '0');
else
    set(hObject, 'String', num2str(round(gapSize)));
end


% --- Executes during object creation, after setting all properties.
function gapText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gapText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function setAnalysisQueue(handles)

selectedDsIds = getappdata(handles.ImageSegmentation, 'selectedDsIds');
if isempty(selectedDsIds)
    return;
end
[images, imageIds, imageNames, datasetNames] = getImageIdsAndNamesFromDatasetIds(selectedDsIds);
[imageIdxNoROIs, roiShapes] = ROIImageCheck(imageIds);
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

%Sort the ROIShapes by Z
for thisImage = 1:numImages
    numROI = length(roiShapes{thisImage});
    for thisROI = 1:numROI
        roiShapes{thisImage}{thisROI} = sortROIShapes(roiShapes{thisImage}{thisROI}, 'byZ');
    end
end

for thisImage = 1:numImages
    theImage = images.get(thisImage-1);
    pixels{thisImage} = theImage.getPixels(0);
    channelLabels{thisImage} = getChannelsFromPixels(pixels{thisImage});
end

set(handles.imageSelect, 'Value', 1);
set(handles.imageSelect, 'String', imageNames);
set(handles.channelSelect, 'Value', 1);
set(handles.channelSelect, 'String', channelLabels{1});
set(handles.channelSelect, 'Enable', 'on');
setappdata(handles.ImageSegmentation, 'imageIds', imageIds);
setappdata(handles.ImageSegmentation, 'imageNames', imageNames);
setappdata(handles.ImageSegmentation, 'roiShapes', roiShapes);
setappdata(handles.ImageSegmentation, 'channelLabels', channelLabels);
setappdata(handles.ImageSegmentation, 'pixels', pixels);
setappdata(handles.ImageSegmentation, 'datasetNames', datasetNames);
setappdata(handles.ImageSegmentation, 'selectedROI', 1);
guidata(handles.ImageSegmentation, handles);



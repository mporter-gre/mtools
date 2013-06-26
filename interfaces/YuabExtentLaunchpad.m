function varargout = YuabExtentLaunchpad(varargin)
% YuabEXTENTLAUNCHPAD MATLAB code for YuabExtentLaunchpad.fig
%      YuabEXTENTLAUNCHPAD, by itself, creates a new YuabEXTENTLAUNCHPAD or raises the existing
%      singleton*.
%
%      H = YuabEXTENTLAUNCHPAD returns the handle to a new YuabEXTENTLAUNCHPAD or the handle to
%      the existing singleton*.
%
%      YuabEXTENTLAUNCHPAD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in YuabEXTENTLAUNCHPAD.M with the given input arguments.
%
%      YuabEXTENTLAUNCHPAD('Property','Value',...) creates a new YuabEXTENTLAUNCHPAD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before YuabExtentLaunchpad_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to YuabExtentLaunchpad_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help YuabExtentLaunchpad

% Last Modified by GUIDE v2.5 26-Feb-2012 21:49:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @YuabExtentLaunchpad_OpeningFcn, ...
                   'gui_OutputFcn',  @YuabExtentLaunchpad_OutputFcn, ...
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


% --- Executes just before YuabExtentLaunchpad is made visible.
function YuabExtentLaunchpad_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to YuabExtentLaunchpad (see VARARGIN)

% Choose default command line output for YuabExtentLaunchpad
handles.output = hObject;
setappdata(handles.YuabExtentLaunchpad, 'passData', '');
set(handles.passwordText, 'KeyPressFcn', {@passKeyPress, handles});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes YuabExtentLaunchpad wait for user response (see UIRESUME)
% uiwait(handles.YuabExtentLaunchpad);


% --- Outputs from this function are returned to the command line.
function varargout = YuabExtentLaunchpad_OutputFcn(hObject, eventdata, handles) 
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

datasetChooser(handles, 'YuabExtentLaunchpad');

selectedDsIds = getappdata(handles.YuabExtentLaunchpad, 'selectedDsIds');
[images imageIds imageNames datasetNames] = getImageIdsAndNamesFromDatasetIds(selectedDsIds);
[imageIdxNoROIs roiShapes] = ROIImageCheck(imageIds);
images = deleteElementFromJavaArrayList(imageIdxNoROIs, images);
imageIds = deleteElementFromVector(imageIdxNoROIs, imageIds);
imageNames = deleteElementFromCells(imageIdxNoROIs, imageNames);
roiShapes = deleteElementFromCells(imageIdxNoROIs, roiShapes);
datasetNames = deleteElementFromCells(imageIdxNoROIs, datasetNames);
numImages = images.size;

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

if ~isempty(imageIds)
    set(handles.beginBtn, 'Enable', 'on');
else
    errordlg('There are no images in the datasets that have ROIs.');
    return;
end

setappdata(handles.YuabExtentLaunchpad, 'imageIds', imageIds);
setappdata(handles.YuabExtentLaunchpad, 'imageNames', imageNames);
setappdata(handles.YuabExtentLaunchpad, 'roiShapes', roiShapes);
setappdata(handles.YuabExtentLaunchpad, 'channelLabels', channelLabels);
setappdata(handles.YuabExtentLaunchpad, 'pixels', pixels);
setappdata(handles.YuabExtentLaunchpad, 'datasetNames', datasetNames);
handles.selectedROI = 1;
guidata(hObject, handles);



% --- Executes on button press in beginBtn.
function beginBtn_Callback(hObject, eventdata, handles)
% hObject    handle to beginBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

YuabExtentAnalysis(handles, 'YuabExtentLaunchpad');

outputToExcel(handles);



function usernameText_Callback(hObject, eventdata, handles)
% hObject    handle to usernameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of usernameText as text
%        str2double(get(hObject,'String')) returns contents of usernameText as a double


% --- Executes during object creation, after setting all properties.
function usernameText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to usernameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function passwordText_Callback(hObject, eventdata, handles)
% hObject    handle to passwordText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of passwordText as text
%        str2double(get(hObject,'String')) returns contents of passwordText as a double


% --- Executes during object creation, after setting all properties.
function passwordText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to passwordText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in loginBtn.
function loginBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loginBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

success = logIn(handles);
if success == true
    set(handles.chooseDatasetsBtn, 'Enable', 'on');
end



function success = logIn(handles)

global client;
global session;
global gateway;
global clientAlive;

credentials{1} = get(handles.usernameText, 'String');
credentials{2} = getappdata(handles.YuabExtentLaunchpad, 'passData');
credentials{3} = 'nightshade.openmicroscopy.org.uk';
credentials{4} = '4064';
setappdata(handles.YuabExtentLaunchpad, 'credentials', credentials);
if isempty(credentials{1}) || isempty(credentials{2}) || isempty(credentials{3}) || isempty(credentials{4})
    helpdlg('Check you have entered a Username and Password.');
    return;
end

%First check the login works. Client, session and gateway are global, so
%will persist and be kept alive until application close.
try
    if ~isjava(client)
        gatewayConnect(credentials{1}, credentials{2}, credentials{3}, credentials{4});
        %saveHistory(credentials);
        success = true;
        selectUserDefaultGroup(credentials{1}, handles, 'YuabExtentLaunchpad');
    else
        experimenter = char(session.getAdminService.getExperimenter(0).getOmeName.getValue.getBytes)';
        if strcmp(experimenter, credentials{1})
            success = true;
        else
            gatewayDisconnect;
            success = logIn(handles);
        end
    end
%     uiwait(groupSelection);
catch ME
    clear global client;
    clear global session;
    clear global gateway;
    clear global clientAlive;
    disp(ME.message);
    warndlg('Could not log on to the server. Check your details and try again.');
    success = false;
    return;
end



function passKeyPress(hObject, eventdata, handles)

lastChar = eventdata.Character;
lastKey = eventdata.Key;
currPass = getappdata(handles.YuabExtentLaunchpad, 'passData');
charset = char(33:126);
if lastChar
    if any(charset == lastChar)
        password = [currPass lastChar];
    elseif strcmp(lastKey, 'backspace')
        password = currPass(1:end-1);
    elseif strcmp(lastKey, 'delete')
        password = '';
    else
        return;
    end

    setappdata(handles.YuabExtentLaunchpad, 'passData', password);
    numChars = length(password);
    stars(1:numChars) = '*';
    set(hObject, 'String', stars);
end


function outputToExcel(handles)

imageNames = getappdata(handles.YuabExtentLaunchpad, 'imageNames');
datasetNames = getappdata(handles.YuabExtentLaunchpad, 'datasetNames');
greenMatrix = num2cell(getappdata(handles.YuabExtentLaunchpad, 'greenMatrix'));
redMatrix = num2cell(getappdata(handles.YuabExtentLaunchpad, 'redMatrix'));

imageNames = [{''} imageNames];
datasetNames = ['Z-Section' datasetNames];

greenDataOut = [imageNames; datasetNames; greenMatrix];
redDataOut = [imageNames; datasetNames; redMatrix];


% greenSignalStartMean = num2cell(getappdata(handles.YuabExtentLaunchpad, 'greenSignalStartMean')');
% greenSignalStartStd = num2cell(getappdata(handles.YuabExtentLaunchpad, 'greenSignalStartStd')');
% greenExtentMean = num2cell(getappdata(handles.YuabExtentLaunchpad, 'greenExtentMean')');
% greenExtentStd = num2cell(getappdata(handles.YuabExtentLaunchpad, 'greenExtentStd')');
% redSignalStartMean = num2cell(getappdata(handles.YuabExtentLaunchpad, 'redSignalStartMean')');
% redSignalStartStd = num2cell(getappdata(handles.YuabExtentLaunchpad, 'redSignalStartStd')');
% redExtentMean = num2cell(getappdata(handles.YuabExtentLaunchpad, 'redExtentMean')');
% redExtentStd = num2cell(getappdata(handles.YuabExtentLaunchpad, 'redExtentStd')');

% dataOut = [{'Image'} {'Dataset'} {'greenSignalStartMean'} {'greenSignalStartStd'} {'greenExtentMean'} {'greenExtentStd'} {'redSignalStartMean'} {'redSignalStartStd'} {'redExtentMean'} {'redExtentStd'}];
% dataOut = [dataOut; imageNames datasetNames greenSignalStartMean greenSignalStartStd greenExtentMean greenExtentStd redSignalStartMean redSignalStartStd redExtentMean redExtentStd];


[saveFile savePath] = uiputfile('*.xls','Save Results','/YuaB_zExtent.xls');
if isnumeric(saveFile) && isnumeric(savePath)
    return;
end

xlswrite([savePath saveFile], greenDataOut, 'cells');
xlswrite([savePath saveFile], redDataOut, 'YuaB');









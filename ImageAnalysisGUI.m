function varargout = ImageAnalysisGUI(varargin)
% IMAGEANALYSISGUI M-file for ImageAnalysisGUI.fig
%      IMAGEANALYSISGUI, by itself, creates a new IMAGEANALYSISGUI or raises the existing
%      singleton*.
%
%      H = IMAGEANALYSISGUI returns the handle to a new IMAGEANALYSISGUI or the handle to
%      the existing singleton*.
%
%      IMAGEANALYSISGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEANALYSISGUI.M with the given input arguments.
%
%      IMAGEANALYSISGUI('Property','Value',...) creates a new IMAGEANALYSISGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageAnalysisGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageAnalysisGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageAnalysisGUI

% Last Modified by GUIDE v2.5 06-Jul-2009 16:30:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageAnalysisGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageAnalysisGUI_OutputFcn, ...
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
     
% --- Executes just before ImageAnalysisGUI is made visible.
function ImageAnalysisGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageAnalysisGUI (see VARARGIN)

% Choose default command line output for ImageAnalysisGUI
handles.output = hObject;
password = '';
setappdata(hObject,'passData',password);
%Set the key press function of the password box for **** insertion.
handles.conditionsPaths = '';
handles.conditionsFiles = '';
handles.currDir = cd;
set(handles.passText, 'KeyPressFcn', {@passKeyPress, handles});
set(handles.newConditionText, 'KeyPressFcn', {@newConditionTextKeyPress, handles});
uicontrol(handles.userText);
checkLoginHistory(handles)

%selete this before compiling!!!!!!!

% Update handles structure

guidata(hObject, handles)


% UIWAIT makes ImageAnalysisGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ImageAnalysisGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

global client;
if isjava(client)
    gatewayDisconnect;
end
varargout{1} = handles.output;


% --- Executes on selection change in ConditionsList.
function ConditionsList_Callback(hObject, eventdata, handles)
% hObject    handle to ConditionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ConditionsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ConditionsList


% --- Executes during object creation, after setting all properties.
function ConditionsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConditionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function userText_Callback(hObject, eventdata, handles)
% hObject    handle to userText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of userText as text
%        str2double(get(hObject,'String')) returns contents of userText as
%        a double


% --- Executes during object creation, after setting all properties.
function userText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to userText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function passText_Callback(hObject, eventdata, handles)
% hObject    handle to passText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of passText as text
%        str2double(get(hObject,'String')) returns contents of passText as a double




% --- Executes during object creation, after setting all properties.
function passText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to passText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    set(hObject,'String',' ');
end


function passKeyPress(hObject, eventdata, handles)

lastChar = eventdata.Character;
lastKey = eventdata.Key;
currPass = getappdata(handles.figure1, 'passData');
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

    setappdata(handles.figure1, 'passData', password);
    numChars = length(password);
    stars(1:numChars) = '*';
    set(hObject, 'String', stars);
end



function serverText_Callback(hObject, eventdata, handles)
% hObject    handle to serverText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of serverText as text
%        str2double(get(hObject,'String')) returns contents of serverText as a double


% --- Executes during object creation, after setting all properties.
function serverText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to serverText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in beginAnalysisButton.
function beginAnalysisButton_Callback(hObject, eventdata, handles)
% hObject    handle to beginAnalysisButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global client;
global session;
global gateway;
global clientAlive;

credentials{1} = get(handles.userText, 'String');
credentials{2} = getappdata(handles.figure1, 'passData');
credentials{3} = get(handles.serverText, 'String');
if isempty(credentials{1}) || isempty(credentials{2}) || isempty(credentials{3})
    helpdlg('Check you have entered a Username, Password and Server.');
    return;
end

conditions = get(handles.conditionsList, 'String');
if isempty(conditions) || strcmp(conditions{1}, '')
    helpdlg('Please enter at least one experimental condition');
    return;
end

%First check the login works. Client, session and gateway are global, so
%will persist and be kept alive until application close.
try
    if ~isjava(client)
        gatewayConnect(credentials{1}, credentials{2}, credentials{3});
        saveHistory(credentials);
    end
catch ME
    clear global client;
    clear global session;
    clear global gateway;
    clear global clientAlive;
    disp(ME.message);
    warndlg('Could not log on to the server. Check your details and try again.');
    return;
end

selectedAnalysis = get(get(handles.AnalysisPanel, 'SelectedObject'), 'Tag');
set(hObject, 'Enable', 'off');
drawnow;
handles.conditionsPaths = getappdata(handles.figure1, 'conditionsPaths');
handles.conditionsFiles = getappdata(handles.figure1, 'conditionsFiles');
guidata(hObject, handles);
switch selectedAnalysis
    case 'segmentAndMeasureRadio'
        selectROIFilesForVolumeIntensityMeasure(credentials, conditions, handles);
    case 'distanceRadio'
        selectROIFilesForDistanceMeasure(credentials, conditions, handles);
    case 'lineMeasureRadio'
        selectROIFilesForLineMeasure(credentials, conditions, handles);
    case 'eventTimerRadio' 
        selectROIFilesForEventTimerAndCrop(credentials, conditions, handles);
    case 'flipRadio'
        helpdlg('For FLIP analysis ROI files are needed to calculate the acquisition bleaching factor. Please select those now...');
        uiwait;
        [files path] = uigetfile('*.xml', 'Select acquisition bleaching factor ROI files...', handles.currDir, 'MultiSelect', 'on');
        handles.constantFiles = files;
        handles.constantPaths = path;
        guidata(hObject, handles);
        selectROIFilesForFLIPAnalysis(credentials, conditions, handles);
    case 'frapRadio'
        selectROIFilesForFRAPAnalysis(credentials, conditions, handles);
end
helpdlg('Analysis complete.', 'Complete');
set(hObject, 'Enable', 'on');



function conditionsText_Callback(hObject, eventdata, handles)
% hObject    handle to conditionsText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of conditionsText as text
%        str2double(get(hObject,'String')) returns contents of conditionsText as a double


% --- Executes during object creation, after setting all properties.
function conditionsText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to conditionsText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newConditionText_Callback(hObject, eventdata, handles)
% hObject    handle to newConditionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newConditionText as text
%        str2double(get(hObject,'String')) returns contents of newConditionText as a double

handles.newCondition = get(hObject, 'String');
guidata(hObject, handles);


function newConditionTextKeyPress(hObject, eventdata, handles)

lastKey = eventdata.Key;
if strcmp(lastKey, 'return')
    uicontrol(hObject); %re-focus the control to populate 'String' property for use in addButton_Callback
    addButton_Callback(hObject, eventdata, handles);
end
    

function newConditionText_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to newConditionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLABget(
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newConditionText as text
%        str2double(get(hObject,'String')) returns contents of newConditionText as a double

%get(hObject,'Value')


% --- Executes during object creation, after setting all properties.
function newConditionText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newConditionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addButton.
function addButton_Callback(hObject, eventdata, handles)
% hObject    handle to addButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newCondition = get(handles.newConditionText, 'String');
[tok remain] = strtok(newCondition);
if strcmp(tok, '') && strcmp(remain, '') || isempty(newCondition)
    set(handles.newConditionText, 'String', '');
    uicontrol(handles.newConditionText);
    return;
end

%Add the newCondition into the existing Conditions list.
conditionsSoFar = get(handles.conditionsList, 'String');
if strcmp(conditionsSoFar, '')
    conditionsSoFar = [];
end

conditionsFilesSoFar = getappdata(handles.figure1, 'conditionsFiles');
if strcmp(conditionsFilesSoFar, '')
    conditionsFilesSoFar = [];
end

conditionsPathsSoFar = getappdata(handles.figure1, 'conditionsPaths');
if strcmp(conditionsPathsSoFar, '')
    conditionsPathsSoFar = [];
end
%Check if the newCondition already exists. Offer to replace the ROI files
%for this condition.
conditionExists = strmatch(newCondition, conditionsSoFar, 'exact');
if ~isempty(conditionExists)
    questionStr = 'This condition has already been entered. Would you like to replace the ROI files attached to this condition?';
    response = questdlg(questionStr, 'Condition Exists', 'Replace', 'Cancel', 'Cancel');
    if isempty(response) || strcmp(response, 'Cancel')
        set(handles.newConditionText, 'String', '');
        uicontrol(handles.newConditionText);
        return;
    end
    [files path] = uigetfile('*.xml', ['Select ROI files for condition: ' newCondition], handles.currDir, 'MultiSelect', 'on');
    if isnumeric(files) && isnumeric(path)
        uicontrol(handles.newConditionText);
        return;
    end
    handles.currDir = path;
    if ~iscell(files)
        singleFile = files;
        clear files;
        files{1} = singleFile;
    end
    conditionsPathsSoFar{conditionExists} = path;
    conditionsFilesSoFar{conditionExists} = files;
else
    %Get the ROI fils and path to go with the conditions.
    [files path] = uigetfile('*.xml', ['Select ROI files for condition: ' newCondition], handles.currDir, 'MultiSelect', 'on');
    if isnumeric(files) && isnumeric(path)
        uicontrol(handles.newConditionText);
        return;
    end
    handles.currDir = path;
    if ~iscell(files)
        singleFile = files;
        clear files;
        files{1} = singleFile;
    end
    conditionsSoFar = [conditionsSoFar; {newCondition}];
    conditionsPathsSoFar = [conditionsPathsSoFar; {path}];
    conditionsFilesSoFar = [conditionsFilesSoFar; {files}];
end

setappdata(handles.figure1, 'conditionsPaths', conditionsPathsSoFar);
setappdata(handles.figure1, 'conditionsFiles', conditionsFilesSoFar);
% handles.conditionsPaths = conditionsPathsSoFar;
% handles.conditionsFiles = conditionsFilesSoFar;
guidata(hObject, handles);
set(handles.conditionsList, 'String', conditionsSoFar);
set(handles.newConditionText, 'String', '');
uicontrol(handles.newConditionText);


% --- Executes on selection change in conditionsList.
function conditionsList_Callback(hObject, eventdata, handles)
% hObject    handle to conditionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns conditionsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from conditionsList



% --- Executes during object creation, after setting all properties.
function conditionsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to conditionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in removeConditionButton.
function removeConditionButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeConditionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedIdx = get(handles.conditionsList, 'Value');
currentConditions = get(handles.conditionsList, 'String');
currentFiles = getappdata(handles.figure1, 'conditionsFiles');
currentPaths = getappdata(handles.figure1, 'conditionsPaths');
numConditions = length(currentConditions);
if selectedIdx ~= numConditions
    for thisCondition = selectedIdx:numConditions-1
        currentConditions{thisCondition} = currentConditions{thisCondition+1};
        currentFiles{thisCondition} = currentFiles{thisCondition+1};
        currentPaths{thisCondition} = currentPaths{thisCondition+1};
    end
    for thisCondition = 1:numConditions-1
        editedConditions{thisCondition} = currentConditions{thisCondition};
        editedFiles{thisCondition} = currentFiles{thisCondition};
        editedPaths{thisCondition} = currentPaths{thisCondition};
    end
    setappdata(handles.figure1, 'conditions', editedConditions);
    setappdata(handles.figure1, 'conditionsFiles', editedFiles);
    setappdata(handles.figure1, 'conditionsPaths', editedPaths);
else
    for thisCondition = 1:numConditions-1
        editedConditions{thisCondition} = currentConditions{thisCondition};
        editedFiles{thisCondition} = currentFiles{thisCondition};
        editedPaths{thisCondition} = currentPaths{thisCondition};
    end
end

if numConditions == 1
    set(handles.conditionsList, 'Value', 1);
    editedConditions{1} = '';
    editedFiles{1} = '';
    editedPaths{1} = '';
    set(handles.conditionsList, 'String', editedConditions);
    handles.conditionsFiles = editedFiles;
    handles.conditionsPaths = editedPaths;
%    rmappdata(handles.figure1, 'conditions');
    rmappdata(handles.figure1, 'conditionsFiles');
    rmappdata(handles.figure1, 'conditionsPaths');
    return
end
if numConditions == 0
    return;
end

set(handles.conditionsList, 'String', editedConditions);
set(handles.conditionsList, 'Value', numConditions-1);
setappdata(handles.figure1, 'conditions', editedConditions);
setappdata(handles.figure1, 'conditionsFiles', editedFiles);
setappdata(handles.figure1, 'conditionsPaths', editedPaths);


function checkLoginHistory(handles)

if ispc
    sysUser = getenv('username');
    sysUserHome = getenv('userprofile');
    historyFile = [sysUserHome '\omero\analysisHistory.mat'];
    try
        history = open(historyFile);
        set(handles.userText, 'String', history.omeroUser);
        set(handles.serverText, 'String', history.omeroServer);
        uicontrol(handles.passText);
    catch
    end
end


function saveHistory(credentials)

omeroUser = credentials{1};
omeroServer = credentials{3};
if ispc
    sysUserHome = getenv('userprofile');
    sysUser = getenv('username');
    omeroDir = [sysUserHome '\omero'];
    historyFile = [sysUserHome '\omero\analysisHistory.mat'];
    if ~isdir(omeroDir)
        mkdir(omeroDir)
    end
    save(historyFile, 'omeroUser', 'omeroServer');
end


function closeReqFcn(hObject, eventdata, handles)

gatewayDisconnect;
delete(handles.figure1);
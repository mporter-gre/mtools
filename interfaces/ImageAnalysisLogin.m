function varargout = ImageAnalysisLogin(varargin)
% IMAGEANALYSISLOGIN M-file for ImageAnalysisLogin.fig
%      IMAGEANALYSISLOGIN, by itself, creates a new IMAGEANALYSISLOGIN or raises the existing
%      singleton*.
%
%      H = IMAGEANALYSISLOGIN returns the handle to a new IMAGEANALYSISLOGIN or the handle to
%      the existing singleton*.
%
%      IMAGEANALYSISLOGIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEANALYSISLOGIN.M with the given input arguments.
%
%      IMAGEANALYSISLOGIN('Property','Value',...) creates a new IMAGEANALYSISLOGIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageAnalysisLogin_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageAnalysisLogin_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageAnalysisLogin

% Last Modified by GUIDE v2.5 30-Jun-2015 20:04:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageAnalysisLogin_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageAnalysisLogin_OutputFcn, ...
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


% --- Executes just before ImageAnalysisLogin is made visible.
function ImageAnalysisLogin_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageAnalysisLogin (see VARARGIN)

% Choose default command line output for ImageAnalysisLogin
handles.output = hObject;

password = '';
setappdata(hObject,'passData',password);
%Set the key press function of the password box for **** insertion.
handles.conditionsPaths = '';
handles.conditionsFiles = '';
handles.currDir = cd;
set(handles.passwordText, 'KeyPressFcn', {@passKeyPress, handles});
uicontrol(handles.usernameText);
checkLoginHistory(handles);
startDiary(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImageAnalysisLogin wait for user response (see UIRESUME)
% uiwait(handles.ImageAnalysisLoginWindow);


% --- Outputs from this function are returned to the command line.
function varargout = ImageAnalysisLogin_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure


%varargout{1} = handles.output;



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



function portText_Callback(hObject, eventdata, handles)
% hObject    handle to portText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of portText as text
%        str2double(get(hObject,'String')) returns contents of portText as a double


% --- Executes during object creation, after setting all properties.
function portText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to portText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in intensityButton.
function intensityButton_Callback(hObject, eventdata, handles)
% hObject    handle to intensityButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off');
success = logIn(handles);
set(hObject, 'enable', 'on');
if success == 0
    return;
end
set(handles.ImageAnalysisLoginWindow, 'visible', 'off');
credentials = getappdata(handles.ImageAnalysisLoginWindow, 'credentials');
intensityMeasureLaunchpad(handles, credentials);
set(handles.ImageAnalysisLoginWindow, 'visible', 'on');


% --- Executes on button press in distanceButton.
function distanceButton_Callback(hObject, eventdata, handles)
% hObject    handle to distanceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off');
success = logIn(handles);
set(hObject, 'enable', 'on');
if success == 0
    return;
end
set(handles.ImageAnalysisLoginWindow, 'visible', 'off');
credentials = getappdata(handles.ImageAnalysisLoginWindow, 'credentials');
distanceMeasureLaunchpad(handles, credentials);
set(handles.ImageAnalysisLoginWindow, 'visible', 'on');


% --- Executes on button press in lineButton.
function lineButton_Callback(hObject, eventdata, handles)
% hObject    handle to lineButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in eventButton.
function eventButton_Callback(hObject, eventdata, handles)
% hObject    handle to eventButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off');
success = logIn(handles);
set(hObject, 'enable', 'on');
if success == 0
    return;
end
set(handles.ImageAnalysisLoginWindow, 'visible', 'off');
eventTimer;
set(handles.ImageAnalysisLoginWindow, 'visible', 'on');


% --- Executes on button press in flipButton.
function flipButton_Callback(hObject, eventdata, handles)
% hObject    handle to flipButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in frapButton.
function frapButton_Callback(hObject, eventdata, handles)
% hObject    handle to frapButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off');
success = logIn(handles);
set(hObject, 'enable', 'on');
if success == 0
    return;
end
set(handles.ImageAnalysisLoginWindow, 'visible', 'off');
FRAPChooser;
set(handles.ImageAnalysisLoginWindow, 'visible', 'on');



function passKeyPress(hObject, eventdata, handles)

lastChar = eventdata.Character;
lastKey = eventdata.Key;
currPass = getappdata(handles.ImageAnalysisLoginWindow, 'passData');
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

    setappdata(handles.ImageAnalysisLoginWindow, 'passData', password);
    numChars = length(password);
    stars(1:numChars) = '*';
    set(hObject, 'String', stars);
end


function checkLoginHistory(handles)

if ispc
    sysUser = getenv('username');
    sysUserHome = getenv('userprofile');
    historyFile = [sysUserHome '\omero\analysisHistory.mat'];
else
    sysUser = getenv('USER');
    sysUserHome = getenv('HOME');
    historyFile = [sysUserHome '/omero/analysisHistory.mat'];
end
try
    history = open(historyFile);
    set(handles.usernameText, 'String', history.omeroUser);
    set(handles.serverText, 'String', history.omeroServer);
    try  %previous versions didn't include port details.
        set(handles.serverPort, 'String', history.omeroPort);
    catch
    end
    uicontrol(handles.passwordText);
catch
end





function saveHistory(credentials)

omeroUser = credentials{1};
omeroServer = credentials{3};
omeroPort = credentials{4};
if ispc
    sysUserHome = getenv('userprofile');
    sysUser = getenv('username');
    omeroDir = [sysUserHome '\omero'];
    historyFile = [sysUserHome '\omero\analysisHistory.mat'];
else
    sysUserHome = getenv('HOME');
    sysUser = getenv('USER');
    omeroDir = [sysUserHome '/omero'];
    historyFile = [sysUserHome '/omero/analysisHistory.mat'];
end

if ~isdir(omeroDir)
    mkdir(omeroDir)
end
save(historyFile, 'omeroUser', 'omeroServer', 'omeroPort');



function success = logIn(handles)

global client;
global session;

credentials{1} = get(handles.usernameText, 'String');
credentials{2} = getappdata(handles.ImageAnalysisLoginWindow, 'passData');
credentials{3} = get(handles.serverText, 'String');
credentials{4} = get(handles.portText, 'String');
setappdata(handles.ImageAnalysisLoginWindow, 'credentials', credentials);
if isempty(credentials{1}) || isempty(credentials{2}) || isempty(credentials{3}) || isempty(credentials{4})
    helpdlg('Check you have entered a Username, Password, Server and Port.');
    success = false;
    return;
end

%First check the login works. Client, session and gateway are global, so
%will persist and be kept alive until application close.
try
    if ~isjava(client)
        userLoginOmero(credentials{1}, credentials{2}, credentials{3}, credentials{4});
        saveHistory(credentials);
        success = true;
        selectUserDefaultGroup(credentials{1}, handles, 'ImageAnalysisLoginWindow');
    else
        try
            experimenter = char(session.getAdminService.getExperimenter(0).getOmeName.getValue.getBytes)';
        catch
            session = client.createSession;
            experimenter = char(session.getAdminService.getExperimenter(0).getOmeName.getValue.getBytes)';
        end
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
    clear global clientAlive;
    disp(ME.message);
    warndlg('Could not log on to the server. Check your details and try again.');
    success = false;
    return;
end



function closeReqFcn(hObject, eventdata, handles)

gatewayDisconnect;
diary off
delete(handles.ImageAnalysisLoginWindow);


% --- Executes on button press in ROITweakButton.
function ROITweakButton_Callback(hObject, eventdata, handles)
% hObject    handle to ROITweakButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off');
success = logIn(handles);
set(hObject, 'enable', 'on');
if success == 0
    return;
end
set(handles.ImageAnalysisLoginWindow, 'visible', 'off');
credentials = getappdata(handles.ImageAnalysisLoginWindow, 'credentials');
ROITweak(handles, credentials);
set(handles.ImageAnalysisLoginWindow, 'visible', 'on');


% --- Executes on button press in labelMakerButton.
function labelMakerButton_Callback(hObject, eventdata, handles)
% hObject    handle to labelMakerButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off');
success = logIn(handles);
set(hObject, 'enable', 'on');
if success == 0
    return;
end
set(handles.ImageAnalysisLoginWindow, 'visible', 'off');
credentials = getappdata(handles.ImageAnalysisLoginWindow, 'credentials');
answer = questdlg('Are your images larger than 512x512 pixels?', 'Image Size', 'Yes', 'No', 'No');

if strcmp(answer, '')
    set(handles.ImageAnalysisLoginWindow, 'visible', 'on');
    return;
elseif strcmpi(answer, 'No')
    labelMaker(handles, credentials);
else strcmpi(answer, 'Yes')
    labelMaker1024(handles, credentials);
end
set(handles.ImageAnalysisLoginWindow, 'visible', 'on');


% --- Executes on button press in createKymographButton.
function createKymographButton_Callback(hObject, eventdata, handles)
% hObject    handle to createKymographButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off');
success = logIn(handles);
set(hObject, 'enable', 'on');
if success == 0
    return;
end
set(handles.ImageAnalysisLoginWindow, 'visible', 'off');
credentials = getappdata(handles.ImageAnalysisLoginWindow, 'credentials');
createKymograph(handles, credentials);
set(handles.ImageAnalysisLoginWindow, 'visible', 'on');


% --- Executes on button press in boxItButton.
function boxItButton_Callback(hObject, eventdata, handles)
% hObject    handle to boxItButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off');
success = logIn(handles);
set(hObject, 'enable', 'on');
if success == 0
    return;
end
set(handles.ImageAnalysisLoginWindow, 'visible', 'off');
credentials = getappdata(handles.ImageAnalysisLoginWindow, 'credentials');
boxIt(handles, credentials);
set(handles.ImageAnalysisLoginWindow, 'visible', 'on');


% --- Executes on button press in bugCounterButton.
function bugCounterButton_Callback(hObject, eventdata, handles)
% hObject    handle to bugCounterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off');
success = logIn(handles);
set(hObject, 'enable', 'on');
if success == 0
    return;
end
set(handles.ImageAnalysisLoginWindow, 'visible', 'off');
credentials = getappdata(handles.ImageAnalysisLoginWindow, 'credentials');
bugCounterMain(handles, credentials);
set(handles.ImageAnalysisLoginWindow, 'visible', 'on');


% --- Executes on button press in copyROIsBtn.
function copyROIsBtn_Callback(hObject, eventdata, handles)
% hObject    handle to copyROIsBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off');
success = logIn(handles);
set(hObject, 'enable', 'on');
if success == 0
    return;
end
set(handles.ImageAnalysisLoginWindow, 'visible', 'off');
copyROIs(handles);
set(handles.ImageAnalysisLoginWindow, 'visible', 'on');


% --- Executes on button press in spotMeasureBtn.
function spotMeasureBtn_Callback(hObject, eventdata, handles)
% hObject    handle to spotMeasureBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(hObject, 'enable', 'off');
success = logIn(handles);
set(hObject, 'enable', 'on');
if success == 0
    return;
end
set(handles.ImageAnalysisLoginWindow, 'visible', 'off');
spotMeasure(handles);
gatewayDisconnect;
set(handles.ImageAnalysisLoginWindow, 'visible', 'on');



function startDiary(handles)

if ispc
    sysUserHome = getenv('userprofile');
    logFile = [sysUserHome '\omero\mtoolsLog.log'];
else
    sysUserHome = getenv('HOME');
    logFile = [sysUserHome '/omero/mtoolsLog.log'];
end

if exist(logFile, 'file') == 2
    delete(logFile);
end

diary(logFile);

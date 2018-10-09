function varargout = loginImageSelector(varargin)
% LOGINIMAGESELECTOR M-file for loginImageSelector.fig
%      LOGINIMAGESELECTOR, by itself, creates a new LOGINIMAGESELECTOR or raises the existing
%      singleton*.
%
%      H = LOGINIMAGESELECTOR returns the handle to a new LOGINIMAGESELECTOR or the handle to
%      the existing singleton*.
%
%      LOGINIMAGESELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOGINIMAGESELECTOR.M with the given input arguments.
%
%      LOGINIMAGESELECTOR('Property','Value',...) creates a new LOGINIMAGESELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before loginImageSelector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to loginImageSelector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help loginImageSelector

% Last Modified by GUIDE v2.5 08-Jan-2010 11:35:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @loginImageSelector_OpeningFcn, ...
                   'gui_OutputFcn',  @loginImageSelector_OutputFcn, ...
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


% --- Executes just before loginImageSelector is made visible.
function loginImageSelector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to loginImageSelector (see VARARGIN)

% Choose default command line output for loginImageSelector
handles.output = hObject;

set(handles.passText, 'KeyPressFcn', {@passKeyPress, handles});
setappdata(handles.imageSelector, 'passData', []);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes loginImageSelector wait for user response (see UIRESUME)
% uiwait(handles.imageSelector);


% --- Outputs from this function are returned to the command line.
function varargout = loginImageSelector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in projectsSelect.
function projectsSelect_Callback(hObject, eventdata, handles)
% hObject    handle to projectsSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns projectsSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from projectsSelect


projIdx = get(hObject, 'Value')-1;
if projIdx == 0
    return;
end
projIdList = getappdata(handles.imageSelector, 'projIdList');
projId = projIdList(projIdx);
set(handles.datasetsSelect, 'Value', 1);
set(handles.imagesSelect, 'Value', 1);
setappdata(handles.imageSelector, 'projectId', projId);
populateDatasetsSelect(handles);


% --- Executes during object creation, after setting all properties.
function projectsSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projectsSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in datasetsSelect.
function datasetsSelect_Callback(hObject, eventdata, handles)
% hObject    handle to datasetsSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns datasetsSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from datasetsSelect

dsIdx = get(hObject, 'Value')-1;
if dsIdx == 0
    return;
end
dsIdList = getappdata(handles.imageSelector, 'dsIdList');
dsId = dsIdList(dsIdx);
set(handles.imagesSelect, 'Value', 1);
setappdata(handles.imageSelector, 'dsId', dsId);
populateImagesSelect(handles);


% --- Executes during object creation, after setting all properties.
function datasetsSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datasetsSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in imagesSelect.
function imagesSelect_Callback(hObject, eventdata, handles)
% hObject    handle to imagesSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns imagesSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imagesSelect

imageIdx = get(hObject, 'Value')-1;
if imageIdx == 0
    return;
end
imageIdList = getappdata(handles.imageSelector, 'imageIdList');
imageId = imageIdList(imageIdx);
setappdata(handles.imageSelector, 'imageId', imageId);
set(handles.okButton, 'Enable', 'on');


% --- Executes during object creation, after setting all properties.
function imagesSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imagesSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)
% hObject    handle to okButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gateway;
imageId = getappdata(handles.imageSelector, 'imageId');
theImage = gateway.getImage(imageId);
createKymograph(theImage);



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



function userText_Callback(hObject, eventdata, handles)
% hObject    handle to userText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of userText as text
%        str2double(get(hObject,'String')) returns contents of userText as a double


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
end


% --- Executes on button press in loginButton.
function loginButton_Callback(hObject, eventdata, handles)
% hObject    handle to loginButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

server = get(handles.serverText, 'String');
username = get(handles.userText, 'String');
password = getappdata(handles.imageSelector, 'passData');
currentString = get(hObject, 'String');

if strcmp(currentString, 'Log in')
    try
        gatewayConnect(username, password, server, '4064');
        set(hObject, 'String', 'Log out');
    catch
        errordlg([{'There was a problem logging in.'} {'Check your details and try again'}], 'Login failed', 'modal');
        return;
    end
    populateProjectsSelect(handles)
else
    gatewayDisconnect;
    set(hObject, 'String', 'Log in');
    set(handles.projectsSelect, 'Value', 1)
    set(handles.projectsSelect, 'String', 'Please log in');
    set(handles.datasetsSelect, 'Value', 1)
    set(handles.datasetsSelect, 'String', 'Please log in');
    set(handles.imagesSelect, 'Value', 1)
    set(handles.imagesSelect, 'String', 'Please log in');
    set(handles.okButton, 'Enable', 'off');
end


    
function passKeyPress(hObject, eventdata, handles)

lastChar = eventdata.Character;
lastKey = eventdata.Key;
currPass = getappdata(handles.imageSelector, 'passData');
charset = char(33:126);
nativeLastChar = unicode2native(lastChar);
if nativeLastChar == 13
    loginButton_Callback(hObject, eventdata, handles);
elseif lastChar
    if any(charset == lastChar)
        password = [currPass lastChar];
    elseif strcmp(lastKey, 'backspace')
        password = currPass(1:end-1);
    elseif strcmp(lastKey, 'delete')
        password = '';
    else
        return;
    end

    setappdata(handles.imageSelector, 'passData', password);
    numChars = length(password);
    stars(1:numChars) = '*';
    set(hObject, 'String', stars);
end



function populateProjectsSelect(handles)

global gateway
projects = gateway.getProjects([],0);
projIter = projects.iterator;
numProj = projects.size;
projNameId{numProj,2} = [];
projNameList{numProj} = [];
projIdList = [];
counter = 1;
while projIter.hasNext
    projNameId{counter,1} = char(projects.get(counter-1).getName.getValue.getBytes');
    projNameId{counter,2} = num2str(projects.get(counter-1).getId.getValue);
    projIter.next;
    counter = counter + 1;
end
projNameId = sortrows(projNameId);
for thisProj = 1:numProj
    projNameList{thisProj} = projNameId{thisProj, 1};
    projIdList(thisProj) = str2double(projNameId{thisProj, 2});
end
set(handles.projectsSelect, 'String', [{'Select a project'} projNameList]);
set(handles.datasetsSelect, 'String', 'Select a dataset');
set(handles.imagesSelect, 'String', 'Select an image');
setappdata(handles.imageSelector, 'projNameList', projNameList);
setappdata(handles.imageSelector, 'projIdList', projIdList);


function populateDatasetsSelect(handles)

global gateway
projId = getappdata(handles.imageSelector, 'projectId');
projectId = java.util.ArrayList;
projectId.add(java.lang.Long(projId));
project = gateway.getProjects(projectId, 0).get(0);
numDs = project.sizeOfDatasetLinks;
dsLinks{numDs} = [];
datasets{numDs} = [];
dsNameId{numDs,2} = [];
dsNameList{numDs} = [];

dsIter = project.iterateDatasetLinks;
counter = 1;
while dsIter.hasNext
    dsLinks{counter} = dsIter.next;
    datasets{counter} = dsLinks{counter}.getChild();
    dsNameId{counter,1} = char(datasets{counter}.getName.getValue.getBytes');
    dsNameId{counter,2} = num2str(datasets{counter}.getId.getValue);
    counter = counter + 1;
end

dsNameId = sortrows(dsNameId);
for thisDs = 1:numDs
    dsNameList{thisDs} = dsNameId{thisDs, 1};
    dsIdList(thisDs) = str2double(dsNameId{thisDs, 2});
end
set(handles.datasetsSelect, 'String', [{'Select a dataset'} dsNameList]);

setappdata(handles.imageSelector, 'dsNameList', dsNameList);
setappdata(handles.imageSelector, 'dsIdList', dsIdList);


function populateImagesSelect(handles)

global gateway
dsId = getappdata(handles.imageSelector, 'dsId');
datasetId = java.util.ArrayList;
datasetId.add(java.lang.Long(dsId));
datasetContainer = omero.api.ContainerClass.Dataset;

images = gateway.getImages(datasetContainer,datasetId);

numImages = images.size;
imageNameId{numImages,2} = [];
imageNameList{numImages} = [];

imageIter = images.iterator;
counter = 1;
while imageIter.hasNext
    imageNameId{counter,1} = char(images.get(counter-1).getName.getValue.getBytes');
    imageNameId{counter,2} = num2str(images.get(counter-1).getId.getValue);
    counter = counter + 1;
    imageIter.next;
end

imageNameId = sortrows(imageNameId);
for thisImage = 1:numImages
    imageNameList{thisImage} = imageNameId{thisImage, 1};
    imageIdList(thisImage) = str2double(imageNameId{thisImage, 2});
end
set(handles.imagesSelect, 'String', [{'Select an image'} imageNameList]);

setappdata(handles.imageSelector, 'imageNameList', imageNameList);
setappdata(handles.imageSelector, 'imageIdList', imageIdList);
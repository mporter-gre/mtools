function varargout = copyROIs(varargin)
% COPYROIS MATLAB code for copyROIs.fig
%      COPYROIS, by itself, creates a new COPYROIS or raises the existing
%      singleton*.
%
%      H = COPYROIS returns the handle to a new COPYROIS or the handle to
%      the existing singleton*.
%
%      COPYROIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COPYROIS.M with the given input arguments.
%
%      COPYROIS('Property','Value',...) creates a new COPYROIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before copyROIs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to copyROIs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help copyROIs

% Last Modified by GUIDE v2.5 05-Dec-2014 16:40:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @copyROIs_OpeningFcn, ...
                   'gui_OutputFcn',  @copyROIs_OutputFcn, ...
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


% --- Executes just before copyROIs is made visible.
function copyROIs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to copyROIs (see VARARGIN)

% Choose default command line output for copyROIs
handles.output = hObject;

populateProjectsSelect(handles);

setappdata(handles.copyROIs, 'fromImageSelected', 0);
setappdata(handles.copyROIs, 'toImageSelected', 0);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes copyROIs wait for user response (see UIRESUME)
% uiwait(handles.copyROIs);


% --- Outputs from this function are returned to the command line.
function varargout = copyROIs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in projectsFromSelect.
function projectsFromSelect_Callback(hObject, eventdata, handles)
% hObject    handle to projectsFromSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns projectsFromSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from projectsFromSelect

projIdList = getappdata(handles.copyROIs, 'projIdList');
projIdx = get(hObject, 'Value');
if projIdx == 1
    return;
end
projIdx = projIdx - 1;
projId = projIdList(projIdx);

populateDatasetsSelect(handles, projId, 'From');

set(handles.dsFromSelect, 'Enable', 'on');
setappdata(handles.copyROIs, 'projFromId', projId);
setappdata(handles.copyROIs, 'fromImageSelected', 0);
checkReady(handles)



% --- Executes during object creation, after setting all properties.
function projectsFromSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projectsFromSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in projectsToSelect.
function projectsToSelect_Callback(hObject, eventdata, handles)
% hObject    handle to projectsToSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns projectsToSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from projectsToSelect

projIdList = getappdata(handles.copyROIs, 'projIdList');
projIdx = get(hObject, 'Value');
if projIdx == 1
    return;
end
projIdx = projIdx - 1;
projId = projIdList(projIdx);

populateDatasetsSelect(handles, projId, 'To');

set(handles.dsToSelect, 'Enable', 'on');
setappdata(handles.copyROIs, 'projToId', projId);
setappdata(handles.copyROIs, 'toImageSelected', 0);

checkReady(handles);


% --- Executes during object creation, after setting all properties.
function projectsToSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projectsToSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dsFromSelect.
function dsFromSelect_Callback(hObject, eventdata, handles)
% hObject    handle to dsFromSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dsFromSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dsFromSelect

dsIdList = getappdata(handles.copyROIs, 'dsFromIdList');
dsIdx = get(hObject, 'Value');
if dsIdx == 1
    return;
end
dsIdx = dsIdx - 1;
dsId = dsIdList(dsIdx);

populateImagesSelect(handles, dsId, 'From');

set(handles.imagesFromSelect, 'Enable', 'on');
setappdata(handles.copyROIs, 'dsFromId', dsId);


% --- Executes during object creation, after setting all properties.
function dsFromSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dsFromSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dsToSelect.
function dsToSelect_Callback(hObject, eventdata, handles)
% hObject    handle to dsToSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dsToSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dsToSelect

dsIdList = getappdata(handles.copyROIs, 'dsToIdList');
dsIdx = get(hObject, 'Value');
if dsIdx == 1
    return;
end
dsIdx = dsIdx - 1;
dsId = dsIdList(dsIdx);

populateImagesSelect(handles, dsId, 'To');

set(handles.imagesToSelect, 'Enable', 'on');
setappdata(handles.copyROIs, 'dsToId', dsId);


% --- Executes during object creation, after setting all properties.
function dsToSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dsToSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in imagesFromSelect.
function imagesFromSelect_Callback(hObject, eventdata, handles)
% hObject    handle to imagesFromSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imagesFromSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imagesFromSelect

global session

imageIdList = getappdata(handles.copyROIs, 'imageFromIdList');
imageIdx = get(hObject, 'Value');

if imageIdx == 1
    return;
end
imageIdx = imageIdx - 1;

imageFromId = imageIdList(imageIdx);

fromImage = getImages(session, imageFromId);
fromPixels = fromImage.getPrimaryPixels;

fromSizeX = fromPixels.getSizeX.getValue;
fromSizeY = fromPixels.getSizeY.getValue;
fromNumZ = fromPixels.getSizeZ.getValue;
fromNumT = fromPixels.getSizeT.getValue;
fromImageName = char(fromImage.getName.getValue.getBytes');

rois = getROIsFromImageId(imageFromId);

fromNumROIs = length(rois);

set(handles.infoFromLbl, 'String', [{fromImageName} {['number of ROIs: ' num2str(fromNumROIs)]} {['Size X/Y: ' num2str(fromSizeX) '/' num2str(fromSizeY)]} {['Size Z/T: ' num2str(fromNumZ) '/' num2str(fromNumT)]}]);

if fromNumROIs > 0
    setappdata(handles.copyROIs, 'fromImageSelected', 1);
else
    setappdata(handles.copyROIs, 'fromImageSelected', 0);
end
checkReady(handles)






% --- Executes during object creation, after setting all properties.
function imagesFromSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imagesFromSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in imagesToSelect.
function imagesToSelect_Callback(hObject, eventdata, handles)
% hObject    handle to imagesToSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imagesToSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imagesToSelect

global session

imageIdList = getappdata(handles.copyROIs, 'imageToIdList');
imageIdx = get(hObject, 'Value');

if imageIdx == 1
    return;
end
imageIdx = imageIdx - 1;

imageToId = imageIdList(imageIdx);

toImage = getImages(session, imageToId);
toPixels = toImage.getPrimaryPixels;

toSizeX = toPixels.getSizeX.getValue;
toSizeY = toPixels.getSizeY.getValue;
toNumZ = toPixels.getSizeZ.getValue;
toNumT = toPixels.getSizeT.getValue;
toImageName = char(toImage.getName.getValue.getBytes');

rois = getROIsFromImageId(imageToId);

toNumROIs = length(rois);

set(handles.infoToLbl, 'String', [{toImageName} {['number of ROIs: ' num2str(toNumROIs)]} {['Size X/Y: ' num2str(toSizeX) '/' num2str(toSizeY)]} {['Size Z/T: ' num2str(toNumZ) '/' num2str(toNumT)]}]);
setappdata(handles.copyROIs, 'toImageSelected', 1);

checkReady(handles)


% --- Executes during object creation, after setting all properties.
function imagesToSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imagesToSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in copyBtn.
function copyBtn_Callback(hObject, eventdata, handles)
% hObject    handle to copyBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function populateProjectsSelect(handles)

global session

projects = getProjects(session, [], false);
numProj = length(projects);
if numProj == 0
    warndlg('No projects found.');
    return;
end
projNameId{numProj,2} = [];
projNameList{numProj} = [];
projIdList = [];
for thisProj = 1:numProj
    projNameId{thisProj,1} = char(projects(thisProj).getName.getValue.getBytes');
    projNameId{thisProj,2} = num2str(projects(thisProj).getId.getValue);
end
projNameId = sortrows(projNameId);
for thisProj = 1:numProj
    projNameList{thisProj} = projNameId{thisProj, 1};
    projIdList(thisProj) = str2double(projNameId{thisProj, 2});
end
set(handles.projectsFromSelect, 'String', [{'Select a project'} projNameList]);
set(handles.projectsToSelect, 'String', [{'Select a project'} projNameList]);
setappdata(handles.copyROIs, 'projNameList', projNameList);
setappdata(handles.copyROIs, 'projIdList', projIdList);




function populateDatasetsSelect(handles, projId, fromTo)

global session
project = getProjects(session, projId, false);
datasets = toMatlabList(project.linkedDatasetList);
numDs = length(datasets);
if numDs == 0
    if strcmpi(fromTo, 'From');
        set(handles.dsFromSelect, 'Value', 1);
        set(handles.dsFromSelect, 'String', 'No datasets in this project');
    else
        set(handles.dsToSelect, 'Value', 1);
        set(handles.dsToSelect, 'String', 'No datasets in this project');
    end
    return;
else
    if strcmpi(fromTo, 'From');
        set(handles.dsFromSelect, 'Value', 1);
        set(handles.imagesFromSelect, 'Value', 1);
        set(handles.imagesFromSelect, 'String', 'Please select...');
        set(handles.imagesFromSelect, 'Enable', 'off');
    else
        set(handles.dsToSelect, 'Value', 1);
        set(handles.imagesToSelect, 'Value', 1);
        set(handles.imagesToSelect, 'String', 'Please select...');
        set(handles.imagesToSelect, 'Enable', 'off');
    end
end

dsNameId{numDs,2} = [];
dsNameList{numDs} = [];

for thisDs = 1:numDs
    dsNameId{thisDs,1} = char(datasets(thisDs).getName.getValue.getBytes');
    dsNameId{thisDs,2} = num2str(datasets(thisDs).getId.getValue);
end

dsNameId = sortrows(dsNameId);
for thisDs = 1:numDs
    dsNameList{thisDs} = dsNameId{thisDs, 1};
    dsIdList(thisDs) = str2double(dsNameId{thisDs, 2});
end

if strcmpi(fromTo, 'From')
    set(handles.dsFromSelect, 'String', [{'Select a dataset'} dsNameList]);
    setappdata(handles.copyROIs, 'dsFromNameList', dsNameList);
    setappdata(handles.copyROIs, 'dsFromIdList', dsIdList);
    setappdata(handles.copyROIs, 'fromImageSelected', 0);
else
    set(handles.dsToSelect, 'String', [{'Select a dataset'} dsNameList]);
    setappdata(handles.copyROIs, 'dsToNameList', dsNameList);
    setappdata(handles.copyROIs, 'dsToIdList', dsIdList);
    setappdata(handles.copyROIs, 'toImageSelected', 0);
end

checkReady(handles)



function populateImagesSelect(handles, dsId, fromTo)

global session
images = getImages(session, 'dataset', dsId);

numImages = length(images);
if numImages == 0
    return;
end
imageNameId{numImages,2} = [];
imageNameList{numImages} = [];

for thisImage = 1:numImages
    imageNameId{thisImage,1} = char(images(thisImage).getName.getValue.getBytes');
    imageNameId{thisImage,2} = num2str(images(thisImage).getId.getValue);
end

imageNameId = sortrows(imageNameId);
for thisImage = 1:numImages
    imageNameList{thisImage} = imageNameId{thisImage, 1};
    imageIdList(thisImage) = str2double(imageNameId{thisImage, 2});
end

if strcmpi(fromTo, 'From')
    set(handles.imagesFromSelect, 'String', [{'Select an image'} imageNameList]);
    set(handles.imagesFromSelect, 'Value', 1);
    setappdata(handles.copyROIs, 'imageFromNameList', imageNameList);
    setappdata(handles.copyROIs, 'imageFromIdList', imageIdList);
    setappdata(handles.copyROIs, 'fromImageSelected', 0);
else
    set(handles.imagesToSelect, 'String', [{'Select an image'} imageNameList]);
    set(handles.imagesToSelect, 'Value', 1);
    setappdata(handles.copyROIs, 'imageToNameList', imageNameList);
    setappdata(handles.copyROIs, 'imageToIdList', imageIdList);
    setappdata(handles.copyROIs, 'toImageSelected', 0);
end

checkReady(handles)





function checkReady(handles)

fromImageSelected = getappdata(handles.copyROIs, 'fromImageSelected');
toImageSelected = getappdata(handles.copyROIs, 'toImageSelected');

if fromImageSelected == 1 && toImageSelected == 1
    set(handles.copyBtn, 'Enable', 'on');
else
    set(handles.copyBtn, 'Enable', 'off');
end


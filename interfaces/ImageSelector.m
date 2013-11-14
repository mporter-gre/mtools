function varargout = ImageSelector(varargin)
% IMAGESELECTOR M-file for ImageSelector.fig
%      IMAGESELECTOR, by itself, creates a new IMAGESELECTOR or raises the existing
%      singleton*.
%
%      H = IMAGESELECTOR returns the handle to a new IMAGESELECTOR or the handle to
%      the existing singleton*.
%
%      IMAGESELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGESELECTOR.M with the given input arguments.
%
%      IMAGESELECTOR('Property','Value',...) creates a new IMAGESELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageSelector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageSelector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageSelector

% Last Modified by GUIDE v2.5 02-Aug-2013 16:27:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageSelector_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageSelector_OutputFcn, ...
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


% --- Executes just before ImageSelector is made visible.
function ImageSelector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageSelector (see VARARGIN)
%TestComment

% Choose default command line output for ImageSelector
handles.output = hObject;
handles.parentHandles = varargin{1};
handles.parentHandles.parentWindowName = varargin{2};
handles.ROIFilter = 0;
if length(varargin) > 2
    handles.ROIFilter = varargin{3};
end

projectId = getappdata(handles.parentHandles.(handles.parentHandles.parentWindowName), 'projectId');
datasetId = getappdata(handles.parentHandles.(handles.parentHandles.parentWindowName), 'datasetId');

if ~isempty(projectId) && ~isempty(datasetId)
    setappdata(handles.imageSelector, 'projectId', projectId);
    setappdata(handles.imageSelector, 'dsId', datasetId);
    populateProjectsSelect(handles);
    populateDatasetsSelect(handles);
    %populateImagesSelect(handles);
    imageNameList = getappdata(handles.parentHandles.(handles.parentHandles.parentWindowName), 'imageNameList');
    imageIdList = getappdata(handles.parentHandles.(handles.parentHandles.parentWindowName), 'imageIdList');
    set(handles.imagesSelect, 'String', [{'Select an image'} imageNameList]);
    setappdata(handles.imageSelector, 'imageNameList', imageNameList);
    setappdata(handles.imageSelector, 'imageIdList', imageIdList);
    populatedProjectIds = getappdata(handles.imageSelector, 'projIdList');
    numProjects = length(populatedProjectIds);
    for thisProject = 1:numProjects
        if populatedProjectIds(thisProject) == projectId
            set(handles.projectsSelect, 'Value', thisProject+1);
        end
    end
    populatedDatasetIds = getappdata(handles.imageSelector, 'dsIdList');
    numDatasets = length(populatedDatasetIds);
    for thisDataset = 1:numDatasets
        if populatedDatasetIds(thisDataset) == datasetId
            set(handles.datasetsSelect, 'Value', thisDataset+1);
        end
    end
else
    populateProjectsSelect(handles);
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImageSelector wait for user response (see UIRESUME)
uiwait(handles.imageSelector);


% --- Outputs from this function are returned to the command line.
function varargout = ImageSelector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on selection change in projectsSelect.
function projectsSelect_Callback(hObject, eventdata, handles)
% hObject    handle to projectsSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns projectsSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from projectsSelect


projIdx = get(hObject, 'Value')-1;
if projIdx == 0
    set(handles.datasetsSelect, 'Value', 1);
    set(handles.datasetsSelect, 'String', 'Select a dataset');
    set(handles.imagesSelect, 'Value', 1);
    set(handles.imagesSelect, 'String', 'Select an image');
    return;
end
projIdList = getappdata(handles.imageSelector, 'projIdList');
projId = projIdList(projIdx);
set(handles.datasetsSelect, 'Value', 1);
set(handles.datasetsSelect, 'String', 'Select a dataset');
set(handles.imagesSelect, 'Value', 1);
set(handles.imagesSelect, 'String', 'Select an image');
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
    set(handles.imagesSelect, 'Value', 1);
    set(handles.imagesSelect, 'String', 'Select an image');
    return;
end
dsIdList = getappdata(handles.imageSelector, 'dsIdList');
dsId = dsIdList(dsIdx);
set(handles.imagesSelect, 'Value', 1);
set(handles.imagesSelect, 'String', 'Select an image');
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
global session;

imagesSelectIdx = get(handles.imagesSelect, 'Value');
if imagesSelectIdx == 1
    return;
end
imageId = getappdata(handles.imageSelector, 'imageId');
theImage = getImages(session, imageId);
projectId = getappdata(handles.imageSelector, 'projectId');
datasetId = getappdata(handles.imageSelector, 'dsId');
setappdata(handles.parentHandles.(handles.parentHandles.parentWindowName), 'imageId', imageId);
setappdata(handles.parentHandles.(handles.parentHandles.parentWindowName), 'newImageObj', theImage);
setappdata(handles.parentHandles.(handles.parentHandles.parentWindowName), 'projectId', projectId);
setappdata(handles.parentHandles.(handles.parentHandles.parentWindowName), 'datasetId', datasetId);
delete(handles.imageSelector);




function populateProjectsSelect(handles)

global gateway
global session

projects = getProjects(session, [], false); %gateway.getProjects([],0);
%projIter = projects.iterator;
numProj = length(projects);
projNameId{numProj,2} = [];
projNameList{numProj} = [];
projIdList = [];
counter = 1;
for thisProj = 1:numProj
    projNameId{thisProj,1} = char(projects(thisProj).getName.getValue.getBytes');
    projNameId{thisProj,2} = num2str(projects(thisProj).getId.getValue);
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
global session

projId = getappdata(handles.imageSelector, 'projectId');
% projectId = java.util.ArrayList;
% projectId.add(java.lang.Long(projId));
%project = gateway.getProjects(projectId, 0).get(0);
project = getProjects(session, projId, true);
numDs = project.sizeOfDatasetLinks;
if numDs == 0
    set(handles.datasetsSelect, 'Value', 1);
    set(handles.datasetsSelect, 'String', 'No datasets in this project');
    return;
end
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
global session

dsId = getappdata(handles.imageSelector, 'dsId');
% datasetId = java.util.ArrayList;
% datasetId.add(java.lang.Long(dsId));
% datasetContainer = omero.api.ContainerClass.Dataset;

%images = gateway.getImages(datasetContainer,datasetId);
images = getImages(session, 'dataset', dsId);

numImages = length(images);
if numImages == 0
    set(handles.imagesSelect, 'Value', 1);
    set(handles.imagesSelect, 'String', 'No images in this dataset');
    return;
end
if handles.ROIFilter == 1
    for thisImage = 1:numImages
        imageIds(thisImage) = images(thisImage).getId.getValue;
    end
    [imageIdxNoROIs roiShapes] = ROIImageCheck(imageIds);
    images = deleteElementFromJavaArrayList(imageIdxNoROIs, images);
    %imageIds = deleteElementFromVector(imageIdxNoROIs, imageIds);
end
numImages = length(images);

imageNameId{numImages,2} = [];
imageNameList{numImages} = [];


for thisImage = 1:numImages
    imageNameId{thisImage,1} = char(images(thisImage).getName.getValue.getBytes');
    imageNameId{thisImage,2} = num2str(images(thisImage).getId.getValue);
end
numImages = length(images);
if numImages > 1
    imageNameId = sortrows(imageNameId);
end
for thisImage = 1:numImages
    imageNameList{thisImage} = imageNameId{thisImage, 1};
    imageIdList(thisImage) = str2double(imageNameId{thisImage, 2});
end
set(handles.imagesSelect, 'String', [{'Select an image'} imageNameList]);

setappdata(handles.imageSelector, 'imageNameList', imageNameList);
setappdata(handles.imageSelector, 'imageIdList', imageIdList);
setappdata(handles.parentHandles.(handles.parentHandles.parentWindowName), 'imageNameList', imageNameList);
setappdata(handles.parentHandles.(handles.parentHandles.parentWindowName), 'imageIdList', imageIdList);


function imageSelectorCloseReq(hObject, eventdata, handles)

setappdata(handles.parentHandles.(handles.parentHandles.parentWindowName), 'cancelledOpenImage', 1);
delete(handles.imageSelector);

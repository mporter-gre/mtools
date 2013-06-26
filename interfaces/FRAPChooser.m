function varargout = FRAPChooser(varargin)
% FRAPCHOOSER M-file for FRAPChooser.fig
%      FRAPCHOOSER, by itself, creates a new FRAPCHOOSER or raises the existing
%      singleton*.
%
%      H = FRAPCHOOSER returns the handle to a new FRAPCHOOSER or the handle to
%      the existing singleton*.
%
%      FRAPCHOOSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRAPCHOOSER.M with the given input arguments.
%
%      FRAPCHOOSER('Property','Value',...) creates a new FRAPCHOOSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FRAPChooser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FRAPChooser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FRAPChooser

% Last Modified by GUIDE v2.5 08-Dec-2010 11:40:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FRAPChooser_OpeningFcn, ...
                   'gui_OutputFcn',  @FRAPChooser_OutputFcn, ...
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


% --- Executes just before FRAPChooser is made visible.
function FRAPChooser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FRAPChooser (see VARARGIN)

% Choose default command line output for FRAPChooser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FRAPChooser wait for user response (see UIRESUME)
uiwait(handles.FRAPChooser);


% --- Outputs from this function are returned to the command line.
function varargout = FRAPChooser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;
varargout{1} = getappdata(handles.FRAPChooser, 'images');
varargout{2} = getappdata(handles.FRAPChooser, 'imageIds');
varargout{3} = getappdata(handles.FRAPChooser, 'imageNames');
varargout{4} = getappdata(handles.FRAPChooser, 'roiShapes');
varargout{5} = getappdata(handles.FRAPChooser, 'datasetNames');
varargout{6} = getappdata(handles.FRAPChooser, 'pixels');
close(hObject)


% --- Executes on button press in addDatasetsButton.
function addDatasetsButton_Callback(hObject, eventdata, handles)
% hObject    handle to addDatasetsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datasetChooser(handles, 'FRAPChooser');

%selectedDsNames = getappdata(handles.FRAPChooser, 'selectedDsNames');
selectedDsIds = getappdata(handles.FRAPChooser, 'selectedDsIds');

if isempty(selectedDsIds)
    set(handles.beginButton, 'Enable', 'off');
else
    set(handles.beginButton, 'Enable', 'on');
end


% --- Executes on button press in beginButton.
function beginButton_Callback(hObject, eventdata, handles)
% hObject    handle to beginButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedDsIds = getappdata(handles.FRAPChooser, 'selectedDsIds');
[images imageIds imageNames datasetNames] = getImageIdsAndNamesFromDatasetIds(selectedDsIds);
[imageIdxNoROIs roiShapes] = ROIImageCheck(imageIds);
images = deleteElementFromJavaArrayList(imageIdxNoROIs, images);
imageIds = deleteElementFromVector(imageIdxNoROIs, imageIds);
imageNames = deleteElementFromCells(imageIdxNoROIs, imageNames);
roiShapes = deleteElementFromCells(imageIdxNoROIs, roiShapes);
datasetNames = deleteElementFromCells(imageIdxNoROIs, datasetNames);
numImages = images.size;

for thisImage = 1:numImages
    theImage = images.get(thisImage-1);
    pixels{thisImage} = theImage.getPixels(0);
    %channelLabels{thisImage} = getChannelsFromPixels(pixels{thisImage});
end

setappdata(handles.FRAPChooser, 'images', images);
setappdata(handles.FRAPChooser, 'imageIds', imageIds);
setappdata(handles.FRAPChooser, 'imageNames', imageNames);
setappdata(handles.FRAPChooser, 'roiShapes', roiShapes);
setappdata(handles.FRAPChooser, 'datasetNames', datasetNames);
setappdata(handles.FRAPChooser, 'pixels', pixels);
%setappdata(handles.FRAPChooser, 'channelLabels', channelLabels);
uiresume;



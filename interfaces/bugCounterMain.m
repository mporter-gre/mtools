function varargout = bugCounterMain(varargin)
% BUGCOUNTERMAIN MATLAB code for bugCounterMain.fig
%      BUGCOUNTERMAIN, by itself, creates a new BUGCOUNTERMAIN or raises the existing
%      singleton*.
%
%      H = BUGCOUNTERMAIN returns the handle to a new BUGCOUNTERMAIN or the handle to
%      the existing singleton*.
%
%      BUGCOUNTERMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BUGCOUNTERMAIN.M with the given input arguments.
%
%      BUGCOUNTERMAIN('Property','Value',...) creates a new BUGCOUNTERMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bugCounterMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bugCounterMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bugCounterMain

% Last Modified by GUIDE v2.5 16-Mar-2013 18:07:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bugCounterMain_OpeningFcn, ...
                   'gui_OutputFcn',  @bugCounterMain_OutputFcn, ...
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


% --- Executes just before bugCounterMain is made visible.
function bugCounterMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bugCounterMain (see VARARGIN)

% Choose default command line output for bugCounterMain
handles.output = hObject;
setappdata(handles.bugCounterMain, 'parentHandles', varargin{1});
setappdata(handles.bugCounterMain, 'credentials', varargin{2});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bugCounterMain wait for user response (see UIRESUME)
uiwait(handles.bugCounterMain);


% --- Outputs from this function are returned to the command line.
function varargout = bugCounterMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;



% --- Executes on button press in addDatasetsButton.
function addDatasetsButton_Callback(hObject, eventdata, handles)
% hObject    handle to addDatasetsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datasetChooser(handles, 'bugCounterMain');


% --- Executes on button press in beginAnalysisButton.
function beginAnalysisButton_Callback(hObject, eventdata, handles)
% hObject    handle to beginAnalysisButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

savePath = uigetdir('','Save Data');

if savePath == 0
    return;
end

selectedDsIds = getappdata(handles.bugCounterMain, 'selectedDsIds');
[images, imageIds, imageNames, datasetNames] = getImageIdsAndNamesFromDatasetIds(selectedDsIds);
[imageIdxNoROIs, roiShapes] = ROIImageCheck(imageIds);
images = deleteElementFromJavaArrayList(imageIdxNoROIs, images);
imageIds = deleteElementFromVector(imageIdxNoROIs, imageIds);
imageNames = deleteElementFromCells(imageIdxNoROIs, imageNames);
%roiShapes = deleteElementFromCells(imageIdxNoROIs, roiShapes);
datasetNames = deleteElementFromCells(imageIdxNoROIs, datasetNames);

setappdata(handles.bugCounterMain, 'savePath', savePath);
setappdata(handles.bugCounterMain, 'images', images);
setappdata(handles.bugCounterMain, 'imageIds', imageIds);
setappdata(handles.bugCounterMain, 'imageNames', imageNames);
setappdata(handles.bugCounterMain, 'datasetNames', datasetNames);

countBugs(handles);

%CloseRequestFcn(hObject, eventdata, handles)
close(handles.bugCounterMain);


function closeReqFCN(hObject, eventdata, handles)

uiresume;
delete(gcf);


function countBugs(handles)

global gateway;

progressBar = waitbar(0,'Ready to process images') ;

imageIds = getappdata(handles.bugCounterMain, 'imageIds');
imageNames = getappdata(handles.bugCounterMain, 'imageNames');
datasetNames = getappdata(handles.bugCounterMain, 'datasetNames');
savePath = getappdata(handles.bugCounterMain, 'savePath');

[numDs, ~] = size(datasetNames);
summaryFilename = 'summaryData';
for thisDs = 1:numDs
    summaryFilename = [summaryFilename '_' datasetNames{thisDs}];
end

numImages = length(imageIds);
header = {'numPix' 'sum green' 'mean green' 'stDev green' 'sum red' 'mean red' 'stDev red' 'sum green - bkg' 'mean green - bkg' 'sum red - bkg' 'mean red - bkg'};
summaryHeader = {'image' 'dataset' 'numPix' 'sum green' 'mean green' 'stDev green' 'sum red' 'mean red' 'stDev red' 'sum green - bkg' 'mean green - bkg' 'sum red - bkg' 'mean red - bkg'};
summaryDataOut = [];
namedDataOut = [];

for thisImg = 1:numImages
    filename = num2str(imageIds(thisImg));
    pixels = gateway.getPixelsFromImage(imageIds(thisImg));
    DICStack = getStackFromPixels(pixels, 0, 0);
    greenStack = getStackFromPixels(pixels, 1, 0);
    redStack = getStackFromPixels(pixels, 2, 0);
    waitbar((thisImg/numImages),progressBar,['Segmenting image ' num2str(thisImg) ' of ' num2str(numImages)]);
    segStack = DICSeg(DICStack, 60);
    waitbar((thisImg/numImages),progressBar,['Calculating intensities of image ' num2str(thisImg) ' of ' num2str(numImages)]);
    dataOut = sumIntensitiesAreasFromDICSeg(segStack, greenStack, redStack);
    [greenBkg, redBkg] = getIntensitiesInROI(imageIds(thisImg), greenStack, redStack);
    bkgLine = [0 greenBkg redBkg];
    dataOut = [bkgLine; dataOut];
    dataOut = subtractBackground(dataOut);
    createSpreadsheetFromData(dataOut, header, [savePath '\' filename]);
    [numLines, ~] = size(dataOut);
    names(1:numLines,1) = {imageNames{thisImg}};
    names(1:numLines,2) = {datasetNames{thisImg}};
    namedData = [names num2cell(dataOut)];
    namedDataOut = [namedDataOut; namedData];
    summaryDataOut = [summaryDataOut; namedDataOut];
    clear 'names';
    clear 'dataOut';
end

createSpreadsheetFromData(summaryDataOut, summaryHeader, [savePath '\' summaryFilename]);

waitbar((thisImg/numImages),progressBar,'Data saved, tidying up...');
pause(4);
close(progressBar);

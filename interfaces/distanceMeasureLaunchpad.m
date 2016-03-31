function varargout = distanceMeasureLaunchpad(varargin)
% DISTANCEMEASURELAUNCHPAD M-file for distanceMeasureLaunchpad.fig
%      DISTANCEMEASURELAUNCHPAD, by itself, creates a new DISTANCEMEASURELAUNCHPAD or raises the existing
%      singleton*.
%
%      H = DISTANCEMEASURELAUNCHPAD returns the handle to a new DISTANCEMEASURELAUNCHPAD or the handle to
%      the existing singleton*.
%
%      DISTANCEMEASURELAUNCHPAD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISTANCEMEASURELAUNCHPAD.M with the given input arguments.
%
%      DISTANCEMEASURELAUNCHPAD('Property','Value',...) creates a new DISTANCEMEASURELAUNCHPAD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before distanceMeasureLaunchpad_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to distanceMeasureLaunchpad_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help distanceMeasureLaunchpad

% Last Modified by GUIDE v2.5 11-Oct-2010 14:58:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @distanceMeasureLaunchpad_OpeningFcn, ...
                   'gui_OutputFcn',  @distanceMeasureLaunchpad_OutputFcn, ...
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


% --- Executes just before distanceMeasureLaunchpad is made visible.
function distanceMeasureLaunchpad_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to distanceMeasureLaunchpad (see VARARGIN)

global session;

% Choose default command line output for distanceMeasureLaunchpad
handles.output = hObject;

%First get the datasets or 'conditions'
handles.credentials = varargin{2};
datasetChooser(handles, 'distanceMeasureLaunchpad');
selectedDsIds = getappdata(handles.distanceMeasureLaunchpad, 'selectedDsIds');
[images, imageIds, imageNames, datasetNames] = getImageIdsAndNamesFromDatasetIds(selectedDsIds);
[imageIdxNoROIs, roiShapes] = ROIImageCheck(imageIds, 'rect');
images = deleteElementFromJavaArrayList(imageIdxNoROIs, images);
imageIds = deleteElementFromVector(imageIdxNoROIs, imageIds);
imageNames = deleteElementFromCells(imageIdxNoROIs, imageNames);
roiShapes = deleteElementFromCells(imageIdxNoROIs, roiShapes);
datasetNames = deleteElementFromCells(imageIdxNoROIs, datasetNames);
numImages = images.size;

for thisImage = 1:numImages
    theImage = images.get(thisImage-1);
    pixels{thisImage} = theImage.getPixels(0);
    channelLabels{thisImage} = getChannelsFromPixels(pixels{thisImage});
    numChannels = length(channelLabels{thisImage});
    for thisChannel = 1:numChannels
        channelLabels{thisImage}{thisChannel} = num2str(channelLabels{thisImage}{thisChannel});
    end
end


setappdata(handles.distanceMeasureLaunchpad, 'imageIds', imageIds);
setappdata(handles.distanceMeasureLaunchpad, 'imageNames', imageNames);
setappdata(handles.distanceMeasureLaunchpad, 'roiShapes', roiShapes);
setappdata(handles.distanceMeasureLaunchpad, 'channelLabels', channelLabels);
setappdata(handles.distanceMeasureLaunchpad, 'pixels', pixels);
handles.selectedROI = 1;
guidata(hObject, handles);


for thisImage = 1:numImages
    imageId = pixels{thisImage}.getImage.getId.getValue;
    channelLabelsThisImage = channelLabels{thisImage};
    numChannels = length(channelLabelsThisImage);
    numROI = length(roiShapes{thisImage});
    numPlanes = 0;
    for thisROI = 1:numROI
        numPlanes = numPlanes + (numChannels * roiShapes{thisImage}{thisROI}.numShapes);
    end
    downloadingBar = waitbar(0,'Downloading image...');
    planesCounter = 1;
    for thisROI = 1:numROI
        roiShapes{thisImage}{thisROI}.name = [imageNames{thisImage} '_mask'];
        roiShapes{thisImage}{thisROI}.origName = imageNames{thisImage};
        numROIZ = roiShapes{thisImage}{thisROI}.numShapes;
        theZs = [];
        for thisROIZ = 1:numROIZ
            theZs = [theZs roiShapes{thisImage}{thisROI}.(['shape' num2str(thisROIZ)]).getTheZ.getValue];
        end
        for thisChannel = 1:numChannels
            for thisZ = 1:numROIZ
                [planesThisROI{thisROI}{thisChannel}(:,:,thisZ)] = getPlane(session, imageId, theZs(thisZ), thisChannel-1, 0);
                waitbar(planesCounter/numPlanes);
                planesCounter = planesCounter + 1;
            end
        end
    end
    close(downloadingBar);
    channel1 = 1;
    channel2 = 1;
    for thisROI = 1:numROI
        [selectorOutput channel1 channel2] = objectSelector(pixels{thisImage}, channelLabels{thisImage}, roiShapes{thisImage}{thisROI}, planesThisROI{thisROI}, handles.credentials, channel1, channel2);
        data{thisImage}{thisROI} = selectorOutput;
    end
end

disp('finished')
writeDataOut(data, roiShapes, datasetNames, selectedDsIds);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes distanceMeasureLaunchpad wait for user response (see UIRESUME)
% uiwait(handles.distanceMeasureLaunchpad);


% --- Outputs from this function are returned to the command line.
function varargout = distanceMeasureLaunchpad_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function writeDataOut(data, roiShapes, datasetNames, datasetIds)

mainHeader = {'Original Image', 'Dataset', 'ROI number', 'Object 1 Channel', 'Object 2 Channel', 'Centroid 1 (xyz)', 'Centroid 2 (xyz)', 'Distance', 'Units'};
emptyLine = {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '};
dataOut = mainHeader;
numImages = length(roiShapes);

%Create the data structure for writing out to .xls
for thisImage = 1:numImages
    numROI = length(roiShapes{thisImage});
    for thisROI = 1:numROI
        dataOut = [dataOut; {roiShapes{thisImage}{thisROI}.origName datasetNames{thisImage} num2str(thisROI) data{thisImage}{thisROI}{1}{1} data{thisImage}{thisROI}{2}{1} num2str(data{thisImage}{thisROI}{7}.Centroid) num2str(data{thisImage}{thisROI}{8}.Centroid) data{thisImage}{thisROI}{9}} data{thisImage}{thisROI}{10}];
    end
end





[saveFile savePath] = uiputfile('*.xls','Save Results',[getenv('userprofile'), '/DistanceMeasurements.xls']);
if isnumeric(saveFile) && isnumeric(savePath)
    return;
end

try
    xlswrite([savePath saveFile], dataOut);
    %Make the dsList structure, remove projList
    attachResults(datasetIds, saveFile, savePath);
catch
    %If the xlswriter fails (no MSOffice installed, e.g.) then manually
    %create a .csv file. Turn every cell to string to make it easier.
    largestCell = 0;
    [rows cols] = size(dataOut);
    for thisRow = 1:rows
        for thisCol = 1:cols
            if isnumeric(dataOut{thisRow, thisCol})
                dataOut{thisRow, thisCol} = num2str(dataOut{thisRow, thisCol});
            end
        end
    end
    delete([savePath saveFile]); %Delete the .xls file and save again as .csv
    [savePart remain] = strtok(saveFile, '.');
    saveFile = [savePart '.csv'];
    fid = fopen([savePath saveFile], 'w');
    for thisRow = 1:rows
        for thisCol = 1:cols
            fprintf(fid, '%s', dataOut{thisRow, thisCol});
            fprintf(fid, '%s', ',');
        end
        fprintf(fid, '%s\n', '');
    end
    fclose(fid);
end
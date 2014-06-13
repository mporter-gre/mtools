function varargout = TssBAnalysis(varargin)
% TSSBANALYSIS MATLAB code for TssBAnalysis.fig
%      TSSBANALYSIS, by itself, creates a new TSSBANALYSIS or raises the existing
%      singleton*.
%
%      H = TSSBANALYSIS returns the handle to a new TSSBANALYSIS or the handle to
%      the existing singleton*.
%
%      TSSBANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TSSBANALYSIS.M with the given input arguments.
%
%      TSSBANALYSIS('Property','Value',...) creates a new TSSBANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TssBAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TssBAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TssBAnalysis

% Last Modified by GUIDE v2.5 18-Mar-2014 21:16:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TssBAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @TssBAnalysis_OutputFcn, ...
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


% --- Executes just before TssBAnalysis is made visible.
function TssBAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TssBAnalysis (see VARARGIN)

% Choose default command line output for TssBAnalysis
handles.output = hObject;
password = '';
setappdata(hObject,'passData',password);
set(handles.passText, 'KeyPressFcn', {@passKeyPress, handles});

setappdata(handles.TssBAnalysis, 'selectedDsIds', []);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TssBAnalysis wait for user response (see UIRESUME)
% uiwait(handles.TssBAnalysis);


% --- Outputs from this function are returned to the command line.
function varargout = TssBAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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


% --- Executes on button press in loginBtn.
function loginBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loginBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off');
success = logIn(handles);
if success == 0
    set(hObject, 'enable', 'on');
    return;
end

set(handles.chooseDatasetsBtn, 'enable', 'on');



% --- Executes on button press in chooseDatasetsBtn.
function chooseDatasetsBtn_Callback(hObject, eventdata, handles)
% hObject    handle to chooseDatasetsBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datasetChooser(handles, 'TssBAnalysis');
dsIds = getappdata(handles.TssBAnalysis, 'selectedDsIds');
if ~isempty(dsIds)
    set(handles.analyseBtn, 'enable', 'on');
end


% --- Executes on button press in analyseBtn.
function analyseBtn_Callback(hObject, eventdata, handles)
% hObject    handle to analyseBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.TssBAnalysis, 'visible', 'off');
dsIds = getappdata(handles.TssBAnalysis, 'selectedDsIds');
TssBAnalysisQueue(dsIds);
set(handles.TssBAnalysis, 'visible', 'on');


function passKeyPress(hObject, eventdata, handles)

lastChar = eventdata.Character;
lastKey = eventdata.Key;
currPass = getappdata(handles.TssBAnalysis, 'passData');
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

    setappdata(handles.TssBAnalysis, 'passData', password);
    numChars = length(password);
    stars(1:numChars) = '*';
    set(hObject, 'String', stars);
end



function success = logIn(handles)

global client;
global session;

credentials{1} = get(handles.usernameText, 'String');
credentials{2} = getappdata(handles.TssBAnalysis, 'passData');
credentials{3} = 'nightshade.openmicroscopy.org.uk';
credentials{4} = '4064';
setappdata(handles.TssBAnalysis, 'credentials', credentials);
if isempty(credentials{1}) || isempty(credentials{2}) || isempty(credentials{3}) || isempty(credentials{4})
    helpdlg('Check you have entered a Username and Password.');
    success = false;
    return;
end

%First check the login works. Client, session and gateway are global, so
%will persist and be kept alive until application close.
try
    if ~isjava(client)
        userLoginOmero(credentials{1}, credentials{2}, credentials{3}, credentials{4});
        success = true;
        selectUserDefaultGroup(credentials{1}, handles, 'TssbAnalysis');
    else
        experimenter = char(session.getAdminService.getExperimenter(0).getOmeName.getValue.getBytes)';
        if strcmp(experimenter, credentials{1})
            success = true;
        else
            userLogoutOmero;
            success = logIn(handles);
        end
    end
%     uiwait(groupSelection);
catch ME
    clear global client;
    clear global session;
    disp(ME.message);
    warndlg('Could not log on to the server. Check your details and try again.');
    success = false;
    return;
end


% --- Executes on button press in summariseBtn.
function summariseBtn_Callback(hObject, eventdata, handles)
% hObject    handle to summariseBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fileNames, filePaths] = uigetfile('*.xls', 'Select .xls files for summary', 'MultiSelect', 'on');
progress = waitbar(0, 'Loading data');
numFiles = length(fileNames);
cellData = [];
neighbourData = [];
focusData = [];
focusNeighbourData = [];
cellCounter = 0;

for thisFile = 1:numFiles
    %Read the worksheets from the selected files.
    thisCellData = xlsread([filePaths fileNames{thisFile}], 'Cell Data');
    thisNeighbourData = xlsread([filePaths fileNames{thisFile}], 'Neighbour Data');
    thisFocusData = xlsread([filePaths fileNames{thisFile}], 'Focus Data');
    thisFocusNeighbourData = xlsread([filePaths fileNames{thisFile}], 'Focus Neighbour Data');
    numCells = length(thisCellData);
    
    %Fudge
    if isempty(thisCellData)
        thisCellData = [0 0 0 0 0 0 0];
    end
    if isempty(thisNeighbourData)
        thisNeighbourData = [0 0];
    end
    if isempty(thisFocusData)
        thisFocusData = [0 0 0 0 0 0];
    end
    if isempty(thisFocusNeighbourData)
        thisFocusNeighbourData = [0 0 0];
    end    
    
    %Re-assign cell numbers to keep them unique after loading another file.
    thisCellData(:,1) = thisCellData(:,1) + cellCounter;
    thisNeighbourData(:,1) = thisNeighbourData(:,1) + cellCounter;
    thisFocusData(:,1) = thisFocusData(:,1) + cellCounter;
    thisFocusNeighbourData(:,1) = thisFocusNeighbourData(:,1) + cellCounter;
    cellCounter = cellCounter + numCells;
    
    %Collate the data.
    cellData = [cellData; thisCellData];
    neighbourData = [neighbourData; thisNeighbourData];
    focusData = [focusData; thisFocusData];
    focusNeighbourData = [focusNeighbourData; thisFocusNeighbourData];
    waitbar(thisFile/numFiles, progress, 'Loading data');
end

%Index of cells with x foci.
foci0 = find(cellData(:,4) == 0);
foci1 = find(cellData(:,4) == 1);
foci2 = find(cellData(:,4) == 2);
foci3p = find(cellData(:,4) > 2);

%Percentage of cells with x foci.
foci0PC = (length(foci0)/cellCounter)*100;
foci1PC = (length(foci1)/cellCounter)*100;
foci2PC = (length(foci2)/cellCounter)*100;
foci3pPC = (length(foci3p)/cellCounter)*100;

%Index of cells with x neighbours.
cell0Neighbours = find(cellData(:,5) == 0);
cell1Neighbours = find(cellData(:,5) == 1);
cell2Neighbours = find(cellData(:,5) == 2);
cell3pNeighbours = find(cellData(:,5) > 2);

%Permutations of intersection of numFoci and numNeighbours.
foci0Neighbours0 = intersect(foci0, cell0Neighbours);
foci1Neighbours0 = intersect(foci1, cell0Neighbours);
foci2Neighbours0 = intersect(foci2, cell0Neighbours);
foci3pNeighbours0 = intersect(foci3p, cell0Neighbours);

foci0Neighbours1 = intersect(foci0, cell1Neighbours);
foci1Neighbours1 = intersect(foci1, cell1Neighbours);
foci2Neighbours1 = intersect(foci2, cell1Neighbours);
foci3pNeighbours1 = intersect(foci3p, cell1Neighbours);

foci0Neighbours2 = intersect(foci0, cell2Neighbours);
foci1Neighbours2 = intersect(foci1, cell2Neighbours);
foci2Neighbours2 = intersect(foci2, cell2Neighbours);
foci3pNeighbours2 = intersect(foci3p, cell2Neighbours);

foci0Neighbours3p = intersect(foci0, cell3pNeighbours);
foci1Neighbours3p = intersect(foci1, cell3pNeighbours);
foci2Neighbours3p = intersect(foci2, cell3pNeighbours);
foci3pNeighbours3p = intersect(foci3p, cell3pNeighbours);

fociYNeighboursX = [length(foci0Neighbours0) length(foci0Neighbours1) length(foci0Neighbours2) length(foci0Neighbours3p);...
    length(foci1Neighbours0) length(foci1Neighbours1) length(foci1Neighbours2) length(foci1Neighbours3p);...
    length(foci2Neighbours0) length(foci2Neighbours1) length(foci2Neighbours2) length(foci2Neighbours3p);...
    length(foci3pNeighbours0) length(foci3pNeighbours1) length(foci3pNeighbours2) length(foci3pNeighbours3p)];

%Percent chance of numNeighbours Vs numFoci
fociYNeighboursXPC(1,1) = fociYNeighboursX(1,1)/sum(fociYNeighboursX(:,1))*100;
fociYNeighboursXPC(2,1) = fociYNeighboursX(2,1)/sum(fociYNeighboursX(:,1))*100;
fociYNeighboursXPC(3,1) = fociYNeighboursX(3,1)/sum(fociYNeighboursX(:,1))*100;
fociYNeighboursXPC(4,1) = fociYNeighboursX(4,1)/sum(fociYNeighboursX(:,1))*100;
fociYNeighboursXPC(1,2) = fociYNeighboursX(1,2)/sum(fociYNeighboursX(:,2))*100;
fociYNeighboursXPC(2,2) = fociYNeighboursX(2,2)/sum(fociYNeighboursX(:,2))*100;
fociYNeighboursXPC(3,2) = fociYNeighboursX(3,2)/sum(fociYNeighboursX(:,2))*100;
fociYNeighboursXPC(4,2) = fociYNeighboursX(4,2)/sum(fociYNeighboursX(:,2))*100;
fociYNeighboursXPC(1,3) = fociYNeighboursX(1,3)/sum(fociYNeighboursX(:,3))*100;
fociYNeighboursXPC(2,3) = fociYNeighboursX(2,3)/sum(fociYNeighboursX(:,3))*100;
fociYNeighboursXPC(3,3) = fociYNeighboursX(3,3)/sum(fociYNeighboursX(:,3))*100;
fociYNeighboursXPC(4,3) = fociYNeighboursX(4,3)/sum(fociYNeighboursX(:,3))*100;
fociYNeighboursXPC(1,4) = fociYNeighboursX(1,4)/sum(fociYNeighboursX(:,4))*100;
fociYNeighboursXPC(2,4) = fociYNeighboursX(2,4)/sum(fociYNeighboursX(:,4))*100;
fociYNeighboursXPC(3,4) = fociYNeighboursX(3,4)/sum(fociYNeighboursX(:,4))*100;
fociYNeighboursXPC(4,4) = fociYNeighboursX(4,4)/sum(fociYNeighboursX(:,4))*100;


%Output to spreadsheet.
waitbar(0, progress, 'Saving data');
output1 = {'% Cells with x numFoci', ' ', ' ', ' '};
output1 = [output1; {'0 Foci', '1 Focus', '2 Foci', '3+ Foci'}];
output1 = [output1; {foci0PC, foci1PC, foci2PC, foci3pPC}];
xlswrite([filePaths 'AnalysisSumary'], output1, '% Cells with x numFoci');

waitbar(1/5, progress, 'Saving data');
output2 = {'Focus location, % from centre'};
output2 = [output2; num2cell(focusData(:,6))];
xlswrite([filePaths 'AnalysisSumary'], output2, 'Focus location');


waitbar(2/5, progress, 'Saving data');
output3 = {'numNeighbours vs. numFoci', ' ', ' ', ' ', ' '};
output3 = [output3; {'Counts', '0 Neighbours', '1 Neighbour', '2 Neighbours', '3+ Neighbours'}];
output3 = [output3; {'0 Foci'}, num2cell(fociYNeighboursX(1,:))];
output3 = [output3; {'1 Focus'}, num2cell(fociYNeighboursX(2,:))];
output3 = [output3; {'2 Foci'}, num2cell(fociYNeighboursX(3,:))];
output3 = [output3; {'3+ Foci'}, num2cell(fociYNeighboursX(4,:))];

output3 = [output3; {' ',' ',' ',' ',' '}];

output3 = [output3; {'% of Cells', '0 Neighbours', '1 Neighbour', '2 Neighbours', '3+ Neighbours'}];
output3 = [output3; {'0 Foci'}, num2cell(fociYNeighboursXPC(1,:))];
output3 = [output3; {'1 Focus'}, num2cell(fociYNeighboursXPC(2,:))];
output3 = [output3; {'2 Foci'}, num2cell(fociYNeighboursXPC(3,:))];
output3 = [output3; {'3+ Foci'}, num2cell(fociYNeighboursXPC(4,:))];

xlswrite([filePaths 'AnalysisSumary'], output3, 'numNeighbours vs. numFoci');

waitbar(3/5, progress, 'Saving data');
focusNeighbourDistance = focusNeighbourData(:,3);
focusNeighbourDistance(focusNeighbourDistance==65535) = [];
output4 = {'Focus distance to touching point'};
output4 = [output4; num2cell(focusNeighbourDistance)];

xlswrite([filePaths 'AnalysisSumary'], output4, 'Focus Touch Distance');


waitbar(4/5, progress, 'Saving data');
output5 = {'Size of Foci'};
output5 = [output5; num2cell(focusData(:,3))];

xlswrite([filePaths 'AnalysisSumary'], output5, 'Focus Size');

waitbar(1, progress, 'Saving data');
close(progress);
msgbox([{'Analysis complete. File saved to'} {[filePaths, ' ', 'AnalysisSummary']}]);












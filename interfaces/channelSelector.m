function varargout = channelSelector(varargin)
% CHANNELSELECTOR M-file for channelSelector.fig
%      CHANNELSELECTOR, by itself, creates a new CHANNELSELECTOR or raises the existing
%      singleton*.
%
%      H = CHANNELSELECTOR returns the handle to a new CHANNELSELECTOR or the handle to
%      the existing singleton*.
%
%      CHANNELSELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANNELSELECTOR.M with the given input arguments.
%
%      CHANNELSELECTOR('Property','Value',...) creates a new CHANNELSELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before channelSelector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to channelSelector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help channelSelector

% Last Modified by GUIDE v2.5 09-Oct-2009 13:54:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @channelSelector_OpeningFcn, ...
                   'gui_OutputFcn',  @channelSelector_OutputFcn, ...
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


% --- Executes just before channelSelector is made visible.
function channelSelector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to channelSelector (see VARARGIN)

% Choose default command line output for channelSelector
handles.output = hObject;
handles.remember = [];
handles.rememberScope = [];

% Update handles structure
guidata(hObject, handles);
set(handles.channelSelect, 'String', varargin{1});
numChannels = length(varargin{1});
handles.numChannels = numChannels;
switch numChannels
    case 1
        set(handles.measureCheck1, 'String', varargin{1}(1));
        set(handles.measureCheck1, 'Visible', 'on');
        set(handles.measureAroundCheck1, 'String', varargin{1}(1));
        set(handles.measureAroundCheck1, 'Visible', 'on');
    case 2
        set(handles.measureCheck1, 'String', varargin{1}(1));
        set(handles.measureCheck1, 'Visible', 'on');
        set(handles.measureCheck2, 'String', varargin{1}(2));
        set(handles.measureCheck2, 'Visible', 'on');
        set(handles.measureAroundCheck1, 'String', varargin{1}(1));
        set(handles.measureAroundCheck1, 'Visible', 'on');
        set(handles.measureAroundCheck2, 'String', varargin{1}(2));
        set(handles.measureAroundCheck2, 'Visible', 'on');
    case 3
        set(handles.measureCheck1, 'String', varargin{1}(1));
        set(handles.measureCheck1, 'Visible', 'on');
        set(handles.measureCheck2, 'String', varargin{1}(2));
        set(handles.measureCheck2, 'Visible', 'on');
        set(handles.measureCheck3, 'String', varargin{1}(3));
        set(handles.measureCheck3, 'Visible', 'on');
        set(handles.measureAroundCheck1, 'String', varargin{1}(1));
        set(handles.measureAroundCheck1, 'Visible', 'on');
        set(handles.measureAroundCheck2, 'String', varargin{1}(2));
        set(handles.measureAroundCheck2, 'Visible', 'on');
        set(handles.measureAroundCheck3, 'String', varargin{1}(3));
        set(handles.measureAroundCheck3, 'Visible', 'on');
    case 4
        set(handles.measureCheck1, 'String', varargin{1}(1));
        set(handles.measureCheck1, 'Visible', 'on');
        set(handles.measureCheck2, 'String', varargin{1}(2));
        set(handles.measureCheck2, 'Visible', 'on');
        set(handles.measureCheck3, 'String', varargin{1}(3));
        set(handles.measureCheck3, 'Visible', 'on');
        set(handles.measureCheck4, 'String', varargin{1}(4));
        set(handles.measureCheck4, 'Visible', 'on');
        set(handles.measureAroundCheck1, 'String', varargin{1}(1));
        set(handles.measureAroundCheck1, 'Visible', 'on');
        set(handles.measureAroundCheck2, 'String', varargin{1}(2));
        set(handles.measureAroundCheck2, 'Visible', 'on');
        set(handles.measureAroundCheck3, 'String', varargin{1}(3));
        set(handles.measureAroundCheck3, 'Visible', 'on');
        set(handles.measureAroundCheck4, 'String', varargin{1}(4));
        set(handles.measureAroundCheck4, 'Visible', 'on');
end
guidata(hObject, handles);
uiwait(handles.figure1);
% UIWAIT makes channelSelector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = channelSelector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
varargout{1} = get(handles.channelSelect, 'Value');
varargout{2} = handles.remember;
varargout{3} = handles.rememberScope;
%Check which channels have been selected for measurement
measureList = [];
measureAroundList = [];
checkSelected = get(handles.measureCheck1, 'Value');
if checkSelected == 1
    measureList = [measureList 1];
end
checkSelected = get(handles.measureCheck2, 'Value');
if checkSelected == 1
    measureList = [measureList 2];
end
checkSelected = get(handles.measureCheck3, 'Value');
if checkSelected == 1
    measureList = [measureList 3];
end
checkSelected = get(handles.measureCheck4, 'Value');
if checkSelected == 1
    measureList = [measureList 4];
end

checkSelected = get(handles.measureAroundCheck1, 'Value');
if checkSelected == 1
    measureAroundList = [measureAroundList 1];
end
checkSelected = get(handles.measureAroundCheck2, 'Value');
if checkSelected == 1
    measureAroundList = [measureAroundList 2];
end
checkSelected = get(handles.measureAroundCheck3, 'Value');
if checkSelected == 1
    measureAroundList = [measureAroundList 3];
end
checkSelected = get(handles.measureAroundCheck4, 'Value');
if checkSelected == 1
    measureAroundList = [measureAroundList 4];
end
varargout{4} = measureList;
varargout{5} = measureAroundList;
varargout{6} = str2double(get(handles.featherText, 'String'));
varargout{7} = get(handles.saveMaskCheck, 'Value');
varargout{8} = get(handles.verifyZCheck, 'Value');
groupObjects = get(handles.groupObjectsRadio, 'Value');
if groupObjects == 1
    varargout{9} = 1;
else
    varargout{9} = 0;
end
close(hObject)
drawnow;



% --- Executes on selection change in channelSelect.
function channelSelect_Callback(hObject, eventdata, handles)
% hObject    handle to channelSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns channelSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channelSelect


% --- Executes during object creation, after setting all properties.
function channelSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in rememberCheck.
function rememberCheck_Callback(hObject, eventdata, handles)
% hObject    handle to rememberCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rememberCheck

if get(hObject, 'Value') == 1
    set(handles.rememberConditionRadio, 'Enable', 'on');
    set(handles.rememberAllRadio, 'Enable', 'on');
end
if get(hObject, 'Value') == 0
    set(handles.rememberConditionRadio, 'Enable', 'off');
    set(handles.rememberAllRadio, 'Enable', 'off');
end

% --- Executes on button press in rememberConditionRadio.
function rememberConditionRadio_Callback(hObject, eventdata, handles)
% hObject    handle to rememberConditionRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rememberConditionRadio


% --- Executes on button press in rememberAllRadio.
function rememberAllRadio_Callback(hObject, eventdata, handles)
% hObject    handle to rememberAllRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rememberAllRadio


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)
% hObject    handle to okButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Check to see if a channel has been selected for measurement.
measureSelected = 0;
checkSelected = get(handles.measureCheck1, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
checkSelected = get(handles.measureCheck2, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
checkSelected = get(handles.measureCheck3, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
checkSelected = get(handles.measureCheck4, 'Value');
if checkSelected == 1
    measureSelected = 1;
end

checkSelected = get(handles.measureAroundCheck1, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
checkSelected = get(handles.measureAroundCheck2, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
checkSelected = get(handles.measureAroundCheck3, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
checkSelected = get(handles.measureAroundCheck4, 'Value');
if checkSelected == 1
    measureSelected = 1;
end
handles.saveMask = get(handles.saveMaskCheck, 'Value');
handles.verifyZ = get(handles.verifyZCheck, 'Value');

if ~measureSelected
    helpdlg('Select a channel to measure.', 'Error');
    return;
end

channelChoice = get(handles.channelSelect, 'Value');
handles.remember = get(handles.rememberCheck, 'Value');
handles.rememberScope = get(get(handles.rememberPanel, 'SelectedObject'), 'Tag');

guidata(hObject, handles);
uiresume;


% --- Executes on button press in measureCheck1.
function measureCheck1_Callback(hObject, eventdata, handles)
% hObject    handle to measureCheck1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureCheck1


% --- Executes on button press in measureCheck2.
function measureCheck2_Callback(hObject, eventdata, handles)
% hObject    handle to measureCheck2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureCheck2


% --- Executes on button press in measureCheck3.
function measureCheck3_Callback(hObject, eventdata, handles)
% hObject    handle to measureCheck3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureCheck3


% --- Executes on button press in measureCheck4.
function measureCheck4_Callback(hObject, eventdata, handles)
% hObject    handle to measureCheck4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureCheck4


% --- Executes on button press in measureAroundCheck1.
function measureAroundCheck1_Callback(hObject, eventdata, handles)
% hObject    handle to measureAroundCheck1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureAroundCheck1


% --- Executes on button press in measureAroundCheck2.
function measureAroundCheck2_Callback(hObject, eventdata, handles)
% hObject    handle to measureAroundCheck2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureAroundCheck2


% --- Executes on button press in measureAroundCheck3.
function measureAroundCheck3_Callback(hObject, eventdata, handles)
% hObject    handle to measureAroundCheck3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureAroundCheck3


% --- Executes on button press in measureAroundCheck4.
function measureAroundCheck4_Callback(hObject, eventdata, handles)
% hObject    handle to measureAroundCheck4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of measureAroundCheck4


% --- Executes on button press in saveMaskCheck.
function saveMaskCheck_Callback(hObject, eventdata, handles)
% hObject    handle to saveMaskCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveMaskCheck


% --- Executes on button press in verifyZCheck.
function verifyZCheck_Callback(hObject, eventdata, handles)
% hObject    handle to verifyZCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of verifyZCheck



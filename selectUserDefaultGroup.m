function varargout = selectUserDefaultGroup(varargin)
% SELECTUSERDEFAULTGROUP M-file for selectUserDefaultGroup.fig
%       This no longer changes the user's default group, but instead now
%       changes the securityContext of the session.
%      SELECTUSERDEFAULTGROUP, by itself, creates a new SELECTUSERDEFAULTGROUP or raises the existing
%      singleton*.
%
%      H = SELECTUSERDEFAULTGROUP returns the handle to a new SELECTUSERDEFAULTGROUP or the handle to
%      the existing singleton*.
%
%      SELECTUSERDEFAULTGROUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTUSERDEFAULTGROUP.M with the given input arguments.
%
%      SELECTUSERDEFAULTGROUP('Property','Value',...) creates a new SELECTUSERDEFAULTGROUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectUserDefaultGroup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectUserDefaultGroup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selectUserDefaultGroup

% Last Modified by GUIDE v2.5 26-Jul-2013 14:18:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @selectUserDefaultGroup_OpeningFcn, ...
                   'gui_OutputFcn',  @selectUserDefaultGroup_OutputFcn, ...
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


% --- Executes just before selectUserDefaultGroup is made visible.
function selectUserDefaultGroup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selectUserDefaultGroup (see VARARGIN)

global session

% Choose default command line output for selectUserDefaultGroup
handles.output = hObject;
handles.username = varargin{1};
handles.parentHandles = varargin{2};
handles.parentFigName = varargin{3};

adminService = session.getAdminService;
userObj = adminService.lookupExperimenter(handles.username);
userId = userObj.getId.getValue;
userGroups = adminService.containedGroups(userId);
currDefaultGroup = char(adminService.getDefaultGroup(userId).getName.getValue.getBytes');
currDefaultGroupIdx = 1;

numGroups = userGroups.size;
groupCounter = 1;
for thisGroup = 0:numGroups-1
    thisGroupName = char(userGroups.get(thisGroup).getName.getValue.getBytes');
    if strcmpi('user', thisGroupName)
        continue;
    end
    if strcmpi(currDefaultGroup, thisGroupName)
        currDefaultGroupIdx = groupCounter;
    end
    userGroupNames{groupCounter} = thisGroupName;
    userGroupIds(groupCounter) = userGroups.get(thisGroup).getId.getValue;
    groupCounter = groupCounter + 1;
end

set(handles.groupSelect, 'String', userGroupNames);
set(handles.groupSelect, 'Value', currDefaultGroupIdx);
setappdata(handles.selectUserDefaultGroupFig, 'userGroupIds', userGroupIds);
setappdata(handles.selectUserDefaultGroupFig, 'currDefaultGroup', currDefaultGroup);
setappdata(handles.selectUserDefaultGroupFig, 'userObj', userObj);
setappdata(handles.selectUserDefaultGroupFig, 'adminService', adminService);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes selectUserDefaultGroup wait for user response (see UIRESUME)
uiwait(handles.selectUserDefaultGroupFig);


% --- Outputs from this function are returned to the command line.
function varargout = selectUserDefaultGroup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on selection change in groupSelect.
function groupSelect_Callback(hObject, eventdata, handles)
% hObject    handle to groupSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns groupSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from groupSelect


% --- Executes during object creation, after setting all properties.
function groupSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to groupSelect (see GCBO)
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

global session

adminService = getappdata(handles.selectUserDefaultGroupFig, 'adminService');
userGroupIds = getappdata(handles.selectUserDefaultGroupFig, 'userGroupIds');
currDefaultGroup = getappdata(handles.selectUserDefaultGroupFig, 'currDefaultGroup');
userObj = getappdata(handles.selectUserDefaultGroupFig, 'userObj');
selectedGroupIdx = get(handles.groupSelect, 'Value');
selectedGroupName = get(handles.groupSelect, 'String');

selectedGroupId = userGroupIds(selectedGroupIdx);
workingGroup = adminService.getGroup(selectedGroupId);
session.setSecurityContext(workingGroup);
%guidata(hObject, handles);

delete(handles.selectUserDefaultGroupFig);

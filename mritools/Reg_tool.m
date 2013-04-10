function Reg_tool(varargin);
% function Reg_tool(varargin);
% Registration tool for 2D or 3D registration. Use with
% imagescn or imagescn.
%
% Usage: Reg_tool;
%
% Author: Daniel Herzka  herzkad@nih.gov
% Laboratory of Cardiac Energetics 
% National Heart, Lung and Blood Institute, NIH, DHHS
% Bethesda, MD 20892
% and 
% Medical Imaging Laboratory
% Department of Biomedical Engineering
% Johns Hopkins University Schoold of Medicine
% Baltimore, MD 21205
%
%
% Registration routines by 
% Dr. Peter Kellman
% Laboratory of Cardiac Energetics 
% National Heart, Lung and Blood Institute, NIH, DHHS
% Bethesda, MD 20892


if isempty(varargin) 
   Action = 'New';
else
   Action = varargin{1};  
end

global DB; DB = 1;

switch Action
case 'New'
    Create_New_Button;

case 'Activate_Reg_Tool'
    Activate_Reg_Tool(varargin{2:end});
case 'Deactivate_Reg_Tool'
    Deactivate_Reg_Tool(varargin{2:end});

case 'Set_Current_Axes' 
	Set_Current_Axes(varargin{2:end});
case 'Select_Dimension'
	Select_Dimension(varargin{2:end});
case 'Select_Axes'
	Select_Axes;
case 'Select_Scope'
	Select_Scope;
case 'Select_Method'
	Select_Method;

case 'Limit_Axes'
		Limit_Axes(varargin{2:end});
case 'Step_Axes'
	Step_Axes(varargin{2:end});
case 'Set_Axes'
 	Set_Axes(varargin{2:end});

case 'Limit_Frame'
	Limit_Frame(varargin{2:end});
case 'Step_Frame'
	Step_Frame(varargin{2:end});
case 'Set_Frame'
 	Set_Frame(varargin{2:end});
	
% case 'Advanced_Options'
% 	Advanced_Options;
case 'Create_Reference'
 	Create_Reference;
case 'Clear_Reference'
 	Clear_Reference;
case 'Start_Registration'
	Start_Registration;
	
case 'Menu_Reg_Tool'
    Menu_Reg_Tool;
    
case 'Close_Parent_Figure'
    Close_Parent_Figure;    
    
otherwise
    disp(['Unimplemented Functionality: ', Action]);
   
end;
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Create_New_Button
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;

fig = gcf;

% Find handle for current image toolbar and menubar
hToolbar = findall(fig, 'type', 'uitoolbar', 'Tag','FigureToolBar' );
hToolMenu = findall(fig, 'Label', '&Tools');

% check to see that there is either more than on axes on the current figure
% or a temporal dimension on the current figure
ax = findobj(fig, 'type','axes'); ax = ax(1);
no_dim_time = isempty(getappdata(ax, 'ImageData'));
no_dim_space = length(findobj(fig,'type', 'axes')) == 1;

if ~isempty(hToolbar) & isempty(findobj(hToolbar, 'Tag', 'figRegTool'))
	hToolbar_Children = get(hToolbar, 'Children');
	
	% The default button size is 15 x 16 x 3. Create Button Image
	button_size_x= 16;
	button_image = NaN* zeros(15,button_size_x);
	
	f= [...
			1     2     3     4     5    16    17    18    19    20    31    32    33    34    35    46    47    48    49    50    61    62    63    64    65 , ...
		82    98   100   107   114   115   122   128   129   130   137   138   139   140   141   147   152   161   162   163   167   175   176   177   178 , ...
		179   189   190   191   192   193   194   195   205   206   207   208   209   221   222   223   237 ...
	]; 
	button_image(f) = 0;
	button_image = repmat(button_image, [1,1,3]);
	
	buttontags = {'figWindowLevel', 'figPanZoom', 'figROITool',  'figProfileTool','figViewImages', 'figPointTool', 'figRotateTool', 'figRegTool'};
	separator = 'off';
	
	hbuttons = [];
	for i = 1:length(buttontags)
		hbuttons = [hbuttons, findobj(hToolbar_Children, 'Tag', buttontags{i})];
	end;
	if isempty(hbuttons)
		separator = 'on';
	end;
	
	hNewButton = uitoggletool(hToolbar);
	set(hNewButton, 'Cdata', button_image, ...
		'OnCallback', 'Reg_tool(''Activate_Reg_Tool'')',...
		'OffCallback', 'Reg_tool(''Deactivate_Reg_Tool'')',...
		'Tag', 'figRegTool', ...
		'TooltipString', 'Register Multiple 2D and 3D Datasets',...
		'UserData', [], ...
		'Separator', separator, ...
		'Enable', 'on');   

	if no_dim_time & no_dim_space
		set(hNewButton, 'Enable', 'off');
	end;
end;

	
% If the menubar exists, create menu item
if ~isempty(hToolMenu) & isempty(findobj(hToolMenu, 'Tag', 'menuViewImages'))
	hWindowLevelMenu = findobj(hToolMenu, 'Tag', 'menuWindowLevel');
	hPanZoomMenu     = findobj(hToolMenu, 'Tag', 'menuPanZoom');
	hROIToolMenu     = findobj(hToolMenu, 'Tag', 'menuROITool');
	hProfileToolMenu = findobj(hToolMenu, 'Tag', 'menuProfileTool');
	hViewImageMenu   = findobj(hToolMenu, 'Tag', 'menuViewImages');
	hPointToolMenu   = findobj(hToolMenu, 'Tag', 'menuPointTool');
	hRotateToolMenu  = findobj(hToolMenu, 'Tag', 'menuRotateTool');
	hRegToolMenu     = findobj(hToolMenu, 'Tag', 'menuRegTool');
	
	position = 9;
	separator = 'On';
	hMenus = [ hWindowLevelMenu, hPanZoomMenu,hROIToolMenu, hProfileToolMenu,hPointToolMenu, hRotateToolMenu, hRegToolMenu ];
	if length(hMenus>0) 
		position = position + length(hMenus);
		separator = 'Off';
	end;
	
	hNewMenu = uimenu(hToolMenu,'Position', position);
	set(hNewMenu, 'Tag', 'menuViewImages','Label',...
		'Movie Tool',...
		'CallBack', 'Reg_tool(''Menu_Reg_Tool'')',...
		'Separator', separator,...
		'UserData', hNewButton...
		); 	
	if no_dim_time & no_dim_space
		set(hNewMenu, 'Enable', 'off');
	end;

end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Activate_Reg_Tool(varargin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;

fig = gcf;

if nargin ==0
    set(0, 'ShowHiddenHandles', 'On');
    hNewButton = gcbo;
    set(findobj('Tag', 'menuRegTool'),'checked', 'on');
else
    hNewButton = varargin{1};
end;

% allows for calls from buttons other than those in toolbar
fig = get(hNewButton, 'Parent');
if ~strcmp(get(fig, 'Type'), 'figure'),
    fig = get(fig, 'Parent');
end

% Deactivate zoom and rotate buttons
hToolbar = findall(fig, 'type', 'uitoolbar');
hToolbar = findobj(hToolbar, 'Tag', 'FigureToolBar');

if ~isempty(hToolbar)
	hToolbar_Children = get(hToolbar, 'Children');
	
	% disable MATLAB's own tools
	Rot3D = findobj(hToolbar_Children,'Tag', 'figToolRotate3D');
	ZoomO = findobj(hToolbar_Children,'Tag', 'figToolZoomOut');
	ZoomI = findobj(hToolbar_Children,'Tag', 'figToolZoomIn');

	% try to disable other tools buttons - if they exist
	WL = findobj(hToolbar_Children, 'Tag', 'figWindowLevel');
	PZ = findobj(hToolbar_Children,'Tag', 'figPanZoom');
	RT = findobj(hToolbar_Children,'Tag', 'figROITool');
	Prof = findobj(hToolbar_Children, 'Tag', 'figProfileTool');
	MV = findobj(hToolbar_Children,'Tag', 'figViewImages');
	PM = findobj(hToolbar_Children,'Tag', 'figPointTool');
	RotT = findobj(hToolbar_Children,'Tag', 'figRotateTool');
	RegT = findobj(hToolbar_Children, 'Tag', 'figRegTool');

	
	old_ToolHandles  =     cat(1,Rot3D, ZoomO, ZoomI,WL,PZ,RT,Prof,MV,PM,RotT);
	old_ToolEnables  = get(cat(1,Rot3D, ZoomO, ZoomI,WL,PZ,RT,Prof,MV,PM,RotT), 'Enable');
	old_ToolStates   = get(cat(1,Rot3D, ZoomO, ZoomI,WL,PZ,RT,Prof,MV,PM,RotT), 'State');
	
	for i = 1:length(old_ToolHandles)
		if strcmp(old_ToolStates(i) , 'on')			
			set(old_ToolHandles(i), 'State', 'Off');
		end;
		set(old_ToolHandles(i), 'Enable', 'Off');
	end;

	%Enable the save_preferences tool button
	SP = findobj(hToolbar_Children, 'Tag', 'figSavePrefsTool');
	set(SP,'Enable','On');
end;

% Start PZ GUI
fig2_old = findobj('Tag', 'RegT_figure');
% close the old WL figure to avoid conflicts
if ~isempty(fig2_old) close(fig2_old);end;

% open new figure
fig2_file = 'Reg_tool_figure.fig';
fig2 = openfig(fig2_file,'reuse');
optional_uicontrols = { ...
%     'Apply_radiobutton',    'Value'; ...
%     'Frame_Rate_edit',      'String'; ...
%     'Make_Avi_checkbox',    'Value'; ...
%     'Make_Mat_checkbox',    'Value'; ...
%     'Show_Frames_checkbox', 'Value'; ...
                   };
set(SP,'Userdata',{fig2, fig2_file, optional_uicontrols});

% Generate a structure of handles to pass to callbacks, and store it. 
handlesReg = guihandles(fig2)

close_str = [ 'hNewButton = findobj(''Tag'', ''figRegTool'');' ...
        ' if strcmp(get(hNewButton, ''Type''), ''uitoggletool''),'....
        ' set(hNewButton, ''State'', ''off'' );' ...
        ' else,  ' ...
        ' Reg_tool(''Deactivate_Reg_Tool'',hNewButton);'...
        ' set(hNewButton, ''Value'', 0);',...
        ' end;',...
		' clear hNewButton;'];

set(fig2, 'Name', 'Image Registration Tool',...
    'closerequestfcn', close_str);

% Record and store previous WBDF etc to restore state after PZ is done. 
old_WBDF = get(fig, 'WindowButtonDownFcn');
old_WBMF = get(fig, 'WindowButtonMotionFcn');
old_WBUF = get(fig, 'WindowButtonUpFcn');
old_UserData = get(fig, 'UserData');
old_CRF = get(fig, 'Closerequestfcn');

% Store initial state of all axes in current figure for reset
h_all_axes = flipud(findobj(fig,'Type','Axes'));
h_axes = h_all_axes(1);

for i = 1:length(h_all_axes)
	h_all_ims(i) = findobj(h_all_axes(i), 'type', 'image');
end;
set(h_all_ims, 'ButtonDownFcn', 'Reg_tool(''Set_Current_Axes'')');
set(h_all_axes,'Nextplot', 'Add');
set(0,'currentfigure', fig);

handlesReg.h_Axes = h_all_axes';
handlesReg.h_Images = h_all_ims;
handlesReg.myyellow = [ 1 0.95 0];
handlesReg.myred = [1 0 0 ];
Disable(handlesReg.Register_pushbutton);

visibility = 'On' ;
textFontSize = 20;
figUnits = get(fig,'Units');
set(fig, 'Units', 'inches');
figSize = get(fig, 'position');
reffigSize = 8;   % 8 inch figure gets 20 pt font
textFontSize = textFontSize * figSize(3) / reffigSize;
set(fig, 'Units', figUnits);

for i = 1:length(h_all_axes)
	X = get(h_all_axes(i), 'xlim');
	Y = get(h_all_axes(i), 'ylim');
	set(fig, 'CurrentAxes', h_all_axes(i));
	htFrameNumbers(i) = text(X(2)*0.98, Y(2), num2str(getappdata(h_all_axes(i), 'CurrentImage')) ,...
		'Fontsize', textFontSize, 'color', handlesReg.myyellow, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'visible', visibility);

end;

set(fig, 'CurrentAxes', h_axes);
handlesReg.CurrentAxes = h_axes;
set(0,'currentfigure', fig2);
handlesReg.ParentFigure = fig;
handlesReg.htFrameNumbers = htFrameNumbers;
set(handlesReg.Frame_Value_edit, 'String', getappdata(h_axes,'CurrentImage'));	

% default values
handlesReg.Dimension = 2;
handlesReg.Scope_Selection = 'Time';   % vs 'Space'
handlesReg.Axes_Selection  = 'Single'; % vs 'All'
handlesReg.Method_Selection = 'Translation'; % vs 'Rotation' or 'Affine'

% create fields for the referencem ROIs to be draw
handlesReg.h_ROI = [];
handlesReg.ROI_mask = [];
handlesReg.ROI_coordinates.X = [];
handlesReg.ROI_coordinates.Y = [];

% set the radiobutton userdata (shortcuts)
set(handlesReg.Dim_2D_radiobutton, 'Userdata', handlesReg.Dim_3D_radiobutton);
set(handlesReg.Dim_3D_radiobutton, 'Userdata', handlesReg.Dim_2D_radiobutton);

% Check to see if the temporal dimension exists for the data
if isempty(getappdata(handlesReg.CurrentAxes, 'ImageData'))
	% current images do not have hidden dimension data
	% therefore disable 3D registrations and only allow 2D registrations vs
	% vs all axes
	set(handlesReg.Dim_3D_radiobutton, 'Userdata', [], 'Enable', 'Off');
	set(handlesReg.Dim_Select_Axes_popupmenu,          'Enable', 'off','Value',2);
	set(handlesReg.Dim_Select_Scope_popupmenu,        'Enable', 'off', 'Value', 2);
	handlesReg.Axes_Selection = 'Fixed_Single';
	handlesReg.Scope_Selection= 'Fixed_Space'; 
	handlesReg.Dimension      = 2;
end;

if length(handlesReg.h_Axes)==1
	% only one Axes given so no 3D registration possible
	% and only single registration vs time possible
	set(handlesReg.Dim_3D_radiobutton, 'Userdata', [], 'Enable', 'Off');
	set(handlesReg.Dim_Select_Axes_popupmenu,          'Enable', 'off','Value', 2);
	set(handlesReg.Dim_Select_Scope_popupmenu,        'Enable', 'off', 'Value', 1);
	handlesReg.Axes_Selection = 'Fixed_Single';
	handlesReg.Scope_Selection= 'Fixed_Time'; 
	handlesReg.Dimension      = 2;
end
guidata(fig2,handlesReg);

% update the frame numebrs
Set_Current_Axes(h_axes);

% Draw faster and without flashes
set(fig, 'Closerequestfcn', [ old_CRF , ',Reg_tool(''Close_Parent_Figure'');']);
set(fig, 'Renderer', 'zbuffer');
set(0, 'ShowHiddenHandles', 'On', 'CurrentFigure', fig);
set(h_all_axes,'Drawmode', 'Fast');

% store the figure's old infor within the fig's own userdata
set(fig, 'UserData', {fig2, old_WBDF, old_WBMF, old_WBUF, old_UserData,old_CRF, ...
		old_ToolEnables, old_ToolHandles, old_ToolStates });
set(fig, 'WindowButtonMotionFcn', '');  % entry function sets the WBMF


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Deactivate_Reg_Tool(varargin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
if nargin ==0
    set(0, 'ShowHiddenHandles', 'On');    
    hNewButton = gcbo;
    set(findobj('Tag', 'menuRegTool'),'checked', 'Off');
else
    hNewButton = varargin{1};
end;
    
% Reactivate other buttons
fig = get(hNewButton, 'Parent');
if ~strcmp(get(fig, 'Type'), 'figure'),
    fig = get(fig, 'Parent');
end

hToolbar = findall(fig, 'type', 'uitoolbar');
if ~isempty(hToolbar)    hToolbar_Children = get(hToolbar, 'Children');
    set(findobj(hToolbar_Children,'Tag', 'figToolRotate3D'),'Enable', 'On');
    set(findobj(hToolbar_Children,'Tag', 'figToolZoomOut'),'Enable', 'On');
    set(findobj(hToolbar_Children,'Tag', 'figToolZoomIn'),'Enable', 'On');
end;

% Restore old BDFs
old_info= get(fig,'UserData');
set(fig, 'WindowButtonDownFcn', old_info{2});
set(fig, 'WindowButtonUpFcn', old_info{3});
set(fig, 'WindowButtonMotionFcn', old_info{4});

% Restore old Pointer and UserData
set(fig, 'UserData', old_info{5});
set(fig, 'CloseRequestFcn', old_info{6});
old_ToolEnables  = old_info{7};
old_ToolHandles = old_info{8};
old_ToolStates  = old_info{9};

fig2 = old_info{1};

handlesReg = guidata(fig2);
delete(handlesReg.htFrameNumbers);
delete(handlesReg.h_ROI);

for i = 1:length(handlesReg.h_Images)
	set(handlesReg.h_Images(i), 'ButtonDownFcn', '');
end;

for i = 1:length(old_ToolHandles)
	try
		set(old_ToolHandles(i), 'Enable', old_ToolEnables{i}, 'State', old_ToolStates{i});
	end;
end;

%disable save_prefs tool button
SP = findobj(hToolbar_Children, 'Tag', 'figSavePrefsTool');
set(SP,'Enable','Off');

set(0, 'ShowHiddenHandles', 'Off');
try
    set(fig2, 'CloseRequestFcn', 'closereq'); 
    close(fig2); 
catch
	delete(fig2);
end;    


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Set_Current_Axes(currentaxes);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
if ~exist('currentaxes', 'var'), currentaxes=gca; end;
hR = guidata(findobj('Tag', 'Reg_figure'));
hR.CurrentAxes = currentaxes;
axes_index = find(hR.h_Axes'==hR.CurrentAxes);
set(hR.Axes_Value_edit, 'string',  num2str(axes_index));
scope = get(hR.Dim_Select_Scope_popupmenu, 'Value');
TIME = 1; SPACE = 2;

if hR.Dimension == 2
	% 2D - set the current axes to red, all others to yellow
	set(hR.htFrameNumbers, 'Color',  hR.myyellow);
	set(hR.htFrameNumbers(axes_index),'Color', hR.myred);
else
	% 3D - set all axes to red if using vs. time
	% or set current axes to red if using vs. space
	if scope==TIME
		set(hR.htFrameNumbers,'Color', hR.myred);
	else % SPACE		
		set(hR.htFrameNumbers, 'Color',  hR.myyellow);
		set(hR.htFrameNumbers(axes_index),'Color', hR.myred);
	end;
end;
Set_Reference_Text_Colors(hR);
guidata(hR.Reg_figure, hR);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Set_Reference_Text_Colors(hR);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function to set the colors of reference text appropiately
% Effectively, if doing a 3D registration, vs Time, then 
% All the text axes labels should be red (denoting reference)
% Otherwise, only the current axes should be red.
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
if (hR.Dimension==3) & (strfind(hR.Scope_Selection,'Time'))
	% special case - all the images displayed make up a reference volume
	set(hR.htFrameNumbers, 'Color',  hR.myred);
else
	set(hR.htFrameNumbers, 'Color',  hR.myyellow);
	set(hR.htFrameNumbers(find(hR.h_Axes'==hR.CurrentAxes)),'Color', hR.myred);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Select_Axes;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to select whether, if performing 2D registration, the
% registration is performed only on the selected axes, or repeatedly 
% on all axes
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'));
if get(hR.Dim_Select_Axes_popupmenu, 'Value')==1
	hR.Axes_Selection='Single';
else
	hR.Axes_Selection='All';
end;
Set_Reference_Text_Colors(hR);
guidata(hR.Reg_figure, hR);	

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Select_Dimension(h_radiobutton);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function callback to the choosing of the registration dimension.
% Can always do 2D registrations, but can only do 3D registration if there
% is a temporal dimension to the data. 
% If 2D, then either doing either a 2D registration within each axes (maybe
% multiple times) or axes-to-axes (maybe mutlple times if 3rd dim
% available). If doing a 3D registration, treating all 
% axes as a 3D volume and the temporal dimension as different version of the 
% volume to be registered.
% If scope is vs space, then doing either a 2D registration of the current
% images vs all other axes (maybe multiple times), or doing a 3D
% registration, treating the temporal dimension as a spatial dimension and
% all the images within one axes as a 3D volume
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;

value = get(h_radiobutton, 'Value');
set(get(h_radiobutton,'Userdata'), 'Value', ~value);
hR = guidata(findobj('Tag', 'Reg_figure'));

if (strcmp(get(h_radiobutton, 'Tag'), 'Dim_2D_radiobutton') & value) | ...
		(strcmp(get(h_radiobutton, 'Tag'), 'Dim_3D_radiobutton') & ~value)
	hR.Dimension = 2;
	if isempty(strfind(hR.Axes_Selection, 'Fixed'));
		Enable(hR.Dim_Select_Axes_popupmenu);
	end;
else 
	hR.Dimension = 3;
	set(hR.Dim_Select_Axes_popupmenu, 'Value', 1);
	hR.Axes_Selection = 'Single';
	Disable(hR.Dim_Select_Axes_popupmenu);
end;
Set_Reference_Text_Colors(hR);
guidata(hR.Reg_figure, hR);	


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Select_Scope;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function callback to the choosing of a registration scope
% If scope is vs time, then doing either a 2D registration within each axes
% (maybe multiple times) vs time or doing a 3D registration, treating all 
% axes as a 3D volume and the temporal dimension as different version of the 
% volume to be registered.
% If scope is vs space, then doing either a 2D registration of the current
% images vs all other axes (maybe multiple times), or doing a 3D
% registration, treating the temporal dimension as a spatial dimension and
% all the images within one axes as a 3D volume
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'));
value = get(hR.Dim_Select_Scope_popupmenu, 'Value');
if value == 1 % Vs. Time
	hR.Scope_Selection = 'Time';
else 	      % Vs. Space
	hR.Scope_Selection = 'Space';
end;
Set_Reference_Text_Colors(hR);
guidata(hR.Reg_figure, hR);	

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Select_Method;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function callback to the choosing of registration method
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'));
value = get(hR.Method_popupmenu, 'Value');
method = get(hR.Method_popupmenu, 'String');
hR.Method_Selection = method{value}
guidata(hR.Reg_figure, hR);	


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Start_Registration;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function callback for registering images 

% to do:
%  2d  vs space
% all
% 3d
% save data
% axis size for new fig
% help
% improve plot fit
% other params...?
% copy - paste rois
% draw tool bugs  - gray out tool, sort

global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'));
registration_method = get(hR.Method_popupmenu, 'String');
registration_method = deblank(registration_method{ get(hR.Method_popupmenu, 'Value'),:});

% Extract the parameter info
create_new_figure=get(hR.Create_New_Figure_checkbox,'value');
save_data=get(hR.Save_Data_checkbox,    'value');
plot_fit =get(hR.Plot_Fit_Data_checkbox,'value');

% define the success flag
success=1;

% Extract image data for all cases; pare it down and reshape it
% to match current applications
[I, xlims, ylims, clims, position, h_axes_grid]=getimagedata(hR.ParentFigure);
fig_position = get(hR.ParentFigure, 'Position');

if ~isa(I,'double'), I=double(I); end
	

% Pare down data if doing single repetitions
if hR.Dimension==2

	if strfind(hR.Scope_Selection,'Time')
		current_frame = str2num(get(hR.Frame_Value_edit,'String'));
		if     strfind(hR.Axes_Selection, 'Single'), 
			ax = hR.CurrentAxes; 
		elseif strfind(hR.Axes_Selection, 'All'),    
			ax = hR.h_Axes;
		end;
		% pare down the image matrix
		for i = 1:length(ax)
			[ax_i(i), ax_j(i)] = find(h_axes_grid==ax(i))
		end;
		ax_ind = sub2ind(size(h_axes_grid), ax_i,ax_j);
		I = I(:,:,:,ax_ind);			

		% initialize the reference frame info		
		sizeI = size(I);
		reference_frame = zeros([sizeI(1:2), length(ax)]);
		refmask         = zeros([sizeI(1:2), length(ax)]);
		% fill out the reference masks for each repetition
		for i = 1:length(ax)
			reference_frame(:,:,i) = I(:,:,current_frame,i);
			refmask(:,:,i)         = hR.ROI_mask{find(hR.h_Axes==ax(i))};
		end;
		
		if ~isa(reference_frame,'double'), reference_frame=double(reference_frame); end;
		if ~isa(refmask,'double'),         refmask=double(refmask);                 end;
		% repeat registration over all axes to be registered (independently)
		Ireg = zeros(size(I));
		for rept = 1:length(ax)
			%                                                          input       reference image,      ,input mask, reference mask, method 
			try, 	[Ireg(:,:,:,rept),       params{i}] = imregister2d(I(:,:,:,rept), reference_frame(:,:,rept), [],        refmask(:,:,rept), registration_method);
			catch    Ireg(:,:,:,rept) = NaN; params{i}=[]; success=0;
			end	
		end;
						
	elseif strfind(hR.Scope_Selection,'Space')
		
		if     strfind(hR.Axes_Selection, 'Single'), 
			current_frames = str2num(get(hR.Frame_Value_edit,'String'));
		elseif strfind(hR.Axes_Selection, 'All'),    
			current_frames = 1:size(I,3); 
		end;
		% switch the data around
		I = permute(I,[1 2 4 3]);
		I = squeeze(I(:,:,:,current_frames));
		
		sizeI = size(I);
		reference_frame = zeros([sizeI(1:2), length(current_frames)]);
		refmask         = zeros([sizeI(1:2), length(current_frames)]);
		
		for i = 1:length(current_frames)
			reference_frame(:,:,i)      = I(:,:,find(hR.h_Axes==hR.CurrentAxes),i);
			refmask(:,:,i)        = hR.ROI_mask{current_frames(i)};
		end;
		if ~isa(reference_frame,'double'), reference_frame=double(reference_frame); end;
		
		% repeat registration over all axes to be registered
		% (independently)
		Ireg = zeros(size(I));
		for rept = 1:length(current_frames)
			try, 	[Ireg(:,:,:,rept),     params{i}] = imregister2d(I(:,:,:,i), reference_frame(:,:,i), [], refmask(:,:,i), registration_method);
			catch    Ireg(:,:,:,rept)=NaN; params{i}=[]; success=0;
			end	
		end;
		I    = permute(I,[1 2 4 3]);
		Ireg = permute(Ireg,[1 2 4 3]);	
	
	end
else % hR.Dimension==3

	% permute the data 
	if strfind(hR.Scope_Selection,'Space')
		I = permute(I,[1 2 4 3]);
	end;
	
	
	disp('Unimplemented functionality: 3D Registrations:');
	success=0;
end

if ~success, disp('Error: Registration failed'); return; end

% Successful registration; proceed to the various forms of output for the
% registration tool;
if create_new_figure
	% make sure all the parameters of the original figure are repeated in
	% the new figure that is being created... ie xlims, ylims, clims,
	% position, colormap etc.
	h_new_fig = figure;
	set(h_new_fig, 'Units', 'inches');

	if hR.Dimension==2 & strfind(hR.Scope_Selection,'Time') & strfind(hR.Axes_Selection, 'Single')
		% 2D vs Time, single axes is the only instance when the new figure
		% is not going to be the same size as the original figure. 
		set(h_new_fig, 'Position', [fig_position(1:2), fig_position(3)/size(h_axes_grid,2), fig_position(4)/size(h_axes_grid,1)])
		imagescn(Ireg,[],[], fig_position(3)/size(h_axes_grid,2),3)
		h_new_ax = findobj(h_new_fig, 'type', 'axes');
		set(h_new_ax, 'xlim', xlims{ax_i, ax_j}, 'ylim', ylims{ax_i, ax_j}, 'clim', clims{ax_i, ax_j});
		
	else
		set(h_new_fig, 'Position', fig_position)
		time_dim = 3;
		imagescn(I, [], [size(h_axes_grid,1), size(h_axes_grid,2)], [], time_dim);
		
	end;
	
end

if plot_fit
	old_fits = findobj('Tag', 'RegistrationFitFigure');
	close(old_fits);
	
	for i = 1:length(params)
		h_plotfit = plotfit2d(params{i}) % creates new figure
		set(h_plotfit, 'Tag', 'RegistrationFitFigure');
	end;
end

if save_data
	fname = []; pname = [];
	[fname,pname] = uiputfile('*.mat', 'Save .mat file');
	
	if isequal(fname,0) | isequal(pname,0)
		% User pressed cancel
		return;
	end;
	registration_parameters = params;
	save([pname,fname], 'I', 'Ireg', 'registration_parameters', 'registration_method' );
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Create_Reference;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function callback for the creation of the reference mask or reference
% volume for 2D or 3D registration. Several possigle ROI types are
% available, including Rectangle, Ellipse, Freehand, and various complex
% models, including: Complex N - AND, Complex N - OR and Complex N XOR. In
% the Complex N category of ROIs, several ROIs are defined and a single
% mask is generated from all ROIs by the given operation
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'))
Reference_method = get(hR.Mask_Style_popupmenu, 'String');
Reference_method = deblank(Reference_method{ get(hR.Mask_Style_popupmenu, 'Value'),:});
success = 1;

% Extract the Images to be used for reference generation. 
% 2D: if doing 'multiple' registrations, the images Array, I, will have a
%     third dimension. 
% 3D: if doing 3D, I will be composed of either all the images being
%     displayed (vs time) or all the images within one axes (vs space)
if hR.Dimension==2
	if strfind(hR.Scope_Selection,'Time')
		ROI_indexes = zeros([1,length(hR.h_Axes)]);
		if   strfind(hR.Axes_Selection, 'Single'),    
			ax = hR.CurrentAxes;
			ROI_indexes(find(ax==hR.h_Axes)) = 1;
		else %strfind(hR.Axes_Selection, 'Multiple')
			ax = hR.h_Axes;
			ROI_indexes = ones(size(ROI_indexes));
		end;
		for i = 1:length(ax)
			I(:,:,i) = get(hR.h_Images(find(ax(i)==hR.h_Axes)), 'CData');
		end;
	else% strfind(hR.Scope_Selection,'Space')
		I = getappdata(hR.CurrentAxes,'ImageData');
		ROI_indexes = zeros([1,size(I,3)]);
		if strfind(hR.Axes_Selection, 'Single')
			current_frame = str2num(get(hR.Frame_Value_edit,'String'));
			I = I(:,:,current_frame);		
			ROI_indexes(current_frame) = 1;
		else %strfind(hR.Axes_Selection, 'Multiple')
			ROI_indexes = ones([1,size(I,3)]);
		end;		
	end;
	
else % 3D
	% If doing a 3D volume, the reference 'image' is actually a reference
	% 'volume' composed of all the current images displayed, or of all
	% the images in a single axes
	if strfind(hR.Scope_Selection,'Time')
		I = zeros([size(get(hR.h_Images(1), 'CData')), length(hR.h_Axes)]);
		for i = 1:length(hR.h_Axes)
			I(:,:,i) = get(hR.h_Images(i), 'CData');
		end;
	else% hR.Scope=='Space'
		I = getappdata(hR.CurrentAxes,'ImageData');
	end;
	ROI_indexes = ones([1, size(I,3)]);
end;

xlims = get(hR.CurrentAxes, 'xlim');
ylims = get(hR.CurrentAxes, 'ylim');
clims = get(hR.CurrentAxes, 'clim');
cmap =  get(hR.ParentFigure, 'colormap');

switch Reference_method
	case {'Ellipse' , 'Rectangle', 'Freehand'}
		% Repeat Mask generation for each of the images that compose
		% the 3d volume of the 3d reference images or repeat mask
		% generation for each of the 2D refence images. Enclose mask
		% generation in a try-catch statement in case something goes wrong
		% or a Cancel button is hit.

% 		try
			for i = 1:size(I,3)
				t = Draw_tool('New', I(:,:,i), Reference_method, xlims, ylims, clims, cmap); ;
				if isempty(t)
					% FAILED for this current mask (should break here...)
					success=0;
				else
					ROI_info(i) = t;
				end;
			end
% 		catch
% 			disp('Problem generating reference Mask.');
% 			disp('Mask not generated. Please Try again');
% 			success = 0;
% 		end;

        if success
			find(ROI_indexes)
			mask{length(ROI_indexes)} = []
			x{length(ROI_indexes)}    = []
			y{length(ROI_indexes)}    = []
			
			whos
			
			count = 1;
			for i = find(ROI_indexes)
				mask{i}= ROI_info(count).ROI_mask;
				x{i}   = ROI_info(count).ROI_x_coordinates;
				y{i}   = ROI_info(count).ROI_y_coordinates;		
				count = count+1;
			end;
		end;
			
% 	case {'Complex-N AND', 'Complex-N OR', 'Complex-N XOR'}
% 		
% 		defAns = 3;
% 		N = inputdlg('How many sub-ROIs in Complex ROI?', 'Define Number of ROIs for Complex ROI', 1, {num2str(defAns)})
% 		if isempty(N), 	 	
% 			% Hit cancel
% 			success=0; 	
% 		else
% 			N = str2num(cell2mat(N));
% 			if ~isnumeric(N),	success=0; 	
% 			elseif (N<=0), 	    success=0; 
% 			end;
% 		end;
% 		
% 		if success
% 			ROI_info = [];
% 			for i = 1:N
% 				ROI_info(i) = Draw_tool('New', I, 'Freehand', xlims, ylims, clims, cmap, ROI_info);
% 			end;
% 		end;	
% 		
% 			
% 		mask = ROI_info(1).ROI_mask;
% 		if strfind(Reference_method, 'AND')
% 			for i = 2:num_ref_masks
% 				mask = mask & ROI_info(i).ROI_mask;				
% 			end;
% 		elseif strfind(Reference_method, 'XOR')
% 			for i = 2:num_ref_masks
% 				mask = xor(mask,ROI_info(i).ROI_mask);				
% 			end;
% 		else % OR
% 			for i = 2:num_ref_masks
% 				mask = mask | ROI_info(i).ROI_mask;				
% 			end;
% 		end;
end;

if success
	% Delete previous ROI once a new succesful ROI acquisition has taken
	% place. Also disable the tools to generate a reference. Change the
	% function of the Generate reference button to clearing the reference
	% mask and enabling all the other buttons.
	if ~isempty(hR.h_ROI), delete(hR.h_ROI);	end;
	hR.ROI_mask = mask;
	hR.ROI_coordinates.X = x;
	hR.ROI_coordinates.Y = y;		
	Enable(hR.Register_pushbutton);
	Disable([ ...
			hR.Dim_2D_radiobutton, hR.Dim_3D_radiobutton, ...
			hR.Dim_Select_Axes_popupmenu, hR.Dim_Select_Scope_popupmenu, ...
			hR.Min_Axes_pushbutton,hR.Minus_Step_Axes_pushbutton,hR.Plus_Step_Axes_pushbutton,hR.Plus_Limit_pushbutton, hR.Axes_Value_edit, ...
			hR.Min_Frame_pushbutton,hR.Minus_Step_Frame_pushbutton,hR.Plus_Step_Frame_pushbutton,hR.Max_Frame_pushbutton,hR.Frame_Value_edit , ...
			hR.Mask_Style_popupmenu]);
	set(hR.Create_Reference_Mask_pushbutton, 'Callback', 'Reg_tool(''Clear_Reference'');', 'String', 'Clear Reference Mask');
	set(hR.h_Images, 'ButtonDownFcn', '');
	guidata(hR.Reg_figure, hR);
	Draw_Reference_ROI;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Clear_Reference;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'));
set(hR.Create_Reference_Mask_pushbutton, 'Callback', 'Reg_tool(''Create_Reference'');', 'String', 'Create Reference Mask');
set(hR.h_Images, 'ButtonDownFcn', 'Reg_tool(''Set_Current_Axes'')');
% Reset tool functionality
Disable(hR.Register_pushbutton);
Enable([ ...
		hR.Dim_2D_radiobutton, hR.Dim_3D_radiobutton, ...
		hR.Dim_Select_Axes_popupmenu, hR.Dim_Select_Scope_popupmenu, ...
		hR.Min_Axes_pushbutton,hR.Minus_Step_Axes_pushbutton,hR.Plus_Step_Axes_pushbutton,hR.Plus_Limit_pushbutton, hR.Axes_Value_edit,...
		hR.Min_Frame_pushbutton,hR.Minus_Step_Frame_pushbutton,hR.Plus_Step_Frame_pushbutton,hR.Max_Frame_pushbutton, hR.Frame_Value_edit , ...
		hR.Mask_Style_popupmenu]);
if strfind(hR.Axes_Selection, 'Fixed'), Disable(hR.Dim_Select_Axes_popupmenu); end;
if strfind(hR.Scope_Selection, 'Fixed'), Disable(hR.Dim_Select_Scope_popupmenu); end;
if (hR.Dimension==3), Disable(hR.Dim_Select_Axes_popupmenu); end;

% Clear the old ROI
delete(hR.h_ROI);
hR.h_ROI = [];
hR.ROI_coordinates.X = [];
hR.ROI_coordinates.Y = [];
guidata(hR.Reg_figure, hR);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Draw_Reference_ROI;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to draw the returned ROI so that it is visible to the user
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;

hR = guidata(findobj('Tag', 'Reg_figure'));

% Draw the reference ROIs on the different axes 
% This varies depending on which of the 4 registration options are being
% drawn:
%  2D - Single vs. Time or Space: Should draw only one ROI on current axes
%  2D - Multiple vs. Time:        Should draw an ROI on each axes
%  2D - Multiple vs. Space:       Should draw an ROI on each temporal frame. ROI
%                                 should change when the frame is moved
%  3D vs. Time:   Should draw an ROI on each of the axes that represent a
%                 volume
%  3D vs. Space:  Should draw an ROI on each time frame of the reference
%                 axes. ROI should change when the frame is moved.

if hR.Dimension==2
	if strfind(hR.Scope_Selection, 'Time')
 		ax = hR.h_Axes;
		set(0, 'CurrentFigure', hR.ParentFigure);
		for i = 1:length(ax)
			if ~isempty(hR.ROI_coordinates.X{i})
				set(hR.ParentFigure, 'CurrentAxes', ax(i));
				pp(i)= plot(hR.ROI_coordinates.X{i}, hR.ROI_coordinates.Y{i}, 'r-', 'Tag', 'ROIObject');		
			end;
		end;
		hR.h_ROI = pp(find(pp));
	else   %strfind(hR.Scope_Selection, 'Space')
		current_frame = str2num(get(hR.Frame_Value_edit,'String'));
		set(0, 'CurrentFigure', hR.ParentFigure);
		set(hR.ParentFigure, 'CurrentAxes', hR.CurrentAxes);
		% Display the reference ROI
		pp= plot(hR.ROI_coordinates.X{current_frame}, hR.ROI_coordinates.Y{current_frame}, 'r-', 'Tag', 'ROIObject');
		hR.h_ROI = pp(find(pp));		
	end;
	
else % hR.Dimension==3
	disp('Unimplemented Functionality.');
end;
guidata(hR.Reg_figure, hR);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Step_Axes(varargin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'));

% call from buttons
direction = varargin{1};
h_Axes = hR.h_Axes';
% specify single or all axes
current_axes = find(h_Axes== hR.CurrentAxes);
axes_range = [1 length(hR.h_Axes)];

if     (current_axes + direction) > axes_range(2), current_axes = axes_range(1);
elseif (current_axes + direction) < axes_range(1), current_axes = axes_range(2);
else                                               current_axes = current_axes + direction; end;

Set_Current_Axes(h_Axes(current_axes));
figure(hR.Reg_figure);
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Limit_Axes(varargin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'));

% call from buttons
direction = varargin{1};
h_Axes = hR.h_Axes';
if direction == 1
	current_axes = length(h_Axes);
else
	current_axes = 1;
end;
Set_Current_Axes(h_Axes(current_axes));
figure(hR.Reg_figure);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Set_Axes;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'));
current_axes = str2num(get(hR.Axes_Value_edit, 'String'));
h_Axes = hR.h_Axes';
axes_range = [1 length(hR.h_Axes)];
% Error check
if current_axes > axes_range(2), current_axes = axes_range(2); end;
if current_axes < axes_range(1), current_axes = axes_range(1); end;
Set_Current_Axes(h_Axes(current_axes));
figure(hR.Reg_figure);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Step_Frame(varargin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'));

% call from buttons
direction = varargin{1};
CurrentAxes = hR.h_Axes;

for i = 1:length(CurrentAxes)
	current_frame = getappdata(CurrentAxes(i), 'CurrentImage');
	image_range   = getappdata(CurrentAxes(i), 'ImageRange');
	image_data    = getappdata(CurrentAxes(i), 'ImageData');

	if     (current_frame + direction) > image_range(2), current_frame = image_range(1); 
	elseif (current_frame + direction) < image_range(1), current_frame = image_range(2); 
	else                                                 current_frame = current_frame + direction; end;
	
	setappdata(CurrentAxes(i), 'CurrentImage', current_frame);
	set(hR.htFrameNumbers(find(hR.h_Axes == CurrentAxes(i))), 'String', num2str(current_frame));
	set(findobj(CurrentAxes(i), 'Type', 'image'), 'CData', squeeze(image_data(:,:,current_frame)));
	set(hR.Frame_Value_edit, 'String', num2str(current_frame));	
	
	if ~isempty(hR.h_ROI)
		
	end;
	
end;
figure(hR.Reg_figure);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Limit_Frame(varargin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'));

% call from buttons
direction = varargin{1};
CurrentAxes = hR.h_Axes';

for i = 1:length(CurrentAxes)
	image_range   = getappdata(CurrentAxes(i), 'ImageRange');
	image_data    = getappdata(CurrentAxes(i), 'ImageData');

	if     direction ==  1, current_frame = image_range(2);
	elseif direction == -1,	current_frame = image_range(1);
	end;
	
	setappdata(CurrentAxes(i), 'CurrentImage', current_frame);
	set(hR.htFrameNumbers(find(hR.h_Axes == CurrentAxes(i))), 'String', num2str(current_frame));
	set(findobj(CurrentAxes(i), 'Type', 'image'), 'CData', squeeze(image_data(:,:,current_frame)));
	set(hR.Frame_Value_edit, 'String', num2str(current_frame));	
end;
figure(hR.Reg_figure);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Set_Frame;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'));
current_frame = str2num(get(hR.Frame_Value_edit, 'String'));
CurrentAxes = hR.h_Axes';

for i = 1:length(CurrentAxes)
	image_range   = getappdata(CurrentAxes(i), 'ImageRange');
	image_data    = getappdata(CurrentAxes(i), 'ImageData');
	% Error check
	if current_frame > image_range(2), current_frame = image_range(2); end;
	if current_frame < image_range(1), current_frame = image_range(1); end;
	setappdata( CurrentAxes(i), 'CurrentImage', current_frame);
	set(hR.htFrameNumbers(find(CurrentAxes == CurrentAxes(i))), 'String', num2str(current_frame));
	set(findobj(CurrentAxes(i), 'Type', 'image'), 'CData', squeeze(image_data(:,:,current_frame)));
end;
figure(hR.Reg_figure);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Menu_Reg_Tool;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;

hNewMenu = gcbo;
checked=  umtoggle(hNewMenu);
hNewButton = get(hNewMenu, 'userdata');

if ~checked
    % turn off button
    %Deactivate_Pan_Zoom(hNewButton);
    set(hNewMenu, 'Checked', 'off');
    set(hNewButton, 'State', 'off' );
else
    %Activate_Pan_Zoom(hNewButton);
    set(hNewMenu, 'Checked', 'on');
    set(hNewButton, 'State', 'on' );
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Close_Parent_Figure;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to make sure that if parent figure is closed, 
% the ROI info and ROI Tool are closed too.
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
delete(findobj('Tag', 'Reg_figure')); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [I, xlim, ylim, clim, position, h_axes_grid]=getimagedata(figurehandle);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [I, xlim, ylim, clim, position]=getimagedata(figurehandle);
% function to get the image data from a figure created by imagescn.m
% 
% usage:
% 	[I, xlim, ylim, clim, position]=getimagedata; % gets current figure window
% 	[I, xlim, ylim, clim, position]=getimagedata(figurehandle);
%   Modified: xlim,ylim, clim, & ax_position are cell arrays of size(x,y)
%     where x & y are the row and column sizes of the axes on 
% 
%
%      ***************************************
%      *  Peter Kellman  (kellman@nih.gov)   *
%      *  Laboratory for Cardiac Energetics  *
%      *  NIH NHLBI                          *
%      ***************************************
%
%      Modified by D.Herzka, (herzkad@nih.gov)
%      Added cell array output & grid axes sorting
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;
hR = guidata(findobj('Tag', 'Reg_figure'));

if nargin<1
    figurehandle=gcf;
end

h_axes_grid = Sort_Axes_handles(hR.h_Axes);
if isappdata(h_axes_grid(1,1),'ImageData') % check if there is a "temporal" dimension
	appdata = 1;	
	t = getappdata(h_axes_grid(1,1),'ImageData');
else
	appdata =0;
	t=get(findobj(h_axes_grid(1,1),'type','image'),'cdata');
end

I = zeros([size(t), size(h_axes_grid)]);
clear t;
for i=1:size(h_axes_grid,1)
	for j=1:size(h_axes_grid,2)
		if appdata
			I(:,:,:,i,j)=getappdata( h_axes_grid(i,j),'ImageData');
		else
			I(:,:,i,j)  =get(findobj(h_axes_grid(i,j),'type','image'),'cdata');
		end;
		xlim{i,j}=get(h_axes_grid(i,j),'xlim');
		ylim{i,j}=get(h_axes_grid(i,j),'ylim');
		clim{i,j}=get(h_axes_grid(i,j),'clim');
		position{i,j}=get(h_axes_grid(i,j),'position');
	end;
end   



return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function h_axes = Sort_Axes_handles(h_all_axes);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% receives a column vector of handles and 
% returns a matrix depending onthe position of 
% each image on the screen
global DB; if DB disp(['Reg_Tool:', Get_Current_Function]); end;

% assumes axes are in a grid pattern
% so sort them by position on the figure
for i = 1:length(h_all_axes);
    position(i,:) = get(h_all_axes(i),'Position');
end;

% calculate the different number of row values and the different number of column values to 
% set the matrix size
[hist_pos_y, bins_y] = hist(position(:,1));
[hist_pos_x, bins_x] = hist(position(:,2));
hy = sum(hist_pos_y>0);
hx = sum(hist_pos_x>0) ;
[hist_pos_y, bins_y] = hist(position(:,1), hy);
[hist_pos_x, bins_x] = hist(position(:,2), hx);

%hist_pos_x = fliplr(hist_pos_x);
h_axes = zeros(hx,hy);

sorted_positions = sortrows([position, h_all_axes'], [2,1]); % sort x, then y
counter = 0;
for i =1:length(hist_pos_x)
    for j = 1:hist_pos_x(i)
        sorted_positions(j+counter,6) = hx - i + 1;
    end;
    counter = counter + hist_pos_x(i);  
end;

sorted_positions = sortrows(sorted_positions,[1,2]); % sort y, then x
counter = 0;
for i =1:length(hist_pos_y)
    for j = 1:hist_pos_y(i)
        sorted_positions(j+counter,7) = i;
    end;
    counter = counter + hist_pos_y(i);
end;

for i = 1:size(sorted_positions,1)
    h_axes(round(sorted_positions(i,6)),round(sorted_positions(i,7))) = sorted_positions(i,5);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Enable(h);
set(h, 'Enable', 'On');
function Disable(h);
set(h, 'Enable', 'Off');
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function  func_name = Get_Current_Function;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Debug function - returns current function name
% 3-line version returns only the current callback
% 7-line version returns the recursive tree
x = dbstack;
x = x(2).name;
func_name = x(findstr('(', x)+1:findstr(')', x)-1);

% func_name = [];
% for i = length(x):-1:2
% 	if ~isempty(findstr('(', x(i).name))
% 		func_name = [func_name, x(i).name(findstr('(', x(i).name)+1:findstr(')', x(i).name)-1), ' : '];
% 	end;
% end;
% func_name = func_name(1:end-3);


%regdata = getappdata(gca, 'ImageData');
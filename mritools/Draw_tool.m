function ROI_info = Draw_tool(varargin);
% function Draw_tool(varargin);
% Function to create ROIs on images.
%
% Usage: ROI_mask = Draw_tool('New', I, ROI_type, [xlims], [ylims],[clims], [cmap], old_rois)
%
% Inputs:
%  'New' - fixed and necessary input
%  I = image to be used for ROIs           [Required]
%  ROI_type: string denoting type of ROI:  [Required]
%      'Rectangle' (uses rbbox)
%      'Ellipse' 
%      'Freehand'
%  xlims - xlimits of image (defaults to size(I,2) [Optional]
%  ylims - ylimits of image (defaults to size(I,1) [Optional]
%  clims - climits of image (defaults to [0, max(I(:))] [Optional]
%  cmap  - colormap of image (defaults to gray(128)] [Optional] 
%  old_rois - structure of coordinates of other ROIs to be displayed during
%             drawing process. Structure should contain two fields 
%             ROI_x_coordiantes & ROI_y_coordinates.
%
% Outputs:
% Structure ROI_info, with the following fields:
%   ROI_mask: Mask of size(I), where 1=inside ROI, 0 = outside. Borders are included 
%   ROI_x_values: x-coordinates of ROI (unsplined)
%   ROI_y_values: y-coordinates of ROI (unsplined)
%   ROI_x_spline_values: x-coordinates of ROI if spline used
%   ROI_y_spline_values: y-coordinates of ROI if spline used
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

if isempty(varargin) 
   Action = 'Activate_Draw_Tool';
   Image_handles = [];
elseif ischar(varargin{1})   % sent in an action
	Action = varargin{1};  
else                     % sent in unidentified material
	Action = 'Exit';
end

% set or clear the global debug flag
%%global DB; DB = 1;

switch Action	
case 'New'
	Activate_Draw_Tool(varargin{2:end});
 	fig = findobj('Tag', 'ROI_Draw_figure');
 	uiwait(fig);
 	handlesDraw = guidata(fig);
	ROI_info = handlesDraw.ROI_info;
	Close_ROI_Draw_figure;
%ROI_info = [];
	

case 'ROI_Angle_Adjust_Entry', ROI_Angle_Adjust_Entry; % Entry
case 'ROI_Angle_Adjust',       ROI_Angle_Adjust; % Cycle
case 'ROI_Angle_Adjust_Exit',  set(gcf, 'WindowButtonMotionFcn', ' ','WindowButtonUpFcn', ' '); ROI_Angle_Adjust_Exit;    
    
case 'ROI_Size_Adjust_Entry', ROI_Size_Adjust_Entry;
case 'ROI_Size_Adjust',       ROI_Size_Adjust;
case 'ROI_Size_Adjust_Exit',  set(gcf, 'WindowButtonMotionFcn', ' ','WindowButtonUpFcn', ' '); ROI_Size_Adjust_Exit; % Exit

case 'ROI_Pos_Adjust_Entry', ROI_Pos_Adjust_Entry(varargin{2});
case 'ROI_Pos_Adjust',       ROI_Pos_Adjust(varargin{2});
case 'ROI_Pos_Adjust_Exit',  set(gcf, 'WindowButtonMotionFcn', ' ','WindowButtonUpFcn', ' '); ROI_Pos_Adjust_Exit;  
		
case 'ROI_Draw_Entry',       ROI_Draw_Entry(varargin{2:end});
case 'ROI_Draw',             ROI_Draw;
case 'ROI_Draw_Exit',        set(gcf, 'WindowButtonMotionFcn', ' ','WindowButtonUpFcn', ' '); ROI_Draw_Exit;    
	
case 'ROI_Point_Move_Entry', ROI_Point_Move_Entry(varargin{2:end});;
case 'ROI_Point_Move',       ROI_Point_Move(varargin{2:end});
case 'ROI_Point_Move_All',   ROI_Point_Move_All(varargin{2:end});		
case 'ROI_Point_Move_Exit',    set(gcf, 'WindowButtonMotionFcn', ' ','WindowButtonUpFcn', ' '); ROI_Point_Move_Exit(varargin{2:end});
	
case 'ROI_Push_Point_Entry', ROI_Push_Point_Entry(varargin{2:end});;
case 'ROI_Push_Point',       ROI_Push_Point(varargin{2:end});
case 'ROI_Push_Point_Exit',  set(gcf, 'WindowButtonMotionFcn', ' ','WindowButtonUpFcn', ' ');  ROI_Push_Point_Exit(varargin{2:end});

case 'Draw_ROI_Finish'
	Draw_ROI_Finish(varargin{2:end});
case 'Draw_Ellipse_Finish'
	Draw_Ellipse_Finish(varargin{2:end});

case 'Draw_Spline'
	Draw_Spline;
case 'Draw_Clear_ROI'
	Draw_Clear_ROI(varargin{2:end});
case 'Toggle_Draw_Mode'
	Toggle_Draw_Mode(varargin{2:end});
case 'ROI_Push_Move_Cursor'
	ROI_Push_Move_Cursor;
case 'Toggle_Spline_Poly'
	Toggle_Spline_Poly(varargin{2:end});
case 'Show_Pixels'
	Show_Pixels;
case 'Draw_Change_Edit_Value'
	Draw_Change_Edit_Value(varargin{2:end});
case 'Draw_Push_Radius'
	Draw_Push_Radius(varargin{2:end});
case 'Draw_Change_Radius_Value'
	Draw_Change_Radius_Value(varargin{2:end});

case 'Exit';
    disp('Unknown Input Argument');
    
otherwise
    disp(['Draw_Tool:Unimplemented Functionality: ', Action]);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Activate_Draw_Tool(varargin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

if nargin< 2
	disp('Error: Not Enough input arguments! Need at least an image and an ROI type');
	return;
end;
I        = varargin{1};
ROI_type = varargin{2};
if nargin < 3, 	xlims = [0.5 size(I,1)+0.5]; else xlims = varargin{3}; end;
if nargin < 4, 	ylims = [0.5 size(I,2)+0.5]; else ylims = varargin{4}; end;
if nargin < 5, 	clims = [0 max(I(:))];       else clims = varargin{5}; end;
if nargin < 6, 	cmap  = gray(128);           else cmap  = varargin{6}; end;
if nargin < 7,  old_rois = [];               else old_rois = varargin{7}; end; 

if isempty(xlims), xlims = [0.5 size(I,1)+0.5]; end;
if isempty(ylims), ylims = [0.5 size(I,2)+0.5]; end;
if isempty(clims), clims = [0 max(I(:))];       end;
if isempty(cmap),  cmap  = gray(128);           end;
	


% define cursors
plus_cursor   = zeros(16,16)*NaN;
circ_cursor   = plus_cursor;
square_cursor = plus_cursor;
ex_button     = plus_cursor;

pw = [  8    24    40    56    72   113   114   115   116   117  123   124   125   126   127  168   184   200   216   232];
pb = [  7     9    23    25    39   41    55    57    71    73   97    98    99   100   101 ...
		107   108   109   110   111  129   130   131   132   133  139   140   141   142   143 ...
		167   169   183   185   199  201   215   217   231   233];
cw = [ ...% inner circle  
		23    24    25    37    38 	42    43    52    60    67 	77    83    93    98   110 ...
		114   120   126   130   142   147   157   163   173   180 	188   197   198   202   203 ...
		215   216   217];
cb = [ ... % outer circle
		7     8     9    21    22  	26    27    36    44    51  61    66    78    82    94  ...
		97   111   113   127   129  143   146   158   162   174  179   189   196   204   213  ...
		214   218   219   231   232   233];
ew = [ 1    15    18    30    35    45    52    60    69    75 ...
		86    90   103   105   120   135   137   150   154   165 ...
		171   180   188   195   205   210   222   225   239 ];
eb = [ 2    14    17    19    29    31    34    36    44    46  ...
		51    53    59    61    68    70    74    76    85    87 ...
		89    91   102   104   106   119   121   134  136   138  ...
		149   151   153   155   164   166   170   172   179   181 ...
		187   189   194   196   204   206   209   211   221   223   226   238];


% open figure, copy current axes parameters, and draw ROIs if editing
fig = openfig('ROI_draw_figure', 'new');
handlesDraw = guihandles(fig);
handlesDraw.Parent_figure = fig;
handlesDraw.ButtonDownStrings{1}  = ['Draw_tool(''ROI_Draw_Entry'',' num2str(fig), ');' ];
handlesDraw.ButtonDownStrings{2}  = ['Draw_tool(''ROI_Push_Point_Entry'',' num2str(fig), ');' ];

plus_cursor(pw) = 2; plus_cursor(pb) = 1;
circ_cursor(cw) = 2; circ_cursor(cb) = 1; 
ex_button(ew) = 1;   ex_button(eb) = 1;
handlesDraw.cursors.plus_cursor   = plus_cursor;
handlesDraw.cursors.circ_cursor   = circ_cursor;

plus_cursor = plus_cursor - 1;  plus_cursor(isnan(plus_cursor)) = 0.8;
circ_cursor = circ_cursor - 1;  circ_cursor(isnan(circ_cursor)) = 0.8;
ex_button     = ex_button - 1;   ex_button(isnan(ex_button))    = 0.8;
set(handlesDraw.Draw_pushbutton,  'CData', repmat(plus_cursor  , [ 1 1 3]));
set(handlesDraw.Push_pushbutton,  'CData', repmat(circ_cursor  , [ 1 1 3]));
set(handlesDraw.Clear_Points_pushbutton,'CData', repmat(ex_button,    [ 1 1 3]));

% initialize other fields used in itearative commands
handlesDraw.Spline = [];
handlesDraw.Points  = [];
handlesDraw.NewPoints = [];
handlesDraw.h_spline = [];
handlesDraw.h_points = [];
handlesDraw.h_newpoints = [];
handlesDraw.h_pixels = [];
handlesDraw.h_circle = [];

handlesDraw.ROI_info.ROI_type   = ROI_type;
handlesDraw.Show_Pixels         = get(handlesDraw.Show_Pixels_checkbox, 'Value');
handlesDraw.Close_ROI           = get(handlesDraw.Close_ROI_checkbox,   'Value');
handlesDraw.Point_Drop_Spacing  = str2num(get(handlesDraw.Point_Drop_edit, 'String'));


set(handlesDraw.Spline_checkbox, 'Userdata', handlesDraw.Polygon_checkbox);
set(handlesDraw.Polygon_checkbox, 'Userdata', handlesDraw.Spline_checkbox);
set(handlesDraw.Temp_Spline_axes, 'Tag', 'Temp_Spline_axes');

% find the axis values and image values of the current axes
handlesDraw.h_Image = imagesc(I);
h_axes = handlesDraw.Temp_Spline_axes;
axis equal; axis off;
hold on;
set(handlesDraw.Temp_Spline_axes,'xlim', xlims,'ylim', ylims, 'clim', clims);
colormap(cmap);

% display any old ROI
for i = 1:length(old_rois)
	plot(old_rois(i).ROI_x_coordinates, old_rois(i).ROI_y_coordinates, 'b-', 'linewidth',2);
end;

% prepare constants for drawing push-cursor
size_x = xlims(2) - xlims(1);
size_y = ylims(2) - ylims(1);
handlesDraw.circle_size = min([size_x, size_y]);
handlesDraw.circle_ratio = str2num(get(handlesDraw.Push_Radius_edit, 'String'))/100;
handlesDraw.Color        = 'r';

handlesDraw.Instruction1_set = strvcat( ...
	'Drag to draw a rectangle. ', ...                                   % Rectangle
	'Use interactive controls to adjust ellipse size. ', ...            % Ellipse
	'Drag to draw ROI points. Individual points can be dragged. .' ...  % Freehand
	);
handlesDraw.Instruction2_set = strvcat( ...
	'Ending drag will take you into Draw mode.',...
	'Click either Draw or Edit buttons for individual point control.', ...
	'Right-click to delete a point.' ...
	);

% store all this info
guidata(handlesDraw.ROI_Draw_figure, handlesDraw);

% Current prep is for freehand
% Need different preps for recangle (rbbox), ellipses (draw a circle)

switch handlesDraw.ROI_info.ROI_type
	case 'Rectangle'
		% Use Rbbox to draw a square but then return the user to standard
		% draw and edit mode. See rbbox example
		set(handlesDraw.Clear_Points_pushbutton, 'Callback', 'Draw_tool(''Draw_Clear_ROI'',''Rectangle'');');
		Draw_Rectangle;
	case 'Ellipse'
		set(handlesDraw.Clear_Points_pushbutton, 'Callback', 'Draw_tool(''Draw_Clear_ROI'',''Ellipse'');');
		Draw_Ellipse;
	otherwise % 'Freehand'
		% call defaults to Freehand if name is not recognized
		% Sends the tool directly into Drawmode without any intermediate
		% Drawing steps
		set(handlesDraw.Instruction1_text, 'String', deblank(handlesDraw.Instruction1_set(3,:)));
		set(handlesDraw.Instruction2_text, 'String', deblank(handlesDraw.Instruction2_set(3,:)));

		set(handlesDraw.ROI_Draw_figure, ...
			'Tag', 'ROI_Draw_figure', ...
			'Pointer', 'custom', ...
			'PointerShapeCData', handlesDraw.cursors.plus_cursor,...
			'PointerShapeHotSpot', [8 8]);
		set(handlesDraw.h_Image, 'ButtonDownFcn', handlesDraw.ButtonDownStrings{1});
		
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Draw_Rectangle;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to set drawng mode to Ellipse. Generates a template ellips with
% its interactive objects on the screen. Function can be called repeatedly
% if user presses clear buttons - 
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;
global OLD_POINT;

handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
set(handlesDraw.Spline_checkbox,  'Value',0);
set(handlesDraw.Polygon_checkbox, 'Value',1);
set(handlesDraw.h_Image, 'ButtonDownFcn', '');

k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
set(handlesDraw.Instruction1_text, 'String', deblank(handlesDraw.Instruction1_set(1,:)));
set(handlesDraw.Instruction2_text, 'String', deblank(handlesDraw.Instruction2_set(1,:)));
drawnow;

finalRect = rbbox;                   % return figure units
set(handlesDraw.Instruction1_text, 'String', deblank(handlesDraw.Instruction1_set(3,:)));
set(handlesDraw.Instruction2_text, 'String', deblank(handlesDraw.Instruction2_set(3,:)));

point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];

for i = 1:4
	handlesDraw.NewPoints = [handlesDraw.NewPoints; [x(i), y(i)] ];
	pp = plot(x(i),y(i), 'r.', 'Userdata', [x(i), y(i)], 'Tag', 'DrawObjectPoint');
	set(pp, 'ButtonDownFcn', ['Draw_tool(''ROI_Point_Move_Entry'',' , num2str(get(handlesDraw.Temp_Spline_axes, 'Parent')) , ',''' , num2str(pp,20), ''');'], ...
		'MarkerEdgeColor', handlesDraw.Color);
	handlesDraw.h_newpoints = [handlesDraw.h_newpoints; pp];
end;
OLD_POINT = [x(end), y(end)];

set(handlesDraw.ROI_Draw_figure, ...
	'Tag', 'ROI_Draw_figure', ...
	'Pointer', 'custom', ...
	'PointerShapeCData', handlesDraw.cursors.plus_cursor,...
	'PointerShapeHotSpot', [8 8]);
set(handlesDraw.h_Image, 'ButtonDownFcn', handlesDraw.ButtonDownStrings{1});
guidata(handlesDraw.ROI_Draw_figure, handlesDraw);
Sort_Points;
Draw_Spline;
Show_Pixels;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Draw_Ellipse;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to set drawng mode to Ellipse. Generates a template ellips with
% its interactive objects on the screen
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
set(handlesDraw.Parent_figure, 'CurrentAxes', handlesDraw.Temp_Spline_axes);
xlim = get(handlesDraw.Temp_Spline_axes, 'xlim');
ylim = get(handlesDraw.Temp_Spline_axes, 'ylim');

center_x = mean(xlim);
center_y = mean(ylim);

percent_size_ROI = 0.1;
size_x = diff(xlim)*percent_size_ROI;
size_y = diff(xlim)*percent_size_ROI;

basic_points = 32;
theta = 0:(360/basic_points):360;
[x,y] = pol2cart(theta*pi/180, repmat(size_x,size(theta,1), size(theta,2)));
alpha = 0 ;

handle_values = Make_ROI_Elements(...
	x + center_x, y + center_y,...
	'r',...
	1,...
	center_x, center_y,...
	center_x - size_x, center_y - size_y, ...
	center_x + size_x, center_y,...
	center_x + size_x, center_y - size_y);

ROI_values = [center_x, center_y, size_x, size_y, alpha];

set(handle_values, 'UserData', [1,1,handle_values, ROI_values ]);

set(handlesDraw.h_Image, 'ButtonDownFcn', '');
set(handlesDraw.Instruction1_text, 'String', deblank(handlesDraw.Instruction1_set(2,:)));				
set(handlesDraw.Instruction2_text, 'String', deblank(handlesDraw.Instruction2_set(2,:)));				

% Disable typical pushbuttons until transistion from interactive
% ellipse to standard ROI is made. Make the first button press the
% transition into regular editing mode
set(handlesDraw.Draw_pushbutton,   'Userdata', get(handlesDraw.Draw_pushbutton,'Callback'),  'callback', 'Draw_tool(''Draw_Ellipse_Finish'',''Draw'')' );
set(handlesDraw.Push_pushbutton,   'Userdata', get(handlesDraw.Push_pushbutton,'Callback'),  'callback', 'Draw_tool(''Draw_Ellipse_Finish'',''Push'')' );
set(handlesDraw.Done_pushbutton,   'Userdata', get(handlesDraw.Done_pushbutton,'Callback'),  'callback', 'Draw_tool(''Draw_Ellipse_Finish'',''Done'')' );
set(handlesDraw.Cancel_pushbutton, 'Userdata', get(handlesDraw.Cancel_pushbutton,'Callback'),'callback', 'Draw_tool(''Draw_Ellipse_Finish'',''Cancel'')' );

guidata(handlesDraw.ROI_Draw_figure, handlesDraw);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Draw_Ellipse_Finish(Mode);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to respond to the user finishing the interactive portion of the
% elliptical ROIs. 
global OLD_POINT; 


handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));

h_objects = flipud(findobj(handlesDraw.ROI_Draw_figure, 'Tag', 'DrawObjectEllipse'));
handles_ROI = get(h_objects(1), 'Userdata');
h_circle = handles_ROI(3);
pts =  [get(h_circle, 'xdata')', get(h_circle, 'ydata')'];
delete(handles_ROI(3:7));
for i = 1:size(pts,1)
	handlesDraw.NewPoints = [handlesDraw.NewPoints; pts(i,:) ];
	pp = plot(pts(i,1),pts(i,2), 'r.', 'Userdata', pts(i,:), 'Tag', 'DrawObjectPoint');
	set(pp, 'ButtonDownFcn', ['Draw_tool(''ROI_Point_Move_Entry'',' , num2str(handlesDraw.ROI_Draw_figure) , ',''' , num2str(pp,20), ''');'], ...
		'MarkerEdgeColor', handlesDraw.Color);
	handlesDraw.h_points(end+1,1) = pp;
end;
OLD_POINT = pts(end,:);

set(handlesDraw.Draw_pushbutton, 'Callback', get(handlesDraw.Draw_pushbutton,'Userdata'), 'Userdata', []);
set(handlesDraw.Push_pushbutton, 'Callback', get(handlesDraw.Push_pushbutton,'Userdata'), 'Userdata', []);
set(handlesDraw.Done_pushbutton, 'Callback', get(handlesDraw.Done_pushbutton,'Userdata'), 'Userdata', []);
set(handlesDraw.Cancel_pushbutton, 'Callback', get(handlesDraw.Cancel_pushbutton,'Userdata'), 'Userdata', []);

guidata(handlesDraw.ROI_Draw_figure, handlesDraw );

Sort_Points;
Draw_Spline;
Show_Pixels;
if strcmp(Mode, 'Push') | strcmp(Mode, 'Draw')
	Toggle_Draw_Mode(Mode);
else
	Draw_ROI_Finish(Mode);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Draw_ROI_Finish(Mode);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to finish creating Freehand ROIs or exit from editing any ROI
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
apply_spline = get(handlesDraw.Spline_checkbox,'Value');
		
pts = handlesDraw.Points;
if isempty(pts) | strcmp(Mode, 'Cancel')
	handlesDraw.ROI_info = [];
	guidata(findobj('Tag', 'ROI_Draw_figure'), handlesDraw);
	uiresume(handlesDraw.ROI_Draw_figure);
	return
end;	

%CALCULATION of points in ROI parameters

% Close the ROI by copying the final point
x = [pts(:,1); pts(1,1)];  y = [pts(:,2) ; pts(1,2)];
xs = x; ys = y;
if apply_spline
	% 	interpolate x & y points into a spline curve
	[xs, ys] = Spline_ROI(x, y);
end;

handlesDraw.ROI_info.ROI_x_coordinates = xs;
handlesDraw.ROI_info.ROI_y_coordinates = ys;
handlesDraw.ROI_info.ROI_x_original = x;
handlesDraw.ROI_info.ROI_y_original = y;

% Determine Mask
im = get(findobj(handlesDraw.Temp_Spline_axes,'Type', 'Image'),'CData');		
[xx,yy] = meshgrid([1:size(im,2)],[1:size(im,1)]);
handlesDraw.ROI_info.ROI_mask =	inpolygon(xx,yy,xs,ys);

guidata(handlesDraw.ROI_Draw_figure, handlesDraw);
uiresume(handlesDraw.ROI_Draw_figure);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Draw_Entry(h_figure);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute once at the beggining of a drag cycle
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

global OLD_POINT; 
OLD_POINT = [-10, -10];  % initialize so that first point is automatically drawn.
set(h_figure, 'WindowButtonMotionFcn', 'Draw_tool(''ROI_Draw'');');
set(h_figure, 'WindowButtonUpFcn',     'Draw_tool(''ROI_Draw_Exit'')'   );
ROI_Draw;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Draw;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

global OLD_POINT;
h_axes = gca;
handlesDraw = guidata(get(h_axes, 'Parent'));
point_drop_pix_thresh = str2num(get(handlesDraw.Point_Drop_edit, 'String'));
p = get(h_axes,'CurrentPoint');
p = [ p(1,1), p(1,2) ];
d = sqrt ( sum( (  (OLD_POINT - p).^2)  ,2) );
if  d > point_drop_pix_thresh
	% store point in the new queue and plot
	handlesDraw.NewPoints = [handlesDraw.NewPoints; p ];
	pp = plot(p(1),p(2), 'r.', 'Userdata', p, 'Tag', 'DrawObjectPoint');
	set(pp, 'ButtonDownFcn', ['Draw_tool(''ROI_Point_Move_Entry'',' , num2str(get(h_axes, 'Parent')) , ',''' , num2str(pp,20), ''');'], ...
		'MarkerEdgeColor', handlesDraw.Color);
	OLD_POINT = p;
	handlesDraw.h_newpoints =   [handlesDraw.h_newpoints; pp];
end;
guidata(get(h_axes, 'Parent'), handlesDraw );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Draw_Exit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;
Sort_Points;
Draw_Spline;
Show_Pixels;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Point_Move_Entry(h_figure, h_point);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute once at the beggining of a drag cycle
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

sel_type = get(h_figure, 'SelectionType')
handlesDraw = guidata(h_figure);
if strcmp(sel_type, 'normal')
	% Normal selection = move point around
	handlesDraw.old_WBMF = get(h_figure,'WindowButtonMotionFcn');
	handlesDraw.old_WBUF = get(h_figure,'WindowButtonUpFcn');	
	set(h_figure, 'WindowButtonMotionFcn', ['Draw_tool(''ROI_Point_Move'','''     ,h_point,''');']);
	set(h_figure, 'WindowButtonUpFcn',     ['Draw_tool(''ROI_Point_Move_Exit'',''',h_point,''');']);
	ROI_Point_Move(h_point);	
	guidata(h_figure, handlesDraw);

elseif strcmp(sel_type, 'alt')
	% remove the point if the point is double-clicked 
	% or right clicked
	h_point = str2num(h_point);
	pos = cell2mat(get(h_point, {'xdata', 'ydata'}));
	idx = find(sum(abs(handlesDraw.Points - repmat(pos, [size(handlesDraw.Points,1),1])),2)==0);
	delete(h_point);
	% remove point from queue
	for i = 1:length(idx)
		handlesDraw.Points = [handlesDraw.Points(1:idx(i)-1,:); handlesDraw.Points(idx(i)+1:end,:)];
		handlesDraw.h_points = [handlesDraw.h_points(1:idx(i)-1,:); handlesDraw.h_points(idx(i)+1:end,:)];
	end;
	% store points again
	% update lines and selected pixels
	guidata(h_figure, handlesDraw);
	Draw_Spline;
	Show_Pixels;
	
elseif 'Extend' 
	% Shift-click selection = move all points around
	handlesDraw.old_WBMF = get(h_figure,'WindowButtonMotionFcn');
	handlesDraw.old_WBUF = get(h_figure,'WindowButtonUpFcn');	
	set(handlesDraw.h_spline, 'Userdata', [ 0 0]);
	set(h_figure, 'WindowButtonMotionFcn', ['Draw_tool(''ROI_Point_Move_All'',''' ,h_point,''');']);
	set(h_figure, 'WindowButtonUpFcn',     ['Draw_tool(''ROI_Point_Move_Exit'',''',h_point,''');']);	
	ROI_Point_Move_All(h_point);
	guidata(h_figure, handlesDraw);
end;
	
handlesDraw


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Point_Move(h_point)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;
h_point = str2num(h_point);
h_axes = get(h_point, 'Parent');
p = get(h_axes,'CurrentPoint');
set(h_point, 'Xdata', p(1,1), 'Ydata', p(1,2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Point_Move_All(h_point)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

h_point = str2num(h_point);
h_axes = get(h_point, 'Parent');
new_point = get(h_axes,'CurrentPoint');
new_point = [new_point(1,1),new_point(2,2)];
%set(h_point, 'Xdata', new_point(1), 'Ydata', new_point(2));
old_point = get(h_point, 'Userdata');
delta = new_point - old_point

handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
for i = 1:length(handlesDraw.h_points)
	new_pos = get(handlesDraw.h_points(i), 'Userdata') + delta;
	set(handlesDraw.h_points(i), 'xdata', new_pos(1), 'ydata', new_pos(2));
end;
Draw_Spline;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Point_Move_Exit(h_point)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

% Change the position of the point in the cue
handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
h_point = str2num(h_point);
h_axes = get(h_point, 'Parent');

set(handlesDraw.ROI_Draw_figure, ...
	'WindowButtonMotionFcn', handlesDraw.old_WBMF , ...
	'WindowButtonUpFcn',     handlesDraw.old_WBUF);
handlesDraw.old_WBMF = [];
handlesDraw.old_WBUF = [];
set(handlesDraw.h_spline, 'Userdata',  []);

for i = 1:length(handlesDraw.h_points)
	old_pos = get(handlesDraw.h_points(i), 'Userdata');
	new_pos = cell2mat(get(handlesDraw.h_points(i), {'xdata', 'ydata'}));
	set(handlesDraw.h_points(i), 'Userdata', new_pos);
	handlesDraw.Points(i,:) = new_pos;
end;
	
% now store points again
guidata(findobj('Tag', 'ROI_Draw_figure'),handlesDraw);
Draw_Spline;
Show_Pixels;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Quick_Draw_Spline;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function that draws the fitted spline to a series of point on an ROI
% curve. If spline is not desired, a straight line fit (polygon) is
% created.
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
draw_spline = get(handlesDraw.Spline_checkbox, 'Value');
points = handlesDraw.Points;

%%%%%% WRONG!!! points needs to be the new poitns, 
% not the old ones that haven't been updated in quick callbacks...

if ~isempty(points)
	points = [points; points(1,:)];
	if  draw_spline & ( size(points,1) > 1)	
		[xs, ys] = Spline_ROI(points(:,1),points(:,2));
		%handlesDraw.h_spline = plot3(xs, ys, repmat(-1,size(xs)), [handlesDraw.Color, '-'], 'Tag', 'DrawObject');
		%handlesDraw.Spline  = [xs', ys'];
		set(handlesDraw.h_spline, 'xdata', xs, 'ydata', ys);
	else
		% draw straight line
		%handlesDraw.h_spline = plot3(points(:,1), points(:,2), repmat(-1,size(points(:,1))), [handlesDraw.Color, '-'],'Tag', 'DrawObject');
		%handlesDraw.Spline  = points;
		set(handlesDraw.h_spline, 'xdata', points(:,1), 'ydata', points(:,2));
	end;
end;
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Draw_Spline;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function that draws the fitted spline to a series of point on an ROI
% curve. If spline is not desired, a straight line fit (polygon) is
% created.
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
draw_spline = get(handlesDraw.Spline_checkbox, 'Value');

if ~isempty(handlesDraw.h_spline)
	% delete the old line
	delete(handlesDraw.h_spline);
	handlesDraw.h_spline = [];
	handlesDraw.Spline   = [];
end;
% unsampled points
points = handlesDraw.Points;

if ~isempty(points)
	
	close_ROI = get(handlesDraw.Close_ROI_checkbox, 'Value');
	if close_ROI,
		points = [points; points(1,:)];
	end;
	if  draw_spline & ( size(points,1) > 1)	
		% draw or redraw spline
		set(handlesDraw.ROI_Draw_figure, 'CurrentAxes', handlesDraw.Temp_Spline_axes);
		[xs, ys] = Spline_ROI(points(:,1),points(:,2));
		handlesDraw.h_spline = plot3(xs, ys, repmat(-1,size(xs)), [handlesDraw.Color, '-'], 'Tag', 'DrawObjectLine');
		handlesDraw.Spline  = [xs', ys'];
	else
		% draw straight line
		handlesDraw.h_spline = plot3(points(:,1), points(:,2), repmat(-1,size(points(:,1))), [handlesDraw.Color, '-'],'Tag', 'DrawObjectLine');
		handlesDraw.Spline  = points;
	end;	
end;
guidata(findobj('Tag', 'ROI_Draw_figure'), handlesDraw);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Toggle_Spline_Poly(h_checkbox)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function to toggle between drawing splines and polygons
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

val = get(h_checkbox, 'Value');

if val
	set(get(h_checkbox, 'Userdata'), 'Value', 0);
else
	set(get(h_checkbox, 'Userdata'), 'Value', 1);
end;
Draw_Spline;
Show_Pixels;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Toggle_Draw_Mode(Mode)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;
% switch between draw mode and edit-push more
handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));;

if strcmp(Mode, 'Push')	
	set(handlesDraw.ROI_Draw_figure, 'PointerShapeCData', handlesDraw.cursors.plus_cursor);
	set(findobj(handlesDraw.ROI_Draw_figure, 'Type', 'Image'), 'ButtonDownFcn', handlesDraw.ButtonDownStrings{2});
	set(handlesDraw.ROI_Draw_figure, 'WindowButtonMotionFcn', 'Draw_tool(''ROI_Push_Move_Cursor'');');
	
	guidata(findobj('Tag', 'ROI_Draw_figure'),handlesDraw);
	Draw_Push_Radius(1);
	ROI_Push_Move_Cursor;

elseif strcmp(Mode, 'Draw')
	set(handlesDraw.ROI_Draw_figure, 'PointerShapeCData', handlesDraw.cursors.plus_cursor);
	set(findobj(handlesDraw.ROI_Draw_figure, 'Type', 'Image'), 'ButtonDownFcn', handlesDraw.ButtonDownStrings{1});
	set(handlesDraw.ROI_Draw_figure, 'WindowButtonMotionFcn', '');
	
	if ~isempty(handlesDraw.h_circle)
		delete(handlesDraw.h_circle);
		handlesDraw.h_circle = [];
	end;
	guidata(findobj('Tag', 'ROI_Draw_figure'),handlesDraw);
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Push_Move_Cursor;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

h_axes = gca;
p = get(h_axes, 'CurrentPoint');
h_circle = findobj(h_axes, 'Tag', 'Cursor_Circle');
xy = get(h_circle, 'UserData');
set(h_circle, 'XData', xy(:,1) + p(1,1), 'YData', xy(:,2) + p(1,2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Sort_Points;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to sort the newly added points to the end of the cue
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

h_axes = gca;
handlesDraw = guidata(get(h_axes, 'Parent'));

old_pts = handlesDraw.Points;
new_pts = handlesDraw.NewPoints;

% Only sort if there is more than two points!
if (size(old_pts,1) > 2) %~isempty(old_pts) &  
	% calculate the distance between the first new_pt the last new pt, all the old points
	% to determine the best entry for the new curves
	dist_start = sqrt ( sum (    (old_pts - repmat(new_pts(1  ,:), [ size(old_pts,1),1])).^2   , 2));
	dist_end   = sqrt ( sum (    (old_pts - repmat(new_pts(end,:), [ size(old_pts,1),1])).^2   , 2));
	
	% determine smallest net distance to 2 adjacent points
	% assume user draws first point closest to the point of entry
	min_dist_idx = find(min(dist_start)==dist_start);
	idx1 = mod( min_dist_idx + 1 - 1 , length(dist_start) ) + 1;
	idx2 = mod( min_dist_idx - 1 - 1,  length(dist_start) ) + 1;
	% assume all new points fit between the first new point
	other_min_dist = min([dist_end([idx1,  idx2])]);
	other_min_dist_idx = find(other_min_dist == dist_end);
		
	if other_min_dist_idx  < min_dist_idx
		% if inserting backwards, flip indexes
		t = other_min_dist_idx;
		other_min_dist_idx = min_dist_idx;
		min_dist_idx = t;
	end;	
	
	if abs(other_min_dist_idx - min_dist_idx) > 1
		% looking at inserting after the last point
		handlesDraw.Points = [old_pts; new_pts];
		handlesDraw.h_points = [handlesDraw.h_points; handlesDraw.h_newpoints];
	elseif other_min_dist_idx == length(old_pts)
		% if the end point is the closest point, just tack on at the end
		handlesDraw.Points = [old_pts; new_pts];
		handlesDraw.h_points = [handlesDraw.h_points; handlesDraw.h_newpoints];
	else
		%insert between the two indexes
		handlesDraw.Points = [ ...
				old_pts(1:min_dist_idx(1),:); ...
				new_pts; ...
				old_pts(min_dist_idx(1)+1:end,:) ];
		handlesDraw.h_points = [ ...
				handlesDraw.h_points(1:min_dist_idx(1)); ...
				handlesDraw.h_newpoints; ...
				handlesDraw.h_points(min_dist_idx(1)+1:end);];
	end;
	
else
	% not enough points, tack points on at the end without sorting
	handlesDraw.Points = [old_pts; new_pts];
	handlesDraw.h_points = [handlesDraw.h_points; handlesDraw.h_newpoints];
end;
% Store points and clear new pts
handlesDraw.NewPoints = [];
handlesDraw.h_newpoints = [];
guidata(get(h_axes, 'Parent'),handlesDraw );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Push_Point_Entry(h_figure);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute once at the beggining of a drag cycle
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

% Normal selection = move point around
set(h_figure, 'WindowButtonMotionFcn', ['Draw_tool(''ROI_Push_Point'');']);
set(h_figure, 'WindowButtonUpFcn',     ['Draw_tool(''ROI_Push_Point_Exit'');']);
ROI_Push_Point;
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Push_Point
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
points = handlesDraw.Points;
p = get(handlesDraw.Temp_Spline_axes,'CurrentPoint');
p = [p(1,1), p(1,2)];
if ~isempty(points)
	% if ROI has been cleared, do nothing
	pixel_thresh = handlesDraw.circle_size * handlesDraw.circle_ratio;
	pixel_push   = pixel_thresh * 1.1;	
	% find the points that are within 4 pixels of the center of the cursos
	dist = sqrt(sum( (points - repmat(p,[size(points,1),1]) ).^2, 2) )';
	in_radius = find(dist <= pixel_thresh);
	for i = 1:length(in_radius)
		% move each point to the edge of a circle of radius 4, in the direction
		% of the vector from the center of the circle to the points
		h_current_point = findobj(handlesDraw.Temp_Spline_axes, ...
			'Xdata', points(in_radius(i),1), 'Ydata', points(in_radius(i),2));
		% unit vector pointing in the correct direction
		v = (points(in_radius(i),:) - p) ./ sqrt ( sum  ( (points(in_radius(i),:) - p).^2  , 2));
		% add unit vector * push_radius to center coordinates
		new_p = p + v.* ( pixel_push );
		set(h_current_point, 'Xdata', new_p(1,1), 'Ydata', new_p(1,2), 'UserData', [new_p(1,1), new_p(1,2)]);
		points(in_radius(i),:) = new_p;
	end;
	% now store the poitns again
	handlesDraw.Points = points;
	guidata(findobj('Tag', 'ROI_Draw_figure'), handlesDraw);
	Draw_Spline;
end;
ROI_Push_Move_Cursor;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Push_Point_Exit;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

% Update the Pixels 
handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
set(handlesDraw.ROI_Draw_figure, 'WindowButtonMotionFcn', 'Draw_tool(''ROI_Push_Move_Cursor'');');
Show_Pixels;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Angle_Adjust_Entry;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute once at the beggining of a drag cycle
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;
fig = gcf;
set(fig, 'WindowButtonMotionFcn', 'Draw_tool(''ROI_Angle_Adjust'');');
set(fig,'WindowButtonUpFcn', 'Draw_tool(''ROI_Angle_Adjust_Exit'')');
ROI_Angle_Adjust;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Angle_Adjust
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

h_angle = gco;
h_axes = get(h_angle, 'Parent');
point = get(h_axes,'CurrentPoint');

%CALCULATION

val = get(h_angle, 'Userdata');
% 1,2  infor table indexes
% 3-7  handle_values = [h_circle, h_center, h_size, h_angle, h_number]
% 8-12 ROI_values = [center_x, center_y, size_x, size_y, angle]

v1 = [point(1,1) point(1,2)]  -[ val(8), val(9)] ;
v2 = [get(h_angle, 'xdata'), get(h_angle, 'ydata')] - [val(8), val(9)];
% get angle (positive only) and multiply it by direction
d = cross([v1 0],[v2 0]);
% calculate angle between the two...
alpha=  acos(  dot(v1,v2)   /(norm(v1) * norm(v2)) ) * -1*sign(d(3));
%alpha_deg = alpha*180/pi
rotmat = [cos(alpha) -sin(alpha); sin(alpha) cos(alpha)];

% now rotate everything by this amount
c = rotmat*[get(val(3),'xdata') - val(8); get(val(3),'ydata') - val(9)];
set(val(3), 'xdata', c(1,:) + val(8), 'ydata', c(2,:) + val(9));
c = rotmat*[get(val(5),'xdata') - val(8); get(val(5),'ydata') - val(9)];
set(val(5), 'xdata', c(1,:) + val(8), 'ydata', c(2,:) + val(9));
c = rotmat*[get(val(6),'xdata') - val(8); get(val(6),'ydata') -  val(9)];
set(val(6), 'xdata', c(1,:)+ val(8), 'ydata', c(2,:)+ val(9));
p = get(val(7),'Position')';
c = rotmat*( [p(1:2) - [val(8) val(9)]']) ;
set(val(7), 'Position', [ c' + [val(8),val(9)] ,p(3)]);

% update only the current object's userdata... 
%set(val(6),'UserData', [val(1:11), alpha]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Angle_Adjust_Exit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;
h_angle = gco;
val = get(h_angle, 'Userdata');

% 1,2  infor table indexes
% 3-7  handle_values = [h_circle, h_center, h_size, h_angle, h_number]
% 8-12 ROI_values = [center_x, center_y, size_x, size_y, angle]

%CALCULATION
v1 = [1 0];

if isappdata(h_angle, 'alpha0')
	alpha0 = getappdata(h_angle, 'alpha0');
else
	alpha0 = 0;
end;

v2 = [get(h_angle, 'xdata'), get(h_angle, 'ydata')] - [val(8), val(9)] ;
d = cross([v1 0],[v2 0]);
alpha = acos(  dot(v1,v2)   /(norm(v1) * norm(v2)) ) *sign(d(3));
alpha = alpha - alpha0;
%alpha_deg = alpha*180/pi

% update all other objects part of this ROI with correct values
set(val(3:7), 'userdata', [val(1:11), alpha]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Size_Adjust_Entry;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute once at the beggining of a drag cycle
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;
fig = gcf;
set(fig, 'WindowButtonMotionFcn', 'Draw_tool(''ROI_Size_Adjust'');');
set(fig,'WindowButtonUpFcn', 'Draw_tool(''ROI_Size_Adjust_Exit'')');
ROI_Size_Adjust;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Size_Adjust
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

% global STORAGE_VAR

h_size = gco;
h_axes = get(h_size, 'Parent');
point = get(h_axes,'CurrentPoint');
val = get(h_size, 'Userdata');
% 1,2  info table indexes
% 3-7  handle_values = [h_circle, h_center, h_size, h_angle, h_number]
% 8-12 ROI_values = [center_x, center_y, size_x, size_y, angle]

%CALCULATION
%val(8:12)
%alpha_deg = val(12)*180/pi

% get the new position
center_pt = [val(8) val(9)];
v1 = [point(1,1)           point(1,2)]           - center_pt;   % new position
v2 = [get(val(5),'xdata'), get(val(5),'ydata')]  - center_pt ;  % old position

% Undo rotation v1 -> inverse v1 - val(12)= angle from +x-axis to circle marker 
alpha = val(12);
%alpha = alpha;
rotmat =[cos(alpha), -sin(alpha); sin(alpha), cos(alpha)];
% undo rotation by alpha on the new point
iv1 = rotmat'*v1';

% d = cross([v2 0],[v1 0])     % angle between old size marker and new size marker                              % after return to horizontal plane
% theta=  acos(  dot(v1,v2)   /(norm(v1) * norm(v2)) ) *sign(d(3));
% theta_deg = theta*180/pi

% determine the skew and use the ratio of the old skew value to the new
% skew value to determine the new coordinates
sx2 = -(iv1(1));
sy2 = -(iv1(2));

%temp_skewmat = [sx2/val(10) 0 ; 0 sy2/val(11)];
skewmat = rotmat * [sx2/val(10) 0 ; 0 sy2/val(11)] * rotmat';

c = skewmat * [get(val(3),'xdata') - center_pt(1); get(val(3), 'ydata') - center_pt(2)];
set(val(3), 'xdata', c(1,:) + center_pt(1), 'ydata', c(2,:) + center_pt(2));

c = (skewmat*[ [get(val(5),'xdata'), get(val(5),'ydata')] - center_pt]')' + center_pt;
set(val(5), 'xdata', c(1), 'ydata', c(2), 'UserData', [val(1:9), sx2, sy2, val(12)]);
c = (skewmat*[  [ get(val(6),'xdata'),get(val(6), 'ydata') ] - center_pt]')'  + center_pt;
set(val(6), 'xdata', c(1), 'ydata', c(2));
p = get(val(7),'Position')';

c = skewmat* ( p(1:2) - center_pt') + center_pt';
set(val(7), 'Position',    [c ;p(3)]);

set(h_size,'Userdata', [val(1:9), sx2, sy2 ,val(12)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Size_Adjust_Exit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;
h_size = gco;
val = get(h_size, 'Userdata');
set(val(3:7), 'userdata', val);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Pos_Adjust_Entry(origin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute once at the beggining of a drag cycle
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;
fig = gcf;
set(fig, 'WindowButtonMotionFcn', ['Draw_tool(''ROI_Pos_Adjust'',' num2str(origin) ');']);
set(fig,'WindowButtonUpFcn', 'Draw_tool(''ROI_Pos_Adjust_Exit'')');
ROI_Pos_Adjust(origin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Pos_Adjust(origin)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

h_pos = gco;
h_axes = get(h_pos, 'Parent');
point = get(h_axes,'CurrentPoint');
val = get(h_pos, 'Userdata');

%CALCULATION
% 1,2  infor table indexes
% 3-7  handle_values = [h_circle, h_center, h_size, h_angle, h_number]
% 8-12 ROI_values = [center_x, center_y, size_x, size_y, angle]

p = get(val(7),'Position')';
% center transform  = new point - old _point
if origin ==1  % call from center plus
    new_center_pt = [point(1,1), point(1,2)] - [val(8) val(9)];
elseif origin ==2  % call from corner number
    new_center_pt= [point(1,1), point(1,2)] - [p(1) p(2)];
end;

d = [get(val(4),'xdata') , get(val(4), 'ydata')] + new_center_pt;
set(val(4), 'xdata',  d(1), 'ydata', d(2));

o = [get(val(3),'xdata')  ;  get(val(3), 'ydata')];
set(val(3), 'xdata', o(1,:) + new_center_pt(1), 'ydata', o(2,:) + new_center_pt(2));
c = [get(val(5),'xdata'), get(val(5),'ydata')] +  new_center_pt;
set(val(5), 'xdata', c(1), 'ydata', c(2));
c = [get(val(6),'xdata'),get(val(6), 'ydata')] + new_center_pt;
set(val(6), 'xdata', c(1), 'ydata', c(2));
c = p(1:2) + new_center_pt';
set(val(7), 'Position',  [c ;p(3)]);

% update info in both number and center
set([val(4), val(7)], 'Userdata', [val(1:7), d(1:2), val(10:12)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Pos_Adjust_Exit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

h_pos = gco;
val = get(h_pos, 'Userdata');
set(val(3:7), 'userdata', val);

%h_pos = gco;
% 1,2  infor table indexes
% 3-7  handle_values = [h_circle, h_center, h_size, h_angle, h_number]
% 8-12 ROI_values = [center_x, center_y, size_x, size_y, angle]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Draw_Clear_ROI(Mode);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;



handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
points = findobj(handlesDraw.Temp_Spline_axes,'Type', 'line')';
all_points = [];
for i = 1:length(points)
	% Extract points the correspond to DrawObjects
	if strfind(get(points(i), 'tag'), 'DrawObject')
		all_points(end+1)=points(i);
	end;
end;
	
if ~isempty(handlesDraw.h_circle)
	% don't delete the circular cursor!!!
	% don't delete previous ROIs either
	i = find(all_points==handlesDraw.h_circle);
	if ~isempty(i)
		all_points = [all_points(1:i-1), all_points(i+1:end)];
	end
end;
delete(all_points);	
handlesDraw.h_spline = [];
handlesDraw.Spline = [];
handlesDraw.Points = [];
handlesDraw.h_pixels = [];
guidata(findobj('Tag', 'ROI_Draw_figure'), handlesDraw );

% If the user began this call to the Draw Tool with either an Ellipse
% or a rectangle manipulation, then clear should reinstate the user 
% to that interactive setting
if strcmp(Mode, 'Rectangle')
	Draw_Rectangle;
elseif strcmp(Mode, 'Ellipse')
	Draw_Ellipse
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Show_Pixels;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
handlesDraw.Show_Pixels = get(handlesDraw.Show_Pixels_checkbox, 'Value');

if ~isempty(handlesDraw.h_pixels)
	delete(handlesDraw.h_pixels);
	handlesDraw.h_pixels = [];
end;

if handlesDraw.Show_Pixels & ~isempty(handlesDraw.Points)
	if ~isempty(handlesDraw.Spline)
		xpts = handlesDraw.Spline(:,1);
		ypts = handlesDraw.Spline(:,2);
	else
		xpts = handlesDraw.Points(:,1);
		ypts = handlesDraw.Points(:,2);
	end;
	im = get(findobj(handlesDraw.Temp_Spline_axes,'Type', 'Image'),'CData');		
	% 	xx = repmat([1:size(im,2)], size(im,1),1);
	% 	yy = repmat([1:size(im,1)]',1,          size(im,2));
	[xx,yy] = meshgrid([1:size(im,2)],[1:size(im,1)]);
	rr = inpolygon(xx,yy,xpts,ypts);
	[ii,jj] = find(rr);
	h_pixels = plot3(jj,ii,repmat(-1, size(jj)), 'bs' , 'MarkerSize', 2, 'MarkerFaceColor', 'b', 'Tag','DrawObjectPixel');
	handlesDraw.h_pixels = h_pixels;
end;
guidata(findobj('Tag', 'ROI_Draw_figure'), handlesDraw );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Draw_Change_Edit_Value(h_edit,Limits, Default_value)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

% Function to insure number entered into editable text
% box is valid
new_val = get(h_edit, 'String');
reject = 1;
try
	x = str2num(new_val);
	if isnumeric(x)
		if (x>Limits(1)) & (x<Limits(2))
			% accept;
			reject = 0;
		end;
	end;
end;
if reject
	set(h_edit, 'String', num2str(Default_value));
end;	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Draw_Push_Radius(Mode);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

% Function to (re)draw the cursor for the push tool
% if Mode == 1, then first time in, and draw cursor
% if Mode == 0, then already in push mode and redraw
handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
basic_points = 64;	
theta = 0:(360/basic_points):360;
[x,y] = pol2cart(theta*pi/180, repmat(handlesDraw.circle_size * handlesDraw.circle_ratio , size(theta,1), size(theta,2)));

if ~isempty(handlesDraw.h_circle) | (Mode==1)
	delete(handlesDraw.h_circle);
	handlesDraw.h_circle = plot(x-100 ,y-100, 'w-', 'Tag', 'Cursor_Circle', 'Userdata', [x',y']); 
	guidata(findobj('Tag', 'ROI_Draw_figure'), handlesDraw );
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Draw_Change_Radius_Value(h_edit);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;
handlesDraw = guidata(findobj('Tag', 'ROI_Draw_figure'));
handlesDraw.circle_ratio = str2num(get(handlesDraw.Push_Radius_edit, 'String'))/100;
guidata(findobj('Tag', 'ROI_Draw_figure'), handlesDraw );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Close_ROI_Draw_figure;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to make sure that if parent figure is closed, 
% the ROI info, ROI Tooland ROI Draw figures are closed too.
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;
delete(findobj('Tag','ROI_Draw_figure'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%Support Routines %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions called internally function and not as callbacks

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [xs, ys] = Spline_ROI(x, y);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	interpolate x & y points into a spline curve
%   return xs and ys, upsampled by a factor f
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

f  = 1/Sample_Rate;      % Upsample curve by a factor of 10 
t  = 1:length(x);
ts = 1: f : length(x);
xs = spline(t, x, ts);
ys = spline(t, y, ts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function F = Sample_Rate;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function  handle_values = Make_ROI_Elements(xs,ys,roi_color,roi_number, center_x, center_y, size_x, size_y, angle_x, angle_y, number_x, number_y, alpha0);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Funciton to create sub-elements of an ROI, including the actual ROI, the
%  resize square, the angle circle, the central plus and the ROI number
%global DB; if DB disp(['Draw_Tool: ', Get_Current_Function]); end;

h_circle = plot(xs,ys,[roi_color,'-'],...
	'ButtonDownFcn', 'Draw_tool(''Change_Current_ROI'')', 'Tag', 'DrawObjectEllipse');

h_center = plot(center_x, center_y , [roi_color,'+'], ...
	'ButtonDownFcn', 'Draw_tool(''ROI_Pos_Adjust_Entry'',1)', 'Tag', 'DrawObjectEllipse'); 

h_size = plot(size_x , size_y, [roi_color,'s'],...
	'ButtonDownFcn', 'Draw_tool(''ROI_Size_Adjust_Entry'')', 'Tag', 'DrawObjectEllipse');

h_angle = plot(angle_x, angle_y, [roi_color,'o'],...
	'ButtonDownFcn', 'Draw_tool(''ROI_Angle_Adjust_Entry'')', 'Tag', 'DrawObjectEllipse');
if nargin == 13
	setappdata(h_angle, 'alpha0', alpha0);	
end;
h_number = text(number_x, number_y, num2str(roi_number),...
	'color', roi_color, ...
	'HorizontalAlignment', 'center' , ...
	'ButtonDownFcn', 'Draw_tool(''ROI_Pos_Adjust_Entry'',2)' ,...
	'Tag', 'DrawObjectEllipse'); 

handle_values = [h_circle, h_center, h_size, h_angle, h_number];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function  func_name = Get_Current_Function;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Debug function - returns current function name
x = dbstack;
x = x(2).name;
func_name = x(findstr('(', x)+1:findstr(')', x)-1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Garbage



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Prep_Edit_Current_ROI(handlesDraw);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to prepare editing of an exisitng ROI
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

data_holder = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
fig = data_holder{1};
fig2 = data_holder{2};
ifig = data_holder{6};
i_current_ROI = data_holder{5};
h_current_axes = data_holder{4};

colororder = repmat('rbgymcw',1,4);

% disable the other figures, if they exist
if ~isempty(fig2), 
	[handlesDraw.h_objects, handlesDraw.object_enable_states] = Change_Figure_States('Disable', [fig2, ifig]);
end;

UserData = get(findobj(fig, 'Tag', 'figROITool'), 'UserData');
ROI_info_table = UserData{1};
current_ROI_data = ROI_info_table(i_current_ROI(1), i_current_ROI(2));

x_coors = get(current_ROI_data.ROI_Data(1,1), 'Xdata')';
y_coors = get(current_ROI_data.ROI_Data(1,1), 'Ydata')';

% load unsplined points, if they exist
if ~isempty(current_ROI_data.ROI_x_original)
	%disp(['Draw_tool: Prep_Edit_Current_ROI: Loading un-splined (original) data']);	
	x_coors =current_ROI_data.ROI_x_original;
	y_coors =current_ROI_data.ROI_y_original;
end	


% remove end point if it is the sams as the first point \
% (avoids problems with moving points and fitting splines)
% Should be made more general (i.e. matrix of distances between points, 
% remove all second points with zero distance
thresh = 0.0001;
if ( abs( x_coors(1)- x_coors(end)) < thresh) & ( abs( y_coors(1)- y_coors(end)) < thresh)
	x_coors = x_coors(1:end-1);
	y_coors = y_coors(1:end-1);
end;
	
handlesDraw.Points = [x_coors, y_coors];
handlesDraw.Color = colororder(i_current_ROI(1));
set(handlesDraw.ROI_Draw_figure,     'CurrentAxes', handlesDraw.Temp_Spline_axes);
set(handlesDraw.Done_pushbutton,   'Callback', 'Draw_tool(''Edit_ROI_Finish'',''Done'');');
set(handlesDraw.Cancel_pushbutton, 'Callback', 'Draw_tool(''Edit_ROI_Finish'',''Cancel'');');
set(handlesDraw.ROI_Draw_figure,     'CloseRequestFcn', 'Draw_tool(''Edit_ROI_Finish'',''Done'');');
set(0, 'CurrentFigure', handlesDraw.ROI_Draw_figure);

for i = 1:length(x_coors)	
	pp = plot(x_coors(i),y_coors(i), 'r.', 'Userdata', [x_coors(i), y_coors(i)]);
	set(pp, 'ButtonDownFcn', ['Draw_tool(''ROI_Point_Move_Entry'',' , num2str(handlesDraw.ROI_Draw_figure), ',''' , num2str(pp,20), ''');'],...
		'MarkerEdgeColor', handlesDraw.Color);
	%get(pp)
end;

handlesDraw.EDITING = 1;
guidata(handlesDraw.ROI_Draw_figure, handlesDraw);

Draw_Spline;
Show_Pixels;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% function Draw_ROI_Finish(Mode);
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Function to finish creating Freehand ROIs or exit from editing any ROI
% %global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;
% center_x = mean(xs);
% center_y = mean(ys);
% 
% maxx = max(xs); maxx = maxx(1);
% maxy = max(ys); maxy = maxy(1);
% minx = min(xs); minx = minx(1);
% miny = min(ys); miny = miny(1);
% imaxx = find(xs==maxx); imaxx = imaxx(end);
% 
% size_x1 = maxx - center_x;
% size_x2 = abs(minx - center_x);
% size_y  = abs(miny - center_y);
% 
% angle_point_x = xs(imaxx);
% angle_point_y = ys(imaxx);
% 
% v1 = [1 0];
% v2 = [angle_point_x, angle_point_y] - [center_x, center_y] ;
% d = cross([v1 0],[v2 0]);
% alpha0 = acos(  dot(v1,v2)   /(norm(v1) * norm(v2)) ) *sign(d(3));
% % Initialize the starting angle as alpha
% alpha = 0;
% 
% for i = 1:length(h_axes_interest(:))
% 	set(fig, 'CurrentAxes', h_axes_interest(i));
% 	h_axes_index = find(h_all_axes'==h_axes_interest(i));
% 	set(0, 'CurrentFigure', fig);
% 
% 	% handle_values = [h_circle, h_center, h_size, h_angle, h_number];
% 	handle_values = Make_ROI_Elements(...
% 		xs, ys,...
% 		colororder(Current_ROI_index),...
% 		Current_ROI_index,...
% 		center_x, center_y,...
% 		center_x - size_x2, center_y - size_y, ...
% 		angle_point_x, angle_point_y,...
% 		center_x + size_x1, center_y - size_y, ...
% 		alpha0);
% 			
% 	
% 	ROI_values = [center_x, center_y, size_x2, size_y, alpha ];
% 	
% 	set(handle_values, 'UserData', ...
% 		[Current_ROI_index, h_axes_index, handle_values, ROI_values ]);
% 	ROI_info_table(Current_ROI_index,h_axes_index).ROI_Data = ...
% 		[handle_values ; ...
% 			ROI_values];
% 	ROI_info_table(Current_ROI_index, h_axes_index).ROI_Exists = 1;
% 	
% 	if apply_spline
% 		% If spline was applied, save original points
% 		% Clear original points if simply drawing straight lines
% 		ROI_info_table(Current_ROI_index,h_axes_index).ROI_x_original = x;
% 		ROI_info_table(Current_ROI_index,h_axes_index).ROI_y_original = y;
% 	else
% 		ROI_info_table(Current_ROI_index,h_axes_index).ROI_x_original = [];
% 		ROI_info_table(Current_ROI_index,h_axes_index).ROI_y_original = [];	
% 	end
% 
% 	update_list(i,:) = [Current_ROI_index, h_axes_index];	
% 	i_current_ROI = [Current_ROI_index, h_axes_index];
% 	
% end;			


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Update_ROI_Info(update_list)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updates the roi info (mean, std, pixs, etc) into the ROI table
%global DB; if DB disp(['Draw_tool: ', Get_Current_Function]); end;

if ~isempty(update_list)
    h_all_axes = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
    fig = h_all_axes{1};    
    fig2 = h_all_axes{2};   
    h_all_axes = h_all_axes{3};
    handles = guidata(fig2);
    userdata = get(findobj(fig, 'Tag', 'figROITool'),'Userdata');
    ROI_info_table = userdata{1};

	debug_mode = 0;
       
    for i = 1:size(update_list,1)
        % get the handles of the image, and the ROI circle
        h_circle = ROI_info_table(update_list(i,1), update_list(i,2)).ROI_Data(1);
        xpts = get(h_circle, 'xdata');
        ypts = get(h_circle, 'ydata');
        im = get(findobj(get(h_circle, 'Parent'), 'Type', 'Image'), 'CData');

        % check boundary conditions
        %xpts(xpts<=1) = 1;  xpts(xpts>size(im,1)) = size(im,1);
        %ypts(ypts<=1) = 1;  ypts(ypts>size(im,2)) = size(im,2);
        
        % reduce the matrix size        
        min_xpts = min(xpts); max_xpts = max(xpts);
        min_ypts = min(ypts); max_ypts = max(ypts);
         
        % shift indexes
        xpts2 = xpts - floor(min_xpts) ;
        ypts2 = ypts - floor(min_ypts) ;
       
        %reduce image size too cover only points
        im2 = im(floor(min_ypts):ceil(max_ypts), floor(min_xpts):ceil(max_xpts));
        %figure; imagesc(im2)
        %hold on; plot(xpts2, ypts2, 'ro-');
        %axis image
        
        %xx = repmat([1:size(im2,2)], size(im2,1),1);
        %yy = repmat([1:size(im2,1)]',1, size(im2,2));
		  [xx,yy] = meshgrid([1:size(im,2)],[1:size(im2,1)]);

        % Do not use roipoly as it only uses integer vertex coordinates
        %BW = roipoly(im, xpts, ypts);
        % However, because in_polygon uses vector and cross products to determine
        % if point is within polygon, make matrix smaller.
        %tic
        rr = inpolygon(xx,yy,xpts2,ypts2);
        %toc
        [ii,jj] = find(rr);

		if debug_mode
            %plot(jj+floor(min_xpts),ii+floor(min_ypts),'r.');
            f = figure;
            imagesc(im2);
            axis equal; 
            hold on;
			title('Press Any Key To Continue');
			plot(jj+1,ii+1,'r.');
            plot(xpts2+1,ypts2+1,'r-.')
			colormap(get(fig, 'Colormap'));
            pause
			try, close(f); end;
        end;
        ii = ii + 1; jj = jj + 1;        
        ROI_vals = double(im2(sub2ind(size(im2),ii,jj)));
   
        mn  = mean(ROI_vals);
        stdev= std(ROI_vals);
        mins = min(ROI_vals);
        maxs = max(ROI_vals);
        pixels = length(ROI_vals);
            
        ROI_info_table(update_list(i,1), update_list(i,2)).ROI_Info = ...
            [mn, stdev, pixels, mins, maxs];    
    end;
    % restore the ROI_info_table with its new info
    userdata{1} = ROI_info_table;    
    set(findobj(fig, 'Tag','figROITool'), 'UserData', userdata);

end;


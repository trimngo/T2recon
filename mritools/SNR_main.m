function SNR_main(action, varargin);

% branch depending on action.
% Necessary structure since outside functions cannot see subfunctions
% To start use,
%	SNR_main
%
%
%
%  Daniel Herzka,
%  Fall 1999
%  The Johns Hopkins University
%  Department of Biomedical Engineering

  global SNR_fig

  if nargin<1 action='start'; end;
  %if exist('SNR_fig'), disp([action,':', get(SNR_fig,
  %'SelectionType')]), end; %[Normal, alt, extended, open]

  switch action

    % SELECT PATH & IMAGE
   case 'start'
    [image_list,im_num] = update_path('new');
    if ~isempty(image_list)
      SNR_main('create',image_list,im_num);
    end;
    
    % FUNCTIONS FOR SCROLLING THE IMAGE
   case 'scroll_image'
    scroll_image(varargin{:});
   case 'propagate_ROIs'
    store_all_current_data(varargin{:});
    
    % CREATE ENVIRONMENT
   case 'create'
    SNR_ROI(varargin{:});
   case 'create_rois'
    create_ROIs(varargin{:});
   case 'update_path'
    update_path('old');
    
    % FUNCTIONS FOR THE AXIS CHANGES
   case 'update_corner_coors'
    update_corner_coors(varargin{:});	
    
   case 'clims_callback'
    cback = ['SNR_main(''update_moved_clims'',', num2str(varargin{1}),');'];
    set(SNR_fig, 'WindowButtonMotionFcn', cback);
    toggle_clims_BDF('Done');
   case 'update_clims'
    update_clims(varargin{:});
   case 'update_moved_clims'
    update_moved_clims(varargin{:});
   case 'done_clims_callback'
    % clear window functions
    set(SNR_fig, 	'WindowButtonMotionFcn', ' ',...
		      'WindowButtonDownFcn', ' ',...
		      'WindowButtonUpFcn', '  ');
    % return object funcions to normal
    toggle_clims_BDF('Off');
    % call again to update the xlims of the wl axes
    update_clims(2); 
    
   case 'update_zoom_coors'
    update_zoom_coors(varargin{:});
   case 'toggle_zoom'
    toggle_zoom(varargin{:});
    
    % FUNCTIONS TO SET AND MAINTAIN MOVABLE OBJECT CALLBACKS
    % CIRCLE CENTERS
   case 'center_callback'
    cback = ['SNR_main(''get_center_point'',',num2str(varargin{1}),');'];
    set(SNR_fig,   'WindowButtonMotionFcn', cback);
    toggle_objects_BDF('Done');
   case 'get_center_point'
    get_center_point(varargin{:});
    
    % AXIS MODIFIERS - angle and size of ROI
    % one square for everything!
   case 'axis1_callback'
    cback = ['SNR_main(''get_rotation_axis1'',',num2str(varargin{1}),');'];
    set(SNR_fig,'WindowButtonMotionFcn',cback );
    toggle_objects_BDF('Done');
   case 'get_rotation_axis1'
    get_rotation_axis1(varargin{:});
    
   case 'axis2_callback'
    cback = ['SNR_main(''get_rotation_axis2'',',num2str(varargin{1}),');'];
    set(SNR_fig,'WindowButtonMotionFcn',cback );
    toggle_objects_BDF('Done');
   case 'get_rotation_axis2'
    get_rotation_axis2(varargin{:});	
    
    % PROFILE TOOL CALLBACKS
   case 'profile_end_point_callback'		
    cback = ['SNR_main(''get_end_point'',',num2str(varargin{1}),');'];
    set(SNR_fig,   'WindowButtonMotionFcn', cback);
    toggle_objects_BDF('Done');
   case 'get_end_point'
    get_end_point(varargin{:});
    
    %	case 'profile_center_callback'		
    %		cback = ['SNR_main(''get_end_center_point'',',num2str(varargin{1}),');'];
    %		set(SNR_fig,   'WindowButtonMotionFcn', cback);
    %		toggle_objects_BDF('Done');
    %	case 'get_end_center_point'
    %		get_end_center_point(varargin{:});
    
   case 'profile_mid_point_callback'		
    cback = ['SNR_main(''get_mid_point'',',num2str(varargin{1}),');'];
    set(SNR_fig,   'WindowButtonMotionFcn', cback);
    toggle_objects_BDF('Done');
   case 'get_mid_point'
    get_mid_point(varargin{:});
    
    
    
    
   case 'done_callback'
    % clear window functions
    set(SNR_fig, 	'WindowButtonMotionFcn', ' ',...
		      'WindowButtonDownFcn', ' ',...
		      'WindowButtonUpFcn', '  ');
    % return object funcions to normal
    toggle_objects_BDF('Off');
    update_SNR(varargin{:});
    update_CNR(varargin{:});
   case 'update_SNR'
    update_SNR(varargin{:});
    update_CNR(varargin{:});
    
   case 'done_profile_callback'
    % clear window functions
    set(SNR_fig, 	'WindowButtonMotionFcn', ' ',...
		      'WindowButtonDownFcn', ' ',...
		      'WindowButtonUpFcn', '  ');
    % return object funcions to normal
    toggle_objects_BDF('Off');
    update_profile(varargin{:});
    update_CNR(varargin{:});
   case 'update_profile'
    update_profile(varargin{:});
    update_CNR(varargin{:});
    
    % SAVING AND STORING DATA 
   case 'store_current'
    store_current_data(varargin{:});
   case 'save_current'
    output_to_text(varargin{:});
    
    % TOGGLE ROIS
   case 'hide_ROIs'
    toggle_visible_ROIs(varargin{:});
    
case 'export_image'
    export_image(varargin{:});
    
case 'make_movie'
    make_momvie(varargin{:});
    
   otherwise
    disp(['Unimplemented Function:', action]);
  end;
	





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function SNR_ROI(image_list,im_num);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function to calculate SNR of a particular ROI in an image. 
% receives an image list (from generate_im_list)
% outputs the SNR in vector form.
  global SNR_fig
  
  % make the GUI
  SNR_GUI;
  h_image_axes = findobj(SNR_fig, 'Tag', 'Image_axes');
  h_image_num = findobj(SNR_fig,'Tag', 'Image_num_text');
  % Display first image in image_list
  current_image = load_image(image_list(im_num,:));
  set(SNR_fig, 'CurrentAxes',h_image_axes );
  
  % update editable text
  im_str = image_list(im_num,:);
  set(h_image_num, 'String', im_str(length(im_str)-4:length(im_str)));
  set(get(h_image_axes,'Title'), 'String', im_str);
  set(findobj(SNR_fig, 'Tag', 'Path_text'),'String',im_str(1:length(im_str)-5))

  % crate iamge
  h_image = imagesc(current_image);
  hold on;
  set(h_image, 'Tag', 'Image_object'); 
  %	set(h_image, 'ButtonDownFcn','SNR_main(''update_corners'')');
  colormap(gray);
  axis('equal');
  axis('tight');
  axis('off');
  
  % adjust drawing in axes and figure for speed
  set(SNR_fig,'Renderer', 'zbuffer');
  set(SNR_fig,'UserData', {image_list,im_num});
  set(h_image_axes,'Drawmode','fast', 'Tag', 'Image_axes');
  
  xlimits = get(h_image_axes,'Xlim');
  ylimits = get(h_image_axes,'Ylim');
  climits = get(h_image_axes,'Clim');
  
  set(findobj('Tag','Xmin_edit'),'String',num2str(floor(xlimits(1))) );
  set(findobj('Tag','Xmax_edit'),'String',num2str(floor(xlimits(2))) );	
  set(findobj('Tag','Ymin_edit'),'String',num2str(floor(ylimits(1))) );
  set(findobj('Tag','Ymax_edit'),'String',num2str(floor(ylimits(2))) );
  
  set(findobj('Tag','Cmin_edit'),'String',num2str(floor(climits(1))) )
  set(findobj('Tag','Cmax_edit'),'String',num2str(floor(climits(2))) );
  set(findobj('Tag','Clims_slider'),'Min', (climits(1)),'Max', (climits(2)));
  
  
  create_ROIs;
  update_SNR;
  update_profile;	
  update_CNR
  create_storage_struct(image_list);
  update_clims(1);
  create_wl_objects;
       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function im = load_image(im_str);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [im,header] = getsigna3(deblank(im_str));
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function update_corner_coors();
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this function changes the axes limits when the 
% corner coordinates have been changed. 
% after a zoom is done and after the user

  global SNR_fig

  % get necessary handles
  h_xmin = findobj(SNR_fig,'Tag','Xmin_edit');
  h_xmax = findobj(SNR_fig,'Tag','Xmax_edit');	
  h_ymin = findobj(SNR_fig,'Tag','Ymin_edit'); 
  h_ymax = findobj(SNR_fig,'Tag','Ymax_edit');
  
  
  h_image = findobj(SNR_fig, 'Tag', 'Image_object');
  
  % get values form handles
  xlims= [str2num(get(h_xmin,'String')) str2num(get(h_xmax,'String'))];
  ylims= [str2num(get(h_ymin,'String')) str2num(get(h_ymax,'String'))];
  size_im = size(get(h_image, 'CData'));

  % check to see ifuser mixed up the coordinates
  if xlims(1)>xlims(2)
    xlims = [xlims(2) xlims(1)];
  end;
  if ylims(1)>ylims(2)
    ylims = [ylims(2) ylims(1)];
  end;
  

  % check to see if user exceeded coordiantes
  if xlims(1)< 0, xlims(1)=0;, set(h_xmin, 'String', num2str(0));end;
  if ylims(1)< 0, ylims(1)=0;, set(h_ymin, 'String', num2str(0));end;
  if xlims(2)>size_im(1), xlims(2) = size_im(1);
    set(h_xmax, 'String', num2str(size_im(1)));
  end;
  if ylims(2)>size_im(2), ylims(2) = size_im(2);
    set(h_ymax, 'String', num2str(size_im(2)));
  end;
    
  set(findobj(SNR_fig, 'Tag', 'Image_axes'),...
      'Xlim', xlims, 'Ylim', ylims);
  
      
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function toggle_zoom();
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% functiont to toggle the zoom button after it is pressed. 

  global SNR_fig
  
  h_button = findobj(SNR_fig,'Tag','Zoom_button');
  vals = get(h_button, 'UserData');
  choice= vals(1,:);
  set(h_button, 'UserData', [vals(2,:); vals(1,:)]);
  set(h_button, 'String', ['Zoom ' , choice]);
  eval(['zoom ',lower(choice)]);
  if strcmp(choice,'Off'), SNR_main('update_zoom_coors');end;
  
  toggle_objects_BDF(choice);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function update_zoom_coors();
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Function refreshes the axes corner displays after a zoom has been done 

  global SNR_fig
  
  % get necessary handles
  h_xmin = findobj(SNR_fig,'Tag','Xmin_edit');
  h_xmax = findobj(SNR_fig,'Tag','Xmax_edit');	
  h_ymin = findobj(SNR_fig,'Tag','Ymin_edit'); 
  h_ymax = findobj(SNR_fig,'Tag','Ymax_edit');
  
  h_image = findobj(SNR_fig, 'Tag', 'Image_object');
  h_axes = findobj(SNR_fig, 'Tag', 'Image_axes');
  
  xlims = get(h_axes, 'Xlim');
  ylims = get(h_axes, 'Ylim');
  
  set(h_xmin, 'String', num2str(floor(xlims(1))));
  set(h_xmax, 'String', num2str(floor(xlims(2))));
  set(h_ymin, 'String', num2str(floor(ylims(1))));
  set(h_ymax, 'String', num2str(floor(ylims(2))));		
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function scroll_image(direction);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function to load the next image onto the screen
% receives direcion
%   1 -->
%  -1 <--
%   0 Refresh with new image (after path/image change)

  global SNR_fig
  
  h_image= findobj(SNR_fig,'Tag','Image_object');
  h_image_num = findobj(SNR_fig,'Tag','Image_num_text');
  % retrieve the image list from the figure''s Userdata
  temp_cell = get(SNR_fig, 'UserData');
  image_list = temp_cell{1};
  current_image = temp_cell{2};
  
  % wrap when image list lengths are exceeded
  if (current_image+direction)> size(image_list,1)
    new_image=1;
  elseif (current_image+direction)<1,
    new_image=size(image_list,1);
  else
    new_image = current_image+direction;
  end;
  
  temp_cell{2}=new_image;
  image_matrix = load_image(image_list(new_image,:));
  
  % update values on screen and to store	
  set(h_image,'CData',image_matrix);
  set(SNR_fig, 'UserData', temp_cell);
  im_str = image_list(new_image,:);
  set(h_image_num, 'String', upper(im_str(length(im_str)-4:length(im_str))));


  %update SNR values for new Image
  update_SNR;
  update_profile;
  update_CNR;
  update_clims(2);
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function create_ROIs();
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function to create the two ROI circles and the line profiel objects
% Each of the objects is assigned a callback funcion here...

  global SNR_fig
  
  h_axes = findobj(SNR_fig, 'Tag','Image_axes');
  xlims = get(h_axes, 'Xlim');
  ylims = get(h_axes, 'Ylim');
  
  % center =  [ x, y ]	
  R1_center = [0.75*xlims(1) + 0.25*xlims(2), 0.25*ylims(1) + 0.75*ylims(2)] ;
  R2_center = [0.75*xlims(1) + 0.25*xlims(2), 0.75*ylims(1) + 0.25*ylims(2)] ;   
  
  % radius is 5% of current axes for both ROIs
  R1_rad1 = 0.05*[ylims(2)-ylims(1)];
  R1_rad2 = 0.05*[ylims(2)-ylims(1)];
  
  R2_rad1 = 0.05*[ylims(2)-ylims(1)];
  R2_rad2 = 0.05*[ylims(2)-ylims(1)];
  
  % angle of each ROI starts at zero
  R1_theta = 0;
  R2_theta = 0;
  
  % generate angles for poitns - use 16 points
  % now have generic circle
  theta = (0:15:360)*2*pi/360;
  [xcoor, ycoor] =pol2cart(theta, 1);
  
  % FIRST CIRCLE
  % create one circle at the center of the image
  h_R1_center = plot(R1_center(2), R1_center(1), 'b+');
  set(h_R1_center, 'Tag', 'R1_ct_plus');
  set(h_R1_center, 'UserData', [R1_center, R1_rad1, R1_rad2, R1_theta]);
  
  h_R1_circ = plot(R1_rad1*xcoor+R1_center(2), R1_rad2*ycoor+R1_center(1), 'b-');
  set(h_R1_circ, 'LineWidth',1, 'Tag', 'R1_circ', 'UserData', [xcoor.', ycoor.']);
  
  % plot a yellow square for first axes and red square for second
  h_R1_axis1 = plot(R1_center(2)+R1_rad1, R1_center(1), 'ys');
  h_R1_axis2 = plot(R1_center(2), R1_center(1)-R1_rad2, 'ys');
  
  %SECOND CIRCLE
  % create a second circle at the upper left corner of the image
  h_R2_center = plot(R2_center(2), R2_center(1), 'r+');
  set(h_R2_center, 'Tag', 'R2_ct_plus');
  set(h_R2_center, 'UserData', [R2_center, R2_rad1, R2_rad2, R2_theta]);
  
  h_R2_circ = plot(R2_rad1*xcoor+R2_center(2), R2_rad2*ycoor+R2_center(1), 'R-');
  set(h_R2_circ, 'LineWidth', 1, 'Tag', 'R2_circ', 'UserData', [xcoor.', ycoor.']);
  
  % plot a yellow square for first axes and red square for second
  h_R2_axis1 = plot(R2_center(2)+R2_rad1, R2_center(1), 'ys');
  h_R2_axis2 = plot(R2_center(2), R2_center(1)-R2_rad2, 'ys');
  
  % clear the window button up function of the figure
  %set(SNR_fig, 'WindowButtonUpFcn', 'SNR_main(''done_callback'');');
  set([h_R1_center, h_R1_circ h_R1_axis1, h_R1_axis2], 'Erasemode', 'normal')
  set([h_R2_center, h_R2_circ h_R2_axis1, h_R2_axis2], 'Erasemode', 'normal');
  
  % CREATE PROFILE LINE AND ENDPOINTS; replot graph too
  
  % get the location of the two endpoints. Assume a zero degree rotation (horizontal)
  % for first display
  
  % interaxis distance
  p_ilength= 0.10*[ylims(2)-ylims(1)];
  p_theta = 0;
  
  %prototype endpoints
  ep2 = [0.75*xlims(1) + 0.25*xlims(2) , mean(ylims)];
  ep1 = [0.25*xlims(1) + 0.75*xlims(2) , mean(ylims)];
  % all points rotate about this point
  cc = [mean([ep1(1),ep2(1)]), mean([ep1(2),ep2(2)])];
  
  ax1_cc = [cc(1),cc(2) - p_ilength];
  ax2_cc = [cc(1),cc(2) + p_ilength];
  
  ax1_ep1 = [ep1(1), ep1(2)-p_ilength];
  ax1_ep2 = [ep2(1), ep2(2)-p_ilength];
  
  ax2_ep1 = [ep1(1), ep1(2)+p_ilength];
  ax2_ep2 = [ep2(1), ep2(2)+p_ilength];
  
  % profile lines
  h_profile_line = plot(	[ax1_ep1(1),ax1_ep2(1)],...
				[ax1_ep1(2),ax1_ep2(2)], 'b-');
  h_profile2_line = plot( [ax2_ep1(1),ax2_ep2(1)],...
			  [ax2_ep1(2),ax2_ep2(2)], 'r-');
  
  % h_profile2_line = plot([ax1_cc(1) ax2_cc(1)], [ax1_cc(2), ax2_cc(2)], 'g-');
  
  % store the 7 protype points points necessary for drawing all objects	
  storage_points = [ 	ax1_ep1;  ax1_ep2;   ax1_cc;   ...  
		    ax2_ep1;  ax2_ep2;   ax2_cc;...
		   ];
  
  set(h_profile_line, 'UserData', storage_points);			
  set(h_profile2_line, 'UserData', p_theta);
  % draw endpoints and mid points separately
	      
  h_end1_1 = plot(ax1_ep1(1),ax1_ep1(2), 'bo');
  h_end1_2 = plot(ax1_ep2(1),ax1_ep2(2), 'bo');
  h_end2_1 = plot(ax2_ep1(1),ax2_ep1(2), 'ro');
  h_end2_2 = plot(ax2_ep2(1),ax2_ep2(2), 'ro');
  
  %h_p_center = plot(cc(1), cc(2), 'y+');
  h_ax1_center = plot(ax1_cc(1), ax1_cc(2),'y+');
  h_ax2_center = plot(ax2_cc(1), ax2_cc(2),'y+');
  
  h_profile_axes = findobj(SNR_fig,'Tag','Profile_axes');
  
  % use one hundread samples as first attempt
  set(SNR_fig,'CurrentAxes', h_profile_axes);
  
  h_line1_plot = plot((1:100),ones(1,100),'b-');
  hold on;
  set(h_line1_plot, 'Tag', 'Profile1_line');
  h_line2_plot = plot((1:100),ones(1,100),'r-');
  
  h_max1 = plot(1,1,'bs');
  h_max2 = plot(1,1,'rs');
  h_min1 = plot(1,1,'bo');
  h_min2 = plot(1,1,'ro');
  
  set(h_max1, 'Tag', 'profile_max1_point');
  set(h_max2, 'Tag', 'profile_max2_point');
  set(h_min1, 'Tag', 'profile_min1_point');
  set(h_min2, 'Tag', 'profile_min2_point');
  
  set([h_line1_plot h_line2_plot], 'LineWidth',2);
  set(h_line2_plot, 'Tag', 'Profile2_line')
  set(gca, 'Tag', 'Profile_axes','Color', [0.8 0.8 0.8]);
  
  % store the handles of the two ROI circles and thr profile line
  % in the UserData of the Axes
  all_handles =[ [ h_R1_center,h_R1_circ, h_R1_axis1, h_R1_axis2]; ...
		 [ h_R2_center,h_R2_circ, h_R2_axis1, h_R2_axis2]; ...
		 [ h_profile_line, h_profile2_line, h_line1_plot, h_line2_plot];...
		 [ h_end1_1, h_end1_2, h_ax1_center, 0 ];...
		 [ h_end2_1, h_end2_2, h_ax2_center, 0 ];...
	       ];
  % set the Button down functions for each object
  set(h_axes, 'UserData',all_handles);
  toggle_objects_BDF('Off');
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function toggle_objects_BDF(val);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function to set and reset ROI objects ButtonDownFcn''s
% before and after action callbacks 
  global SNR_fig
  
  h_image_axes = findobj(SNR_fig,'Tag','Image_axes');
  h_objects = get(h_image_axes, 'UserData');
  if strcmp(val,'Off')
    % turning zoom on, setting all object 
    % callbacks back to normal
    % centers get callbacks for motion
    set(h_objects(1,1), 'ButtonDownFcn','SNR_main(''center_callback'',1);');
    set(h_objects(2,1), 'ButtonDownFcn','SNR_main(''center_callback'',2);');
    
    % yellow squares
    set(h_objects(1,3), 'ButtonDownFcn','SNR_main(''axis1_callback'',1);');
    set(h_objects(2,3), 'ButtonDownFcn','SNR_main(''axis1_callback'',2);');
    
    % red square callbacks
    set(h_objects(1,4), 'ButtonDownFcn','SNR_main(''axis2_callback'',1);');
    set(h_objects(2,4), 'ButtonDownFcn','SNR_main(''axis2_callback'',2);');			
    
    %3[ h_profile_line, h_profile2_line, h_line1_plot, h_line2_plot];...
    %4[ h_end1_1, h_end1_2, h_ax1_center, 0];... 
    %5[ h_end2_1, h_end2_2  h_ax2_center, 0];...
    
    % green end point callbacks
    for i = 1:2
      set(h_objects(4,i), 'ButtonDownFcn', ...
			['SNR_main(''profile_end_point_callback'',',num2str(i),');']);
      
    end;
    
    for i = 1:2
      set(h_objects(5,i), 'ButtonDownFcn', ...
			['SNR_main(''profile_end_point_callback'',',num2str(i+3),');']);
      
    end;		
    
    set(h_objects(4,3), 'ButtonDownFcn', ...
		      ['SNR_main(''profile_mid_point_callback'',',num2str(1),');']);              
    
    set(h_objects(5,3), 'ButtonDownFcn', ...
		      ['SNR_main(''profile_mid_point_callback'',',num2str(2),');']);              
    
    
    
  elseif strcmp(val,'On ')
    %turn zoom off so turn objects on
    set(h_objects, 'ButtonDownFcn', '  ');
    
  elseif strcmp(val,'Done')
    % turn the ButtonDownFcns to the same as the window button down funcs
    set(h_objects(1:2,:), 'ButtonDownFcn', 'SNR_main(''done_callback'')');
    set(h_objects(4:5,1:3), 'ButtonDownFcn', 'SNR_main(''done_profile_callback'')');
  end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function toggle_window_BDF(val);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function to set and reset ROI objects ButtonDownFcn''s
% before and after action callbacks 
global SNR_fig
	if strcmp(val,'Done');
		set(SNR_fig, 	'WindowButtonDownFcn','SNR_main(''done_callback'');');
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function get_center_point(ROI);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to update and move the centers of 
% both circles. Expects ROI to be either 1 or 2;
% NO FINDOBJS- Too slow!

% get the current point
    points = get(gca,'CurrentPoint') ;
    center = [points(1,2), points(1,1)];
    
    % get necesary handles
    all_handles = get(gca,'UserData');
    % get ROI specific object handles	
    %handles = [ h_R1_center, h_R1_circ, h_R1_axis1, h_R1_axis2]
    handles = all_handles(ROI,:);
    
    % old_cent = [ centx, centy, R1 R2 theta];
    old_info = get(handles(1), 'UserData');
    
    % get normalized circle coordinate point, from circle''s UserData
    coors = get(handles(2),'UserData');
    
    %rotate to present angl
    %rotation maxtrig [ cos -sin, sin cos]
    Rmat = [cos(old_info(5)), -sin(old_info(5)); sin(old_info(5)), cos(old_info(5))];
    coors = (Rmat*([old_info(3)*coors(:,1), old_info(4)*coors(:,2) ]).').';
    
    % rotate the axis for new length
    rotR1 = Rmat*([old_info(3), 0].');
    rotR2 = Rmat*([0, old_info(4)].');
    
    set(handles(1), 'Xdata', center(2), 'YData', center(1));
    set(handles(2), 'XData', coors(:,1)+center(2), 'YData', coors(:,2)+center(1));
    set(handles(3), 'XData', rotR1(1)+center(2), 'YData', rotR1(2)+center(1));
    set(handles(4), 'XData', center(2)-rotR2(1),'YData', center(1)-rotR2(2));
    set(handles(1), 'UserData', [center, old_info(3:5) ]);
    
    drawnow;
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function get_rotation_axis1(ROI)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to update angle and shape of
% both circles. Expects ROI to be either 1 or 2;
% NO FINDOBJS- Too slow!

   % get the current point
	points = get(gca,'CurrentPoint') ;
	newpt = [points(1,2), points(1,1)];
	
	% get necesary handles
	all_handles = get(gca,'UserData');
	% get ROI specific object handles	
	%handles = [ h_R1_center, h_R1_circ, h_R1_axis1, h_R1_axis2]
	handles = all_handles(ROI,:);
	
	% old_cent = [ centx, centy, R1 R2 theta];
	old_info = get(handles(1), 'UserData');

	% get normalized circle coordinate point, from circle''s UserData
	coors = get(handles(2),'UserData');

	% calculate new values for axis
	newR1 = sqrt(  (newpt(2) - old_info(2))^2 + (newpt(1) - old_info(1))^2 );
	
	% theta is defined as the angle between the horizontal 
	% and the ray from the center of teh circle to the new pt.
	new_theta = sign(newpt(1)-old_info(1))* acos((newpt(2)-old_info(2))/newR1 );
	%new_theta*180/pi
	% rotate to present angle
	Rmat = [cos(new_theta), -sin(new_theta); sin(new_theta), cos(new_theta)];
	
	rotR1 = Rmat*([newR1, 0].');
	rotR2 = Rmat*([0, old_info(4)].');

	coors = (Rmat*([newR1*coors(:,1), old_info(4)*coors(:,2) ]).').';

	set(handles(2), 'XData', coors(:,1)+old_info(2), 'YData', coors(:,2)+old_info(1));
	set(handles(3), 'XData', rotR1(1)+old_info(2), 'YData', rotR1(2)+old_info(1));
	set(handles(4), 'XData', old_info(2)-rotR2(1),'YData', old_info(1)-rotR2(2));
	set(handles(1), 'UserData', [old_info(1:2), newR1, old_info(4) new_theta]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function get_rotation_axis2(ROI)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to update angle and shape of
% both circles. Expects ROI to be either 1 or 2;
% NO FINDOBJS- Too slow!

	% get the current point
	points = get(gca,'CurrentPoint') ;
	newpt = [points(1,2), points(1,1)];
	
	% get necesary handles
	all_handles = get(gca,'UserData');
	% get ROI specific object handles	
	%handles = [ h_R1_center, h_R1_circ, h_R1_axis1, h_R1_axis2]
	handles = all_handles(ROI,:);
	
	% old_cent = [ centx, centy, R1 R2 theta];
	old_info = get(handles(1), 'UserData');

	% get normalized circle coordinate point, from circle''s UserData
	coors = get(handles(2),'UserData');

	% calculate new values for axis
	newR2 = sqrt(  (newpt(2) - old_info(2))^2 + (newpt(1) - old_info(1))^2 );
	
	% theta is defined as the angle between the horizontal 
	% and the ray from the center of teh circle to the new pt.
	new_theta = sign(newpt(1)-old_info(1))*acos((newpt(2)-old_info(2))/newR2 )+pi/2;
	% new_theta*180/pi
	% rotate to present angle
	Rmat = [cos(new_theta), -sin(new_theta); sin(new_theta), cos(new_theta)];
	
	rotR1 = Rmat*([old_info(3), 0].');
	rotR2 = Rmat*([0, newR2].');

	coors = (Rmat*([old_info(3)*coors(:,1), newR2*coors(:,2) ]).').';

	set(handles(2), 'XData', coors(:,1)+old_info(2), 'YData', coors(:,2)+old_info(1));
	set(handles(3), 'XData', rotR1(1)+old_info(2), 'YData', rotR1(2)+old_info(1));
	set(handles(4), 'XData', old_info(2)-rotR2(1),'YData', old_info(1)-rotR2(2));
	set(handles(1), 'UserData', [old_info(1:2), old_info(3) , newR2, new_theta]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function update_SNR(ROI)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the mean, std, and pixel blanks for the particular ROI,
% and recalc the SNR

global SNR_fig

	if nargin<1
		ROI = 1:2;
	end;

	
	% get necesary handles
	h_image_axes = findobj(SNR_fig,'Tag', 'Image_axes');
	all_handles = get(h_image_axes,'UserData');
	h_image= findobj(SNR_fig,'Tag','Image_object');
	% get ROI specific object handles	
	% get the blanks handles and [R1mn R2mn R1s R2s R1px R2px SNR ncorr]

	blank_handles = get(findobj(SNR_fig,'Tag','ROI1'),'UserData');

	image_data =get(h_image ,'CData');
	noise_correction_factor = str2num(get(blank_handles(8),'String'));

	for i=1:length(ROI)
		%handles = [ h_R1_center, h_R1_circ, h_R1_axis1, h_R1_axis2]
		handles = all_handles(i,:);

		% get normalized circle coordinate point, from circle''s UserData
		coors = get(handles(2),'UserData');

		% old_cent = [ centx, centy, R1 R2 theta];
		old_info = get(handles(1), 'UserData');

		%create the points coordinates 
		Rmat = [cos(old_info(5)), -sin(old_info(5)); sin(old_info(5)), cos(old_info(5))];
		coors = (Rmat*([old_info(3)*coors(:,1), old_info(4)*coors(:,2) ]).').';
		coors(:,1)= coors(:,1)+old_info(2);
		coors(:,2)= coors(:,2)+old_info(1);
		
		BW = roipoly(image_data,coors(:,1), coors(:,2));
%%		debug
%			figure
%			imagesc(BW);
%			axis('equal');
%			axis('tight');
%			figure(SNR_fig);
%			[xx,yy] = find(BW);
%			plot(xx,yy,'ws');
		ff = find(BW);
		data1 = image_data(ff);
		mns(i) = mean(data1(:));
		stds(i) = std(data1(:));
		
		mns(i) = round(mns(i)*10)/10;
		stds(i) = round(stds(i)*10)/10;
				
		set(blank_handles(i),  'String', num2str(mns(i)));
		set(blank_handles(i+2),'String', num2str(stds(i)));	%set std
		set(blank_handles(i+4),'String', num2str(length(ff))); %set pixels
	end;

	SNR = mns(1)/(stds(2)*noise_correction_factor);
	set(blank_handles(7), 'String', num2str((round(SNR*100)/100 )));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function update_CNR();
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the mean, std, and pixel blanks for the particular ROI,
% and recalc the SNR

global SNR_fig
	
	% get necesary handles
	h_image_axes = findobj(SNR_fig,'Tag', 'Image_axes');
	all_handles = get(h_image_axes,'UserData');

	% get ROI specific object handles	
	% get the blanks handles and [P1mn P2mn P1s P2s CNR ncorr];
	blank_handles_prof = get(findobj(SNR_fig,'Tag','PRFL1'),'UserData');
	blank_handles_rois = get(findobj(SNR_fig,'Tag','ROI1'),'UserData');

	prof_handles =all_handles(3,3:4);

	% get the noise std
	std_noise = str2num(get(blank_handles_rois(4),'String'));
	% get the noise correction factor
	noise_correction_factor = str2num(get(blank_handles_prof(6),'String'));

	% get the means and stds of each profile 
	for i=1:length(prof_handles)
		
		data1 = get(prof_handles(i),'YData');				

		mns(i) = mean(data1(:));
		stds(i) = std(data1(:));
		
		mns2(i) = round(mns(i)*10)/10;
		stds2(i) = round(stds(i)*10)/10;
				
		set(blank_handles_prof(i),  'String', num2str(mns2(i)));
		set(blank_handles_prof(i+2),'String', num2str(stds2(i)));	%set std
	end;

	CNR = (mns(1) - mns(2))/(std_noise*noise_correction_factor);
	set(blank_handles_prof(5), 'String', num2str((round(CNR*100)/100 )));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function [image_list, im_num] = update_path(action);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the mean, std, and pixel blanks for the particular ROI,
% and recalc the SNR
global SNR_fig

if strcmp(action,'new')
    SNR_fig = [];
    % insure proper file is selected...
    % first call, allow user to pick first image to be displayed
    % and standard path.
    filterspec= [pwd,filesep,'*I.*'];
    [filename,pathname] = uigetfile(filterspec, 'Select Path and Image');
elseif strcmp(action,'old') | strcmp(action, 'imageold')
    old_path = get(findobj(SNR_fig,'Tag', 'Path_text'),'String');		
    filterspec= [old_path,filesep, '*I.*'];
    [filename,pathname] = uigetfile(filterspec, 'Select Path and Image');
end;

	if (filename~=0)
		% now generate the sorted image list
		image_list = generate_image_list(pathname);

		% locate the index of the chosen image within the image list
		for i =1:size(image_list,1)
			find_str = findstr(lower(image_list(i,:)),lower(filename));
			if ~isempty(find_str), im_num = i;, end;
		end;



		if strcmp(action,'old')			% update path	
			set(findobj(SNR_fig, 'Tag', 'Path_text'),'String',...				
             upper(pathname(1:length(pathname)-1)));
			set(SNR_fig,'UserData', {image_list,im_num});
			% now refresh the screen with chosen image
			scroll_image(0)
			% replace the old data structure
			create_storage_struct(image_list);
		end;
	else
		% get out of program
		image_list = []; im_num = [];
	end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function image_list = generate_image_list(pathname);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function to generate image_list for display
  image_struct = dir([pathname,'*I.*'])
  temp = [];
  for i = 1:length(image_struct)
      if ~image_struct(i).isdir
          temp = strvcat(temp,[pathname , image_struct(i).name]);
      end;
  end;
  temp
  % now sort the images based on the position of the 'I.' 
  % assumes all the names are the same lengths
  image_list = sortrows(temp, [findstr('I.',temp(1,:)) :1:  findstr('I.',temp(1,:))+4   ]);
  % now sort the list, as it will not necessarily be in ascending order..
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function update_profile();
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to update the profile display after a change in endpoint


global SNR_fig

	h_image_axes = findobj(SNR_fig, 'Tag', 'Image_axes');
	all_handles = get(h_image_axes,'UserData');

	h_image = findobj(SNR_fig,'Tag','Image_object');
	image_data =get(h_image ,'CData');
	
	num_samples = str2num(get(findobj(SNR_fig,'Tag','Samples_edit'),'String'));

	% get the xdata of the profile lines (end points)
	xdata(1,:) =get(all_handles(3,1),'XData');
	ydata(1,:) =get(all_handles(3,1),'YData');

	xdata(2,:) =get(all_handles(3,2),'XData');
	ydata(2,:) =get(all_handles(3,2),'YData');
	
	[s1,s2] = size(image_data);
	if (sum(find(xdata<1))), xdata(find(xdata<1))= 1; end;
	if (sum(find(ydata<1))), ydata(find(ydata<1))= 1; end;

	if (sum(find(xdata>s1))),xdata(find(xdata<s1))= s1; end;
	if (sum(find(ydata>s2))),ydata(find(ydata<s2))= s2; end;
     
	xvector = linspace((xdata(1,1)), (xdata(1,2)), num_samples);
	yvector = linspace((ydata(1,1)), (ydata(1,2)), num_samples);		

	if(sum(find(~(size(xvector))))>0) xvector = xdata(1)*ones(1,num_samples); end;
	if(sum(find(~(size(yvector))))>0) yvector = ydata(1)*ones(1,num_samples); end;

	zi = interp2(image_data,xvector,yvector, 'linear');

	xvector2 = linspace((xdata(2,1)), max(xdata(2,2)), num_samples);
	yvector2 = linspace((ydata(2,1)), max(ydata(2,2)), num_samples);

	if(sum(find(~(size(xvector2))))>0) xvector2 = xdata(4)*ones(1,num_samples); end;
	if(sum(find(~(size(yvector2))))>0) yvector2 = ydata(4)*ones(1,num_samples); end;

	zi2 = interp2(image_data, xvector2, yvector2);
	% set the ydata for the profile plot
	set(all_handles(3,3), 'Xdata', 1:num_samples, 'YData', zi);
	set(all_handles(3,4), 'Xdata', 1:num_samples, 'YData', zi2);
   
   min1 = min(zi);
   min2 = min(zi2);
   max1 = max(zi);
   max2 = max(zi2);
   
   min1_pos = find(zi==min1(1));
   min2_pos = find(zi2==min2(1));
   max1_pos = find(zi==max1(1));
   max2_pos = find(zi2==max2(1));
   
   min1_pos = min1_pos(1);
   min2_pos = min2_pos(1);
   max1_pos = max1_pos(1);
   max2_pos = max2_pos(1);
   
   set(findobj(SNR_fig, 'Tag', 'profile_min1_point'), ...
      'Xdata', min1_pos, 'YData', min1);
   set(findobj(SNR_fig, 'Tag', 'profile_min2_point'), ...
      'Xdata', min2_pos, 'YData', min2);
   set(findobj(SNR_fig, 'Tag', 'profile_max1_point'), ...
      'Xdata', max1_pos, 'YData', max1);
   set(findobj(SNR_fig, 'Tag', 'profile_max2_point'), ...
      'Xdata', max2_pos, 'YData', max2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function get_end_point(ep);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to update the end points and line
% of the profile tool. 

%1,2 or 4,5 for ep
  
% get the current point
  points = get(gca,'CurrentPoint') ;
  new_point = [points(1,1), points(1,2)];
  
  % get necesary handles
  all_handles = get(gca,'UserData');
  
  const = 0;
  if ep>2 const =3; end;
  
  const2 = -1;
  if mod(ep-const,2) const2 = +1; end;
  
  
  %6X2
  storage_points = get(all_handles(3,1),'UserData');
  center_point = storage_points(3+const,:);
  old_point = storage_points(ep,:) ;
  complement_point = storage_points(ep + const2,:);
  center_point  = (complement_point +  new_point)./2;
  
  storage_points(ep,:)= new_point;
  storage_points(3+const, :) = center_point; 
  
  %  plot(center_point(1), center_point(2), 'rx');       
  %  plot(new_point(1), new_point(2), 'bx');       
  %  plot(complement_point(1), complement_point(2), 'yx');       
  
  const3=0;
  if (ep>2) const3=1;end;
  
  % update lines
  set(all_handles(3,1+const3), 'XData', [storage_points(1+3*const3,1) storage_points(2+3*const3,1)],...
		    'YData', [storage_points(1+3*const3,2) storage_points(2+3*const3,2)]);
  % update corners
  set(all_handles(4+const3,1), 'XData', storage_points(1+3*const3,1),...
		    'Ydata', storage_points(1+3*const3,2));		%ep 1
  set(all_handles(4+const3,2), 'XData', storage_points(2+3*const3,1),... 
		    'Ydata', storage_points(2+3*const3,2));		%ep 2
  set(all_handles(4+const3,3), 'Xdata', storage_points(3+3*const3,1),...
		    'YData', storage_points(3+3*const3,2));               % ax center    
  
  % note no change to prototype points with respect to size...
  set(all_handles(3,1),'UserData', storage_points);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function get_mid_point(ep);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to update the end points and line
% of the profile tool. 

  

% get the current point
  points = get(gca,'CurrentPoint') ;
  new_center_point = [points(1,1), points(1,2)];
  
  % get necesary handles
  all_handles = get(gca,'UserData');
  
  % handles of interest...
  %handles = %3	[ h_profile_line, h_profile2_line, h_line1_plot, h_line2_plot];...
  %4	[ h_end1_1(1), h_end1_2(2), h_ax1_center(1)
  %5   [ h_end2_1(3), h_end2_2(4), h_ax2_center(2)];...
  %storage_points = [   ax1_cc;	ax1_ep1; ax1_ep2 	...	
  %		      ax2_cc  ; ax2_ep1; ax2_ep2	...
  
  storage_points = get(all_handles(3,1),'UserData');
  
  const=1;
  if ep==1 const =0; end;
  
  old_center_point = storage_points(3+3*const,:);
  % relocate end points
  storage_points((1:3)+3*const,:) = storage_points((1:3)+3*const,:) ...
      + repmat(-1*old_center_point + new_center_point,3,1);
  
  const3=0;
  if (ep>1) const3=1;end;
  
  % update lines
  set(all_handles(3,1+const3), 'XData', [storage_points(1+3*const3,1) storage_points(2+3*const3,1)],...
		    'YData', [storage_points(1+3*const3,2) storage_points(2+3*const3,2)]);
  % update corners
  set(all_handles(4+const3,1), 'XData', storage_points(1+3*const3,1),...
		    'Ydata', storage_points(1+3*const3,2));		%ep 1
  set(all_handles(4+const3,2), 'XData', storage_points(2+3*const3,1),... 
		    'Ydata', storage_points(2+3*const3,2));		%ep 2
  set(all_handles(4+const3,3), 'Xdata', storage_points(3+3*const3,1),...
		    'YData', storage_points(3+3*const3,2));               % ax center    
  
  % note no change to prototype points with respect to size...
  set(all_handles(3,1),'UserData', storage_points);
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function get_end_center_point(ep);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to update the end points and line
% of the profile tool. 

% get the current point
  points = get(gca,'CurrentPoint') ;
  new_center = [points(1,1), points(1,2)];
  
  % get necesary handles
  all_handles = get(gca,'UserData');
  
  % handles of interest...
  %handles = %3	[ h_profile_line, h_profile2_line, h_line1_plot, h_line2_plot];...
  %4	[ h_end1_1(1), h_end1_2(2), h_end2_1(3), h_end2_2(4)];...
  %5	[ h_p_center(1), h_ax1_center(2), h_ax2_center(3), 0];...
  %storage_points = [ 	cc ;  	ax1_cc;	ax2_cc; 			...	
  %			   		ax1_ep1; 	ax1_ep2;	ax2_ep1;  ax2_ep2;	...
  %BDF	
  %	for i = 1:4
  %	set(h_objects(4,i), 'ButtonDownFcn', ['SNR_main(''end_point_callback'',',num2str(i),');']);
  %	end;
  %	for i = 1:3
  %	set(h_objects(5,i), 'ButtonDownFcn', ['SNR_main(''end_center_callback'',',num2str(i),');']);
  %	end;		
  
  % prototypes are centered (0,0)
  sp = get(all_handles(3,1),'UserData');
  
  % shift to (0,0) by subtracting the old center 
  % get old angle; rotate; then shift to new center
  theta = get(all_handles(3,2),'UserData');
  Rmat = [cos(theta), -sin(theta) ; sin(theta) cos(theta)];
  rp(1:7,:) = [[0,0];(Rmat*sp(2:7,:).').'] + repmat(new_center,7,1);
  
  set(all_handles(3,1), 'XData', [rp(4,1) rp(5,1)],...
		    'YData', [rp(4,2) rp(5,2)]);
  set(all_handles(3,2), 'XData', [rp(6,1) rp(7,1)],...
		    'YData', [rp(6,2) rp(7,2)]);
  % update corners
  set(all_handles(4,1), 'XData', rp(4,1), 'Ydata', rp(4,2));%ep1,1
  set(all_handles(4,2), 'XData', rp(5,1), 'Ydata', rp(5,2));%ep1,2
  set(all_handles(4,3), 'XData', rp(6,1), 'Ydata', rp(6,2));%ep2,1
  set(all_handles(4,4), 'XData', rp(7,1), 'Ydata', rp(7,2));%ep2,2
  
  % update centers
  set(all_handles(5,1), 'XData', rp(1,1), 'Ydata', rp(1,2));		%main center
  set(all_handles(5,2), 'XData', rp(2,1), 'Ydata', rp(2,2));		%ax1 center
  set(all_handles(5,3), 'XData', rp(3,1), 'Ydata', rp(3,2));		%ax2 center
  
  % update center and store again
  sp(1,:) = new_center;
  set(all_handles(3,1),'UserData',sp);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function store_all_current_data();
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to store currently displayed data 
% in memory so that user can later output a batch for an image group

  global SNR_fig

  % get the miage 
  current_data = getuprop(SNR_fig, 'CurrentData');
  
  for kk = 1:length(current_data);
    store_current_data;
    scroll_image(1);
  end;
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function store_current_data();
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to store currently displayed data 
% in memory so that user can later output a batch for an image group

  global SNR_fig
  current_data = getuprop(SNR_fig,'CurrentData');
  
  temp_cell = get(SNR_fig, 'UserData');
  current_image = temp_cell{2};
  
  current_data(current_image).ROI1_mean = (get(findobj(SNR_fig, ... 
						  'Tag', 'R1_mn_text'),'String'));
  current_data(current_image).ROI1_std = (get(findobj(SNR_fig, ...
						  'Tag', 'R1_std_text'),'String'));
  current_data(current_image).ROI2_mean = (get(findobj(SNR_fig, ...
						  'Tag', 'R2_mn_text'),'String'));
  current_data(current_image).ROI2_std = (get(findobj(SNR_fig, ...
						  'Tag', 'R2_std_text'),'String'));
  current_data(current_image).ROI1_pix = (get(findobj(SNR_fig, ...
						  'Tag', 'R1_px_text'),'String'));
  current_data(current_image).ROI2_pix = (get(findobj(SNR_fig, ...
						  'Tag', 'R2_px_text'),'String'));
  current_data(current_image).SNR = (get(findobj(SNR_fig, ...
						 'Tag', 'SNR_text'),'String'));
  current_data(current_image).Profile1_mean = (get(findobj(SNR_fig, ...
						  'Tag', 'P1_mn_text'),'String'));
  current_data(current_image).Profile1_std = (get(findobj(SNR_fig, ...
						  'Tag', 'P1_std_text'),'String'));
  current_data(current_image).Profile2_mean =(get(findobj(SNR_fig, ...
						  'Tag', 'P2_mn_text'),'String'));
  current_data(current_image).Profile2_std = (get(findobj(SNR_fig, ...
						  'Tag', 'P2_std_text'),'String'));
  current_data(current_image).CNR = (get(findobj(SNR_fig, ...
						 'Tag', 'CNR_text'),'String'));
  
  current_data(current_image).Profile1 = (get(findobj(SNR_fig,...
						  'Tag', 'Profile1_line'),'Ydata'));
  current_data(current_image).Profile2 = (get(findobj(SNR_fig,...
						  'Tag', 'Profile2_line'),'Ydata'));
  
  setuprop(SNR_fig,'CurrentData', current_data); 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function output_to_text();
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to output current stored data into a 
% text file that is excel readable

  global SNR_fig
  
  data = getuprop(SNR_fig,'CurrentData');
  [filename, pathname] = uiputfile([pwd, filesep,'*.SNR'], 'Enter Name & Location to save');
  fid = fopen([pathname, filename],'w');
  filename
  fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\%s\t%s\t%s\t%s%s\n',... 
	  'Image name', 'ROI1 mean', 'ROI1 std', 'ROI1 pix' ,...
	  'ROI2 mean', 'ROI2 std', 'ROI2 pix', 'SNR',...
	  'Profile1 mean', 'Profile1 std', 'Profile2 mean', 'Profile2 std', ...
	  'CNR',';');
  fprintf(fid,'\n');   
  
  for i = 1:length(data)
    if isempty(data(i).ROI1_mean)
      fprintf(fid, '%s\t\n', data(i).Image_name);
    else
      fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\%s\t%s\t%s\t%s\n',...   
	      data(i).Image_name,...
	      data(i).ROI1_mean,...
	      data(i).ROI1_std,...
	      data(i).ROI1_pix,...
	      data(i).ROI2_mean,...
	      data(i).ROI2_std,...
	      data(i).ROI2_pix,...
	      data(i).SNR,...
	      data(i).Profile1_mean,...
	      data(i).Profile1_std,...
	      data(i).Profile2_mean,...
	      data(i).Profile2_std,...
	      data(i).CNR...
	      );
      if get(findobj(SNR_fig,'Tag', 'Store_profile_radiobutton'),'Value')
	fprintf(fid, '%s\t', 'Profile1');
	for kk = 1:length(data(i).Profile1)
	  fprintf(fid, '%d\t', data(i).Profile1(kk));
	end;
	fprintf(fid, '%s\t', 'Profile2');
	for kk = 1:length(data(i).Profile2)
	  fprintf(fid, '%d\t', data(i).Profile2(kk));
	end;
      end;
      fprintf(fid,'\n');
    end;
    
  end;
  
  fprintf(fid, '\n');
  fclose(fid);
  
  if get(findobj(SNR_fig,'Tag', 'Store_profile_radiobutton'),'Value')
    seriespath = get(findobj(SNR_fig, 'Tag', 'Path_text'),'String');
    %['save ', pathname , filename, ' seriespath data']	  
    eval(['save ', pathname , filename, ' seriespath data']);
  end;
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function create_storage_struct(image_list);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to create the data structure used to store
% the calculated data

  global SNR_fig
  
  % now put the image_list and other results into a 
  % structure in memory
  
  current_data = struct('Image_name', [],...
			'ROI1_mean', [],...
			'ROI1_std', [],...
			'ROI2_mean', [],...
			'ROI2_std', [],...
			'ROI1_pix', [],...
			'ROI2_pix', [],...
			'SNR', [],...
			'Profile1_mean', [],...
			'Profile1_std', [],...
			'Profile2_mean', [],...
			'Profile2_std', [],...
			'CNR', [],...
			'Profile1', [],...
			'Profile2', []);
  
                              
  for jj = 1:size(image_list,1)
    current_data(jj).Image_name = image_list(jj,:);
  end;
  setuprop(SNR_fig, 'CurrentData', current_data);
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function update_clims(object);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this function changes the color limits of the image
% object = 1 --> editable text boxes ... update slider, then change image
% object = 2 --> auto clim changed ... update text boxes then change image
%                or image scrolling arrows activated (scroll_image). 
  global SNR_fig


  h_window_axes = findobj(SNR_fig,'Tag', 'Window_axes');
  h_auto = findobj(SNR_fig,'Tag', 'Auto_clim_radiobutton');
  
  data = getuprop(SNR_fig, 'windowlevel');
  if isempty(data)
    h_cmin = findobj(SNR_fig,'Tag', 'Cmin_edit');
    h_cmax = findobj(SNR_fig,'Tag', 'Cmax_edit');
    h_image_axes = findobj(SNR_fig, 'Tag','Image_axes');
  else
    h_image_axes = data(7);
    h_cmin = data(8);
    h_cmax = data(9);
  end;
  
  
  if (object==1) % call from the text boxes
    % turn radiobutton off
    set(h_auto, 'Value', 0);
    
    % get clim values from editable text
    clims = [ str2num(get(h_cmin, 'String')) str2num(get(h_cmax, 'String'))];
    
    %update the plot;   
    level = mean(clims);
    window = level - clims(1);
    % update objects in plot
    set(h_image_axes, 'Clim', clims);    
    set(h_window_axes, 'UserData', [window, level]);
    if ~isempty(data)
      data(1) = window;
      data(2) = level;
      set(data(3), 'Xdata', data(2));
      set(data(4), 'Xdata', [ data(2)- data(1)]);
      set(data(5), 'Xdata', [ data(2)+ data(1)]) ;
      % set the axes to the closest hundred of the currently set clim
      oldline = [100*floor((data(2)-data(1))/100) 100*ceil((data(2)+data(1))/100)];
      set(data(6), 'Xdata', [oldline(1), data(2)-data(1), data(2)+data(1), oldline(2)]);
      setuprop(SNR_fig, 'windowlevel', data);             
    end;
  elseif (object==2)
    % call from either an image scroll, an image change, or pressed auto button
    % only do something if Auto radio button is on; Otherwise do nothing;   
    
    % if auto radio button on do something
    if get(h_auto,'Value') set(h_image_axes, 'ClimMode', 'auto'); end;
    % now update the plots and the editable text boxed
    clims = get(h_image_axes, 'Clim');
    set(h_cmax, 'String', num2str(clims(2)));
    set(h_cmin, 'String', num2str(clims(1)));
    set(h_window_axes, 'Xlim', clims);
    
    if ~isempty(data)
      data(2) = mean(clims);
      data(1) = abs(data(2) - clims(1));
      set(data(3), 'Xdata', data(2));
      set(data(4), 'Xdata', [ data(2)- data(1)]);
      set(data(5), 'Xdata', [ data(2)+ data(1)]);
      % Use the current wl endpoints to set the axis limits. 
      oldline = [100*floor((data(2)-data(1))/100) 100*ceil((data(2)+data(1))/100)];
      set(h_window_axes, 'Xlim', oldline);
      set(data(6), 'Xdata', [oldline(1), data(2)-data(1), data(2)+data(1), oldline(2)]);
      setuprop(SNR_fig, 'windowlevel', data)
    end;   
  end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function create_wl_objects(object);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function creates and does setup for the window and level manipulating objects

  global SNR_fig
  
  
  h_image_axes = findobj(SNR_fig, 'Tag','Image_axes');
  h_wl_axes = findobj(SNR_fig, 'Tag', 'Window_axes');
  
  h_cmax = findobj(SNR_fig, 'Tag', 'Cmax_edit');
  h_cmin = findobj(SNR_fig, 'Tag', 'Cmin_edit');
  
  set(SNR_fig, 'CurrentAxes', h_wl_axes);
  
  clims = get(h_image_axes, 'Clim');
  wl = get(h_wl_axes, 'UserData');
  
  h_line = plot( [ 0 wl(2)-wl(1) wl(2)+wl(1) clims(2) ], [ 0 0 1 1], 'b-'); 
  hold on
  h_endpoint1 = plot( wl(2)-wl(1), 0, 'rs');
  h_endpoint2 = plot( wl(2)+wl(1), 1, 'rs');
  
  h_midpoint = plot( wl(2), 0.5,'bs'); 
  
  set([h_endpoint1 h_endpoint2], 'markerfacecolor', [1 0 0], 'markeredgecolor', [0 0 0]);
  set(h_midpoint, 'markerfacecolor', [ 0 0 1], 'markeredgecolor' , [ 0 0 0],...
		  'Erasemode', 'xor');
  set(h_wl_axes, 'Tag', 'Window_axes');
  
  set(h_midpoint, 'ButtonDownFcn', 'SNR_main(''clims_callback'',1)'); 
  set(h_endpoint1, 'ButtonDownFcn', 'SNR_main(''clims_callback'',2)',...
		   'Erasemode', 'xor');
  set(h_endpoint2, 'ButtonDownFcn', 'SNR_main(''clims_callback'',3)',...
		   'Erasemode', 'xor');
  set(h_line, 'Erasemode', 'xor');
  
  % set the x-axis limits to take into account new endpoints
  set(h_wl_axes, 'Xlim', [ clims(1) clims(2)])           
  set(h_wl_axes, 'Ylim', [ -0.05 1.05]);
  
  setuprop(SNR_fig, 'windowlevel',[ wl, h_midpoint, h_endpoint1, h_endpoint2, h_line, ...
		    h_image_axes, h_cmin, h_cmax h_wl_axes])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function update_moved_clims(object);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to update teh movement of the wl graph points

global SNR_fig

	% get the current point
	points = get(gca,'CurrentPoint') ;
	center = [points(1,2), points(1,1)];
   data = getuprop(SNR_fig, 'windowlevel');
   
   if object==1
      data(2) = center(2);
   elseif object==2
      data(1) = data(2) - center(2);
   elseif object==3
      data(1) = center(2)- data(2);
   end;
   
   set(data(3), 'Xdata', data(2));
   set(data(4), 'Xdata', [ data(2)- data(1)]);
   set(data(5), 'Xdata', [ data(2)+ data(1)]) ;
   oldline = get(data(6), 'XData');
   set(data(6), 'Xdata', [oldline(1), data(2)-data(1), data(2)+data(1), oldline(4)]);
   set(data(7), 'Clim', sort([data(2)-data(1) data(2)+data(1)]));
   set(data(8), 'String', num2str(round( data(2)-data(1))));
   set(data(9), 'String', num2str(round( data(2)+data(1))));
   
   % update the data into memory
   setuprop(SNR_fig,'windowlevel', data);    
   
   % need to update the xlims of the w&l axes so that after all the motion you 
   % set the axes correctly

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function toggle_clims_BDF(val);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function to set and reset ROI objects ButtonDownFcn''s
% before and after action callbacks 
  global SNR_fig

  
  data = getuprop(SNR_fig, 'windowlevel');
  
  if strcmp(val,'On')
    % currently changing clims,  setting all objects  
    % callbacks back to normal 
    % centers get callbacks for motion
    set(data(3:6) , 'ButtonDownFcn', ' ');
  elseif strcmp(val, 'Done')
    % callbacks to end clims callback
    set(data(3:6),'ButtonDownFcn', 'SNR_main(''done_clims_callback'')');
  elseif strcmp(val, 'Off') 
    % callback is back to normal
    set(data(3), 'ButtonDownFcn', 'SNR_main(''clims_callback'',1)'); 
    set(data(4), 'ButtonDownFcn', 'SNR_main(''clims_callback'',2)'); 
    set(data(5), 'ButtonDownFcn', 'SNR_main(''clims_callback'',3)');
    set(findobj(SNR_fig,'Tag', 'Auto_clim_radiobutton'),'Value', 0); 
  end
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function toggle_visible_ROIs();
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to toggle visibility and enabling of active image objects
  
  global SNR_fig
  
  % get necesary handles
  all_handles = get(findobj(SNR_fig, 'Tag','Image_axes') ,'UserData');
  
  % get value of toggle button
  h_toggle = findobj(SNR_fig, 'Tag', 'Hide_togglebutton');
  h_toggle_value = get(h_toggle, 'Value');
  toggle_str = 'On';
  set(h_toggle, 'String', 'Hide');
  if h_toggle_value % hide
    toggle_str = 'Off';
    set(h_toggle, 'String', 'Show');
  end;
  
  set([all_handles(1,:), all_handles(2,:),all_handles(3,1:2), ...
       all_handles(4,1:3), all_handles(5,1:3) ] , 'Visible', ...
      toggle_str);
  
%	all_handles =[ [ h_R1_center,h_R1_circ, h_R1_axis1, h_R1_axis2]; ...
%				[ h_R2_center,h_R2_circ, h_R2_axis1, h_R2_axis2]; ...
%				[ h_profile_line, h_profile2_line, h_line1_plot, h_line2_plot];...
%				[ h_end1_1, h_end1_2, h_ax1_center, 0 ];...
%                                [ h_end2_1, h_end2_2, h_ax2_center, 0 ];...



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function [I,header]= getsigna3(name,plotfl)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getsigna3 reads in a 5.x signa file with a
% 7904 char header.  This would have to be changed
% if the header size is different.
% 14336 char header.(for 4.x. scanner)
%	PS : image is 256 by 256
%
% Example use:
%
% filename = '017/I.004';
% I2 = getsigna(filename);
% imagesc(I2); axis image; colormap(gray); 
%
%	modified from Dr. McVeigh's version
%	Cengizhan 7.24.1997
%	mod1 2.4.98 --> reads also when last char is line return
%			put error file for invalid fid
%			also displays the image if two inputs
%
%  
skip =1;

if ~skip

    hsize =7904; % header size here
    imsize = [256 256]; % image size here
    plotfl=0;
    if nargin ~=1 
        plotfl=1;
    end;
    if strcmp(computer,'PCWIN')
        fid = fopen(name, 'r','ieee-be'); 
    else
        fid = fopen(name);
    end;
    
    if fid>0
        header = fread(fid,hsize,'uchar');  
        I = fread(fid, imsize,'uint16');  
        fclose(fid);
        I = I';
    else, %  mod1 upto end
        lt=length(name);
        fid = fopen(name(1:lt-1));
        if fid>0
            header = fread(fid,hsize,'uchar');  
            I = fread(fid, imsize,'uint16');  
            fclose(fid);
            I = I';
        else,
            %disp(['Can not read the file ' name]);
            I=[];return;
        end;
        
    end;
    if plotfl,
        figure;imagesc(I); axis image; colormap gray;
    end;
    
    return;
else
    hsize =7904; % header size here
    imsize = [256 256]; % image size here
    plotfl=0;
    if nargin ~=1 
        plotfl=1;
    end;
    
    byte='b';				% Big-endian byte ordering
    
    fid = fopen(name,'r',byte);
    if fid>0,
        header = fread(fid,hsize/4,'int32');  
        I = fread(fid, imsize,'int16');  
        fclose(fid);
        I = I';
    else, 
        disp(['Can not read the file ' name]);
        I=[];return;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function export_image(action)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to export window/leveled image to a new figure. All settings established
% in the main window are maintained. Also allows for export to a previously created
% export figure for graph comparison. Simple subplot layouts are used. 
% Queries for the use of joint fig to push images together
% NOT IMPLEMENTED YET: How to combine each of several colormaps
% since the colormap is a property of the figure, not the axes


% CONSTANTS
% rows columns of subplots
  LAYOUT = [ 1 1; 1 2; 1 3;           ... % 1 2 3
	     2 2; 2 3; 2 3; 2 4; 2 4; ... % 4 5 6 7 8
	     3 4; 3 4; 3 4; 3 4;      ... % 9 10 11 12
	     4 4; 4 4; 4 4; 4 4;      ... % 13 14 15 16
	     4 5; 4 5; 4 5; 4 5;      ... % 17 18 19 20
	     5 5; 5 5; 5 5; 5 5; 5 5; ... % 21 22 23 24 25
	   ];
  current_axes = [];
  
  print_figure = findobj('Tag', 'CurrentPrintFigure');
  if ~isempty(print_figure)
    % check out how many subplots are used and of the last print figure 
    disp('old figure exists; Get UserData ');
    print_figure = print_figure(1);
    axes_data = get(print_figure,'UserData')
    index = length(axes_data)+1
  else
    disp('create new figure');
    print_figure = figure('Tag' , 'CurrentPrintFigure');
    axes_data = struct('CData', [], 'clim', [], 'xlim', [], 'ylim', ...
		       []);
    index=1;
  end;
  
  new_axis = findobj('Tag' , 'Image_axes');
  new_axis = new_axis(1);   
  
  allchildren = recursive_all_child(print_figure);   
  figure(print_figure);
  delete(allchildren);

  
  % collect data from the original axes
  axes_data(index).CData = get(findobj(new_axis, 'Type', 'image'),'CData');
    
  axes_data(index).clim = get(new_axis, 'Clim');
    
  SNR_fig = findobj('Tag','Fig1');
  h_xmin = findobj(SNR_fig,'Tag','Xmin_edit');
  h_xmax = findobj(SNR_fig,'Tag','Xmax_edit');	
  h_ymin = findobj(SNR_fig,'Tag','Ymin_edit'); 
  h_ymax = findobj(SNR_fig,'Tag','Ymax_edit');
    
  axes_data(index).xlim = [str2num(get(h_xmin, 'String')), ...
		    str2num(get(h_xmax,'String'))];
  axes_data(index).ylim = [str2num(get(h_ymin, 'String')), ...
		    str2num(get(h_ymax,'String'))];
  axes_data(index)
  size(axes_data)
  subplot_layout = LAYOUT(length(axes_data),:)
  counter = 1;
  
  for counter = 1:length(axes_data)
    s=subplot(subplot_layout(1),subplot_layout(2),counter);
    axes_data(counter)
    h=imagesc(axes_data(counter).CData, axes_data(counter).clim); 
    axis('equal'); 
    axis('tight');
    colormap(gray);
    set(s, 'xlim', axes_data(counter).xlim,'ylim', axes_data(counter).ylim ...
	   );
    drawnow
  end;
  
  set(print_figure, 'UserData', axes_data);
  
  % push all plots together
  %disp('to call jointfig');
  jointfig(print_figure, subplot_layout(1),subplot_layout(2));
  %disp('called jointfig');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function h_output = recursive_all_child(h_input)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function attempts to identify all objects, recursively, in parent object;
  h_output = [];
  for i =  1:length(h_input)
    hh =allchild(h_input(i)).';
    if isempty(hh)
      h_out1 = [];
    else
      %found children
      h_out1 = [hh,recursive_all_child(hh)];
    end;
    h_output = [h_output, h_out1];
  end;
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function jointfig(hfig,no_row,no_col)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%   jointfig(hfig,no_row,no_col)
%	--> joint subplots without any space between them
%   hfig : figure handler, if none, keyin gcf instead
%   no_row    : No. of row subplots
%   no_col    : No. of column subplots
%
%                 DO-SIG GONG,
%				  mail: D.Gong@soton.ac.uk
%				  HFRU/ISVR, University of Southampton, UK
%				  latest modified at 99-03-01 7:27PM
%
%             Removed comments DHL
  
% All the movement of subplots should be done in unit of points
  figure(hfig), hsubplot = get(hfig,'Children');
  % convert the position unit from pixel into points : should be restored)
  set(hfig,'unit','point')
  
  % BEWARE! hsubplot has different order from the original subplot sequence
  % for instance,
  %
  %  -----------------------         -----------------------
  %  |     1    |     2     |        |     4    |     3     |
  %  |----------+-----------|        |----------+-----------|
  %  |     3    |     4     |        |     2    |     1     |
  %  -----------------------         -----------------------
  %       subplot(22i)                  get(gcf,'Children')
  %
  % THEREFORE, transpose hsubplot into the one in original subplot sequence, like this..
  
  hsubplot = hsubplot(length(hsubplot):-1:1);
  no_subplot1 = length(hsubplot);
  no_space  = no_row*no_col;
  no_delta = no_space - no_subplot1;
  
  % in case of the odd number of subplots
  if no_delta,
    for i = 1:no_delta
      addsubplot = subplot(no_row,no_col,no_subplot1+i);
      hsubplot = [hsubplot; addsubplot];
    end
  end
  no_subplot = length(hsubplot);
  
  % Default position of figure in a window in point coord
  for i=1:no_subplot,
    set(hsubplot(i),'unit','point'),
    tmp_ylab_pos = get(get(hsubplot(i),'ylabel'),'position');
    ylab_pos(i) = tmp_ylab_pos(1);
  end
  new_ylab_pos = min(ylab_pos);
  coner1 = get(hsubplot(1),'position');
  coner2 = get(hsubplot(length(hsubplot)),'position');
  
  % position of lowest-left coner
  inix = coner1(1);
  iniy = coner2(2)*1.13;
  
  % axis line width
  alinewidth = get(hsubplot(1),'linewidth');
  
  % total lengths
  total_xlength = (coner2(1) + coner2(3) - coner1(1)) + (no_col-1) * alinewidth;
  total_ylength = (coner1(2) + coner1(4) - coner2(2)) + (no_row-1) * alinewidth;
  
  % width of each subplot
  delx = 1.0 * total_xlength / no_col;  
  
  % height of each subplot
  dely = 0.97 * total_ylength / no_row;  
  
  index_loop = no_subplot+1;              % total subplots index (reverse order)
  for index_row = no_row:-1:1,             % loop for row index
    for index_col = no_col:-1:1          % loop for column index
      index_loop = index_loop - 1;
      
      startx = inix + (index_col - 1) * delx;
      starty = iniy + (no_row - index_row) * dely;
      POSITION = [startx, starty, delx ,dely];
      
      %.......It's kind of bug of MATLAB
      if alinewidth < 1.0
	POSITION =  [ startx - 0.5 * alinewidth * (index_col-1), ...
		      starty + 0.9 * alinewidth * (index_row-1), delx ,dely];
	%          POSITION =
        %          [startx-1.0*alinewidth*(index_col-1),
        %          starty+1.5*alinewidth*(index_row-1), delx
        %          ,dely]);
	
      end
      
      set(hsubplot(index_loop),'position',POSITION);
 
      subplot(hsubplot(index_loop));
      
      iscale = size(get(gca,'yscale'),2);  % 3:log, 6:linear
      
      % remove xlabels & xticklabels of subplots located in upper rows other than lowest row
      
      if index_row ~= no_row,
	if ~(no_delta & index_row == (no_row - 1) & index_col == no_col),
	  set(get(gca,'xlabel'),'String',[])
	  set(gca,'xticklabel',[]);  %remove xticklabel
	end
      end
      
      % remove ylabels & yticklabels of subplots located in right columns other than leftmost column
      if index_col ~= 1,
	set(get(gca,'ylabel'),'String',[])
	set(gca,'yticklabel',[]);  %remove yticklabel
      end
      
      % remove first yticklabel of subplots located in lower rows
      % other than highest row, linear yscale only
      
      % .... only linear scale
      if index_row ~= 1 & iscale == 6
	a = get(gca,'ytick'); b = get(gca,'ylim');
	if a(length(a)) == b(length(b)), 
	  a = a(1:length(a)-1); 
	  set(gca,'ytick',a); 
	end
      end
      
      % remove first xticklabel of subplots located in left columns
      % other than rightmost column
      % .... only linear scale
      
      if ~no_delta,
	if index_col ~= no_col & iscale == 6
	  a = get(gca,'xtick'); b = get(gca,'xlim');
	  if a(length(a)) == b(length(b)), 
	    a = a(1:length(a)-1); 
	    set(gca,'xtick',a); 
	  end
	end
      else
	if index_col == no_col & index_row == no_row - 1 & iscale == 6,
	  a = get(gca,'xtick'); 
	  a = a(2:length(a)); 
	  set(gca,'xtick',a); 
	end	
      end	
      
    end
  end
  
  % get back to initial unit
  set(hfig,'unit','default')
  for i=1:no_subplot,	set(hsubplot(i),'unit','default'),end
  
  % delete dummy subplots
  if no_delta, for i = 1:no_delta, delete(hsubplot(no_subplot1+i)); end, end
  
  
  function fig = SNR_GUI()
% Function to create the SNR Measurement Tool's Graphical Interface
% Daniel Herzka July 2000

global SNR_fig;

% group shifts
SNR_ys = +.08;
Profile_ys =+.11;
save_ys = -0.85;
window_ys = 0.0;
% FIGURE
h0 = figure('Color',[0.8 0.8 0.8], ...
	'BusyAction', 'cancel',...
...%	'MenuBar','none', ...
	'Name','SNR Measurement GUI', ...
	'NumberTitle','off', ...
   'Position',... %[76  20   916   728],...   
   [65 38 901 691] ,...
   ... %'Position',[323 59 924 863], ...
     'Tag','Fig1');
SNR_fig = h0;
setuprop(SNR_fig, 'CurrentData', []);

% AXES  and associated texts
h1 = axes('Parent',h0, ...
	'Units','normalized',...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[1 1 1], ...
	'Position',[0.02  0.10  0.73  0.73 ], ...
	'Tag','Image_axes', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
h2 = text('Parent',h1, ...
	'Units','normalized', ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[0.498371335504886 -0.02891092814371258 0], ...
	'Tag','Axes1Text4', ...
	'VerticalAlignment','cap');
set(get(h2,'Parent'),'XLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[-0.03915171288743882 0.497751124437781 9.160254037844386], ...
	'Rotation',90, ...
	'Tag','Axes1Text3', ...
	'VerticalAlignment','baseline');
set(get(h2,'Parent'),'YLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','right', ...
	'Position',[ -0.0653    1.0750    9.1603] , ...
	'Tag','Axes1Text2', ...
	'Visible','off');
set(get(h2,'Parent'),'ZLabel',h2);
h2 = text('Parent',h1, ...
	'Units','normalized', ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[0.498371335504886 1.00748502994012 0], ...
	'Tag','Title', ...
	'VerticalAlignment','bottom');
set(get(h2,'Parent'),'Title',h2);

% SCROLLING BUTTONS
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',14, ...
	'ListboxTop',0, ...
	'Position',[0.10 0.02 0.567 0.07], ...
	'String','R1mn',...
	'Style','frame', ...
	'Tag','Scroll_frame');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'Callback', 'SNR_main(''scroll_image'',-1)',...
	'FontSize',24, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.41 0.03 0.07 0.05], ...
	'String','<', ...
	'Tag','Left_Button');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'Callback', 'SNR_main(''scroll_image'',1)',...
	'FontSize',24, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.48 0.03 0.07 0.05], ...
	'String','>', ...
   'Tag','Right_Button');

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'ButtonDownFcn', 'SNR_main(''update_path'',''old'');',...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback', 'SNR_main(''update_path'',''old'');',...
	'FontSize', 18,...
	'HorizontalAlignment', 'center',...
	'ListboxTop',0, ...
	'Position',[0.58 0.03 0.07 0.05], ...
        'String', 'I.001',...
	'Style','pushbutton', ...
	'Tag','Image_num_text');

% ZOOM Button with customized switching callback
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.70196078431372 0.701960784313725], ...
	'ButtonDownFcn', 'SNR_main(''update_corners'')',...
	'Callback','SNR_main(''toggle_zoom'');',...
	'FontSize',20, ...
	'FontWeight','normal', ...
	'ListboxTop',0, ...
	'Position',[0.11 0.03 0.14 0.05], ...
	'String','Zoom Off ', ...
	'UserData',['On '; 'Off'],...
	'Style', 'togglebutton',...
	'Value', 0,...
	'Tag','Zoom_button');

% SNR GRID STATIONARY ELEMENTS
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',14, ...
	'ListboxTop',0, ...
	'Position',[0.735 SNR_ys+0.23 0.26 0.39], ...
	'Style','frame', ...
	'Tag','SNR_frame');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',14, ...
	'FontWeight', 'bold',...
	'ListboxTop',0, ...
	'Position',[0.75 SNR_ys+0.605 0.05 0.03], ...
	'String', 'SNR',...
	'Style','text', ...
	'Tag','SNR_label_text');

R1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',14, ...
	'FontWeight','normal', ...
	'ForegroundColor',[0 0 1], ...
	'ListboxTop',0, ...
	'Position',[0.8 SNR_ys+0.57 0.085 0.030], ...
	'String','ROI 1', ...
	'Style','text', ...
	'Tag','ROI1');
R2 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',14, ...
	'FontWeight','normal', ...
	'ForegroundColor',[1 0 0], ...
	'ListboxTop',0, ...
	'Position',[0.89 SNR_ys+0.57 0.085 0.030], ...
	'String','ROI 2', ...
	'Style','text', ...
	'Tag','ROI2');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',14, ...
	'ForegroundColor',[0 0 1], ...
	'ListboxTop',0, ...
	'Position',[0.815 SNR_ys+0.515 0.065 0.040], ...
	'String','R1mn',...
	'Style','frame', ...
	'Tag','R1_mn_frame');
R1mn = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',14, ...
	'ForegroundColor',[0 0 1], ...
	'ListboxTop',0, ...
	'Position',[0.82 SNR_ys+0.52 0.055 0.030], ...
	'String','R1mn',...
	'Style','text', ...
	'Tag','R1_mn_text');

R2mn = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1 ], ...
	'FontSize',14, ...
	'ForegroundColor',[1 0 0], ...
	'ListboxTop',0, ...
	'Position',[0.90 SNR_ys+0.52 0.055 0.030], ...
	'String','R2mn',...
	'Style','text', ...
	'Tag','R2_mn_text');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'ForegroundColor',[1 0 0], ...
	'FontSize',14, ...
	'ListboxTop',0, ...
	'Position',[0.895 SNR_ys+0.465 0.065 0.040], ...
	'Style','frame', ...
	'Tag','R2_std_frame');
R2s = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',14, ...
	'ForegroundColor',[1 0 0], ...
	'ListboxTop',0, ...
	'Position',[0.90 SNR_ys+0.47 0.055 0.030], ...
	'String','R2s',...
	'Style','text', ...
	'Tag','R2_std_text');
R1s = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',14, ...
	'ForegroundColor',[0 0 1], ...
	'ListboxTop',0, ...
	'Position',[0.82 SNR_ys+0.47 0.055 0.030], ...
	'String','R1s',...
	'Style','text', ...
	'Tag','R1_std_text');



R2px = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',14, ...
	'ForegroundColor',[1 0 0], ...
	'ListboxTop',0, ...
	'Position',[0.90 SNR_ys+0.42 0.055 0.030], ...
	'String', 'R2px',...
	'Style','text', ...
	'Tag','R2_px_text');
R1px = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',14, ...
	'ForegroundColor',[0 0 1], ...
	'ListboxTop',0, ...
	'Position',[0.82 SNR_ys+0.42 0.055 0.030], ...
	'String', 'R1px',...
	'Style','text', ...
	'Tag','R1_px_text');


h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',14, ...
	'ListboxTop',0, ...
	'Position',[0.76 SNR_ys+0.52 0.055 0.03], ...
	'String','Mu', ...
	'Style','text', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',14, ...
	'ListboxTop',0, ...
	'Position',[0.76 SNR_ys+0.47 0.055 0.03], ...
	'String','Std', ...
	'Style','text', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',14, ...
	'ListboxTop',0, ...
	'Position',[0.76 SNR_ys+0.42 0.055 0.03], ...
	'String','Pix', ...
	'Style','text', ...
	'Tag','StaticText2');







% SNR TEXT AND BLANK
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',20, ...
	'FontWeight','normal', ...
	'ForegroundColor',[0 0 1], ...
	'ListboxTop',0, ...
	'Position',[0.78 SNR_ys+0.24 0.09 0.05], ...
	'String', 'SNR',...
	'Style','text', ...
	'Tag','StaticText1');
SNR = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',20, ...
	'ListboxTop',0, ...
	'Position',[0.88 SNR_ys+0.24 0.10 0.05], ...
	'Style','text', ...
	'Tag','SNR_text');





% NOISE CORRECTION FACTOR
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',14, ...
	'FontWeight','normal', ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[0.74 SNR_ys+0.31 0.185 0.035], ...
	'String', ' Noise Corr. Factor:',...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',14, ...
	'FontWeight','normal', ...
	'ForegroundColor',[0 0 0], ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[0.74 SNR_ys+0.35 0.185 0.035], ...
	'String', ' Phased Array Coils:',...
	'Style','text', ...
	'Tag','StaticText1');
ncorr = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',14, ...
	'ListboxTop',0, ...
	'Position',[0.925 SNR_ys+0.31 0.055 0.035], ...
	'String','0.695', ...
	'Style','text', ...
	'Tag','Corr_text', ...
	'UserData', [ 0.6550 0.6820 0.6950]);
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
     'BackgroundColor',[1 1 1], ...
     'Callback', 	['h_corr = findobj(''Tag'',''Corr_text'');,',...
          	'h_coil = findobj(''Tag'',''Coils_menu'');,',...
      		'vals = get(h_coil, ''UserData'');,',...
               'curr_val = str2num(popupstr(h_coil));,',...                         
               'set(h_corr, ''String'', num2str(vals(curr_val)));,',...
			'SNR_main(''update_SNR'');'],...
  	'FontSize',14, ...
	'ListboxTop',0, ...
	'Max',3, ...
	'Min',1, ...
	'Position',[0.925 SNR_ys+0.36 0.055 0.035], ...
	'String',['1';'2';'4'], ...
	'Style','popupmenu', ...
     'Tag','Coils_menu', ...
     'UserData', [0.655;0.682;0;0.695],...
	'Value',3);


% ROI TOGGLE BUTTON
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'Callback', 'SNR_main(''toggle_rois'');',...
	'FontSize',20, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.75 0.7 0.2 0.075], ...
	'String',' Profile', ...
	'Tag','Create_button',...
	'Visible', 'off');


% AXES limit blanks, & ZOOM Button
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback', 'SNR_main(''update_corner_coors'')',...
	'Fontsize', 14,...
	'ForegroundColor', [0 0 1],...
	'ListboxTop',0, ...
	'Position',[0.044 0.06 0.04 0.04], ...
	'Style','edit', ...
	'Tag','Xmin_edit');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback', 'SNR_main(''update_corner_coors'')',...
	'Fontsize', 14,...
	'ForegroundColor', [0 0 1],...
	'ListboxTop',0, ...
	'Position',[0.685 0.06 0.04 0.04], ...
	'Style','edit', ...
	'Tag','Xmax_edit');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback', 'SNR_main(''update_corner_coors'')',...
	'Fontsize', 14,...
	'ForegroundColor', [0 0 1],...
	'ListboxTop',0, ...
	'Position',[0.001 0.79 0.04 0.04], ...
	'Style','edit', ...
	'Tag','Ymin_edit');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback', 'SNR_main(''update_corner_coors'')',...
	'Fontsize', 14,...
	'ForegroundColor', [0 0 1],...
	'ListboxTop',0, ...
	'Position',[0.001 0.10 0.04 0.04], ...
	'Style','edit', ...
	'Tag','Ymax_edit');




% PATH & IMAGE CHANGES
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'ButtonDownFcn', 'SNR_main(''update_path'',''old'');',...
   'BackgroundColor',[0.701961 0.701961 0.701961], ...   
   'Callback',  'SNR_main(''update_path'',''old'');',...
	'FontSize', 12,...
	'FontWeight', 'normal',...
	'HorizontalAlignment', 'Left',...
	'ListboxTop',0, ...
	'Position',[0.02 0.960 0.71 0.035],...
	'String', pwd,...
	'Style','pushbutton', ...
	'Tag','Path_text');



%PROFILE Axes
h1 = axes('Parent',h0, ...
	'Units','normalized',...
	'Box', 'on',...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[0.8 0.8 0.8], ...
	'Position',[0.10  0.85  0.55  0.1 ], ...
	'Tag','Profile_axes', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
h2 = text('Parent',h1, ...
	'Units','normalized', ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[0.498371335504886 -0.02891092814371258 0], ...
	'Tag','Axes2Text4', ...
	'VerticalAlignment','cap');
set(get(h2,'Parent'),'XLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[-0.03915171288743882 0.497751124437781 9.160254037844386], ...
	'Rotation',90, ...
	'Tag','Axes2Text3', ...
	'VerticalAlignment','baseline');
set(get(h2,'Parent'),'YLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','right', ...
	'Position',[ -0.0653    1.0750    9.1603], ...
	'Tag','Axes2Text2', ...
	'Visible','off');
set(get(h2,'Parent'),'ZLabel',h2);
h2 = text('Parent',h1, ...
	'Units','normalized', ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[0.498371335504886 1.00748502994012 0], ...
	'Tag','Title', ...
	'VerticalAlignment','bottom');
set(get(h2,'Parent'),'Title',h2);

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',14, ...
	'ListboxTop',0, ...
	'Position',[0.735 Profile_ys+0.61 0.26 0.27], ...
	'Style','frame', ...
	'Tag','Profile_frame');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',14, ...
	'FontWeight', 'bold',...
	'HorizontalAlignment','left',...
	'ListboxTop',0, ...
	'Position',[0.75 Profile_ys+0.865 0.05 0.03], ...
	'String', 'CNR',...
	'Style','text', ...
	'Tag','Profile_label_text');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',14, ...
	'FontWeight','normal', ...
	'ForegroundColor',[0 0 0], ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[0.74 Profile_ys+0.82 0.185 0.035], ...
	'String', ' Samples:',...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback', 'SNR_main(''update_profile'');',...
	'BackgroundColor',[1 1 1], ...
	'FontSize',14, ...
	'ListboxTop',0, ...
	'Position',[0.925 Profile_ys+0.82 0.055 0.04], ...
	'String','100', ...
	'Style','edit', ...
	'Tag','Samples_edit');

% PROFILE GRIDS
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',14, ...
	'ListboxTop',0, ...
	'Position',[0.76 Profile_ys+0.73 0.055 0.03], ...
	'String','Mu', ...
	'Style','text', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',14, ...
	'ListboxTop',0, ...
	'Position',[0.76 Profile_ys+0.69 0.055 0.03], ...
	'String','Std', ...
	'Style','text', ...
	'Tag','StaticText2');

% labels
P1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',14, ...
	'FontWeight','normal', ...
	'ForegroundColor',[0 0 1], ...
	'ListboxTop',0, ...
	'Position',[0.8 Profile_ys+0.78 0.085 0.030], ...
	'String','PRFL 1', ...
	'Style','text', ...
	'Tag','PRFL1');
P2 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',14, ...
	'FontWeight','normal', ...
	'ForegroundColor',[1 0 0], ...
	'ListboxTop',0, ...
	'Position',[0.89 Profile_ys+0.78 0.085 0.030], ...
	'String','PRFL 2', ...
	'Style','text', ...
	'Tag','PRFL2');


P1mn = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',14, ...
	'ForegroundColor',[0 0 1], ...
	'ListboxTop',0, ...
	'Position',[0.82 Profile_ys+0.73 0.055 0.030], ...
	'String','P1mn',...
	'Style','text', ...
	'Tag','P1_mn_text');
P2mn = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1 ], ...
	'FontSize',14, ...
	'ForegroundColor',[1 0 0], ...
	'ListboxTop',0, ...
	'Position',[0.90 Profile_ys+0.73 0.055 0.030], ...
	'String','P2mn',...
	'Style','text', ...
	'Tag','P2_mn_text');
P2s = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',14, ...
	'ForegroundColor',[1 0 0], ...
	'ListboxTop',0, ...
	'Position',[0.90 Profile_ys+0.69 0.055 0.030], ...
	'String','P2s',...
	'Style','text', ...
	'Tag','P2_std_text');
P1s = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',14, ...
	'ForegroundColor',[0 0 1], ...
	'ListboxTop',0, ...
	'Position',[0.82 Profile_ys+0.69 0.055 0.030], ...
	'String','P1s',...
	'Style','text', ...
	'Tag','P1_std_text');



% CNR TEXT AND BLANK
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',20, ...
	'FontWeight','normal', ...
	'ForegroundColor',[0 0 1], ...
	'ListboxTop',0, ...
	'Position',[0.78 Profile_ys+0.62 0.09 0.05], ...
	'String', 'CNR',...
	'Style','text', ...
	'Tag','StaticText1');
CNR = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',20, ...
	'ListboxTop',0, ...
	'Position',[0.88 Profile_ys+0.62 0.10 0.05], ...
	'Style','text', ...
	'Tag','CNR_text');


h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'Callback', 'SNR_main(''store_current'');',...
	'FontSize',20, ...
	'FontWeight','normal', ...
	'ListboxTop',0, ...
	'Position',[0.33 save_ys+0.88 0.07 0.05], ...
	'String','Store', ...
	'Tag','Store_button');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'Callback', 'SNR_main(''save_current'');',...
	'FontSize',20, ...
	'FontWeight','normal', ...
	'ListboxTop',0, ...
	'Position',[0.26 save_ys+0.88 0.07 0.05], ...
	'String','Save', ...
	'Tag','save_button');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Fontsize', 10,...
	'ForegroundColor', [0 0 0],...
	'ListboxTop',0, ...
	'Position',[0.00 -0.01 0.1 0.04], ...
	'String', 'Save Profile',...
	'Style','radiobutton', ...
	'Tag','Store_profile_radiobutton',...
	'Value', 1 );
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Fontsize', 10,...
	'ForegroundColor', [0 0 0],...
	'ListboxTop',0, ...
	'Position',[0.00 0.02 0.1 0.04], ...
	'String', 'Save Matfile',...
	'Style','radiobutton', ...
	'Tag','Store_matfile_radiobutton',...
	'Value', 1 );

h1 = axes('Parent',h0, ...
	'Units','normalized',...
	'Box', 'on',...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[0.8 0.8 0.8], ...
	'Position',[0.735  window_ys+0.01  0.26  .28 ], ...
	'Tag','Window_back_axes', ...
	'XColor',[0 0 0], ...
	'Xticklabel', [],...
        'Xtick', [],...
	'YColor',[0 0 0], ...
	'Yticklabel', [],...
        'Ytick', [],...
	'ZColor',[0 0 0]);



h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',14, ...
	'FontWeight', 'bold',...
	'ListboxTop',0, ...
	'Position',[0.75 window_ys+0.275 0.05 0.03], ...
	'String', 'W&L',...
	'Style','text', ...
	'Tag','window_label_text');

%Window Level Axes Axes
h1 = axes('Parent',h0, ...
	'Units','normalized',...
	'Box', 'on',...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[0.8 0.8 0.8], ...
	'Position',[0.81  window_ys+0.05  0.17  .20 ], ...
	'Tag','Window_axes', ...
	'TickDir', 'in',...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
h2 = text('Parent',h1, ...
	'Units','normalized', ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[0.498371335504886 -0.02891092814371258 0], ...
	'Tag','Axes3Text4', ...
	'VerticalAlignment','cap');
set(get(h2,'Parent'),'XLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[-0.03915171288743882 0.497751124437781 9.160254037844386], ...
	'Rotation',90, ...
	'Tag','Axes3Text3', ...
	'VerticalAlignment','baseline');
set(get(h2,'Parent'),'YLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','right', ...
	'Position',[ -0.0653    1.0750    9.1603], ...
	'Tag','Axes3Text2', ...
	'Visible','off');
set(get(h2,'Parent'),'ZLabel',h2);
h2 = text('Parent',h1, ...
	'Units','normalized', ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[0.498371335504886 1.00748502994012 0], ...
	'Tag','Title', ...
	'VerticalAlignment','bottom');
set(get(h2,'Parent'),'Title',h2);


h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback', 'SNR_main(''update_clims'',1)',...
	'Fontsize', 14,...
	'ForegroundColor', [0 0 0],...
	'ListboxTop',0, ...
	'Position',[0.74 0.21 0.04 0.04], ...
	'Style','edit', ...
	'Tag','Cmax_edit');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback', 'SNR_main(''update_clims'',1)',...
	'Fontsize', 14,...
	'ForegroundColor', [0 0 0],...
	'ListboxTop',0, ...
	'Position',[0.74 0.055 0.04 0.04], ...
	'Style','edit', ...
	'Tag','Cmin_edit');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback', 'SNR_main(''update_clims'',2)',...
	'Fontsize', 10,...
	'ForegroundColor', [0 0 0],...
	'ListboxTop',0, ...
	'Position',[0.736 0.1325 0.045 0.04], ...
	'String', 'Auto',...
	'Style','radiobutton', ...
	'Tag','Auto_clim_radiobutton',...
	'Value', 1 );

% hiding and showing ROIs
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'Callback', 'SNR_main(''hide_ROIs'');',...
	'FontSize',20, ...
	'FontWeight','normal', ...
	'ListboxTop',0, ...
	'Position',[0.01 0.55 0.07 0.05], ...
	'String',['Hide'; 'ROIs'], ...
        'Style', 'Togglebutton',...
	'Tag','Hide_togglebutton',...
	'TooltipString', 'Toggle Visibility of Active Objects'...
);

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'Callback', 'SNR_main(''propagate_ROIs'');',...
	'FontSize',20, ...
	'FontWeight','normal', ...
	'ListboxTop',0, ...
	'Position',[0.01 0.5 0.07 0.05], ...
	'String',['All'], ...
   'Style', 'Pushbutton',...
	'Tag','Propagate_button',...
	'TooltipString', 'Propagate Current ROIs through all Images'...
);

% Export Function Button
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'Callback', 'SNR_main(''export_image'');',...
	'FontSize',20, ...
	'FontWeight','normal', ...
	'ListboxTop',0, ...
	'Position',[0.01 0.45 0.07 0.05], ...
	'String',['Print'], ...
   'Style', 'Pushbutton',...
	'Tag','Export_button',...
	'TooltipString', 'Export Current Image to a Print Figure'...
);

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'Callback', 'SNR_main(''make_movie'');',...
	'FontSize',20, ...
	'FontWeight','normal', ...
	'ListboxTop',0, ...
	'Position',[0.01 0.4 0.07 0.05], ...
	'String',['Movie'], ...
   'Style', 'Pushbutton',...
	'Tag','Movie_button',...
	'TooltipString', 'Create a Movie (avi)'...
);




set(R1,'UserData', [R1mn R2mn R1s R2s R1px R2px SNR ncorr]);
set(P1,'UserData', [P1mn P2mn P1s P2s CNR ncorr]);


if nargout > 0, fig = h0; end


  
  

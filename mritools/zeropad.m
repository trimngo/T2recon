function out=zeropad(in,xsize,ysize,position)
% function    out=zeropad(in,xsize,ysize,position)
%
% function to zero pad to desired size
%
% out(y,x,:,:) is the output image with desired zero-padding
% in(y,x,:,:) is the input image (input may be 2,3, or 4 dimensions)
% xsize is the desired output size in the x-direction (columns)
% ysize is the desired output size in the y-direction (rows)
% position is 'center' (default), 'top', 'bottom', 'right', 'left'

%     ***************************************
%     *  Peter Kellman  (kellman@nih.gov)   *
%     *  Laboratory for Cardiac Energetics  *
%     *  NIH NHLBI                          *
%     ***************************************

[rows,cols,size3,size4]=size(in);

% return of input is correct size
if xsize==cols & ysize==rows
    out=in;
    return
end

if nargin==3; position='center'; end % default is to center image data
out=zeros(ysize,xsize,size3,size4);
switch (position)
case 'center'
	ymin=(ysize-rows)/2+1;ymax=ymin+rows-1;
	xmin=(xsize-cols)/2+1;xmax=xmin+cols-1;
	out(ymin:ymax,xmin:xmax,:,:)=in;
case 'top'
	ymin=1;ymax=rows;
	xmin=(xsize-cols)/2+1;xmax=xmin+cols-1;
    out(ymin:ymax,xmin:xmax,:,:)=in;
case 'bottom'
	ymin=1+ysize-rows;ymax=ysize;
	xmin=(xsize-cols)/2+1;xmax=xmin+cols-1;
    out(ymin:ymax,xmin:xmax,:,:)=in;
case 'right'
	ymin=(ysize-rows)/2+1;ymax=ymin+rows-1;
	xmin=(xsize-cols+1);xmax=xsize;
    out(ymin:ymax,xmin:xmax,:,:)=in;
case 'left'
	ymin=(ysize-rows)/2+1;ymax=ymin+rows-1;
	xmin=1;xmax=cols;
    out(ymin:ymax,xmin:xmax,:,:)=in;
end
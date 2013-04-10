function xproj=proj_data(x,data,supp,kspace2imspace,imspace2kspace)
xproj=x+kspace2imspace(data-imspace2kspace(x).*supp);
% x + measureddata_imagespace - (imspace_x but only portion specified by supp)

% assumption here is that data has the same support as supp
% supp are the regions that will be updated to whatever is in data


%for phase projection we want
%kspace regions not measured in partial echo (kx) want to leave alone
%kpace regions measured actually measured by partial echo, want to update
%true measured data
%kspace regions recovered by SENSE but not measured in partial echo, want
%to leave alone.


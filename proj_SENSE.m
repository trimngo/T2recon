function gcproj=proj_SENSE(gc,s)
ncoils=size(gc,4);
I=1/(sum(abs(s).^2,4));
%combine coils
g=sum(gc.*conj(s),4).*I;


%create coil images
gcproj=s.*repmat(g,[1 1 1 ncoils]);
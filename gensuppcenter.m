function [supp_center,kwin]=gensuppcenter(nkx,nky,nkz,ncoils,nechos,cres)
%% dbg
dbg=false;
if dbg
    nkx=128;
    nky=60;
    nkz=30;
    ncoils=8;
    cres=[10,10];
end

%% generate the support and accompanying window in kspace
% fill in center of kspace
suppky_cent=false(1,nky,1);
suppky_cent(1:cres(1)/2)=true;
suppky_cent(end-cres(1)/2+1:end)=true;

suppkz_cent=false(1,1,nkz);
suppkz_cent(1:cres(2)/2)=true;
suppkz_cent(end-cres(2)/2+1:end)=true;

supp_center=logical(repmat(suppky_cent,[nkx 1 nkz ncoils nechos])&repmat(suppkz_cent,[nkx nky 1 ncoils nechos]));

%make the kaiser window for the center of kspace here
kywin=zeros(1,nky);
kzwin=zeros(1,1,nkz);
kywin(suppky_cent)=fftshift(kaiser(sum(suppky_cent),3));
kzwin(suppkz_cent)=fftshift(kaiser(sum(suppkz_cent),3)); %do we need to remove this if no undersampling?
kwin=repmat(kywin,[nkx 1 nkz ncoils nechos]).*repmat(kzwin,[nkx nky 1 ncoils nechos]);
%(does ringing occur when we are fully sampled?)

%TODO: Check that the window isn't too strong when we are fully sampled
%% displays
if dbg
    figure;imagescn(permute(supp_center(:,:,:,1),[2 3 1]),[],[],[],3);
    figure;imagescn(permute(kwin,[2 3 1 4 5]),[],[],[],3);
end
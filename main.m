clear all;
%% paths
addpath('mritools');
addpath('utilities');
%% load in data
dataind=1;
[data,data_noise,TE_vals,mask,cmask]=loaddata(dataind);
% data=data(:,:,:,:,1);
% data_noise=data_noise(:,:,:,:,1);
% mask=mask(:,:,:,:,1);
% cmask=cmask(:,:,:,:,1);
% nechos=1;
[nkx nky nkz ncoils nechos]=size(data);

%% load undersampling pattern and window
cres=[20 10]; %fullly sampled center of kspace
% rate=3.958763e+00;
%     rate=2;
[supp_center,kwin]=gensuppcenter(nkx,nky,nkz,ncoils,nechos,cres);
% [supp]=gensupp_gauss(nkx,nky,nkz,ncoils,nechos,mask,rate,cres);

supp_center=zeros(size(data));
reg_rate=[2 2];
[supp]=gensupp_reg(nkx,nky,nkz,ncoils,nechos,reg_rate,supp_center);
% 
% if dataind==1
%     %partial dataset, just pretend dataset isn't partial for SENSE purposes
%     supp=repmat(supp(1,:,:,:,:),[nkx, 1 1 1 1]);
% end
% figure; imagescn(supp,[],[],[],3);
% figure; imagescn(permute(supp,[2 3 1 4 5]),[],[],[],3);

%% setup recon
kspace2imspace=@(x) sqrt(nkx*nky*nkz)*fftshift(ifft3(x),1); %very important that the scaling factor is there in order to use the sum
imspace2kspace=@(x) (1/sqrt(nkx*nky*nkz))*fft3(ifftshift(x,1));

%% undersample data
supp=supp.*mask;
[udata]=data.*supp;

%% estimate coil sense
% s=estcoilsens(data,kwin,kspace2imspace);
s=estcoilsens(data,ones(size(data)),kspace2imspace); %ideal coil sensitivity

%% whiten data
[data_decorr,s_decorr]=whiten(data,s,data_noise);
[udata_decorr,s_decorr]=whiten(udata,s,data_noise);

%% recon
cgrecon=Recon_cgsense;
[v,delta,ne]=cgrecon.run(udata_decorr,s_decorr,supp,mask,kwin,data_decorr,kspace2imspace,imspace2kspace);
% recon(udata_decorr,s_decorr,supp,mask,kwin,data_decorr,kspace2imspace,imspace2kspace);

%% gs recon
gs=kspace2imspace(data_decorr);

%% compare gs and fully samp recon
I=1/(sum(abs(s_decorr).^2,4));
%combine coils
% vcomb=sum(v.*conj(s_decorr),4).*I;
gscomb=sum(gs.*conj(s_decorr),4).*I;
figure; imagescn(abs(cat(2,gscomb,v,v-gscomb)),[],[],[],3);

figure;
subplot(2,1,1); plot(ne);
subplot(2,1,2); plot(delta);

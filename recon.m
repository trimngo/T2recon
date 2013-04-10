function [v,delta,ne]=recon(udata_decorr,s_decorr,supp,mask,kwin,data_decorr,kspace2imspace,imspace2kspace)
% set(0,'DefaultFigureVisible','off');  % all subsequent figures "off"
%% setup
[nkx,nky,nkz,ncoils,nechos]=size(udata_decorr);

%% estimate the phase
% phaseref=angle(kspace2imspace(udata_decorr.*cmask.*kwin));
% phaseref=angle(kspace2imspace(data_decorr)); %perfect phase estimation
% phaseref=angle(kspace2imspace(udata_decorr.*cmask));
phaseref=zeros(size(udata_decorr)); %%dummy mask
figure; imagescn(phaseref,[],[],[],3);

%% see if Least squares projection matrix preserves scaling of gs (it does)
I=1/sqrt(sum(abs(s_decorr).^2,4));
% I=ones(nkx,nky,nkz);
% gs=sum(kspace2imspace(data_decorr).*conj(s_decorr),4).*(I.^2); %v
gs=kspace2imspace(data_decorr);
% gsc=gs.*(I.^2);
% b=gs./I; %b
% b2=(sum(kspace2imspace(imspace2kspace(s_decorr.*repmat(b.*I,[1 1 1 ncoils]))).*conj(s_decorr),4).*I);
% gs2=b2.*I;
% % % 
% figure; imagescn(abs(cat(2,gs,gs2,gs./gs2)),[],[],[],3);
% % figure; imagescn(abs(cat(2,gs,gsc,gs./gsc)),[],[],[],3);
% figure; imagescn(abs(cat(2,b,b2,b./b2)),[],[],[],3);

%% reconstruct with different phase weightings
I=1/(sum(abs(s_decorr).^2,4));
figure;imagescn(abs(gs),[],[],[],3);
db0=kspace2imspace(udata_decorr(:,:,:,:,1));

%combine coils
db0comb=sum(db0.*conj(s_decorr),4).*I;
gscomb=sum(gs.*conj(s_decorr),4).*I;
figure; imagescn(abs(cat(2,gscomb,db0comb,db0comb-gscomb)),[],[],[],3);
% db0=zeros(nkx,nky,nkrz);
% phasew=[0.023:0.001:0.034];
% phasew=[0.011:0.001:0.022];
% phasew=[0.1:0.01:0.2];
% phasew=[0.25:0.01:0.36];
% parfor i=1:length(phasew)
%     i
% sense recon
coilprojw=[1 1 0];
cmask=zeros(size(udata_decorr)); %%dummy
[v,delta,ne]=pocsense(udata_decorr,s_decorr,supp,cmask,phaseref,kspace2imspace,imspace2kspace,600,gs,db0,coilprojw,false);

% phasew=1;
%phase recon
% [v{2},delta{2},ne{2}]=pocsense(udata_decorr,s_decorr,supp,psupp,phaseref,kspace2imspace,imspace2kspace,100,gs,v{1},phasew,false);
% end
% figure; imagescn(abs(v),[],[],[],3);

%% turn figures back on
% set(0,'DefaultFigureVisible','on');  % all subsequent figures "on"
close all;
function [  ] = main(  )
%% paths
addpath('../../mritools');
addpath('../../utilities');
%% load in data
dataind=1;
[data,data_noise,TE_vals,mask,cmask]=loaddata(dataind);
data=data(:,:,:,:,1);
data_noise=data_noise(:,:,:,:,1);
mask=mask(:,:,:,:,1);
cmask=cmask(:,:,:,:,1);
nechos=1;
[nkx nky nkz ncoils nechos]=size(data);

%% load undersampling pattern and window
cres=[20 10]; %fullly sampled center of kspace
% rate=3.958763e+00;
%     rate=2;
[supp_center,kwin]=gensuppcenter(nkx,nky,nkz,ncoils,nechos,cres);
% [supp]=gensupp_gauss(nkx,nky,nkz,ncoils,nechos,mask,rate,cres);

supp_center=zeros(size(data));
reg_rate=[2 1];
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

%% try different amounts of kx undersampling
% parfor i=1:nkx/2
%     i
    [v,delta,ne]=partialrecon(data, data_noise,supp,mask,kwin,nkx/2,kspace2imspace,imspace2kspace);
% end


%% compare between different amounts of undersampling
nem=cell2mat(ne');
deltam=cell2mat(delta');
figure;
subplot(2,1,1); plot(nem');
subplot(2,1,2); plot(deltam');

%% compare between diff weights
ufacts=1:nkx/2;
% nem=cell2mat(ne');
% deltam=cell2mat(delta');
% figure;
% subplot(2,1,1); plot(nem');
% legend(num2str(phasew));
% subplot(2,1,2); plot(deltam');
% figure; plot(phasew,nem(:,100)); title('error at 100th it versus phasew');

figure; plot(ufacts,nem);
% figure; plot(ufacts,nem(:,1)); hold all
% plot(ufacts,nem(:,2));
% plot(ufacts,nem(:,3));

%% pause
a=1;

function [v,delta,ne]=partialrecon(data, data_noise,supp,mask, kwin, ufactor,kspace2imspace,imspace2kspace)
% set(0,'DefaultFigureVisible','off');  % all subsequent figures "off"
%% setup
[nkx,nky,nkz,ncoils,nechos]=size(data);
%% simulate a partial fourier acquisition
kxsupp=zeros(nkx,1);
kxcsupp=kxsupp;
% kxsupp([1:nkx/2, nkx-(nkx/4)-1:nkx])=1;
% kxcsupp([1:nkx/4, nkx-(nkx/4)-1:nkx])=1;
kxsupp([1:nkx/2, nkx-(ufactor)+1:nkx])=1;
kxcsupp([1:ufactor, nkx-(ufactor)+1:nkx])=1;
pmask=repmat(kxsupp,[1 nky nkz ncoils]);
cmask=repmat(kxcsupp,[1 nky nkz ncoils]);

figure;
subplot(2,1,1);stem(kxsupp);
subplot(2,1,2);stem(kxcsupp);

figure; imagescn(pmask,[],[],[],3);
figure; imagescn(cmask,[],[],[],3);

supp=supp.*pmask;
figure; imagescn(supp,[],[],[],3);

%% undersample data
supp=supp.*mask;
[udata]=data.*supp;

%% estimate coil sense
% s=estcoilsens(data,kwin,kspace2imspace);
s=estcoilsens(data,ones(size(data)),kspace2imspace); %ideal coil sensitivity
%% compute simplified noise matrix
Z=squeeze(data_noise).';
Psi=(1/size(Z,2))*(Z*Z');

%% compute cholesky decomp
L=chol(Psi,'lower');

%% compute virtual coils and coil sensitivity
data_decorr=zeros(size(data));
s_decorr=zeros(size(data));
for e=1:nechos
    m=reshape(udata(:,:,:,:,e),[nkx*nky*nkz ncoils]).';
    m_decorr=(L\m).';
    udata_decorr(:,:,:,:,e)=reshape(m_decorr,[nkx nky nkz ncoils]);
    
    m=reshape(data(:,:,:,:,e),[nkx*nky*nkz ncoils]).';
    m_decorr=(L\m).';
    data_decorr(:,:,:,:,e)=reshape(m_decorr,[nkx nky nkz ncoils]);
    
    s_temp=reshape(s(:,:,:,:,e),[nkx*nky*nkz ncoils]).';
    s_temp_decorr=(L\s_temp).';
    s_decorr(:,:,:,:,e)=reshape(s_temp_decorr,[nkx nky nkz ncoils]);
end

figure; imagescn(abs(s_decorr),[],[],[],3);
%% reconstruct virtual coils and display
x_decorr=kspace2imspace(data_decorr);
figure; imagescn(abs(x_decorr),[],[],[],3);

%% check if data is actually decorrelated
Zcheck=(L\Z);
% Psicheck=(1/size(Zcheck,2))*(Zcheck'*Zcheck);
Psicheck=(1/size(Zcheck,2))*(Zcheck*Zcheck');
% figure; imagesc(abs(Psi));
figure; imagesc(abs(Psicheck));

%% estimate the phase
% phaseref=angle(kspace2imspace(udata_decorr.*cmask.*kwin));
% phaseref=angle(kspace2imspace(data_decorr)); %perfect phase estimation
phaseref=angle(kspace2imspace(udata_decorr.*cmask));
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
[v,delta,ne]=pocsense(udata_decorr,s_decorr,supp,pmask,phaseref,kspace2imspace,imspace2kspace,300,gs,db0,coilprojw,false);

% phasew=1;
%phase recon
% [v{2},delta{2},ne{2}]=pocsense(udata_decorr,s_decorr,supp,psupp,phaseref,kspace2imspace,imspace2kspace,100,gs,v{1},phasew,false);
% end
% figure; imagescn(abs(v),[],[],[],3);

%% compare gs and fully samp recon
I=1/(sum(abs(s_decorr).^2,4));
%combine coils
vcomb=sum(v.*conj(s_decorr),4).*I;
gscomb=sum(gs.*conj(s_decorr),4).*I;
figure; imagescn(abs(cat(2,gscomb,vcomb,vcomb-gscomb)),[],[],[],3);

figure;
subplot(2,1,1); plot(ne);
subplot(2,1,2); plot(delta);

%% turn figures back on
% set(0,'DefaultFigureVisible','on');  % all subsequent figures "on"
close all;

function [gc,delta,ne]=pocsense(m,s,supp,psupp,phaseref,kspace2imspace,imspace2kspace,maxits,gs,g0c,coilprojw,debug)
%% run
% debug=;
[nkx nky nkz ncoils]=size(m);
pproj=true; %true:parallel projections, false: sequential projections
I=1/sqrt(sum(abs(s).^2,4));

fh1=figure;
fh2=figure;

gc=g0c;

coilproj=[];
coilproj{1}=@(x) proj_data(x,m,supp,kspace2imspace,imspace2kspace);
coilproj{2}=@(x) proj_SENSE(x,s);
coilproj{3}=@(x) proj_phase(x,phaseref,true(size(phaseref))); %%w/o phase mask
% coilproj{4}=@(x) proj_data(x,m,psupp,kspace2imspace,imspace2kspace);
% coilprojw=[1 1 phasew];
coilprojw=coilprojw./sum(coilprojw);
% ones(length(coilproj),1)*(1/length(coilproj)); %equal weighting
lambda=1; %should be [0,1]

frame=[];
error=[];
for i=1:maxits
%     frame(:,:,i)=gc(:,:,10,1);
%     imagesc(abs(frame(:,:,i)));axis equal; colormap('gray'); drawnow;
    gcprev=gc;
    
    %compute error
    ne(i)=norm(vect(gc-gs))/norm(gs(:));
    
    %Projections
    if pproj %parallel
        pgc=zeros(nkx,nky,nkz,ncoils,size(coilproj,2));
        for j=1:length(coilproj)
            pgc(:,:,:,:,j)=coilprojw(j)*coilproj{j}(gc);
        end
        t1=sum(pgc,5);
    else %sequential (fix later)
        t1=gc;
        for j=1:length(coilproj)
            t1=coilproj{j}(t1);
        end
    end
    
    %update estimate
    gc=gc+lambda*(t1-gc); %(1-lambda)g+lambda*t1
    
    %compute change
    delta(i)=norm(vect(gc-gcprev))/norm(vect(gcprev));
    
    if debug && i>1
        figure(fh1);
        g=sum(gc.*conj(s),4).*(1/sum(abs(s).^2,4));
        imagesc(abs(g(:,:,10)));axis equal; colormap('gray');
        figure(fh2);
        subplot(2,1,1); plot(ne);
        subplot(2,1,2); plot(delta);
    end
    fprintf('Joint: Iteration: %i, delta: %d\n',i,delta(i));
end

% v=I.*b;
function compgs(a,gs)
figure; imagescn(abs(cat(2,gs,a,a./gs)),[],[],[],3);
function [data,data_noise,TE_vals,mask,cmask]=loaddata(s)
%% main body
switch s
    case 1
        fn='/home/tringo/Dropbox/data/T2/20110806 Phantom A67/DATA LISTs/raw_014_STD.mat';
        fprintf(1,'Loading %s\n',fn) ;
        data=double(load_philips(fn));
        
        %exclude crappy echos
        TE_vals=[25:5:55];
        TE_vals=TE_vals(3:6);
        data=data(:,:,:,:,3:6);
        [nkx,nky,nkz,ncoils,nechos]=size(data);
        mask=abs(squeeze(sum(sum(data(:,:,:,:,1),1),4)))>0;
        mask=repmat(reshape(mask,[1 nky nkz]),[nkx 1 1 ncoils nechos]);
        cmask=mask;
        
        fn_noise='/home/tringo/Dropbox/data/T2/20110806 Phantom A67/DATA LISTs/raw_014_NOI.mat';
        fprintf(1,'Loading noise scan %s\n',fn_noise) ;
        data_noise=double(load_philips(fn_noise));
    case 2
        % load In vivo Swine - VT-share/20110816 VTA Pig B306 8 days post MI, scan 28 (low res) and scan 29 ( high res)
        fn='/home/tringo/Dropbox/data/T2/20110816 VTA Pig B306 8 days post MI/DATA LIST/raw_029_STD.mat';
        fprintf(1,'Loading %s\n',fn) ;
        %The T2W for B306 post , scan 28  ( 4 volumes with TEs 0, 25, 35, 45 ms) and scan 29 ( 3 volumes with TE 0, 25, 45ms).
        TE_vals=[0 25 45];
        data=load_philips(fn);
        
        %TODO: partial reshape should return a full mask and a calibration
        %data mask. Create another output from loaddata that gives both.
        [data,nkx,nky,nkz,mask,cmask]=partialreshape(data);
        
        fn_noise='/home/tringo/Dropbox/data/T2/20110816 VTA Pig B306 8 days post MI/DATA LIST/raw_029_NOI.mat';
        fprintf(1,'Loading noise scan %s\n',fn_noise) ;
        data_noise=double(load_philips(fn_noise));
    case 3
        fn='../../../data/T2/20110806 Phantom A67/DATA LISTs/raw_014_STD.mat';
        fprintf(1,'Loading %s\n',fn) ;
        [data,nkx,nky,nkz,ncoils,nechos]=load_philips(fn);
        
        %exclude crappy echos
        TE_vals=[25:5:55];
        TE_vals=TE_vals(3:6);
        data=data(:,:,:,:,3:6);
        [nkx,nky,nkz,ncoils,nechos]=size(data);
        mask=abs(squeeze(sum(sum(data(:,:,:,:,1),1),4)))>0;
        mask=repmat(reshape(mask,[1 nky nkz]),[nkx 1 1 ncoils nechos]);
        cmask=mask;
end

% mask=abs(squeeze(sum(sum(data(:,:,:,:,1),1),4)))>0;
% mask=repmat(reshape(mask,[1 nky nkz]),[nkx 1 1 ncoils nechos]);
% %% setup data properties
% fn{1}='/home/tringo/data/T2/20110806 Phantom A67/DATA LISTs/raw_014_STD.mat';
% % TE_vals_list{1}=[25:5:55,0.01]; %exclude the last echo (according to Dr. Ding);
% TE_vals_list{1}=[25:5:55]; %exclude the last echo (according to Dr. Ding);
% loadcmd{1}=@load_philips;
% 
% % load In vivo Swine - VT-share/20110816 VTA Pig B306 8 days post MI, scan 28 (low res) and scan 29 ( high res)
% fn{2}='/home/tringo/data/T2/20110816 VTA Pig B306 8 days post MI/DATA LIST/raw_029_STD.mat';
% %The T2W for B306 post , scan 28  ( 4 volumes with TEs 0, 25, 35, 45 ms) and scan 29 ( 3 volumes with TE 0, 25, 45ms). 
% TE_vals_list{2}=[0 25 45];
% loadcmd{2}=@load_philips;
% 
% %In vivo NV - T2map-share/20110804 NV007, scan 18 ( low res) and scan 19 ( high res)
% fn{3}='/home/tringo/data/T2/20110804 NV007/DATA LIST/raw_019_STD.mat';
% TE_vals_list{3}=[0 25 45];
% loadcmd{3}=@load_philips;
% 
% %% Brain datasets
% % fn{4}='/home/tringo/data/brain/amir/amir_pourmorteza_286811229_301_MPRAGE_SAG_Sense_20090203';
% % loadcmd(4)=@load_hdr;
% 
% %% common load code
% fprintf(1,'Loading %s\n',fn{s}) ;
% [data,nkx,nky,nkz,ncoils,nechos,TE_vals]=loadcmd{s}(fn{s},TE_vals_list{s});
% %some points are actually zero, we assume that all coils have the same
% %sampling pattern and kx is fully encoded
% mask=abs(squeeze(sum(sum(data(:,:,:,:,1),1),4)))>0;
% mask=repmat(reshape(mask,[1 nky nkz]),[nkx 1 1 ncoils nechos]); 


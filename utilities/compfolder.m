function compfolder(foldername,refname,slice,coil)
dbg=0
if dbg
    foldername='experiments';
    refname='full.mat';
    slice=6;
    coil=1;
end
%% takes a folder compares images in it
flist=dir(foldername);
isdir=[flist.isdir];
flist=flist(~isdir);
flist={flist(:).name};

%% find the ref image and move it to the beginning of the array
temp=flist(1);
refind=find(strcmp(refname,flist));
flist(1)=flist(refind);
flist(refind)=temp;

%% load images into cell array
imgs={};
for i=1:length(flist)
    temp=struct2cell(load([foldername '/' flist{i}]));   %allows different variable names
    imgs{i}=temp{1};
end

%% compare images
ax=comp(imgs,slice,coil);

%% title the graphs
%TODO: word wrap to allow for really long file names
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/118446
for i=1:length(flist)
    title(ax(1,i),flist{i}(1:end-4));
end
% suptitle(foldername);
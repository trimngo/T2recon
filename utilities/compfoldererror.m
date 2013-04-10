function compfoldererror(foldername)
% takes a folder compares images in it
dbg=0
if dbg
    foldername='experiments';
    refname='full.mat';
    slice=6;
    coil=1;
end
%%
flist=dir(foldername);
isdir=[flist.isdir];
flist=flist(~isdir);
flist={flist(:).name};

%% load data into cell array
dat={};
for i=1:length(flist)
    temp=struct2cell(load([foldername '/' flist{i}]));   %allows different variable names
    dat{i}=temp{1};
end

%% display graphs
figure;
for i=1:length(flist)
    plot(dat{i}); hold all;
end

%% legend
%TODO: word wrap to allow for really long file names
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/118446
labels={};
for i=1:length(flist)
    labels{i}=flist{i}(1:end-4);
end
legend(labels);
%% title
title(foldername);
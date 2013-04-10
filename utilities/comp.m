function ax=comp(imgs,slice,coil)
%images is cell array of test images, first is the gold standard

%assume image is 2D
%row one: abs of all images including gs
%row two: diff of all images with gold standard
%columns are different coils
%show images space and difference
%scales all images to the same color scale

%% setup image matrix
for i=1:length(imgs)
    imgcell{1,i}=abs(imgs{i});
    imgcell{2,i}=angle(imgs{i});
    imgcell{3,i}=abs(imgs{i}-imgs{1});
    
    %     NRMSE(i)=mean(vect(abs(imgs{i}-imgs{1})))/mean(abs(imgs{1}(:)));
    NRMSE(i)=nrmse(imgs{1},imgs{i});
end

climcell=cell(size(imgcell));
for i=1:length(imgs)
    for r=1:3
        if r==2
            climcell{r,i}=[-pi pi];
        else
            climcell{r,i}=[min(abs(vect(cell2mat(imgcell(r,:))))) max(abs(vect(cell2mat(imgcell(r,:)))))];
        end
    end
end

%% display images
figure;
dp=cell(size(imgcell));
for i=1:numel(imgcell)
    dp{i}=imgcell{i}(:,:,slice,coil);
end
ax=imagemat(dp,climcell);

%% add error calculation and display
for i=1:length(imgs)
    title(ax(3,i),sprintf('%d',NRMSE(i)));
end

function ax=imagemat(imgcell,climcell)
ax=subplotmat(size(imgcell));
for r=1:size(imgcell,1)
    for c=1:size(imgcell,2)
        imagesc(imgcell{r,c},'Parent',ax(r,c),climcell{r,c});
    end
end

axis(vect(ax),'equal','tight','off');
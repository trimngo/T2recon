function cent=maxnd(temp)
%find max location of max of a matrix, eg:find center of kspace
dims=size(temp);
[~,ind]=max(temp(:));
cent=zeros(size(dims));
str=[];
for k=1:length(dims)
    str=[str ['cent(' num2str(k) ') ']];
end

eval(['[' str ']=ind2sub(size(temp),ind);']);
% cent=ind2sub(size(temp),ind);
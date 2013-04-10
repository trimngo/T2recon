function cent=max3d(temp)
%find max location of max of a matrix, eg:find center of kspace
[y,ind]=max(temp(:));
cent=zeros(3,1);
[cent(1),cent(2),cent(3)]=ind2sub(size(temp),ind);
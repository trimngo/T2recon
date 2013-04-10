function [supp,pmask,cmask] = simpartial( supp )
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

end


function cref=estcoilsens(udata,kwin,kspace2imspace)
[nkx nky nkz ncoils nechos]=size(udata);
%% My method
% this only works on a single echo
%problem: somehow the estimated sensitivities are invariant in z direction
%even with very localized coils, they are invariant in z
%not sure if they are invariant or not, need to look at this more closely
%just plot a profile cutting through z
%yes, definitely invariant, need to figure out why
%z profile become not invariant if we don't put the coils exactly in the
%center of the volume

x3_f_cent=udata.*kwin;
% figure; imagescn(abs(udata).^(1/2),[],[],[],3);
% figure; imagescn(abs(permute(x3_f_cent,[2 3 1 4])).^(1/2),[],[],[],3);
% x3_f_cent=udata.*kwin; %multiply with window here

%TODO:might want to replace the below with a generalized kspace to image space
%function (would break a few things though, just have to go through and
%check)
cref=kspace2imspace(x3_f_cent); %kaiser window already applied
% figure;imagescn(abs(cref(:,:,:,4)),[],[],[],[]);
cref_rss=sqrt(sum(abs(cref.^2),4));
% cref_rss=rss(cref,4);
% figure;plot(vect(abs(cref(2*nkx/4,2*nky/4,:,1))));hold all;
% plot(vect(abs(cref(2*nkx/4,2*nky/4,:,2))));
% plot(vect(abs(cref(2*nkx/4,2*nky/4,:,3))));
% plot(vect(abs(cref(2*nkx/4,2*nky/4,:,4))));
% figure;plot(vect(abs(cref_rss(2*nkx/4,2*nky/4,:))));
% figure; imagescn(cref_rss,[],[],[],[]);
for i=1:ncoils
        cref(:,:,:,i,:)=cref(:,:,:,i,:)./(cref_rss+eps); %add eps to avoid divbyzero
%     cref(:,:,:,i)=cref(:,:,:,i)./(cref(:,:,:,1)+eps); %add eps to avoid divbyzero
end
% figure;plot(vect(abs(cref(2*nkx/4,2*nky/4,:,1))));hold all;
% plot(vect(abs(cref(2*nkx/4,2*nky/4,:,2))));
% plot(vect(abs(cref(2*nkx/4,2*nky/4,:,3))));
% plot(vect(abs(cref(2*nkx/4,2*nky/4,:,4))));
% 
% figure;plot(vect(abs(cref(:,nky/2,nkz/2,1))));hold all;
% plot(vect(abs(cref(:,nky/2,nkz/2,2))));
% plot(vect(abs(cref(:,nky/2,nkz/2,3))));
% plot(vect(abs(cref(:,nky/2,nkz/2,4))));

%% kellman's method
% cref=zeros(nkx,nky,nkz,ncoils);
% rec=recon_ifft(udata.*kwin);
% %something weired happens at edges if rec isn't reconstructed with correct
% %image space shift
% for z=1:nkz
%     cref(:,:,z,:)=b1map(squeeze(rec(:,:,z,:)));
% end

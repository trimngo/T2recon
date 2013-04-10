function [data_decorr,s_decorr]=whiten(data,s,data_noise)
%% setup
[nkx,nky,nkz,ncoils,nechos]=size(data);

%% compute simplified noise matrix
Z=squeeze(data_noise).';
Psi=(1/size(Z,2))*(Z*Z');

%% compute cholesky decomp
L=chol(Psi,'lower');

%% compute virtual coils and coil sensitivity
data_decorr=zeros(size(data));
s_decorr=zeros(size(data));
for e=1:nechos
    m=reshape(data(:,:,:,:,e),[nkx*nky*nkz ncoils]).';
    m_decorr=(L\m).';
    data_decorr(:,:,:,:,e)=reshape(m_decorr,[nkx nky nkz ncoils]);
    
%     m=reshape(data(:,:,:,:,e),[nkx*nky*nkz ncoils]).';
%     m_decorr=(L\m).';
%     data_decorr(:,:,:,:,e)=reshape(m_decorr,[nkx nky nkz ncoils]);
    
    s_temp=reshape(s(:,:,:,:,e),[nkx*nky*nkz ncoils]).';
    s_temp_decorr=(L\s_temp).';
    s_decorr(:,:,:,:,e)=reshape(s_temp_decorr,[nkx nky nkz ncoils]);
end

figure; imagescn(abs(s_decorr),[],[],[],3);

% %% reconstruct virtual coils and display
% x_decorr=kspace2imspace(data_decorr);
% figure; imagescn(abs(x_decorr),[],[],[],3);

%% check if data is actually decorrelated
Zcheck=(L\Z);
% Psicheck=(1/size(Zcheck,2))*(Zcheck'*Zcheck);
Psicheck=(1/size(Zcheck,2))*(Zcheck*Zcheck');
% figure; imagesc(abs(Psi));
figure; imagesc(abs(Psicheck));
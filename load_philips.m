function data=load_philips(fn)
load(fn);
% tidy up the data into a large matrix
nkx=DataStruct.kx.Size;
nky=DataStruct.ky.Size;
nkz=DataStruct.kz.Size;
ncoils=DataStruct.chan.Size;
nechos=DataStruct.CellSizes;

data=zeros(nkx,nky,nkz,ncoils,nechos,'single');

for e=1:nechos
    data(:,:,:,:,e)=Data{e}; %Data is provided by above load
end

%format kspace to matlab conventions
data=ifftshiftn(data,[1 2 3]);
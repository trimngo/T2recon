function x=fftshiftn(y,dims)
%ifftshifts the specficied dims
x=y;
for i=1:length(dims)
    x=fftshift(x,dims(i));
end
function x=ifftshiftn(y,dims)
%ifftshifts the specficied dims
x=y;
for i=1:length(dims)
    x=ifftshift(x,dims(i));
end
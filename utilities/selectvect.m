function x=selectvect(N,pos)
%returns an N length vector of all zeros except for a one at pos
x=zeros(N,1);
x(pos)=1;
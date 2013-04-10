function out=nrmse(ref,x)
% http://en.wikipedia.org/wiki/Root-mean-square_deviation
out=sqrt(mean(abs(x(:)-ref(:)).^2))/range(abs(x(:)));
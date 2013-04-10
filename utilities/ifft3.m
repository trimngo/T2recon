function x=ifft3(y)
x=ifft(ifft(ifft(y,[],1),[],2),[],3);
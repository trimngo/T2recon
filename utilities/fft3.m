function x=fft3(y)
x=fft(fft(fft(y,[],1),[],2),[],3);
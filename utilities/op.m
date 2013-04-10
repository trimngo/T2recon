function y=op(x,cmd)
%applies a vector command to x
eval(['y=x' cmd ';']);
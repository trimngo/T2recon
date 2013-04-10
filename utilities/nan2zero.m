function output=nan2zero(input)
inds=isnan(input);
output=input;
output(inds)=0;
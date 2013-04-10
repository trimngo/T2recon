function output=remnan(input)
inds=isfinite(input);
output=input(inds);
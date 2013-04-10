function h=subplotmat(dims)
%generates a matrix of handles corresponding to a matrix of axes
rows=dims(1);
cols=dims(2);
h=zeros(dims);

for r=1:rows
    for c=1:cols
        h(r,c)=subplot(rows,cols,(r-1)*cols+c);
    end
end
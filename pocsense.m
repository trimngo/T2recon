function [gc,delta,ne]=pocsense(m,s,supp,psupp,phaseref,kspace2imspace,imspace2kspace,maxits,gs,g0c,coilprojw,debug)
%% run
% debug=;
[nkx nky nkz ncoils]=size(m);
pproj=true; %true:parallel projections, false: sequential projections
I=1/sqrt(sum(abs(s).^2,4));

fh1=figure;
fh2=figure;

gc=g0c;

coilproj=[];
coilproj{1}=@(x) proj_data(x,m,supp,kspace2imspace,imspace2kspace);
coilproj{2}=@(x) proj_SENSE(x,s);
coilproj{3}=@(x) proj_phase(x,phaseref,true(size(phaseref))); %%w/o phase mask
% coilproj{4}=@(x) proj_data(x,m,psupp,kspace2imspace,imspace2kspace);
% coilprojw=[1 1 phasew];
coilprojw=coilprojw./sum(coilprojw);
% ones(length(coilproj),1)*(1/length(coilproj)); %equal weighting
lambda=1; %should be [0,1]

frame=[];
error=[];
for i=1:maxits
%     frame(:,:,i)=gc(:,:,10,1);
%     imagesc(abs(frame(:,:,i)));axis equal; colormap('gray'); drawnow;
    gcprev=gc;
    
    %compute error
    ne(i)=norm(vect(gc-gs))/norm(gs(:));
    
    %Projections
    if pproj %parallel
        pgc=zeros(nkx,nky,nkz,ncoils,size(coilproj,2));
        for j=1:length(coilproj)
            pgc(:,:,:,:,j)=coilprojw(j)*coilproj{j}(gc);
        end
        t1=sum(pgc,5);
    else %sequential (fix later)
        t1=gc;
        for j=1:length(coilproj)
            t1=coilproj{j}(t1);
        end
    end
    
    %update estimate
    gc=gc+lambda*(t1-gc); %(1-lambda)g+lambda*t1
    
    %compute change
    delta(i)=norm(vect(gc-gcprev))/norm(vect(gcprev));
    
    if debug && i>1
        figure(fh1);
        g=sum(gc.*conj(s),4).*(1/sum(abs(s).^2,4));
        imagesc(abs(g(:,:,10)));axis equal; colormap('gray');
        figure(fh2);
        subplot(2,1,1); plot(ne);
        subplot(2,1,2); plot(delta);
    end
    fprintf('Joint: Iteration: %i, delta: %d\n',i,delta(i));
end
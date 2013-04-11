classdef Recon_cgsense < Recon_base
    %RECON_CGSENSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function [v,delta,ne]=runalg(my,m,s,supp,csupp,phaseref,kspace2imspace,imspace2kspace,maxits,gs,b0,coilprojw,debug)
            %%
            % debug=true;
            %initiate
            I=1/sqrt(sum(abs(s).^2,4)); %set this to all ones if don't want intensity correction.
            dcf=ones(size(m));
            a=I.*sum(kspace2imspace(dcf.*m).*conj(s),4);
            % a=sum(kspace2imspace(m).*conj(s),4);
            [nkx nky nkz ncoils nechos]=size(m);
            % b=zeros(nkx,nky,nkz);
            b=b0;
            r=a-I.*sum(kspace2imspace(dcf.*imspace2kspace(s.*repmat(I.*b0,[1 1 1 ncoils 1])).*supp).*conj(s),4); %modified from original paper
            
            if debug
                fh1=figure;
                fh2=figure;
            end
            for i=1:maxits
                delta(i)=(r(:)'*r(:))/(a(:)'*a(:));
                
                v=I.*b;
                ne(i)=norm(vect(v-gs))/norm(gs(:));
                
                fprintf('Iteration %i: delta=%d, error=%d\n',i,delta(i),ne(i));
                
                if debug && i>1
                    figure(fh1);
                    imagesc(abs(v(:,:,10))); axis equal; colormap('gray');
                    figure(fh2);
                    subplot(2,1,1); plot(ne);
                    subplot(2,1,2); plot(delta(2:end));
                end
                if delta(i)<eps
                    %there is a problem with the algorithm if r=0 (div. by zero) so we have to check
                    %for that.
                    break;
                end
                q=I.*sum(kspace2imspace(dcf.*imspace2kspace(s.*repmat(I.*a,[1 1 1 ncoils])).*supp).*conj(s),4);
                b=b+((r(:)'*r(:))/(a(:)'*q(:)))*a;
                r=r-((r(:)'*r(:))/(a(:)'*q(:)))*q;
                a=r+((r(:)'*r(:))/(r(:)'*r(:)))*a;
            end
        end
    end
end


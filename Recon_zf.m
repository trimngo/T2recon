classdef Recon_zf < Recon_base
    %RECON_ZF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function [v,vcomb,delta,ne]=runalg(my,m,s,supp,csupp,phaseref,kspace2imspace,imspace2kspace,maxits,gs,b0,coilprojw,debug)
            v=kspace2imspace(m);
            delta=[];            
            vcomb=my.combcoils(v,s);
            ne=my.computeNE(vcomb,gs);
        end
    end
    
end


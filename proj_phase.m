function xproj=proj_phase(x,phaseref,phasemask)
%phasemask indicates region of low phase change, where we can trust the
%phaseref
%simple method
% xproj=abs(x).*exp(1i*phaseref);

% Haacke's cosine method
xpe=abs(x).*cos(phaseref-angle(x)).*exp(1i*phaseref);
xproj=x;
xproj(phasemask)=xpe(phasemask);
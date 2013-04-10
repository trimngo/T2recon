function supp=gensupp_reg(nkx,nky,nkz,ncoils,nechos,rate,supp_center)
    % suppkyind=randperm(nky,m); %random sampling
    suppkyind=1:rate(1):nky; %regular sampling
    suppky=false(1,nky,1);
    suppky(suppkyind)=true; %fill in chosen support
    
    % suppkzind=randperm(nkz,m); %random sampling
    suppkzind=1:rate(2):nkz; %regular sampling
    suppkz=false(1,1,nkz);
    suppkz(suppkzind)=true; %fill in chosen support
    
%     figure;stem(suppky(:));
%     figure;stem(suppkz(:));
    
    supp=repmat(suppky,[nkx 1 nkz ncoils nechos])&repmat(suppkz,[nkx nky 1 ncoils nechos]);
    supp=supp|supp_center;

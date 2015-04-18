function [xavg, xrange, ncams] = camstats(x,nid,nt,intvl)
%[XAVG, XRANGE, NCAMS] = CAMSTATS(X,NID, NT, INTVL) 
%takes MASC data output in X and
%provides statistics for the properties of X where the ID numbers are the
%same and within time INTVL. NID is the column for 
%the image IDs where there are NCAMS of good images per id 
%AVG and RANGE are self-explanatory. NCAMS is the number of camera images going
%into the calculation of XAVG and XRANGE.
%%%NOTE!!! To avoid nasty floating point errors in ISMEMBER.M this function
%%%requires ISMEMBERF.m from the Mathworks File Exchange 
%%% http://www.mathworks.com/matlabcentral/fileexchange/23294-ismemberf


%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification

% Loop through time and filter by same ids

[R,C] = size(x);
ids = x(:,nid); %image id numbers
t = x(:,nt); % timestamps in datenumber format
dateintvl = datenum([0 0 0 0 0 intvl]); %interval between images





%%%%%%%%% GROUP ACCORDING TO NUMBER OF CAMERAS PER IMAGE %%%%

%Make space for matrices
xavg = zeros(length(t),C);
xrange = zeros(length(t),C);
ncams = zeros(length(t),1);

length(t);
parfor i = 1:length(t); %cycle through the image times 
    maxrange = nanmin(i+5,length(t));
    minrange = nanmax(1,i-5);
    lookuprange = minrange:maxrange; 
    idsrange = ids(lookuprange);
    trange = t(lookuprange);
    idsgood = find(ismember(idsrange,ids(i))==1);
    timesgood = find(ismemberf(trange,t(i),'row','tol',dateintvl*2) == 1);
    
    indintersect  = (intersect(idsgood,timesgood));
    idind  = lookuprange(indintersect);
    ncams_temp(i) = length(idind); %number of cams per flake
    if ncams(i) > 3
       idind
       error('too many ids! Duplicate timestamps?')
    end
    xavg_temp(i,:) = nanmean(x(idind,:),1); %mean of flakes
    xrange_temp(i,:) = nanmax(x(idind,:),[],1) - nanmin(x(idind,:),[],1); %range for flakes
end
    [C,IA,IB] = unique(xavg_temp(:,nt));
    xavg = xavg_temp(IA,:);
    xrange = xrange_temp(IA,:); 
    ncams = ncams_temp(IA)';
    
    
end


function [imgpaths] = camlabelstats(x,y, nid,nt,intvl)
%[imgpaths, NCAMS] = CAMSTATS(X, Y, NID, NT, INTVL) 
%takes MASC data output in X and
%image path vector Y and provides a structure for the file path of the images
% where the ID numbers are the
%same and within time INTVL. NID is the column for 
%the image IDs in X where there are NCAMS of good images per id. NT is the column 
%for the timestamps in datenumber format 
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
ncams = zeros(length(t),1);
%paths_temp = {};
paths_temp = cell(length(t),3);
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
    
    tavg(i) = nanmean(x(idind,nt),1); %mean of time
    
    %%Force 3 per snowflake by means of repetition.
    if length(idind) == 1;
        idind = [idind idind idind];
    elseif length(idind) == 2;
        idind  = [idind idind(1)];
    end
    
          
    %paths_temp = vertcat(paths_temp,y(idind)');
    paths_temp(i,:) = y(idind)';    
end

[C,IA,IB] = unique(tavg); %find the indices IA where the time means are the same
paths = paths_temp(IA,:); %image paths
imgpaths = cell(length(IA),4);%cell array for image paths with time stamp

for i = 1:length(IA);

    imgpaths(i,1) = {tavg(IA(i))}; %time in first column

end
imgpaths(:,2:4) = paths; %image paths in last three columns

end
    


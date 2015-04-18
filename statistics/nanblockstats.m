function xstats = nanblockstats(x, n, tblock, nmin, timeres, statname, timeformat)

% XSTATS = NANBLOCKSTATS(X,N,TBLOCK,NMIN,STATNAME,TIMEFORMAT) 
% NANBLOCKSTATS Calculates a sequentially blocked statistics of a matrix
% X where the time coordinate along a row dimension
%  which is continuous but where X may have missing data with NaNs. 
%   N refers to the column dimension of the matrix X represented by
%   the time coordinate. The time coordinate must be in TIMEFORMAT 'datenum' and 'seconds'.
%   The time co-ordinate must be evenly spaced with resolution TIMERES in seconds
%   and be in either datenum or seconds format. 
%   TBLOCK is the number of points in each block in seconds
%   Effectively this function downsamples the time data and X by a factor of TBLOCK and
%   calculates statistics for each block. 2<NMIN<TBLOCK/TIMERES is the minimum 
%   threshold number for sampling. Where TMID is the middle timestep
%   of each block. XSTATS is the statistic for each value of TMID
%   Options for STATNAME are 'mean', 'min', 'max', 'freq', and for
%   percentiles, e.g. '5' '25' '50' '75' and '95'
%   Options for TIMEFORMAT are 'datenum' and 'seconds'
%%%NOTE!!! To avoid nasty floating point errors in ismember this function
%%%requires ISMEMBERF.m from the Mathworks File Exchange 
%%% http://www.mathworks.com/matlabcentral/fileexchange/23294-ismemberf

[~,C] = size(x);
datan = setdiff(1:C,n); %get data indices except timestamp
data = x(:,datan); %data
time = x(:,n); %time

% check for irregularly spaced data
if gradient(gradient(time))./gradient(time) > 0.0001
    error('Data must be evenly spaced in time');
end


% Don't allow calculations for too little data per block
if strcmp(statname,'mean') ~= 1 & nmin < 3
    error('TMIN MUST BE >= 3');
end

% The block must be at least twice as long as the temporal resolution
if strcmp(statname,'mean') == 1 & tblock == timeres
    error('TBLOCK MUST BE >= 2*TIMERES');
end

% Samples per block can't be greater than the max number of samples  in the block
if nmin > tblock./timeres
    error('TMIN MUST BE <= TBLOCK/TIMERES');
end

quantval = 50; %For parallelization this seems to need to be initialized (????)
if isempty(str2num(statname)) == 0; %test for quantile input
    functionname = 'quantile';
    quantval = str2num(statname)/100; %quantile
    if floor(1/min(abs(quantval-1),quantval))>nmin %need enough points 
        error('TMIN MUST BE LARGE ENOUGH TO ACCOMMODATE THE PERCENTILE!')
    end
elseif isequal(statname,'freq') == 1;
    functionname = 'freq';
else
    functionname = strcat('nan',statname);%nanmean, nanstd, etc...

end



%datenum or seconds format
if isequal(timeformat,'seconds')==1;
    t = datenum([zeros(length(time), 5) time]);
elseif isequal(timeformat,'datenum') == 1; 
    t = time;
end

%NEED TO TRUNCATE THE DATASET SO THAT IT DOESN"T EXTEND BEYOND NBINS*DT
% AND THAT IT STARTS ON THE HOUR
dt = datenum(0,0,0,0,0,tblock); % we define here how often the data should increase its timestamp
tstart = ceil(min(t)./dt)*dt; %Start with first time block with data
tend = floor(max(t)./dt)*dt; % End with last time block with data
blocklength = round(tblock/timeres);%indices per averaging block
timeresnum = datenum([0 0 0 0 0 timeres]);%resolution in datenum

startind = round((tstart - min(t))/timeresnum + 1);
endind = round(length(t) - (max(t)-tend)/timeresnum);
nbins = (endind - startind )/blocklength;
ttrunc = tstart:timeresnum:tend; % data does not extend betyond NBINS*DT
[~,tmid] = hist(ttrunc,nbins); %midpoints of the bins
tmidvec = [];
tmid = tmid';
for i = 1:nbins;
    tmidvectemp = repmat(tmid(i),blocklength,1);
    tmidvec = cat(1,tmidvec, tmidvectemp); % new time vector
end

%Truncate data so that it starts and ends in the same place as tmidvec
data = data(startind:endind,:);

%Preallocate space
xstats = zeros(nbins,C); 


%
parfor i = 1:length(tmid);
    %Improve speed by limiting lookup range for time matching
    minrange = (i-1)*length(tmidvec)/nbins+1; %starting index for tmidvec 
    lookuplength = round(tblock/timeres)-1;
    maxrange = minrange + lookuplength;
    lookuprange = minrange:maxrange; %indices for averaging
  
% Find indices that correspond with center bins
     dateind = lookuprange;

    if isequal(functionname,'freq') == 1
        xstats(i,datan) = length(find(isnan(data(dateind,1)) == 0))/tblock; %fraction non-NaNs
    else
        if length(dateind) < nmin
            xstats(i,datan) = NaN*ones(1,C); %statistics must satisfy minimum number
            
        else
            if isequal(functionname,'quantile') == 1
                xstats(i,datan) = quantile(data(dateind,:),quantval); %quantile
            else
                xstats(i,datan) = feval(functionname,data(dateind,:)); %stats
                
            end
        end
    end
    
end
tmid = tmid';


if isequal(timeformat,'seconds')==1;
   tvec = datevec(tmid);
   tmid = tvec(:,4)*3600 + tvec(:,5)*60 + tvec(:,6);
end

xstats(:,n) = tmid;

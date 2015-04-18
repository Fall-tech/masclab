function nanx = labelinsertnans(x, n, intvl, timeformat)

% NANY = INSERTNANS(X,N,INTVL,TIMEFORMAT) inserts NaNs in image paths
% cell array X where data is missing in a time 
% series. N refers to the column dimension represented by
% the time coordinate. The time coordinate must be in TIMEFORMAT 'datenum' or 'seconds'
% INTVL is the basic time coordinate separation in number of seconds. If the
% data timestamps are marked in finer units, they are rounded to INTVL. The
% output is the continuous dataset
% NANX that has the sameformat as X but has NANs where data is missing. The timestamp is in its
% original format
%%%NOTE!!! To avoid nasty floating point errors in ISMEMBER.M this function
%%%requires ISMEMBERF.m from the Mathworks File Exchange 
%%% http://www.mathworks.com/matlabcentral/fileexchange/23294-ismemberf

[R,C] = size(x);
labelsn = setdiff(1:C,n);
timevec = cell2mat(x(:,n)); %time vector in either seconds or datenum
%datavec = x(:,datan); %data matrix

if isequal(timeformat,'seconds')==1;
    timevecround = round(timevec/intvl)*intvl;%round seconds to INTVL
    t = timevecround; % t is rounded timestamps of orginal data
    
    %datapresent are indices in a continuous time series where data is present

    datestart = min(t); dateend = max(t);
    dateseries = [datestart:intvl:dateend]'; %timeseries in intervals of int
    datapresent = find(ismemberf(dateseries,t)==1);

elseif isequal(timeformat,'datenum')==1;
    [Y,MO,D,H,MI,S] = datevec(timevec); %convert to vector format
    Sround = round(S/intvl)*intvl;%round seconds to INTVL
    t = datenum([Y,MO,D,H,MI,Sround]); % t is rounded timestamps of original data
    %datapresent are indices in a continuous time series where data is present
    ttot = floor(Y*1e12 + MO*1e10 + D*1e7 + H*1e5 + MI*1e3 + Sround *1e1); %Unique time
    
    datestart = min(t); 
    dateend = max(t);
    dateintvl = datenum([0 0 0 0 0 intvl]);
    dateseries = [datestart:dateintvl:dateend]'; %continuous timeseries in intervals of int
    
    [Y,MO,D,H,MI,S] =  datevec(dateseries);
    dateseriestot = floor(Y*1e12 + MO*1e10 + D*1e7  + H*1e5 + MI*1e3 + S*1e1); %Unique time 2e
    [D,IA,IB] = intersect(ttot,dateseriestot) ; %find ttot in dataseriesttot
    
end

%set NaNs for timeseries length

nanx = cell(length(dateseries),4);%cell array for image paths with time stamp

for i = 1:length(dateseries);
    nanx(i,1) = {dateseries(i)}; %time in first column
end

nanx(IB,2:4) = x(IA,labelsn); %image paths in last three columns

end

function nanx = insertnans(x, n, intvl, timeformat)

% NANX = INSERTNANS(X,N,INTVL,TIMEFORMAT) inserts NaNs where data is missing in a time 
% series where N refers to the column dimension of matrix X represented by
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
datan = setdiff(1:C,n);
timevec = x(:,n); %time vector in either seconds or datenum
datavec = x(:,datan); %data matrix

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
    %datapresent = find(ismemberf(dateseries,t,'row','tol',dateintvl/1.5)==1);%indices of continuous time series that are coincident with data timestamps
    %datapresent = find(ismember(datevec(dateseries),datevec(t),'rows')==1);%indices of continuous time series that are coincident with data timestamps

end

%set NaNs for timeseries length
nanx = NaN*ones(length(dateseries),C);
%Full continuous time series with NaNs where data is missing
nanx(:,n) = dateseries;
nanx(IB,datan) = datavec(IA,:);


end

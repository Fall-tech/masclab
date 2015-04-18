%%%%This code calculates consecutive time-blocked statistics in a time series
%%%%using NANBLOCKSTATS based on the time continuous output from LOADSTATS.M 
%%%%Note that this code seems to require large amounts of
%%%%memory. 

%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification


close all;
clear all;

mascpaths
%%%% Initialize parallel computing if desired 
parproc = 1;


if parproc == 1;
    if (matlabpool('size')) == 0
         myCluster = parcluster()
         matlabpool(myCluster)
    end
end

diagnostics_params %get inputfile names
blockstats_params %specify output files and averaging time period

dirall = strcat(campaigndir,camname);


indatafile = strcat([dirall '/' stripstatsinputfile]); %Continuous statistics from LOADSTATS.M and DIAGNOSTICS_PARAMS.M
  

% Output .mat file

outdatafile = strcat([dirall '/' blockstatsoutputfile]); %From BLOCKSTATS_PARAMS.M



    %Load Data;
    load(indatafile);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% ASSIGN SELECTED DATA TO HEADER LABELS %%%%%%%%%%%%%%


    for i = 1:length(statsheaderstring);
        eval([statsheaderstring{i} '= statsdatamean(:, i);'])
    end
    
    if veloutlier == 1
        velidx = find(strcmp(statsheaderstring,'vel') == 1); %find index for vel
    
        velbad = find(statsdatamean(:,velidx)>velthresh); %identify "bad" velocities
   
        statsdatamean(velbad,velidx) = NaN; %set them to NaN
    end
    
    
    good = find(datenumber >= datenum(starttime) & datenumber <= datenum(endtime)); %times defined in DIAGNOSTICS_PARAMS.m

    stripdata = [datenumber(good) statsdatamean(good,:)]; 
    fracrealdata = [datenumber(good) maxdim(good)]; %fracreal calculates the fraction of the timeblock that has snowflake data 
    
    disp('Calculate statistics. This may take a while.')
    datameanblock = nanblockstats(stripdata, 1, nsecsinblock, nmin,interarrivaltime,'mean','datenum');  %NANBLOCKSTATS.M can do a lot. Check it out
    fracrealblock = nanblockstats(fracrealdata, 1, nsecsinblock, nmin,interarrivaltime,'freq','datenum');  
 
    fracreal = fracrealblock(:,2);
    
    blockheaderstring = ['datenumber' statsheaderstring];

    disp('Saving blocked data')
    save(outdatafile,'fracreal','datameanblock','blockheaderstring'); % save data

%   Loads a contiguous time series diagnostic and physical statistics from the MASC into memory
%   for analysis and plotting as the user sees fit.

%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification
  


mascpaths;
%Read in data?
getstatsdata = 1;

 close all;
 

if getstatsdata == 1
%Read in data. 
disp('Prepare to wait. Set getstatsdata to 0 if already done')
    clearvars;
    diagnostics_params;



    % Read processed statistics and diagnostics continuous output from LOADSTATS and
    % LOADDIAGS
    % Assign data to variable names 
    statsindatafile = strcat([strcat(campaigndir,camname) '/' stripstatsinputfile]);
    disp('Loading physical statistics');
    load(statsindatafile)
    
    for i = 1:length(statsheaderstring);
        eval([statsheaderstring{i} '= statsdatamean(:, i);']) %Assign data to variable names
    end
    
    
    clear statsdatamean;
    
    diagsindatafile = strcat([strcat(campaigndir,camname) '/' stripdiagsinputfile]);
    disp('Loading diagnostic statistics');
    load(diagsindatafile)
    %Diagsdatamean may be longer than statsdatamean
    good = find(diagsdatamean(:,10) > 0); %acceptid
    goodrange = max(1,(min(good))):max(good)'; %Range is diags file starts at first index with accepted flakes
    if abs(diagsdatamean(goodrange(1),3) - idcam(1)) > 0.2 %idcam comparison
        error('There is a misalignment in the diagnostics and statistics files!')
    end
        
    for i = 1:length(diagsheaderstring);
        eval([diagsheaderstring{i} '= diagsdatamean(goodrange, i);'])
    end
    clear diagsdatamean
    
    %%%% Load image labels file 
    labelsindatafile = strcat([strcat(campaigndir,camname) '/' striplabelsinputfile]);
    disp('Loading snowflake image paths');
    load(labelsindatafile)
        
    cam0path = labelsdata(goodrange,2);
    cam1path = labelsdata(goodrange,3);
    cam2path = labelsdata(goodrange,4);
    datenumbercam = cell2mat(labelsdata(goodrange,1));
    
    clear labelsdata
    
    
end

    diagnostics_params;
    cam_params;





%Analysis thresholds and criteria. The parameter goodv narrows down to
%images where everything is as close as possible to as it should be to
%obtain flake images with good velocity measurements
sxthresholds;
%Added variables. In particular habitsel as the updated complexity variable
AddedVars;



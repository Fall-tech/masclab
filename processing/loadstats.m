
%%%% Code for loading snowflake statistics and diagnostics file.
%%%% Requires LABEL_PARAMS, CAM_PARAMS, INSERTNANS and CAMSTATS %%%%

%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification


% Note. If you get this error: 

%    Error in uploaddirs (line 20)
%    d = regexp( r{2}, '\.','split' );

%    then UPLOADDIRS needs to be modified

mascpaths;
close all


clear all
parproc = 1;

if parproc == 1; 
    if (matlabpool('size')) == 0
         myCluster = parcluster()
         matlabpool(myCluster)
    end
end

%%%%%%%%%OUTPUT PARAMTERS%%%%%%%%%%%%

statsoutputfile = 'Statsdata'; %To go in directory DIRALL as specfied below

stripstatsoutputfile = 'StripStatsdata'; %To go in directory DIRALL as specfied below




%%%%%%%%%INPUT PARAMTERS%%%%%%%%%%%%


%%%%%%%%%PHYSICAL PARAMTERS%%%%%%%%%%%%

Tref = 268; %Ref temperature
mu0 = 18e-6; %Pa Dynamic viscosity at 291
C  = 120;
T0 = 291;
mu = mu0*(T0 + C)/(Tref + C)*(Tref/T0)^(3/2); %Sutherlands formula

grav = 9.8; %m/s^2 gravity
rhoi = 917; %kg/m3 bulk ice density


%%%%%%%%%%% Load user specified parameters %%%%%%%%%%%%
    
 %labelling convention and analaysis bounds for input and output
    label_params% outputs: campaigndir,camname,labelformat,cropcamdir,uncropcamdir,rejectdir
 % Camera and lens details
    cam_params %outputs: MASCtype, fovmat, colorcammat, interarrivaltime


   

%%%%The following range could be the same as that specified originally in
%%%%MASC_process
    starthr = [2013 01 01  01]; % Specifies the starting hour for a desired range of upload
    endhr = [2013 04 30 23]; % Specifies the ending hour for a desired range of upload


    flakedirs = dir(strcat(campaigndir,camname));
    dirall = strcat(campaigndir,camname);
    dirlistall = {flakedirs.name};
    
 % upload flake directorie names 
    dirlist = uploaddirs(dirall,dirlistall,starthr,endhr); %outputs: directory list
    
    %index locations of first and last directories
    STARTind = find(strcmp(strcat(dirall,'/',dirlistall,'/'),dirlist(1)) == 1);
    ENDind = find(strcmp(strcat(dirall,'/',dirlistall,'/'),dirlist(length(dirlist))) == 1);

%If multiple directories, order with most recent first: .e.g
%flakedir = {'./11082012/' './11092012/' './11092012_2/'};



statsdata = [];

%Concatenate statistics files

parfor i = STARTind:ENDind;
    flakedir = cell2mat(strcat(dirall,'/',dirlistall(i),'/')); 

    dirconcell = struct2cell(cat(1,dir(flakedir)));
% Avoid empty directories
    if any(ismember(dirconcell(1,:),'stats.txt')) == 0  
        continue
    end

    statsname = strcat([flakedir 'stats.txt']);
    s = dir(statsname);
% test for empty stats.txt files
    if s.bytes <= 115
	continue
    end
% Read in statistics, diagnostics, and file paths.    
    dataset = importdata(statsname,' ',1);
    statsdata = [statsdata; dataset.data];

end
%get header data from single directory
flakedir = cell2mat(strcat(dirall,'/',dirlistall(12),'/'));
statsname = strcat([flakedir 'stats.txt']);
dataset = importdata(statsname,' ',1);
% sort by date because parallelization jumbles
[R,C] = size(statsdata);
statsdatatemp = sortrows([datenum(statsdata(:,4:9)) statsdata],1);
statsdata = statsdatatemp(:,2:C+1);

 statsheaderstring = regexp(dataset.textdata{:}, '\t','split');
 statsheader = genvarname(statsheaderstring);


disp('data read');

idcol = 1; %column where the camera id is in the diagnostics and statistics files


%%%%%%%%%%%% ASSIGN STATS DATA TO HEADER LABELS %%%%%%%%%%%%%%


for i = 1:length(statsheader);
    eval([statsheader{i} '= statsdata(:, i);'])
end


flakeangidx = find(strcmp(statsheader,'flakeang') == 1);
statsdata(:,flakeangidx) = abs(statsdata(:,flakeangidx)); %consider only absolute value of flake angle 
partxsec = partarea.*xsec; %Actual cross-section of flake in mm^2
req = sqrt(partxsec/pi); %Area equivalent radius in mm;
mass = 4/3*pi*rhoi*(req*1e-3).^3*1e6; %mg (assumes 917 kg/m3 as bulk ice density)
volume = 4/3*pi*(req).^3; %mm^3
complexity = perim./(2*pi*req); %Ratio of actual perimeter to perimeter of a circle with equivalent xsec
tauaer = vel./grav; %Time to adjust to terminal fallspeed.
velaer = 2/9*rhoi*(req.*1e-3).^2.*grav./mu; %Terminal fallspeed in still air assuming Stokes drag and req represents a solid sphere.

datenumber = datenum([yr month day hr mins sec]);
statsdata = [statsdata partxsec req mass volume complexity datenumber];
statsheaderstring = [statsheaderstring 'partxsec' 'req' 'mass' 'volume' 'complexity' 'datenumber'];
[R, C] = size(statsdata); %C is the column of DATENUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% GROUP ACCORDING TO NUMBER OF CAMERAS PER IMAGE %%%%
%%%%% The following calculates statistics where multiple cameras, reducing the length
%%%%% to the number of unique id stamps

[statsdatameangaps, statsdatarangegaps, ncams] = camstats(statsdata, idcol,C,interarrivaltime);
disp('camstats done');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Assign variable name to time stamp with gaps
datenumbermeangaps = genvarname('datenumbermeangaps');
eval([datenumbermeangaps '= statsdatameangaps(:,C);']);


%Create new complexity measures based on variability between camera angles

maxdimidx = find(strcmp(statsheaderstring,'maxdim') == 1); 
perimidx = find(strcmp(statsheaderstring,'perim') == 1);
partareaidx = find(strcmp(statsheaderstring,'partarea') == 1);
flakeangidx = find(strcmp(statsheaderstring,'flakeang') == 1);
aspratidx = find(strcmp(statsheaderstring,'asprat') == 1);
partxsecidx = find(strcmp(statsheaderstring,'partxsec') == 1);
reqidx = find(strcmp(statsheaderstring,'req') == 1);
complexityidx = find(strcmp(statsheaderstring,'complexity') == 1);   

var = statsdatarangegaps./statsdatameangaps;
var_maxdim = var(:,maxdimidx);
var_perim = var(:,perimidx);
var_partarea = var(:,partareaidx);
var_flakeang = var(:,flakeangidx);
var_asprat = var(:,aspratidx);
var_partxsec = var(:,partxsecidx);
var_req = var(:,reqidx);
var_complexity = var(:,complexityidx);

%Full time series with gaps
statsdatameangaps = [statsdatameangaps...
    var_maxdim var_perim var_partarea var_flakeang...
var_asprat var_partxsec var_req var_complexity ncams];
statsheaderstring = [statsheaderstring ...
    'var_maxdim' 'var_perim' 'var_partarea' 'var_flakeang'...
 'var_asprat' 'var_partxsec' 'var_req' 'var_complexity' 'ncams' ];


clearvars -except dirall statsoutputfile stripstatsoutputfile statsdatameangaps C interarrivaltime statsheaderstring;
%Save data for statistical analysis
statsdatafilepath = strcat([dirall '/' statsoutputfile]);
save(statsdatafilepath);


%%%%%%%%% CREATE A CONTINUOUS TIME SERIES WITH NANS WHERE DATA IS ABSENT
%%%%%%%%% %%%%

       statsdatamean = insertnans(statsdatameangaps,C, interarrivaltime,'datenum'); % interarrivaltime specified in cam_params.m;

disp('insertnans done') 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% THIRD PASS TO ASSIGN SELECTED DATA TO HEADER LABELS %%%%%%%%%%%%%%


for i = 1:length(statsheaderstring);
    eval([statsheaderstring{i} '= statsdatamean(:, i);'])
end

%Save data for producing strip charts

clear statsdatameangaps 
stripdatafilepath = strcat([dirall '/' stripstatsoutputfile]);
save(stripdatafilepath,'-v7.3');


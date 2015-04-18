
%%%% Code for loading snowflake diagnostics file including image paths.
%%%% Requires LABEL_PARAMS, CAM_PARAMS, INSERTNANS and CAMSTATS %%%%
%%%% BE SURE TO MODIFIY BOTH PARAMS FILES!!!!!
%%%% Requires SORTCELL from the matlab file exchange 
%%%% http://www.mathworks.com/matlabcentral/fileexchange/13770-sorting-a-cell-array

%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification


% Note. If you get this error: 

%    Error in uploaddirs (line 20)
%    d = regexp( r{2}, '\.','split' );

%    then UPLOADDIRS needs to be modified

mascpaths;
close all
%%%% Save data? Choose 0 if just testing, 1 otherwise %%%%%%%%%


clear all
savedata = 1 ;

parproc = 1;

if parproc == 1; 
    if (matlabpool('size')) == 0
         myCluster = parcluster()
         matlabpool(myCluster)
    end
end

%%%%%%%%%OUTPUT PARAMTERS%%%%%%%%%%%%

diagsoutputfile = 'Diagsdata'; %To go in directory DIRALL as specfied below

stripdiagsoutputfile = 'StripDiagsdata'; %To go in directory DIRALL as specfied below

labelsoutputfile = 'Labelsdata'; %To go in directory DIRALL as specfied below

striplabelsoutputfile = 'StripLabelsdata'; %To go in directory DIRALL as specfied below

%%%%%%%%%INPUT PARAMTERS%%%%%%%%%%%%



%%%%%%%%%%% Load user specified parameters %%%%%%%%%%%%
    
 %labelling convention and analaysis bounds for input and output
    label_params% outputs: campaigndir,camname,labelformat,cropcamdir,uncropcamdir,rejectdir
 % Camera and lens details
    cam_params %outputs: MASCtype, fovmat, colorcammat, interarrivaltime


    %%%%The following range could be the same as that specified originally in
    %%%%MASC_process
    starthr = [2013 01 01 01]; % Specifies the starting hour for a desired range of upload
    endhr = [2013 04 30 23]; % Specifies the ending hour for a desired range of upload

%    starthr = [2013 03 22 23]; % Specifies the starting hour for a desired range of upload
%    endhr = [2013 03 23 01]; % Specifies the ending hour for a desired range of upload

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

diagsdata = [];


%Concatenate statistics files

parfor i = STARTind:ENDind;
    flakedir = cell2mat(strcat(dirall,'/',dirlistall(i),'/')); 

    dirconcell = struct2cell(cat(1,dir(flakedir)));
% Avoid empty directories
    if any(ismember(dirconcell(1,:),'diagnostics.txt')) == 0  
        continue
    end

    statsname = strcat([flakedir 'stats.txt']);
    diagsname = strcat([flakedir 'diagnostics.txt']);
    s = dir(statsname);
% test for empty stats.txt files
    if s.bytes <= 200
	continue
    end
% Read in diagnostics paths.    
    diagset = importdata(diagsname,' ',1);
    diagsdata = [diagsdata; diagset.data];
     

end

 if parproc == 1
     % sort diagsdata by date because parallelization jumbles
     [R,C] = size(diagsdata);
     datenumber = datenum(diagsdata(:,4:9)); 
     diagsdatatemp = sortrows([datenumber diagsdata],1);
     diagsdata = diagsdatatemp(:,2:C+1);
 end
 clock
%Concatenate labels files
labelsdata = cell(length(diagsdata),1);
labelsdata = {};
for i = STARTind:ENDind;
    flakedir = cell2mat(strcat(dirall,'/',dirlistall(i),'/')); 

    dirconcell = struct2cell(cat(1,dir(flakedir)));
% Avoid empty directories
    if any(ismember(dirconcell(1,:),'diagnostics.txt')) == 0  
        continue
    end

    statsname = strcat([flakedir 'stats.txt']);
    labelsname = strcat([flakedir 'labels.txt']);
    s = dir(statsname);
% test for empty stats.txt files
    if s.bytes <= 200
	continue
    end
% Read in diagnostics and file paths.    
 
    fid = fopen(labelsname);
    labelset = textscan(fid,'%s');
    fclose(fid);
    labelsdata = [labelsdata(:); labelset{:}];
    

end
clock 
%get header data from single directory
flakedir = cell2mat(strcat(dirall,'/',dirlistall(12),'/'));
diagsname = strcat([flakedir 'diagnostics.txt']);
dataset = importdata(diagsname,' ',1);

%error('test');
% if parproc == 1 
%     % sort labelsdata by date because parallelization jumbles
%     labelsdatatmp = cell(length(diagsdata),2),%cell array for image paths with time stamp
%     labelsdatatmp(:,1) = {datenumber}; %time in first column
%     labelsdatatmp(:,2) = labelsdata; %image paths in last column
%     labelsdatatmp2 = sortcell(labelsdatatmp,1); %sort by datenumber
%     labelsdata = labelsdatatmp(:,2); %sorted labels
% end

% Get header data and generate variables from header information
 diagsheaderstring = regexp(dataset.textdata{:}, '\t','split');
 diagsheader = genvarname(diagsheaderstring);


disp('data read');

idcol = 1; %column where the camera id is in the diagnostics and statistics files

%%%%%%%%%%%% ASSIGN DIAGNOSTICS DATA TO HEADER LABELS %%%%%%%%%%%%%%


datenumber = datenum([yr month day hr mins sec]);
diagsdata = [diagsdata datenumber];
diagsheaderstring = [diagsheaderstring 'datenumber'];


[R, C] = size(diagsdata); %C is the column of DATENUMBER

%%%%%%%%% GROUP ACCORDING TO NUMBER OF CAMERAS PER IMAGE %%%%
%%%%% The following calculates statistics where multiple cameras, reducing the length
%%%%% to the number of unique id stamps

[diagsdatameangaps, diagsdatarangegaps, ncams] = camstats(diagsdata, idcol, C, interarrivaltime);
disp('camstats done');
clock
%%%%% The following creates a structure for each of the multiple camera views, so that the length
%%%%% of the structure is equivalent to the number of unique id stamps

labelsdatagaps = camlabelstats(diagsdata, labelsdata, idcol, C, interarrivaltime); %First column is datenumber
disp('camlabelstats done');
clock
if min(gradient(cell2mat(labelsdatagaps(:,1)))) < 0
    error('labelsdatagaps times not monotonically increasing');
end

if min(gradient((diagsdatameangaps(:,C)))) < 0
    error('diagsdatameangaps times not monotonically increasing');
end

%error('test')
%Assign variable name to time stamp with gaps
datenumbermeangaps = genvarname('datenumbermeangaps');
eval([datenumbermeangaps '= diagsdatameangaps(:,C);']);

%%Create new diagnostics measures based on variability between camera angles

vardiags = diagsdatarangegaps./diagsdatameangaps;

heightidx = find(strcmp(diagsheaderstring,'height') == 1); %Flake height should be the same if in focus
var_height = vardiags(:,heightidx);
focusidx = find(strcmp(diagsheaderstring,'focus') == 1); %Flake focus should be the similar if in focus
var_focus = vardiags(:,focusidx);
botlocidx = find(strcmp(diagsheaderstring,'botloc') == 1); %Flake distance from top should be the same if same flake
var_botloc = vardiags(:,botlocidx);
horzlocidx = find(strcmp(diagsheaderstring,'horzloc') == 1); %Flake distance from left of frame should be the similar if in focus
var_horzloc = vardiags(:,horzlocidx);


diagsdatameangaps = [diagsdatameangaps var_height var_botloc var_horzloc var_focus];
diagsheaderstring = [diagsheaderstring 'var_height' 'var_botloc' 'var_horzloc' 'var_focus'];

clear ncams;

%%Create .mat file for diagnostics and labels data
diagsdatafilepath = strcat([dirall '/' diagsoutputfile]);
labelsdatafilepath = strcat([dirall '/' labelsoutputfile]);

delete(diagsdatafilepath);
delete(labelsdatafilepath);

clearvars -except dirall diagsoutputfile labelsoutputfile diagsdatafilepath...
    labelsdatafilepath labelsdatagaps diagsdatameangaps C interarrivaltime diagsheaderstring savedata...
    stripdiagsoutputfile striplabelsoutputfile;


if savedata == 1
    save(diagsdatafilepath);
    save(labelsdatafilepath);
end

%%%%%%%%% CREATE A CONTINUOUS TIME SERIES WITH NANS WHERE DATA IS ABSENT
%%%%%%%%% %%%%

clearvars -except dirall stripdiagsoutputfile striplabelsoutputfile ...
    labelsdatagaps diagsdatameangaps C interarrivaltime diagsheaderstring savedata;


diagsdatamean = insertnans(diagsdatameangaps,C, interarrivaltime,'datenum'); % interarrivaltime specified in cam_params.m;
labelsdata = labelinsertnans(labelsdatagaps,1, interarrivaltime,'datenum'); % interarrivaltime specified in cam_params.m;

disp('insertnans done') 


%Save data for producing strip charts

clear diagsdatameangaps 
clear labelsdatagaps
stripdatafilepath = strcat([dirall '/' stripdiagsoutputfile]);
striplabelsfilepath = strcat([dirall '/' striplabelsoutputfile]);
delete(stripdatafilepath);
delete(striplabelsfilepath);

if savedata == 1
    save(stripdatafilepath,'diagsdatamean','diagsheaderstring','-v7.3');
    save(striplabelsfilepath,'labelsdata','-v7.3');%This takes forever
end

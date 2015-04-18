%%%%This code calculates overall time-blocked statistics in a time series through
%%%%NANBLOCKSTATS and then produces a strip chart through STRIPCHART

%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification


close all;
clear all;
mascpaths
%%%% Initialize parallel computing if necessary
parproc = 1;

% Load previously saved BLOCKSTATSOUTPUTFILE?
blockload = 1;

%Get user specified file and printing parameters
diagnostics_params;
blockstats_params;
strip_params;

if parproc == 1;
    if (matlabpool('size')) == 0
         myCluster = parcluster()
         matlabpool(myCluster)
    end
end

dirall = strcat(campaigndir,camname);


% Output .mat file from BLOCKSTATS.M is input here

indatafile = strcat([dirall '/' blockstatsinputfile]);

%output strip chart
stripchartfile = strcat([dirall '/' stripchartfile]);   


%Delete any pre-existing stripchart
if exist(strcat(stripchartfile,'.mat')) == 2
   delete(stripchartfile);
end

%Load output from BLOCKSTATS.M
load(indatafile) 

%Find the indices associated with the variables that are desired to be
%plotted as described in STRIP_PARAMS.M
for i = 1:length(stripvariables);
        idx(i) = find(strcmp(blockheaderstring,stripvariables(i)) == 1);
end
 
%time 
time = datameanblock(:,1);    

%Matrix of desired data with data frequency appended
x = [time datameanblock(:,idx) fracreal];

%call strip
[ax,hlines] = stripchart(x,1,loglin,labels,pagetime,orientation,stripchartfile);

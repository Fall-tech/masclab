%   Parameters for BLOCKSTATS.M
%
%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification
  

%Length of time block in seconds
%nsecsinblock = 60;
%nsecsinblock = 300;
nsecsinblock = 3600;

%outputfile = 'Blockstats1m';
%outputfile = 'Blockstats5m';
blockstatsoutputfile = 'Blockstats1h';

%Minimum amount of data per block that is defined by nsecsinblock. Required to calculate statistics
%nmin = 10;
nmin = 60;

%Restrict velocity outliers from stripfile statistics? Set to zero if
%vel is not part of STRIPVARIABLES in STRIP_PARAMS.m

veloutlier = 1; % 1 if "yes"

%Velocity outlier threshold. The goal here is to eliminate clearly errroneous velocity statistics
% from the averaging, albeit in a crude fashion. THIS IS ONLY SUITABLE FOR STRIP CHARTS NOT REAL ANALYSIS
%This is done in a more sophisticated way in SXTHRESHOLDS.M
velthresh = 5; %m/s





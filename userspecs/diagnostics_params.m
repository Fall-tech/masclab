%   Output files from LOADSTATS.M and LOADDIAGS.M 
%
%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification
  

label_params;% Get directories
%Period of analysis in datevec format [Y,MO,D,H,MI,S] 
starttime = [2013 12 18 01 0 0]; % Specifies the starting hour for a desired range of upload
endtime = [2014 05 04 12 0 0]; % Specifies the ending hour for a desired range of upload
%starttime = [2013 1 01 01 0 0];
%endtime = [2013 4 26 17 0 0];


%What is the input file

statsinputfile = 'Statsdata'; %Output from LOADSTATS.M
diagsinputfile = 'Diagsdata'; %Output from LOADDIAGS.M
labelsinputfile = 'Labelsdata'; %Output from LOADDIAGS.M

stripstatsinputfile = 'StripStatsdata'; %Output from LOADSTATS.M
stripdiagsinputfile = 'StripDiagsdata'; %Output from LOADDIAGS.M
striplabelsinputfile = 'StripLabelsdata'; %Output from LOADDIAGS.M


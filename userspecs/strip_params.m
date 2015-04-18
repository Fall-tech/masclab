%   Parameters for FLAKESTRIP.M
%
%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification
  

%Start time in datevec format [Y,MO,D,H,MI,S] 
starttime = [2013 12 18 01]; % Specifies the starting hour for a desired range of upload
endtime = [2014 05 04 12]; % Specifies the ending hour for a desired range of upload

blockstatsinputfile = 'Blockstats1h'; %This is blockstatsouputfile in BLOCKSTATS_PARAMS.M

% Output stripchart
stripchartfile = 'Stripchart';

%output orientation
orientation = 'portrait'; % landscape or portrait

%Names of variables to be plotted in the stripchart *setting aside FRACREAL (the
%frequency variable)*
stripvariables = {'vel' 'maxdim' 'req' 'complexity' 'flakeang' 'asprat' };

%Variable LaTeX strings used in stripchart. Should match STRIPVARIABLES
%with Frequency added
labels = {'$V\,\rm{(m\,s^{-1})}$' '$D_{\rm{max}}\,\rm{(mm)}$' '$r_{\rm{eq}}\,\rm{(mm)}$'...
     '$\chi$' '$\theta\,(^\circ)$' '$\alpha$' '$\rm{Frequency\,(Hz)}$'}; 

%which variables are to be plotted on a log scale (beta)
loglin = [0 0 0 0 0 0 0 0 0 0 0];

%time per page expressed in datevec format [yy mm dd hh mm ss]
pagetime = [0 0 5 0 0 0]; 


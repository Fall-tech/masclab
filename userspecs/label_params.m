   
%%%%%%%%%%%%%  Input directories  %%%%%%%%%%%%%%
%
%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification
  

%%The directory where the hourly data files lies is campaigndir/camname %%
S = pwd;
if strcmp(S,'/Volumes/garrett-group2/WASHARX/Analysis') == 1

    campaigndir = '/Volumes/garrett-group2/WASHARX/2012_2013/'; %Path to where directories are contained
else
    campaigndir = '/uufs/chpc.utah.edu/common/home/garrett-group2/WASHARX/2012_2013/'; %Path to where directories are contained

end
campaigndir = '/uufs/chpc.utah.edu/common/home/garrett-group2/WASHARX/2013-2014/'
%campaigndir = '/uufs/chpc.utah.edu/common/home/garrett-group2/WASHARX/2012_2013/' %Path to where directories are contained
camname = '1BASE'; %Specifies the name assigned to the camera
%camname = '1HC'; %Specifies the name assigned to the camera



%%%%% IMAGE LABELLING FORMAT %%%%%%%%%%%%%
    

    %%%2013.02.12_13.23.44.46528_flake_15589_cam_2.png Winter 2013 and
    %%%Winter 2014
    labelformat = 0;

    %%%2012.02.12_13.23.44_flake_15589_cam_2.png Prior to Winter 2013
    %labelformat = 1;

    %%%%CAM20120121T151459_9171_3 %%% For 01212012_2
    %labelformat = 2;

    %%%%CAM1_Flake2119.png
    %labelformat = 3; %%%% Prior to 01212012 
  
%%%%%%%%%%%%%  Output directories  %%%%%%%%%%%%%%
    cropcamdir = 'CROP_CAM';
    uncropcamdir = 'UNCROP_CAM';
    rejectdir = 'REJECTS';
    tripletdir = 'TRIPLETS';
    
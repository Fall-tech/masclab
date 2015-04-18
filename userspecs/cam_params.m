  
%%%%%%%%% PARAMETERS DESCRIBING THE MASC SETUP %%%%%%%%%%%%%%%%
%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification

    %%%% FIELD OF VIEW FOR EACH LENS IN THE HORIZONTAL DIRECTION  %%%%
    %%%% TRUST, BUT VERIFY!!!! %%%%%%
    %%% 12 mm lens = 47 mm FOV on old MASC, 44 mm on new MASC with 1.2 MP
    %%% 12 mm lens = 75 mm FOV with 5 MP
    %%% 16 mm lens = 33 mm FOV with 1.2 MP
    %%% 35 mm lens = 22 mm FOV with 5 MP
    %%% 25 mm lens = 33 mm FOV with 5 MP
    %%% 16 mm lens = 63 mm FOV with 5 MP
    

    %MASCtype = 0; %Prototype: Assumes Sony cameras
    MASCtype = 1; %Standard: Assumes Unibrain cameras for 2013 season
    %MASCtype = 2; %Standard: Assumes Unibrain cameras for 2014 season
    %MASCtype = 30; %Standard Assumes Unibrain cameras for DOE sale
    %MASCtype = 40; %Standard Assumes Unibrain cameras for Vanderbilt sale

    %%% Interarrival time and Field of View and color for cameras 0 1 and 2
    if MASCtype == 0
         %Minimum time interarrival time between triggers in seconds
         interarrivaltime = 1;
         %Color cameras for cameras 0 1 and 2? 1 if yes
         colorcammat = [1 1 1];
         %mm %Prototype MASC with 12 mm lenses
         fovmat = [47 47 47];
            
    elseif MASCtype == 1
         %Minimum time interarrival time between triggers in seconds
         interarrivaltime = 0.5;
         %Color cameras for cameras 0 1 and 2? 1 if yes
         colorcammat = [0 0 0];
         
         %fovmat = [33 22 47]; %mm New MASC with 16 mm 35 mm 16 mm 2012
         %Season

         %fovmat = [33 33 44]; %mm New MASC with 16 mm 25 mm 12 mm 2013
         %Season
         
         fovmat = [33 63 33]; %mm New MASC with 16 mm 16 mm 16 mm 2014 Season
         
         
    elseif MASCtype == 30
         %Minimum time interarrival time between triggers in seconds
         interarrivaltime = 0.5;
         %Color cameras for cameras 0 1 and 2? 1 if yes
         colorcammat = [0 0 0];
        
          %mm FT MASC with 12 mm lenses
          fovmat = [75 75 75]; %mm FT MASC with 12 mm 12 mm 12 mm and 5MP on each
          
    elseif MASCtype == 40
         %Minimum time interarrival time between triggers in seconds
         interarrivaltime = 0.5;
         %Color cameras for cameras 0 1 and 2? 1 if yes
         colorcammat = [0 0 0];
        
          %mm FT MASC with 12 mm lenses
          fovmat = [75 75 75]; %mm FT MASC with 12 mm 12 mm 12 mm and 5MP on each
    end


         

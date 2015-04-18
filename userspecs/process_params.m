
%%%%%%%%%%%%%  PROCESSING AND ANALYSIS PARAMETERS AND THRESHOLDS FOR MASC CAMERA  %%%%%
% Some of the parameters described below involve a fair bit of trial and error and
% guesswork since they specify what image characteristics qualify an image
% for rejection
%
%   Copyright Tim Garrett, University of Utah 2014. This code is freely available for
%   non-commercial distribution and modification

         %Matlab magic stuff for filling in flake x-sections


   %%%%%Background threshold. Ostensibly all pixels outside the flake
   %%%%%should fall below this threshold brightness
         if MASCtype == 0; %prototype
            backthresh = 22; %2012 Estimate of maximum background value on scale of 0 to 256
            %backthresh = [25 32 25]; %2013 Estimate of maximum background value on scale of 0 to 256
            topdiscard = 150; %2013 discard of top clutter
         elseif MASCtype > 0; %new camera
            backthresh = 3;
         end

   %%%%% Masking to limit field of view
   
          if MASCtype == 0; %prototype
                topdiscard = 150; %2013 discard of top clutter
                botdiscard = 0; %2013 discard of bottom clutter
                leftdiscard = 0; %2013 discard of left clutter
                rightdiscard = 0; %2013 discard of right clutter
                
          elseif MASCtype == 1 % new 2013 season
  
                topdiscard = 0; %2013 discard of top clutter
                botdiscard = 0; %2013 discard of bottom clutter
                leftdiscard = 0; %2013 discard of left clutter
                rightdiscard = 0; %2013 discard of right clutter
                
          elseif MASCtype == 2 % new 2014 season
  
                topdiscard = 0; %2013 discard of top clutter
                botdiscard = 0; %2013 discard of bottom clutter
                leftdiscard = 0; %2013 discard of left clutter
                rightdiscard = 0; %2013 discard of right clutter

          elseif MASCtype == 30 % DOE MASC

                topdiscard = 400; %discard of top clutter
                botdiscard = 360; %discard of bottom clutter
                leftdiscard = 600; %discard of left clutter
                rightdiscard = 600; %discard of right clutter
              
          elseif MASCtype == 40 % Vanderbilt MASC

                topdiscard = 460; %discard of top clutter
                botdiscard = 300; %discard of bottom clutter
                leftdiscard = 600; %discard of left clutter
                rightdiscard = 600; %discard of right clutter
              
          end
          discardmat = [topdiscard botdiscard leftdiscard rightdiscard];
          
   %%%%%In order to assess the flake area internal complexities are blurred 
   %%%%%with the linefill parameter. This avoids small local discontinuites 
   %%%%%to make a single flake
            linefill = 200; %200 micron line (a guess for minimum flake size)
            
   
   %%%%%%Minimum acceptable average width in microns
            sizemin = 200;
   
   %%%%%%Maximum acceptable length for a flake to touch the image frame
   %%%%%%edge
            edgetouchlength = 500;
   
   %%%%%%Minimum acceptable maximum pixel brightness [0 1]. Darker flakes
   %%%%%%tend to be out of focus
   
            minbright = 0.2;
  %%%%% The following threshold is a guess for the focus reject, not a hard and fast rule
  %%%%% lower values correspond to fewer "rejects"
  
            focusthresh = 0.01;
  
  %%%%% The following threshold is intended to allow for acceptance even
  %%%%% when there are multiple flakes in the frame. The idea is that dim,
  %%%%% small and featureless images do not confuse the velocity
  %%%%% measurement when there is an image also present that has the
  %%%%% product of these factors exceeded by the following factor
  
            velthresh = 10;
  
  %%%%% Irregularities in the background or out-of-focus images have very low internal variability
  %%%%% The below specifies the minimum variability the images must have
            rangefiltthresh = 5; 

  %%%%% Automatically send estimated out of focus images to the rejects folder?
 
            focusreject = 1;
  

  %%%%% Display accepted images while processing? This might decrease speed a little.
 
            displayaccept = 0;

  %%%%% Display rejected images while processing? This might decrease speed a little.
 
            displayreject = 0;
            
  %%%%% Modify processed images for improved display by brightening?
            flakebrighten  = 1;
            
  %%%%% If images are modified, the desired max intensity of the image [0 1]
            limitintens = 1;

  %%%%% If images are modified, the desired median intensity of the image [0 1]
            medianintens = 0.7;

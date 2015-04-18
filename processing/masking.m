function flakebwout = masking(flakebwin,horz,vert,discardmat,backthresh,MASCtype,cam)
%MASKING.M Creates a dark background for MASC images 
%   This script makes all points less than some threshold BACKTHRESH have a
%   value that is identical, and it removes all extraneous clutter in the
%   image peripheries as defined by DISCARDMAT in PROCESS_PARAMS.M. HORZ
%   and VERT are the horizontal and vertical dimensions of the
%   image.MASCTYPE is determined in cam_params

        topdiscard = discardmat(1);
        botdiscard = discardmat(2);
        leftdiscard = discardmat(3);
        rightdiscard = discardmat(4);
        
        if MASCtype == 0;     
            
            background = find(flakebwin<40);
            backthresh = quantile(flakebwin(background),0.995) + 2;
            backmin = quantile(flakebwin(background),0.01);
            flakebwin(1:topdiscard,:) = backmin; %Remove top clutter
            flakebwin(find(flakebwin<=backthresh)) = backmin; %Smooth background so background edges aren't detected

        elseif MASCtype == 1
            
            flakebwin(find(flakebwin<=backthresh)) = mean(flakebwin(flakebwin<=backthresh)); %Smooth background so background edges aren't detected
        
        
        elseif MASCtype == 2
            
            if cam == 1 %Only central camera has top and bottom clutter.
                flakebwin(1:topdiscard,:) = backthresh; %Remove top clutter
                flakebwin(vert-botdiscard:vert,:) = backthresh; %Remove bottom clutter
                flakebwin(:,1:leftdiscard) = backthresh; %Remove left clutter
                flakebwin(:,horz-rightdiscard:horz) = backthresh; %Remove right clutter
            end
            
            flakebwin(find(flakebwin<=backthresh)) = mean(flakebwin(flakebwin<=backthresh)); %Smooth background so background edges aren't detected
        
        elseif MASCtype > 2; %Commercial cameras
            
                flakebwin(1:topdiscard,:) = backthresh; %Remove top clutter
                flakebwin(vert-botdiscard:vert,:) = backthresh; %Remove bottom clutter
                flakebwin(:,1:leftdiscard) = backthresh; %Remove left clutter
                flakebwin(:,horz-rightdiscard:horz) = backthresh; %Remove right clutter
            
            flakebwin(find(flakebwin<=backthresh)) = mean(flakebwin(flakebwin<=backthresh)); %Smooth background so background edges aren't detected
            
        end

        flakebwout = flakebwin;
        
        
end


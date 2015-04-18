%Selection criteria


%Diagnostic criteria

% Identify images where the total number of flakes in the masking area is
% low
vlowtot = find(totalflakes > 0 & totalflakes <= 2);

%Specify a sweet spot MEDLOC. By looking at lot of images, 
%particularly in the directory UNCROP_CAM, it should be possible
%to identify a sweet spot where "good" triggers happen, expressible in a
%distance BOTLOC (in mm) from the bottom of the frame. Of course, 
%BOTLOC is the image resolution in mm multipled by the number of pixels.
%This will be specific to each camera and its alignment. An
%easy way to do it is just a histogram of botloc. For example
if strcmp(camname,'1BASE') & campaignid == 1; %2013 season
    medloc = find(botloc<=20 & botloc>=12);

elseif strcmp(camname,'1BASE') & campaignid == 1; %2014 season
    medloc = find(botloc<=25 & botloc>=10); %Looser due to camera orientation issues

elseif strcmp(camname,'masc'); %2014 DOE masc in Barrow
    medloc = find(botloc<=36 & botloc>=32);
end

%Estimated best selection for velocity calculations. Requires there being a
%a very low number of total objects in the FOV (allowing for background clutter)
%The premise is that fast flakes appear to be part of a
%scale break that might be associated with flakes coming from under as one
%is falling from on top. This "confuses" the MASC and is a phenomenon
%repeatable in the lab. This last criteria may be removed entirely with cameras that
%see the entire triggering depth of field (e.g. MASC V.2). Flakes are only
%considered also if the location is in the middle of the field of view.

goodv = intersect(medloc,intersect(vlowtot,find(isnan(vel)~=1))); 


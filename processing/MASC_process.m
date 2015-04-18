%%%%%%%%%%%%%%%%%%%%%IMAGE PROCESSING SCRIPT FOR MASC%%%%%%%%%%%%%%%%%%%%%

%   Copyright Tim Garrett, University of Utah 2015. This code is freely available for
%   non-commercial distribution and modification



%%%%%THE VALUE OF FIRSTTIME DETERMINES WHETHER TO LOAD UP THE TOTAL 
%%%%%DIRECTORY TREE FROM SCRATCH OR TO USE A PRIOR LOAD IN MEMORY 
%%%%%TO RESTART THE LOAD OR LOOK AT A PARTICULAR IMAGE%%%%%%%%%

%If firsttime == 1 then load up the total directory tree.
%Otherwise firsttime == 0 for selecting and testing individual flakes in
%dirname. Useful for code development and for adjusting algorithm reject parameters in process_params file


% If running on parallel processors with the matlab parallel computing
% tool box then parproc = 1; Also, change the command for j = STARTind:ENDind;
% to parfor j = STARTind:ENDind;
 
% If the desire is to skip directories that have already been processed
% even if just partially, then skipprocdir = 1;

% If the desire is to skip directories that have been fully processed then skiprecdir = 1; 
% This is a bit like skipprocdir except that
% if processing fails mid directory, then that directory will still need to be
% reanalyzed as a whole

%mascpaths;
clear all
firsttime = 1; 
skipprocdir = 0;
skiprecdir = 0;
parproc = 1; %If 1, be sure that the statement below reads parfor j = STARTind:ENDind;


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Initialize parallel processing pool %%%%%%
%delete(poolobj);

if parproc == 1;
  poolobj = gcp('nocreate'); % If no pool, do not create new one.
  if isempty(poolobj)
     poolobj=parpool;
  end
end

if firsttime == 1; 
    
    clearvars -except firsttime skipprocdir skiprecdir parproc;
 
%%%%%%%%%%% Load user specified parameters %%%%%%%%%%%%
    
 %labelling convention and analaysis bounds for input and output
    label_params% outputs: campaigndir,camname,labelformat,cropcamdir,uncropcamdir,rejectdir
 % Camera and lens details
    cam_params %outputs: MASCtype, fovmat, colorcammat, interarrivaltime
 % Image processing thresholds    
    process_params %outputs: backthresh, linefill, minbright, focusthresh, rangefiltthresh, focusreject


%%%%%%%%%%%%%%%%%%%% Enter the Start and End hours %%%%%%%%%%%%%%%%%%%%%%%    
    starthr = [2014 04 01 01]; % Specifies the starting hour for a desired range of upload
    endhr = [2014 06 01 01]; % Specifies the ending hour (inclusive) for a desired range of upload
   
  
%%%%%%%%%%%%%% Find all relevant snowflake directories %%%%%%%%%%%%%%%%%%%%%%%    
    alldirs = dir(strcat(campaigndir,camname)); %all directories, whether or not they contain flakes
    dirall = strcat(campaigndir,camname);
    dirlistall = {alldirs.name};
    dirdateall = datenum({alldirs.date}); %directory timestamp in datenum format
    
     % upload names of only those directories that contain flakes 
    dirlist = uploaddirs(dirall,dirlistall,starthr,endhr); %outputs directories with flakes
    %index locations of first and last directories
    STARTind = 1;
    ENDind = length(dirlist);
    
    %index of starting flake image to be analyzed
    STARTINDEX = 1;


%%%%%%%%%%%%%%%%%%%% FILE SELECTION FOR FOCUSSING ON A PARTICULAR DIRECTORY OR IMAGE %%%%%%%%%%%%%%%%
elseif firsttime == 0;
        
    %%%% Choose whether testing a single flake (1) or whole directory (0)%%%%
    flaketest = 0; 
    
    close all; clear flakebw
     %labelling convention and analaysis bounds for input and output
    label_params% outputs: campaigndir,camname,labelformat,cropcamdir,uncropcamdir,rejectdir
     % Camera and lens details
    cam_params %outputs: MASCtype, fovmat, colorcammat, interarrivaltime
    % Image processing thresholds    
    process_params %outputs: backthresh, linefill, minbright, focusthresh, rangefiltthresh, focusreject


    dirname = '1BASE_2014.04.25_Hr_17';%dirname is desired directory 
    STARTind = find(strcmp(dirlist,strcat(dirall,'/',dirname)) == 1);
    ENDind = find(strcmp(dirlist,strcat(dirall,'/',dirname)) == 1);
    
    flakedir = strcat(dirall,'/',dirname,'/');
    display(flakedir)
    
    
    %%%% Upload fallspeed and image names %%%%%%%%%
    [picfiles, pictime,picid,piccam, fallspeed, fallid ] = upload(flakedir);
    
    if isempty(STARTind)
        error('no such directory with flakes');
    end
    
    if flaketest == 1 %If looking at a single flake
        flaketeststart = 28165; %flake "number"
        camtest = 1; %camera number
    
        flakeid = find(picid == flaketeststart & piccam == camtest); 
        STARTINDEX = flakeid;
    else %If looking at a single directory
        STARTINDEX = 1; %start at the first flake
    end
    
end


%%%%%%%%%%%%% Loop through directory tree and process each flake %%%%%%%%%%

parfor j = STARTind:ENDind;
    %%%% Create space for triplets %%%%%
    idtriplet = zeros(3,1);
    filesnametriplet = cell(3,1);
    triptych = cell(3,1);
    %%%%%% upload flake information %%%%%
    flakedir = cell2mat(strcat(dirlist(j),'/')); %List of directories
    display(flakedir)
    
    %Skip directories that have already been analyzed if skipprocdir == 1
    dirconcell = struct2cell(cat(1,dir(flakedir)));
    if any(ismember(dirconcell(1,:),'REJECTS')) == 1  & skipprocdir == 1
        continue
    end
    
    %Skip directories that have no dataInfo file    
    if any(ismember(dirconcell(1,:),'dataInfo.txt')) ~= 1
        warning('No dataInfo.txt file found')
                continue%Skip the directory
    end
    
            
    %Skip directories that have recently been fully analyzed if skiprecdir == 1
    if skiprecdir == 1
        if any(ismember(dirconcell(1,:),'diagnostics.txt')) == 1; %Is there a diagnostics output file. If not, code will proceed normally
            %If so compare diagnostics and dataInfo files to see if the
            %directory is partially analyzed
                
            [h,A] = hdrload(cell2mat(strcat(dirlist(j),'/','diagnostics.txt')));
            [h,B] = hdrload(cell2mat(strcat(dirlist(j),'/','dataInfo.txt')));
            if isempty(A) | isempty(B) | (A(end,1) ~= B(end,1)); %Check that the last flakeid's are the same in diagnostics and dataInfo files
                continue% If so don't analyze the directory and go to next dirlist(j)
            end
        end        
    end

 
    
    %%%% Upload fallspeed and image names %%%%%%%%%
    [picfiles, pictime,picid,piccam, fallspeed, fallid ] = upload(flakedir);
    
    if firsttime == 0 
        if flaketest == 1;
            ENDINDEX = STARTINDEX; %For the case that a single flake is analyzed
        else
            [cropcam,uncropcam,rejects, triplets, fid0, fid1, fid2] = outdirs(flakedir,cropcamdir,uncropcamdir, rejectdir, tripletdir );
            ENDINDEX = length(picid); %For the case that a single directory is analyzed
        end
        
    elseif firsttime == 1;
        [cropcam,uncropcam,rejects, triplets, fid0, fid1, fid2] = outdirs(flakedir,cropcamdir,uncropcamdir, rejectdir, tripletdir );
        ENDINDEX = length(picid); 
    else        
        ENDINDEX = length(picid); %Otherwise, analyze to end of directories
    end
    % Create output directories and files
    
    
    %%%Start processing each flake
    for k = STARTINDEX:ENDINDEX
        id = picid(k);
        
        
        % ensure the fallspeed id matches the flake id
        fallindex = find(fallid == id);
        if isempty(fallindex) == 1;
            speed = NaN;
        else
            speed = fallspeed(fallindex(1));
        end
        
        cam = piccam(k);
        date = pictime(k,1:3);
        time = pictime(k,4:6);
        %disp(strcat('id', num2str(id), ' cam', num2str(cam)))  %verbosity
        %disp(strcat('date ', num2str(date), ' time ', num2str(round(time))))%date and time
        
        
        %%%%Read flake image and its embedded info
        filesname = picfiles{k};
        flakefile = strcat(flakedir,filesname);
        flakeImInfo = imfinfo(flakefile);
        if strcmp(flakeImInfo.Format,'png') ~= 1 %check if image really is an image
            warning('File is not a png')
            filesname
            continue
        end
        
        flake       = imread(flakefile);
        flakeImInfo.CreationTime = flakeImInfo.CreationTime(1:length(flakeImInfo.CreationTime)-5 );

        idcam = id + (cam + 1)/10; %an index for later use in analysis
        
        %%%%%%%% Flake dimensions
        horz = flakeImInfo.Width;
        vert = flakeImInfo.Height;
        res = fovmat(cam + 1)/horz*1000; %image resolution in microns
        
        colorcam = colorcammat(cam + 1);
        flakeImInfo.XResolution = res;
        flakeImInfo.YResolution = res;
        
        %%%%% Convert all images to Black and White
        if colorcam == 1;
            flakebw = rgb2gray(demosaic(flake,'gbrg'));%Sony color camera Bayer scheme
        else
            flakebw = flake;
        end
        
        %%%%%% Mask out clutter and the background
        flakebw = masking(flakebw,horz,vert,discardmat,backthresh,MASCtype,cam);
        
        
        %%%%%%% Matlab magic: a bit black box. Mostly yanked from image toolbox
        %%%%%%% doc sheets. Detects snowflake internal edges and creates a snowflake
        %%%%%%% cross-section
        se0 = strel('line', floor(1.5*linefill)/res, 0); %horz
        se90 = strel('line', floor(1.5*linefill)/res, 90); %vert
        
        
        BW = edge(flakebw,'Sobel',0.008); %edge detection algorithm
        BWsdil = imdilate(BW, [se0 se90]); %dilates edges
        BWdfill = imfill(BWsdil,'holes'); %fills in dilated edgy image
        BWfinal = imerode(BWdfill,[se0 se90]); %filled cross-section
        
        %Isn't matlab amazing: everything one could want in one command for
        %analyzing the image cross-section
        statsall = regionprops(BWfinal,'Image','BoundingBox','SubarrayIdx',...
            'PixelList','PixelIdxList',...
            'Perimeter','Area','MajorAxisLength',...
            'Orientation','MinorAxisLength');
        
        %local variability within the snowflake. Fun to look at: imshow(rangearry,[])
        rangearry = rangefilt(flakebw);
        totalflakes = length(statsall);
        good = zeros(1,totalflakes);
        
        %%%%%%%%%%%%%%%% ASSESS THE QUALITIES AND NUMBER OF EACH DISTINCT
        %%%%%%%%%%%%%%%% OBJECT IN THE FRAME
            
            %%% The next section determines whether images get sent to a
            %%% rejects folder
        
        %Send to rejects folder if a black frame 
        if length(statsall) == 0
            %imwrite(flakebw,[rejects '/' filesname],'png',...
            %    'Title', flakeImInfo.Title, 'Author', flakeImInfo.Author, 'Description', flakeImInfo.Description, ...
            %    'Copyright', flakeImInfo.Copyright, 'CreationTime', flakeImInfo.CreationTime, 'Source', flakeImInfo.Source, ...
            %    'BitDepth', 8);
            imwrite(flakebw,[rejects '/' filesname],'png');
            acceptid = 0;
            labelsdata = flakefile;
            fprintf(fid0,'%s\n',labelsdata'); % save label data 
            diagnosticdata = [id cam idcam date time acceptid totalflakes NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
            fprintf(fid2,'%6d %4d %8.1f %8d %8d %8d %8d %8d %8.3f %4d %6d %6d %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f\n',diagnosticdata'); % save statistics
              continue
            
        else
             %cycle through all snowflake objects in frame
            good = zeros(1,length(statsall));
            areafocus = zeros(1,length(statsall));
            
            for i = 1:length(statsall);
                
                flakeloc = statsall(i).PixelList; %indices
                flakebox = statsall(i).SubarrayIdx{:}; %box around each flake
                flakeareatotal = statsall(i).Area; %total area of each flake
                areamask = cat(1,statsall(i).PixelIdxList); %indices for each flake
                flakemask = areamask(find(flakebw(areamask) > backthresh)); %flake cross-section indices
                flakearea = length(flakemask); %indices that exceed background threshold
                intens = mean(flakebw(flakemask))/256; %[0 1] average brightness
                rangeintens = mean(rangearry(flakemask))/256; %[0 1] As a complexity measure, the mean interpixel range of normalized intensity within the snowflake bounds
                partialarea = length(flakemask)./length(areamask); %fraction of enclosed area that exceeds background
                
                % On the basis that in focus flakes are both bright and variable, a rough metric that seems to work for estimating degree of focus
                focus = intens.*rangeintens;
              
                %length of flake that touches edge of image frame
                edgetouch = res*sum([length(find(flakeloc(:,1) == 1 | flakeloc(:,1) == horz)) length(find(flakeloc(:,2) == 1 | flakeloc(:,2) == vert))]);
                areafocus(i) = focus*flakearea;
  
                %%%% identify whether a flake in the frame is good (1) or
                %%%% bad (0)
                if flakearea <= floor((sizemin/res)^2) | ... %must exceed minimum size
                        mean(mean(rangefilt(flakebw(flakemask)))) < rangefiltthresh | ... %exceed minimum focus
                        max(flakebw(flakemask)) < minbright*256 | ...%exceed minimum brightness
                        edgetouch > edgetouchlength | ... % micrometers touching the edge of the frame
                        (focusreject == 1 & round(focus*100)/100 < focusthresh); %limit bad illumination or focus; %
                    good(i) = 0;
                else       
                    good(i) = 1;
                end
                
            end
        end
        
        idx = find(good == 1);
        nflakes = length(idx); %Total number of good images
        
        % Of the good flakes (idx) find the flake that is most large and in focus
        maxareafocus = max(areafocus(idx)); 
        relareafocus = areafocus(idx)./maxareafocus; %relative areafocus
        relareafocussort = sort(relareafocus,2,'descend'); %Sort from high to low
        relareafocussort(isnan(relareafocussort) == 1) = []; % Omit NaNs
        
        
        %Send to the image frame to the rejects folder if no good flakes or if more than one good flake
        %Too many flakes confuse the velocity measurement and might be
        %blowing snow. However, the largest, most in focus image will be
        %selected provided AREAFOCUS passes a relative threshold VELTHRESH compared to the
        %next largest and in focus flake.
        
        if  nflakes == 0 | (length(relareafocussort) > 1 ...
                & max(relareafocus)/relareafocussort(2) < velthresh); 
         %   imwrite(flakebw,[rejects '/' filesname],'png',...
         %       'Title', flakeImInfo.Title, 'Author', flakeImInfo.Author, 'Description', flakeImInfo.Description, ...
         %       'Copyright', flakeImInfo.Copyright, 'CreationTime', flakeImInfo.CreationTime, 'Source', flakeImInfo.Source, ...
         %       'BitDepth', 8);
            imwrite(flakebw,[rejects '/' filesname],'png')
            acceptid = 0;
            labelsdata = flakefile;
            fprintf(fid0,'%s\n',labelsdata'); % save label data 
            diagnosticdata = [id cam idcam date time acceptid totalflakes nflakes NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
                fprintf(fid2,'%6d %4d %8.1f %8d %8d %8d %8d %8d %8.3f %4d %6d %6d %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f\n',diagnosticdata'); % save statistics
              if displayreject == 1;
            'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'       
             %pause(0.3)           
            hr = figure(1);
            imshow(flakebw,'InitialMagnification','fit')
            
            %truesize;
            end
            
            continue
            
        else
            % if the flake escapes the rejects, save!!!
            
            idxgood = idx(find(relareafocus == 1));
            
            %%%% The next section calculates the properties of good flake
            %%%% raw image
            stats = statsall(idxgood); %select the flake
            
            % Select the flake indices
            areamask = cat(1,stats.PixelIdxList);
            flakemask = areamask(find(flakebw(areamask) > backthresh)); %flake cross-section indices
            imagealone = flakebw(flakemask);
            
            % Flake physical statistics
            partialarea = length(flakemask)./length(areamask); %fraction of enclosed area that exceeds background            
            maxdim = cat(1,stats.MajorAxisLength)*res*1e-3; %Maximum dimension along major axis
            flakeang = cat(1,stats.Orientation); %Angle from horizontal of major axis
            asprat = cat(1,stats.MinorAxisLength)/cat(1,stats.MajorAxisLength); %Minor/Major
            xsec = cat(1,stats.Area)*(res*1e-3)^2; %area in mm^2
            perim = cat(1,stats.Perimeter)*res*1e-3; %perimeter in mm
            strucdens = bwarea(BW(flakemask))*res*1e-3/xsec; % internal structure density in edges/mm;            
            
            % Flake image statistics
            intens = mean(imagealone)/255; %[0 1] average brightness
            minintens = double(min(imagealone))/255; %[0 1] maximum brightness
            maxintens = double(max(imagealone))/255; %[0 1] minimum brightness
            medintens = double(median(double(imagealone)))/255; %[0 1] minimum brightness
            rangeintens = mean(rangearry(flakemask))/255; %[0 1] As a complexity measure, the mean interpixel range of normalized intensity within snowflake bounds            
            height = cat(1,stats.BoundingBox(4))*res*1e-3; %height in mm
            width = cat(1,stats.BoundingBox(3))*res*1e-3; %width in mm
            botloc = cat(1,stats.BoundingBox(2))*res*1e-3; %Distance of bottom of flake from top of frame in mm
            horzloc = cat(1,stats.BoundingBox(1))*res*1e-3  + width/2;  %Distance of center of flake from left of frame in mm
            
            %ADJUST BRIGHTNESS
            if flakebrighten == 1;
                flakebw(flakemask) = brightening(flakebw(flakemask),minintens,maxintens,limitintens);
            end
            
            
            %CREATE BOUNDING BOX FOR CROPPED FLAKES
            B = stats.BoundingBox; %top left and width and height
            cmin = floor(B(1)); cmax = cmin + B(3);
            rmin = floor(B(2)); rmax = rmin + B(4); %Rows are from top down
            
            buf = ceil(100/res); %100 micrometers black space around image
            rflakemin = max(rmin-buf,1); rflakemax = min(rmax+buf,vert); %omit edge noise
            cflakemin = max(cmin-buf,1); cflakemax = min(cmax+buf,horz); %omit edge noise
            flaketrunc = flakebw(rflakemin:rflakemax,cflakemin:cflakemax);
            if displayaccept == 1; %If the desire is to see the flakes as they are processed
            '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'       
            ha = figure(2);
            
            %pause(0.3)           
            imshow(flakebw,'InitialMagnification','fit')
            %truesize;
            
            end
            
            %%%%%%%%%%% Identification of candidates for the Triplets
            %%%%%%%%%%% folder where three good images pass from each camera
            idtriplet(cam+1) = id;
            filesnametriplet{cam+1} = filesname;                 
            triptych{cam+1} = flaketrunc; %for triplet saving
                                                   
            
                % Write cropped and uncropped accepted images
                %imwrite(flaketrunc,[cropcam '/' filesname],'png',...
                  %  'Title', flakeImInfo.Title, 'Author', flakeImInfo.Author, 'Description', flakeImInfo.Description, ...
                   % 'Copyright', flakeImInfo.Copyright, 'CreationTime', flakeImInfo.CreationTime, 'Source', flakeImInfo.Source, ...
                   % 'BitDepth', 8,'XResolution',flakeImInfo.XResolution,'YResolution',flakeImInfo.YResolution);
                %imwrite(flakebw,[uncropcam '/' filesname],'png',...
                 %   'Title', flakeImInfo.Title, 'Author', flakeImInfo.Author, 'Description', flakeImInfo.Description, ...
                 %   'Copyright', flakeImInfo.Copyright, 'CreationTime', flakeImInfo.CreationTime, 'Source', flakeImInfo.Source, ...
                 %   'BitDepth', 8,'XResolution',flakeImInfo.XResolution,'YResolution',flakeImInfo.YResolution);
                imwrite(flaketrunc,[cropcam '/' filesname],'png')
                    
                imwrite(flakebw,[uncropcam '/' filesname],'png')
                    
                % Write triplet images
                % 'triplet'
                % [id cam]
                % idtriplet
                if std(idtriplet) == 0 %all camera ids are the same in idtriplet
                    
                    for i = 1:3;
 %                       imwrite(triptych{i},[triplets '/' filesnametriplet{i}],'png',...
  %                          'Title', flakeImInfo.Title, 'Author', flakeImInfo.Author, 'Description', flakeImInfo.Description, ...
   %                         'Copyright', flakeImInfo.Copyright, 'CreationTime', flakeImInfo.CreationTime, 'Source', flakeImInfo.Source, ...
    %                        'BitDepth', 8,'XResolution',flakeImInfo.XResolution,'YResolution',flakeImInfo.YResolution);
                        imwrite(triptych{i},[triplets '/' filesnametriplet{i}],'png');
                        
                    end
                end
                
                %%%Any adjustments made here MUST be changed correspondingly in
                %%%the header labels specified in OUTDIRS.m
                
                %Write labels parameters to file
                labelsdata = flakefile;

                %Write physical parameters to file
                flakedata = [id cam idcam date time nflakes speed maxdim xsec perim partialarea rangeintens strucdens flakeang asprat];
                %Write diagnostic parameters to file
                acceptid = 1;
                diagnosticdata = [id cam idcam date time acceptid totalflakes nflakes intens minintens maxintens rangeintens strucdens focus maxareafocus height width botloc horzloc];
                
                if length(flakedata) ~= 19;
                    error('flakedata is the wrong length for correct printing to file');
                end
                
                if length(diagnosticdata) ~= 23;
                    error('diagnosticdata is the wrong length for correct printing to file');
                end
                
                fprintf(fid0,'%s\n',labelsdata'); % save label data 
                fprintf(fid1,'%6d %4d %8.1f %8d %8d %8d %8d %8d %8.3f %6d %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f\n',flakedata'); % save statistics
                fprintf(fid2,'%6d %4d %8.1f %8d %8d %8d %8d %8d %8.3f %4d %6d %6d %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f\n',diagnosticdata'); % save statistics
        end
                    
%            fclose(fid0);
%            fclose(fid1);
%            fclose(fid2);

    end
    

end

    delete(poolobj); %Close parallel pool


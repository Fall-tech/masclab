function [picfiles, pictime,picid,piccam, fallspeed, fallid ] = upload(dirname)
%UPLOAD Uploads MASC fallspeed and image filenames to be processed
%[picfiles, pictime,picid,piccam, fallspeed, fallid ] =
%upload(dirname) reads in images within the
%directory DIRNAME and outputs a list PICFILES of images in DIRNAME,
%each with a timestamp PICTIME, an picture number PICID, a camera number PICCAM a
%fallspeed measurement FALLSPEED and a fallspeed number FALLID. The 
%fallspeed associated with the picture is where FALLID == PICID

%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification


    
    %upload image information from within DIRNAME
           
       
        [imginfo delim nheaderlines] = importdata([dirname 'imgInfo.txt']); %read imagelist and time from imgInfo.txt
        [imgrowN imgcolN] = size(imginfo.textdata);
        
        %Read picture data from imgInfo.txt
        pictime = zeros(imgrowN-nheaderlines,6);
        picid = zeros(imgrowN-nheaderlines,1);
        piccam = zeros(imgrowN-nheaderlines,1);
        picfiles = cell(imgrowN-nheaderlines,1);
       
        for i = 1:length(picid)
            
            picid(i) = str2num(imginfo.textdata{i+nheaderlines,1});
            piccam(i) = str2num(imginfo.textdata{i+nheaderlines,2});
            picday = imginfo.textdata{i+nheaderlines,3};
            pictimestamp = imginfo.textdata{i+nheaderlines,4};
            picfiles{i} = imginfo.textdata{i+nheaderlines,5};
            temp = cell2mat({picday});
            temp2 = cell2mat({pictimestamp});
            
            d = regexp( temp, '\.','split' );
            t = regexp( temp2, '\:','split' );
            
            
            picyr = str2num(d{3});
            picmo = str2num(d{1});
            picdd = str2num(d{2});
            pichh = str2num(t{1});
            picmm = str2num(t{2});
            picss = str2num(t{3});

            pictime(i,:) = [picyr picmo picdd pichh picmm picss]; %Matrix of timestamps 

        end

        %Import fallspeed data, allowing for possibility none was collected


        try
            [datainfo delim nheaderlines]= importdata([dirname 'dataInfo.txt']);
            [datarowN datacolN] = size(datainfo.data);
            
        %Read picture data from dataInfo.txt
            fallspeed = datainfo.data; % fallspeed
            fallid = zeros(datarowN-nheaderlines,1); %fallspeed id
            for i = 1:length(fallspeed);
                fallid(i) = str2num(datainfo.textdata{i+nheaderlines,1});
            end
        catch %goes here if datainfo.txt does not exist
            fallspeed = NaN*ones(length(picid),1); %all fallspeeds become NaNs
            fallid = picid;
        end
    



function [cropcam,uncropcam,rejects,triplets,fid0, fid1,fid2] = outdirs(dirname,cropcamdir,uncropcamdir, rejectdir, tripletdir )
%OUTDIRS Processed data and image output directories
%   [CROPCAM,UNCROPCAM,REJECTS,TRIPLETS, FID1, FID2] =
%   outdirs(DIRNAME,CROPCAMDIR,UNCROPCAMDIR,REJECTDIR,TRIPLETDIR) places
%   in the directory DIRNAME three directories for image output for cropped
%   images CROPCAMDIR uncropped images UNCROPCAMDIR and rejects
%   REJECTDIR. FID1 and FID2 are the ids of the files for image statistics 
%   and diagnostic statistics.
  
%   Copyright Tim Garrett, University of Utah. This code is freely available for
%   non-commercial distribution and modification



    cropcam = strcat([dirname cropcamdir]);
    uncropcam = strcat([dirname uncropcamdir]);
    rejects = strcat([dirname rejectdir]);
    triplets = strcat([dirname tripletdir]);

    %%% create subdirectories
        mkdir(cropcam); mkdir(uncropcam); mkdir(rejects); mkdir(triplets);   

    %%%%Create analyzed flake statistics filename
        statsname = strcat([dirname 'stats.txt']);
    %%%%Create analyzed flake diagnostics filename
        diagsname = strcat([dirname 'diagnostics.txt']);
    %%%%Create analyzed flake diagnostics filename
        labelsname = strcat([dirname 'labels.txt']);
       
        
    %%%Clear directories and create statistics and diagnostics file    
        delete(strcat([cropcam '/*']));%clear directories
        delete(strcat([uncropcam '/*']));
        delete(strcat([rejects '/*']));
        delete(strcat([triplets '/*']));
        
        if exist(statsname) == 2 | exist(diagsname) == 2 | exist(labelsname) == 2; % Delete preexisting output files
            delete(statsname);
            delete(diagsname);
            delete(labelsname);
        end
        
        fid0 = fopen(labelsname,'a');
        fid1 = fopen(statsname,'a');
        fid2 = fopen(diagsname,'a');

        header1 = ['id\tcam\tidcam\tyr\tmonth\tday\thr\tmins\tsec\tnflakes\tvel\tmaxdim\txsec\tperim\tpartarea\trangeintens\tstrucdens\tflakeang\tasprat\n'];
        header2 = ['id\tcam\tidcam\tyr\tmonth\tday\thr\tmins\tsec\tacceptid\ttotalflakes\tnflakes\tintens\tminintens\tmaxintens\trangeintens\tstrucdens\tfocus\tmaxareafocus\theight\twidth\tbotloc\thorzloc\n'];

        fprintf(fid1,header1);
        fprintf(fid2,header2);
    




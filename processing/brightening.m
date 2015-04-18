function imageout = brightening(imagein,minintens,maxintens,limitintens )
%BRIGHTENING.M Summary of this function goes here
%   Detailed explanation goes here
%Increases the intensity values in image IMAGEIN  to new values 
% such that 1% of image is saturated at LIMITINTENS.
% This increases the brightness of the output image.
% If that does not increase the median brightness beyond
% MEDIANINTENS then a (minor) gamma correction is performed
                medintens = double(median(double(imagein)))/255;     
                imageout = imadjust(imagein,[minintens maxintens],[minintens limitintens]);
                newmedian = double(median(double(imageout)))/255;
                
                if newmedian < medintens
                    gamma = log(medianintens)/log(newmedian);
                    if gamma > 0.6;
                        imageout = (double(imageout)/255).^(gamma)*255;	
                    else 
                        imageout = (double(imageout)/255).^(0.6)*255;
                    end
                    newmedian = double(median(double(imageout)))/255;
       
                end
          
           
end


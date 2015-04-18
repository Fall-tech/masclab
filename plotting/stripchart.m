function [ax,hlines] = stripchart(x,n,loglin,labels,pagetime,orientation,outfile)
%[AX, HLINES] = STRIPCHART(X,N,LOGLIN,LABELS,PAGETIME,ORIENTATION,OUTFILE,TIMEFORMAT) Create stripchart
%   for X where the time coordinate is along a row dimension
%   which is continuous but where X may have missing data with NaNs. 
%   N refers to the column dimension of the matrix X represented by
%   the time coordinate.
%   X(:,N) is a rows serial date number (from DATENUM)
%   X is the desired array of dependent variables in columns
%   LOGLIN is a vector specifying whether each variable is to be plotted
%   in linspace (0) or logspace (1);
%   LABELS is a vector string of labels for X
%   PAGETIME is the desired length per page in datevec format
%   [Y,MO,D,H,MI,S] (e.g. [0 0 0 24 0 0] for one day. It is best to express
%   1 day as 24 h and 1 hour as 60 minutes, etc...
%   ORIENTIATION 'landscape' or 'portrait'
%   OUTFILE the file to which the stripchart goes out

delete(strcat(outfile,'*'));

[~,C] = size(x);
datan = setdiff(1:C,n);
data = x(:,datan);
time = x(:,n);

if max(pagetime) < 3;
    error('Express PAGETIME in the next smaller time unit')
end
[R, nvars] = size(data);

%Omit isolated points
for j = 1:nvars
        datadn = diff([data(j,1); 0]);
        dataup = diff([0; data(j,1)]);
        isolated = find(isnan(datadn) == 1 & isnan(dataup) == 1);
        data(isolated,j) = NaN;
end
%Define page and height per strip
pagelength = datenum(pagetime);
dateidx = find(pagetime~=0); 
if strcmp(orientation,'landscape') == 1;
        pagewidth = 11; pageheight = 8.5;
    else
        pagewidth = 8.5; pageheight = 11;
end
%left = 0.065;
%bottom = 0.045;
%height = 0.91/nvars;
%width = 0.90;
left = 0.075;
bottom = 0.055;
height = 0.90/nvars;
width = 0.89;

axes('XTickLabelMode','manual');
%Calculate number of pages
npages = ceil(max(time)/pagelength-min(time)/pagelength);

for i = 1:npages 
    %set page
    clf;
    
    h = figure('units','inches','position',[0 0 pagewidth pageheight]);
    set(gcf,'units','inches');
    set(gcf,'position',[0 0 pagewidth pageheight],'PaperOrientation',orientation);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 pagewidth pageheight ]);
    
    %set time in page
    mintime = datevec(min(time));
    %Start at least interval + pagelength
    tmin = datenum([mintime(1:dateidx),zeros(1,6-dateidx)])+pagelength*(i-1);
    tmax = tmin+pagelength;
    %account for final page
    if tmax > max(time);
        good = find(time>=tmin&time<=max(time));
    else
        good = find(time>=tmin&time<=tmax);
    end
    
    %time ticks
    nticks = max(factor(max(pagetime)));
    tickint = datenum(pagetime/nticks);
    %time labels
    labelloc = tmin:tickint:tmax;
    V = datevec(labelloc);
    ticklabels = num2str(V(:,dateidx));
    %y Font size
    fontsize = 14*sqrt(4/nvars);
    %Calculate each strip
    for j = 1:nvars;
        ax(j) = subplot('Position',[left bottom+(nvars-(j-1) - 1)*height width height ]);
        datastrip = data(good,j);
        hlines(j) = plot(time(good),datastrip,'k');
        set(hlines(j),'LineWidth',1);
        set(ax(j),'FontSize',fontsize);
        if isnan(max(datastrip)) == 1 | max(datastrip) == min(datastrip); %Ways of dealing with no data or zeros
            if loglin(j) == 1;
                ymin = 0.1; ymax = 1;
            else
                ymin = 0;ymax = 1;
            end
        else
            if loglin(j) == 1;
                ylog
                ymin = 10^floor(log10(min(datastrip)));
                ymax = 10^ceil(log10(max(datastrip)));

            else
                ymin = 0.95^(sign(min(datastrip)))*min(datastrip);
                ymax = 1.05^(sign(max(datastrip)))*max(datastrip);
            end
        end
        
        %set labels and ticks
        if (isnan(ymin) == 1) | (isnan(ymax) == 1);
            ymin = min(datastrip);ymax = max(datastrip);
        end
        %k = legend(labels(j),1);
        k = text(tmin + pagelength/50, ymin + 0.8*(ymax- ymin),labels(j));
        
        legend('boxoff')
        set(k,'Interpreter','Latex','FontSize',fontsize)
        
        axis([tmin tmax ymin ymax])
        set(gca,'YGrid','on')
        set(gca,'XTick',labelloc);
        if j == 1 & nvars >1;
            set(gca,'XAxisLocation','top');
        end
        if j < nvars & j > 1
            set(gca,'XTickLabel',{''});
            
        else
            set(gca,'XTickLabel',ticklabels);
        end
        
        set(gca,'XMinorTick','on','FontSize',14);
        %date at top left
        if (j == 1);
            daystring = datestr(min(time(good)),1); %dd-mmm-yyyy
               
            if loglin(j) == 1;    
                text(min(time(good)) + tickint/3,2*ymax,daystring,'FontSize',fontsize);                
            else
                text(min(time(good)) + tickint/3,1.2*ymax,daystring,'FontSize',fontsize);
            end
        end    
    end
print('-dpsc2','-append',outfile)
%print('-dpng','-r1200','-append',outfile)
    
end
end


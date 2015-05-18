%added variables
cosflakeang = cos(flakeang*pi/180);
intensrat = maxintens./minintens;
habitsel = ((complexity).*(1+rangeintens)); %The idea here is that riming rounds and brightens.
velmaxdim = vel./maxdim; % The idea here is that objects that approach the bulk density fall quickly.
sxent = rangeintens.*intens; %Like ndlogn
rainsel = velmaxdim./intens; % The idea here is that objects that approach the bulk density fall quickly.
 
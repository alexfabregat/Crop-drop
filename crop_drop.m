% This scripts reads a set of images (frames from gfsview)
% detects the location of a drop and crops the image.

%nl = 400;Res_9
nl=250; % Size of the cropped image in pixels
nf=19;  % Maximum frame index
crop_periodic = false; % Trims the image removing periodicity before cropping the drop 

for ii=0:nf

% Read in a standard MATLAB color demo image.
%folder = 'S05M10_PI20_IC2/T2';
folder = 'NO_FORCING';
baseFileName = ['mu10_1_',num2str(ii,'%02d'),'.jpg'];
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);
if ~exist(fullFileName, 'file')
	% Didn't find it there.  Check the search path for it.
	fullFileName = baseFileName; % No path this time.
	if ~exist(fullFileName, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end

rgbImage = imread(fullFileName);
if(crop_periodic)
rgbImage = rgbImage(1:700,:,:);
end

% Get the dimensions of the image.  numberOfColorBands should be = 3.
[rows, columns, numberOfColorBands] = size(rgbImage);

% Extract the individual red, green, and blue color channels.
redChannel   = rgbImage(:, :, 1);
greenChannel = rgbImage(:, :, 2);
blueChannel  = rgbImage(:, :, 3);

% Threshold the red image at 70.
eggMask = blueChannel < 100;
% Get it's convex hull to smooth it out.
 ggMask = bwconvhull(eggMask, 'Objects');
% Make sure there are no small noise regions by getting
% rid of blobs less than 5 pixels in size.
 eggMask = bwareaopen(eggMask, 5);

[i,j] = find(eggMask==1);

minx = min(i);
maxx = max(i);
miny = min(j);
maxy = max(j);
lx=maxx-minx;
ly=maxy-miny;

x0 = minx-floor((nl-lx)/2);
x1 = maxx+ ceil((nl-lx)/2);
y0 = miny-floor((nl-ly)/2);
y1 = maxy+ ceil((nl-ly)/2);

if(x0<0)
    x1=x1+abs(x0)-1;
    x0=1;
end

if(y0<0)
    y1=y1+abs(y0)-1;
    y0=1;
end

if(x1>rows)
    x0=x0-abs(x1)-1;
    x1=rows;
end

if(y1>columns)
    y0=y0-abs(y1)-1;
    y1=columns;
end

if((x1-x0)~=nl|(y1-y0)~=nl)
    disp('Error')
    return
end

disp([num2str(x0),' ',num2str(x1),' ',num2str(y0),' ',num2str(y1)])

figure(2)
pause(0.001)
imshow(rgbImage(x0:x1,y0:y1,:))

baseFileName = ['crop_mu10_1_',num2str(ii,'%02d'),'.jpg'];
fullFileName = fullfile(folder, baseFileName);
print(fullFileName,'-djpeg','-r0')
end

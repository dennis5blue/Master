clc;
clear;
addpath('../Utility');
inputPath = '../../SourceData/test4_png/';

res.X = 1280; res.Y = 720;
reg.X = 16; reg.Y = 9;
N = 10;
idx = 10; % print which position in schedule

schedule = [10 6 7 8 9 2 3 4 5 1];

% Initial txRegions
for i = 1:N
    eval(['txRegs.cam' num2str(i) '=ones(reg.Y,reg.X);']);
end

for i = 2:N
    cam = schedule(i);
    eval(['thisCamTxRegions = txRegs.cam' num2str(cam) ';']);
    for j = 1:i-1
        ovCam = schedule(j);
        eval(['tempRefCamTxRegs = txRegs.cam' num2str(ovCam) ';']);                        
        tempTxRegs = IfTxRequired(inputPath,cam,ovCam,tempRefCamTxRegs,reg);
        thisCamTxRegions = min(thisCamTxRegions,tempTxRegs);
    end
    eval(['txRegs.cam' num2str(cam) ' = thisCamTxRegions;']);
end
eval(['targetCamTxRegs = txRegs.cam' num2str(schedule(idx)) ';']);

% read images
cam = [inputPath 'camera_',num2str(schedule(idx)),'.png'];
img = im2double(imread(cam));

imgOver = img;
xSize = length(img(1,:,1))/reg.X;
ySize = length(img(:,1,1))/reg.Y;

for xx = 1:reg.X
    for yy = 1:reg.Y
        if targetCamTxRegs(yy,xx) == 0
            imgOver((yy-1)*ySize+1:yy*ySize,(xx-1)*xSize+1:xx*xSize,:) = 1;
        end
    end
end

figure(1);
subplot(211);
imshow(img); title('Original frame');
subplot(212);
imshow(imgOver); title('Transmitted frame');
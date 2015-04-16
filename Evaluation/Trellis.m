clc;
clear;
addpath('./Utility');

% Read files
bits = 8.*dlmread('../SourceData/test_phase_0.txt');
pos = dlmread('../SourceData/test_pos.txt');
pos = 100.*pos(:,1:3);
dir = dlmread('../SourceData/test_pos.txt');
dir = dir(:,6);

% Parameters settings
nSlots = 1000; % number of time slots
tau = 1; % time slot duration (ms)
bsX = 0; bsY = 0; % position of base station
txPower = 0.1; % transmission power (watt)
n0 = 1e-16; % cannot change this value (hard code in CalChannelGain)
N = 10; % number of total cameras
res.X = 1280; res.Y = 720;
reg.X = 16; reg.Y = 9;
W = 180; % kHz

rate = bits./(res.X*res.Y); % in bpp

for i = 0:N-1
    I = imread(['../SourceData/test2_png/camera_' num2str(i) '.png']);
    mean     = sum(I(:))/length(I(:));
    variance = sum((I(:) - mean).^2)/(length(I(:)) - 1);
    distortion = variance*(2^(-2*rate(i+1)));
    PSNR = 10*log10(double(( ( 255 )^2 )/distortion));
end

% Greedy optimization
Schedule = [0:9]';
for run = 1:N-1
    nextSchedule = -1*ones(1,N)';
    for i = 1:length(Schedule)
        schedCams = Schedule(i,:);
        unschedCams = [0:N-1];
        unschedCams(ismember(unschedCams,schedCams))=[];
        p = -1;
        bestCam = -1;
        for c = 1:length(unschedCams)
            cam = unschedCams(c);
            if CalProfit(cam,schedCams,unschedCams,N,reg) > p
                p = CalProfit(cam,schedCams,unschedCams,N,reg);
                bestCam = cam;
            end
        end
        nextSchedule(i) = bestCam;
    end
    Schedule = [Schedule nextSchedule];
end

vecPSNR = [];
for nSlots = 500:500:2000
    % Find best schedule
    bestSche = 0;
    bestPsnr = 0;
    for i = 1:length(Schedule)
        supCams = [];
        totalReqSlots = 0;
        for c = 1:length(Schedule(i,:))
            cam = Schedule(i,c);
            snr = txPower*CalChannelGain(pos(cam+1,1),pos(cam+1,2),bsX,bsY)/n0;
            reqSlots = ceil(bits(cam+1)/(tau*W*log2(1+snr)));
            totalReqSlots = totalReqSlots + reqSlots;
            if totalReqSlots > nSlots
                break;
            end
            supCams = [supCams cam];
        end
        unSupCams = [0:N-1];
        unSupCams(ismember(unSupCams,supCams))=[];
        temp = CalPsnr(supCams,unSupCams,N,rate,res,reg);
        if temp > bestPsnr
            bestPsnr = temp;
            bestSche = i;
        end
    end
    vecPSNR = [vecPSNR bestPsnr];
end

% vecPSNR = [29.8070 30.6299 31.7285 32.2934] % for trellis
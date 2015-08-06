%function [improveRatio] = SAselection (in_numCams,in_testVersion,in_searchRange,in_overRange)
    clc;
    clear;
    in_numCams = '20';
    in_testVersion = '12';
    in_searchRange = '512';
    in_overRange = '1';
    
    addpath('./Utility');
    inputPath = ['../SourceData/test' in_testVersion '/'];
    searchRange = str2num(in_searchRange);

    % Read files
    vecBits = 8.*dlmread([inputPath 'outFiles/rng' in_searchRange '/indepByte.txt']); % bits
    pos = dlmread([inputPath 'plotTopo/pos.txt']);
    dir = dlmread([inputPath 'plotTopo/dir.txt']);
    matCost = 8.*dlmread([inputPath 'outFiles/rng' in_searchRange '/corrMatrix.txt']);

    % Parameters settings
    bsX = 0; bsY = 0; % position of base station
    numIntersections = 4; % only for test version 12
    initNumCams = 24; % only for test version 12
    N = str2num(in_numCams); % number of total cameras
    rho = str2num(in_overRange);
    iterLimit = 1000;
    initTemperature = 1; % initial temperature
    coolParam = 0;
    % Initialize matCost according to N
    for i = 1:length(vecBits)
        matCost(i,i) = vecBits(i);
    end
    if mod(N,numIntersections) ~= 0
        disp ('Error, Bad number of cameras (must be a multiply of 4 for test version 12)');
    elseif mod(N,numIntersections) == 0
        needToRm = [];
        gg = (initNumCams - N)/numIntersections;
        qq = initNumCams/numIntersections;
        for i = 0:numIntersections-1
            for j = qq-gg+1:qq
                needToRm = [needToRm i*qq+j];
            end
        end
    end
    matCost(needToRm,:) = [];
    matCost(:,needToRm) = [];
    
    initSelection = find(randi(2,1,N)==2); % initial I-frame cameras set
    % Calculate initial reference structure as the input of SA
    vecAns = zeros(1,N);
    for i = 1:N
        if ismember(i,initSelection)
            vecAns(i) = (i);
        else
            bestRef = i;
            for j = 1:length(initSelection)
                iCam = initSelection(j);
                if IfCanOverhear(pos(i,1),pos(i,2),pos(iCam,1),pos(iCam,2),bsX,bsY,rho) && matCost(i,iCam) <= matCost(i,bestRef)
                    bestRef = iCam;
                end
            end
            vecAns(i) = bestRef;
        end
    end
    lowestPayoff = 0;
    for i = 1:N
        lowestPayoff = lowestPayoff + matCost(i,vecAns(i));
    end
    lowestPayoff
    
    % Start SA (add, discard, rotate)
    for iter = 1:iterLimit
        currTemperature = initTemperature/log(iter+coolParam);
    end

    bestSelection;
    finalTxBits = CalExactCostConsiderOverRange( bestSelection,matCost,pos,bsX,bsY,rho );
    improveRatio = (sum(vecBits(1:N))-finalTxBits)/sum(vecBits(1:N));
%end
function [improveRatio] = DMCP (in_ifSave,in_numCams,in_testVersion,in_searchRange,in_overRange)
    %clc;
    %clear;
    ifSaveFile = str2num(in_ifSave);
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
    N = str2num(in_numCams); % number of total cameras
    rho = str2num(in_overRange);
    d_GeoTech = 50;
    
    % Generate cost matrix by camera pos and direction
    matCost_GeoTech = zeros(N,N);
    for i = 1:N
        for j = 1:N
            camDistance = sqrt( (pos(i,1)-pos(j,1))^2 + (pos(i,2)-pos(j,2))^2 );
            theta = dir(i)-dir(j); % in radius
            if camDistance == 0
                disparity = 0.25*( abs((d_GeoTech*sin(theta))/(d_GeoTech+cos(theta))) + ...
                                   abs((d_GeoTech*sin(theta))/(d_GeoTech-cos(theta))) + ...
                                   abs((d_GeoTech*cos(theta))/(d_GeoTech+sin(theta)) - 1) + ...
                                   abs((-d_GeoTech*cos(theta))/(d_GeoTech-sin(theta)) + 1) );
            else
                disparity = 1;
            end
            if i == j
                disparity = 1;
            end
            corrCoef = 1 - disparity;
            matCost_GeoTech(i,j) = (1-0.5*corrCoef)*vecBits(i) - 0.5*corrCoef*vecBits(j);
        end
    end
    
    for i = 1:length(vecBits)
        matCost(i,i) = vecBits(i);
        matCost_GeoTech(i,i) = vecBits(i);
    end
    
    % Conduct overhearing graph
    vecAdjGraph = [];
    for i = 1:N
        m_outEdge = []; % for camera i, out edge i -> j means i can hear j
        m_inEdge = []; % for camera i, in edge k -> i means k can hear i
        for j = 1:N
            if IfCanOverhear( pos(i,1),pos(i,2),pos(j,1),pos(j,2),bsX,bsY,rho ) == 1 % check if i can hear j
                m_outEdge = [m_outEdge j];
            end
            if IfCanOverhear( pos(j,1),pos(j,2),pos(i,1),pos(i,2),bsX,bsY,rho ) == 1 % check if j can hear i
                m_inEdge = [m_inEdge j];
            end
        end
        newNode = struct('idx',i,'weight',vecBits(i),'outEdge',m_outEdge,'inEdge',m_inEdge,'ifIFrame',-1,'cost',inf);
        vecAdjGraph = [vecAdjGraph newNode];
    end
    
    vecIfDetermined = zeros(1,N);
    bestSelection = zeros(1,N);
    countIter = 0;
    while sum(vecIfDetermined) < N
        countIter = countIter + 1;
        %vecIfDetermined
        vecMetric = zeros(1,N);
        for cam = 1:N
            if vecIfDetermined(cam) == 1
                vecMetric(cam) = inf;
            elseif vecIfDetermined(cam) == 0
                vecCanHearMe = vecAdjGraph(cam).inEdge;
                if length(vecCanHearMe) > 0
                    metric = CalJointEmtropy(vecCanHearMe,vecBits,matCost_GeoTech)/length(vecCanHearMe);
                else
                    metric = inf;
                end
                vecMetric(cam) = metric;
            end
        end
        
        for cam = 1:N
            if vecIfDetermined(cam) == 0
                vecTwoHopCams = [];
                vecCanHearMe = vecAdjGraph(cam).inEdge;
                for i = vecCanHearMe
                    if vecIfDetermined(i) == 0
                        vecTwoHopCams = [vecTwoHopCams i];
                    end
                end
                for oneHopCam = vecCanHearMe
                    vecCanHearOneHopCam = vecAdjGraph(oneHopCam).inEdge;
                    for twoHopCam = vecCanHearOneHopCam
                        if vecIfDetermined(twoHopCam) == 0
                            if ismember(twoHopCam,vecTwoHopCams) == 0
                                vecTwoHopCams = [vecTwoHopCams twoHopCam];
                            end
                        end
                    end
                end
                
                vecMetric;
                % add as I-frame camera if metric is the smaller among 2-hops cameras
                if vecMetric(cam) == min(vecMetric(vecTwoHopCams))
                    if bestSelection(cam) == 0
                        bestSelection(cam) = 1;
                        vecIfDetermined(cam) = 1;
                        vecIfDetermined(vecAdjGraph(cam).inEdge) = 1;
                    end
                end
            end
        end
    end
    %bestSelection
    finalTxBits = CalExactCostConsiderOverRange( bestSelection,matCost,pos,bsX,bsY,rho );
    improveRatio = (sum(vecBits(1:N))-finalTxBits)/sum(vecBits(1:N));
    %reducedIter = (2^N - length(recordLb))/(2^N);
    if ifSaveFile == 1
        saveFileName = ['mat/DMCP/DMCP_test' in_testVersion '_cam' num2str(N) '_rng' in_searchRange '_rho' num2str(rho) '.mat'];
        save(saveFileName);
    end
end
function [improveRatio] = DMCP_Inter (in_ifSave,in_numCams,in_testVersion,in_overRange,in_degree)
    %clc;
    %clear;
    ifSaveFile = str2num(in_ifSave);
    addpath('./Utility');
    inputPath = ['../SourceData/test' in_testVersion '/'];

    % Read files
    vecBits = 8.*dlmread([inputPath 'outFiles/' in_degree '/indepByte.txt']); % bits
    matCost = 8.*dlmread([inputPath 'outFiles/' in_degree '/corrMatrix.txt']);
    pos = dlmread([inputPath 'plotTopo/pos_' in_degree '.txt']);
    dir = dlmread([inputPath 'plotTopo/dir_' in_degree '.txt']);
    
    % Parameters settings
    bsX = 0; bsY = 0; % position of base station
    N = str2num(in_numCams); % number of total cameras
    rho = str2num(in_overRange);
    numHeads = 2;
    magicNum = 2;
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
    
    coverTopo = zeros(N,N); % since all cameras are placed at the same position
    for i = 1:N
        for j = 1:N
            if sqrt( (pos(i,1)-pos(j,1))^2 + (pos(i,2)-pos(j,2))^2 ) <= sqrt( (pos(i,1)-bsX)^2 + (pos(i,2)-bsY)^2 )
                coverTopo(i,j) = 1;  % means i covers j
            end
        end
    end
    constCoverTopo = coverTopo;
    
    % start DMCP
    recordCoverTimes = zeros(1,N);
    metric = zeros(1,N);
    clusterHeads = zeros(1,numHeads);
    m_numHeads = 0;
    
    % Determine cluster heads
    while m_numHeads < numHeads
        m_numHeads = m_numHeads + 1;
        for i=1:N
            m_coverdNodesTemp = find(coverTopo(i,:)==1);
            m_coverdNodes = [];
            for k=1:length(m_coverdNodesTemp)
                node_k = m_coverdNodesTemp(k);
                if recordCoverTimes(node_k) < magicNum
                    m_coverdNodes = [m_coverdNodes node_k];
                end
            end
            m_coverdNum = length(m_coverdNodes);
            if m_coverdNum > 0
                metric(i) = CalJointEmtropy(m_coverdNodes,vecBits,matCost_GeoTech)/m_coverdNum;
            else
                metric(i) = inf;
            end
        end
        [m_val m_index] = sort(metric,'ascend');
        clusterHeads(m_numHeads) = m_index(1);
        coverTopo(:,m_index(1)) = zeros(N,1);
        coverTopo(m_index(1),:) = zeros(1,N);
        % Update recordCoverTimes
        recordCoverTimes = recordCoverTimes + coverTopo(m_index(1),:);
    end

    % Determine cluster members
    attachCondition = zeros(2,N); % 1st row is node index, 2nd row is its cluster head
    for i=1:N
        node_i = i;
        vecCost = [];
        for h=1:numHeads
            vecCost = [vecCost matCost_GeoTech(node_i,clusterHeads(h))];
        end
        [m_val m_index] = sort(vecCost,'ascend');
        attachCondition(1,node_i) = node_i;
        attachCondition(2,node_i) = clusterHeads(m_index(1));
    end
    attachCondition;
    clusterHeads;
    bestSelection = zeros(1,N);
    for i = 1:length(clusterHeads)
        bestSelection(clusterHeads(i)) = 1;
    end
    finalTxBits = CalExactCostConsiderOverRange( bestSelection,matCost,pos,bsX,bsY,rho );
    improveRatio = (sum(vecBits(1:N))-finalTxBits)/sum(vecBits(1:N));
    %reducedIter = (2^N - length(recordLb))/(2^N);
    if ifSaveFile == 1
        saveFileName = ['mat/DMCP_test' in_testVersion '_cam' num2str(N) '_rng' in_searchRange '_rho' num2str(rho) '.mat'];
        save(saveFileName);
    end
end
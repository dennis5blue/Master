function [improveRatio] = MDS_proposed_geoTech_Inter (in_ifSave,in_numCams,in_testVersion,in_searchRange,in_overRange)
    %clc;
    %clear;
    %in_numCams = '30';
    %in_testVersion = '10';
    %in_searchRange = '512';
    %in_overRange = '1';
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
    numIntersections = 4; % only for test version 12
    initNumCams = 24; % only for test version 12
    
    % Generate cost matrix by camera pos and direction
    matCost_GeoTech = zeros(initNumCams,initNumCams);
    for i = 1:initNumCams
        for j = 1:initNumCams
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
            matCost_GeoTech(i,j) = disparity;
        end
    end
    
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
    vecBits(needToRm) = [];
    matCost(needToRm,:) = [];
    matCost(:,needToRm) = [];
    matCost_GeoTech(needToRm,:) = [];
    matCost_GeoTech(:,needToRm) = [];
    matCost_GeoTech = matCost_GeoTech.*(sum(vecBits)/length(vecBits));

    % Conduct overhearing graph
    vecAdjGraph = [];
    for i = 1:N
        m_outEdge = []; % for camera i, out edge i -> j means i can hear j
        m_inEdge = []; % for camera i, in edge k -> i means k can hear i
        for j = 1:N
            if j ~= i && IfCanOverhear( pos(i,1),pos(i,2),pos(j,1),pos(j,2),bsX,bsY,rho ) == 1 % check if i can hear j
                m_outEdge = [m_outEdge j];
            end
            if j ~= i && IfCanOverhear( pos(j,1),pos(j,2),pos(i,1),pos(i,2),bsX,bsY,rho ) == 1 % check if j can hear i
                m_inEdge = [m_inEdge j];
            end
        end
        newNode = struct('idx',i,'weight',vecBits(i),'outEdge',m_outEdge,'ifIFrame',-1,'cost',inf);
        vecAdjGraph = [vecAdjGraph newNode];
    end
    
    countIter = 0;
    while(1)
        countIter = countIter + 1;
        % Cal the head metric by each camera's best out edge
        vecBestOutEdge = FindBestOutEdge( vecAdjGraph,matCost_GeoTech );
        vecHeadMetric = zeros(1,N);
        for cam = 1:N
            m_node = vecAdjGraph(cam);
            if m_node.ifIFrame == -1
                m_headMetric = - m_node.weight;
                for i = 1:N
                    if vecBestOutEdge(i) == cam
                        m_headMetric = m_headMetric + ( vecBits(i) - matCost_GeoTech(i,cam) );
                    end
                end
            elseif m_node.ifIFrame == 0 || m_node.ifIFrame == 1
                m_headMetric = -inf; % already been determined
            else
                disp('Something wrong when assigning nwe I-frame');
            end
            vecHeadMetric(cam) = m_headMetric;
        end
        % Select one cluster head (become head if it has the largest head metric)
        [val idx] = sort(vecHeadMetric,'descend');
        newNode = vecAdjGraph(idx(1));
        newNode.ifIFrame = 1;
        newNode.cost = vecBits(idx(1));
        newNode.outEdge = [];
        vecAdjGraph(idx(1)) = newNode;
    
        % Attach P-cam to new generated I-cam
        % Attach an I-cam if this edge is the best outEdge
        for cam = 1:N
            m_node = vecAdjGraph(cam);
            if m_node.ifIFrame == -1
                m_outEdge = m_node.outEdge;
                m_candidateI = []; % best vertex among outEdges
                m_cost = inf; % weight of best vertex among outEdges
                for i = 1:length(m_outEdge)
                    refcam = m_outEdge(i);
                    if vecAdjGraph(refcam).ifIFrame == 1 && matCost_GeoTech(cam,refcam) < m_cost
                        m_candidateI = refcam;
                        m_cost = matCost_GeoTech(cam,refcam);
                    end
                end
            
                pFlag = 1;
                for i = 1:length(m_outEdge)
                    refcam = m_outEdge(i);
                    if matCost_GeoTech(cam,refcam) < m_cost && vecAdjGraph(refcam).ifIFrame ~= 0
                        pFlag = 0;
                    end
                end
            
                if pFlag == 1
                    m_node.ifIFrame = 0;
                    m_node.cost = matCost_GeoTech(cam,m_candidateI);
                    m_node.outEdge = m_candidateI;
                    vecAdjGraph(cam) = m_node;
                end
            end
        end
        
        %{
        % For remaining cameras, if all its neighbors is determined as P-frame, it becomes an I-frame
        for cam = 1:N
            m_node = vecAdjGraph(cam);
            if m_node.ifIFrame == -1
                m_outEdge = m_node.outEdge;
                iFlag = 1;
                for i = 1:length(m_outEdge)
                    refcam = m_outEdge(i);
                    % if neighbor is determined as P-frame, becomes I-frame
                    if vecAdjGraph(refcam).ifIFrame == 1  
                        iFlag = 0;
                    end
                    if vecAdjGraph(refcam).ifIFrame == -1 && m_node.weight > vecBits(refcam)
                        iFlag = 0;
                    end
                end

                if iFlag == 1
                    m_node.ifIFrame = 1;
                    m_node.cost = vecBits(cam);
                    %m_node.outEdge = m_candidateI;
                    vecAdjGraph(cam) = m_node;
                end
            end
        end
        %}
        
        % check if all cameras are determined
        ifbreak = 1;
        for i = 1:N
            m_node = vecAdjGraph(i); 
            if m_node.ifIFrame == -1
                ifbreak = 0;
            end
        end
        if ifbreak == 1
            break;
        end
    end
    
    totalCost = 0;
    bestSelection = zeros(1,N);
    for i = 1:N
        %vecAdjGraph(i)
        m_node = vecAdjGraph(i);
        totalCost = totalCost + m_node.cost;
        if m_node.ifIFrame == 1
            bestSelection(i) = 1;
        end
    end

    bestSelection;
    totalCost;
    %improveRatio = (sum(vecBits(1:N))-totalCost)/sum(vecBits(1:N));
    finalTxBits = CalExactCostConsiderOverRange( bestSelection,matCost,pos,bsX,bsY,rho );
    improveRatio = (sum(vecBits(1:N))-finalTxBits)/sum(vecBits(1:N));
    if ifSaveFile == 1
        saveFileName = ['mat/MDS/MDSProposedOutput2_test' in_testVersion '_cam' num2str(N) '_rng' in_searchRange '_rho' in_overRange '.mat'];
        save(saveFileName);
    end
end
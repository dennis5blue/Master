function [improveRatio] = BBselection_baseline (in_numCams,in_testVersion,in_searchRange,in_overRange)
    %clc;
    %clear;
    %in_numCams = '30';
    %in_testVersion = '10';
    %in_searchRange = '512';
    %in_overRange = '1';
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
    firstCam = 1;
    for i = 1:N
        matCost(i,i) = vecBits(i);
    end
    matCost = matCost(1:N,1:N);
    vecBits = vecBits(1:N);

    % First branch
    vecX = -1*ones(1,N); % indicate if a camera is encoded as an I-frame
    BBqueue = [];
    vecX(firstCam) = 1;
    %newNode = struct('depth',1,'lb',CalBBLowerBound2(vecX,matCost),'selection',vecX);
    newNode = struct('depth',1,'lb',CalBBLowerBoundBaselineConsiderOverRange(vecX,matCost,pos,bsX,bsY,rho),'selection',vecX);
    
    BBqueue = [newNode BBqueue];
    vecX(firstCam) = 0;
    %newNode = struct('depth',1,'lb',CalBBLowerBound2(vecX,matCost),'selection',vecX);
    newNode = struct('depth',1,'lb',CalBBLowerBoundBaselineConsiderOverRange(vecX,matCost,pos,bsX,bsY,rho),'selection',vecX);
    BBqueue = [newNode BBqueue];

    % Strat BB algorithm
    recordUb = [];
    recordLb = [];
    recordNumInQueue = [];
    initSolution = ones(1,N);
    ub = CalExactCost(initSolution,matCost);
    while length(BBqueue) > 0
        % sort BBqueue to get lowest lb and depthest node
        BBqueue = sortStruct(BBqueue,'lb',-1); % -1 means sort descending
        BBqueue = sortStruct(BBqueue,'depth',1); % 1 means sort ascending

        % pop the last element
        BBnode = BBqueue(length(BBqueue));
        BBqueue(length(BBqueue)) = [];

        if BBnode.depth == N
            %m_cost = CalExactCost(BBnode.selection,matCost);
            m_cost = CalExactCostConsiderOverRange( BBnode.selection,matCost,pos,bsX,bsY,rho );
            if m_cost < ub
                ub = m_cost;
                bestSelection = BBnode.selection;
            end
        elseif BBnode.depth < N
            %nextCam = RandomSelectNextBranch( BBnode.selection );
            nextCam = BBnode.depth + 1; % exactly determine next camera for branching

            % branch 1
            m_selec = BBnode.selection;
            m_selec(nextCam) = 1;
            %m_lb = CalBBLowerBound2(m_selec,matCost);
            m_lb = CalBBLowerBoundBaselineConsiderOverRange(m_selec,matCost,pos,bsX,bsY,rho);
            if m_lb < ub
                newNode = struct('depth',BBnode.depth+1,'lb',m_lb,'selection',m_selec);
                BBqueue = [newNode BBqueue];
            end

            % branch 0
            m_selec(nextCam) = 0;
            %m_lb = CalBBLowerBound2(m_selec,matCost);
            m_lb = CalBBLowerBoundBaselineConsiderOverRange(m_selec,matCost,pos,bsX,bsY,rho);
            if m_lb <= ub
                newNode = struct('depth',BBnode.depth+1,'lb',m_lb,'selection',m_selec);
                BBqueue = [newNode BBqueue];
            end
        end
        %[BBnode.lb ub]
        recordUb = [recordUb ub];
        recordLb = [recordLb BBnode.lb];
        recordNumInQueue = [recordNumInQueue length(BBqueue)];
    end

    bestSelection;
    %finalTxBits = CalExactCost(bestSelection,matCost)
    finalTxBits = CalExactCostConsiderOverRange( bestSelection,matCost,pos,bsX,bsY,rho );
    improveRatio = (sum(vecBits(1:N))-finalTxBits)/sum(vecBits(1:N));
    reducedIter = (2^N - length(recordLb))/(2^N);
    saveFileName = ['mat/BBBaselineOutput2_test' in_testVersion '_cam' num2str(N) '_rng' in_searchRange '_rho' num2str(rho) '.mat'];
    save(saveFileName);
end
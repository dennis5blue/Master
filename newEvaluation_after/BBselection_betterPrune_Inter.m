function [improveRatio] = BBselection_betterPrune_Inter (in_ifSave,in_numCams,in_testVersion,in_overRange,in_degree)
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
    firstCam = 1;
    
    % Initialize matCost according to N
    for i = 1:length(vecBits)
        matCost(i,i) = vecBits(i);
    end

    % First branch
    vecX = -1*ones(1,N); % indicate if a camera is encoded as an I-frame
    BBqueue = [];
    vecX(firstCam) = 1;
    %newNode = struct('depth',1,'lb',CalBBLowerBound2(vecX,matCost),'selection',vecX);
    newNode = struct('depth',1,'lb',CalBBLowerBound2ConsiderOverRange(vecX,matCost,pos,bsX,bsY,rho),'selection',vecX);
    
    BBqueue = [newNode BBqueue];
    vecX(firstCam) = 0;
    %newNode = struct('depth',1,'lb',CalBBLowerBound2(vecX,matCost),'selection',vecX);
    newNode = struct('depth',1,'lb',CalBBLowerBound2ConsiderOverRange(vecX,matCost,pos,bsX,bsY,rho),'selection',vecX);
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
            m_lb = CalBBLowerBound2ConsiderOverRange(m_selec,matCost,pos,bsX,bsY,rho);
            if m_lb < ub
                newNode = struct('depth',BBnode.depth+1,'lb',m_lb,'selection',m_selec);
                BBqueue = [newNode BBqueue];
            end

            % branch 0
            m_selec(nextCam) = 0;
            %m_lb = CalBBLowerBound2(m_selec,matCost);
            m_lb = CalBBLowerBound2ConsiderOverRange(m_selec,matCost,pos,bsX,bsY,rho);
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
    if ifSaveFile == 1
        saveFileName = ['mat/BB/Proposed/BBBetterPruneOutput2_test' in_testVersion '_cam' num2str(N) '_rng' in_searchRange '_rho' num2str(rho) '.mat'];
        save(saveFileName);
    end
end
function BBselection_betterPrune (in_numCams,in_testVersion,in_searchRange,in_overRange)
    %clc;
    %clear;
    %in_numCams = '25';
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
    tau = 1; % ms
    txPower = 0.1; % transmission power (watt)
    n0 = 1e-16; % cannot change this value (hard code in CalChannelGain)
    N = str2num(in_numCams); % number of total cameras
    W = 180; % kHz
    rho = str2num(in_overRange);
    firstCam = 1;
    for i = 1:N
        matCost(i,i) = vecBits(i);
    end
    matCost = matCost(1:N,1:N);
    vecBits = vecBits(1:N);

    vecC = [];
    for i = 1:N
        snr = txPower*CalChannelGain(pos(i,1),pos(i,2),bsX,bsY)/n0;
        capacity = tau*W*log2(1+snr);
        vecC = [vecC capacity];
    end

    % First branch
    vecX = -1*ones(1,N); % indicate if a camera is encoded as an I-frame
    BBqueue = [];
    vecX(firstCam) = 1;
    newNode = struct('depth',1,'lb',CalBBLowerBound2(vecX,matCost),'selection',vecX);
    BBqueue = [newNode BBqueue];
    vecX(firstCam) = 0;
    newNode = struct('depth',1,'lb',CalBBLowerBound2(vecX,matCost),'selection',vecX);
    BBqueue = [newNode BBqueue];

    % Strat BB algorithm
    recordUb = [];
    recordLb = [];
    ub = inf;
    while length(BBqueue) > 0
        % sort BBqueue to get lowest lb and depthest node
        BBqueue = sortStruct(BBqueue,'lb',-1); % -1 means sort descending
        BBqueue = sortStruct(BBqueue,'depth',1); % 1 means sort ascending

        % pop the last element
        BBnode = BBqueue(length(BBqueue));
        BBqueue(length(BBqueue)) = [];

        if BBnode.depth == N
            m_cost = CalExactCost(BBnode.selection,matCost);
            if m_cost < ub
                ub = m_cost;
                bestSelection = BBnode.selection;
            end
        elseif BBnode.depth < N
            nextCam = RandomSelectNextBranch( BBnode.selection );

            % branch 1
            m_selec = BBnode.selection;
            m_selec(nextCam) = 1;
            m_lb = CalBBLowerBound2(m_selec,matCost);
            if m_lb < ub
                newNode = struct('depth',BBnode.depth+1,'lb',m_lb,'selection',m_selec);
                BBqueue = [newNode BBqueue];
            end

            % branch 0
            m_selec(nextCam) = 0;
            m_lb = CalBBLowerBound2(m_selec,matCost);
            if m_lb <= ub
                newNode = struct('depth',BBnode.depth+1,'lb',m_lb,'selection',m_selec);
                BBqueue = [newNode BBqueue];
            end
        end
        %[BBnode.lb ub]
        recordUb = [recordUb ub];
        recordLb = [recordLb BBnode.lb];
    end

    bestSelection
    finalTxBits = CalExactCost(bestSelection,matCost)
    improveRatio = (sum(vecBits(1:N))-finalTxBits)/sum(vecBits(1:N))
    reducedIter = (2^N - length(recordLb))/(2^N)
    %saveFileName = ['mat/BBBetterPruneOutput_test' testVersion '_cam' num2str(N) '_rng' searchRg '.mat'];
    %save(saveFileName);
end
function BBselection (numCams)
    %clc;
    %clear;
    %addpath('./Utility');
    inputPath = '../SourceData/test9/';
    searchRange = 512;

    % Read files
    vecBits = 8.*dlmread([inputPath 'outFiles/indepByte.txt']); % bits
    pos = dlmread([inputPath 'pos.txt']);
    dir = dlmread([inputPath 'dir.txt']);
    matCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRange) '/corrMatrix.txt']);

    % Parameters settings
    bsX = 0; bsY = 0; % position of base station
    tau = 1; % ms
    txPower = 0.1; % transmission power (watt)
    n0 = 1e-16; % cannot change this value (hard code in CalChannelGain)
    N = str2num(numCams); % number of total cameras
    W = 180; % kHz
    rho = 1;
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
    newNode = struct('depth',1,'lb',CalBBLowerBound(vecX,matCost),'selection',vecX);
    BBqueue = [newNode BBqueue];
    vecX(firstCam) = 0;
    newNode = struct('depth',1,'lb',CalBBLowerBound(vecX,matCost),'selection',vecX);
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
            m_lb = CalBBLowerBound(m_selec,matCost);
            if m_lb < ub
                newNode = struct('depth',BBnode.depth+1,'lb',m_lb,'selection',m_selec);
                BBqueue = [newNode BBqueue];
            end

            % branch 0
            m_selec(nextCam) = 0;
            m_lb = CalBBLowerBound(m_selec,matCost);
            if m_lb <= ub
                newNode = struct('depth',BBnode.depth+1,'lb',m_lb,'selection',m_selec);
                BBqueue = [newNode BBqueue];
            end
        end
        %[BBnode.lb ub]
        recordUb = [recordUb ub];
        recordLb = [recordLb BBnode.lb];
    end

    %bestSelection
    finalTxBits = CalExactCost(bestSelection,matCost);
    saveFileName = ['mat/IframeStructure_cam' num2str(N) '.mat'];
    save(saveFileName);
end
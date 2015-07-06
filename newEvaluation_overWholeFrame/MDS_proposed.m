function MDS_proposed (in_numCams,in_testVersion,in_searchRange,in_overRange)
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
    tau = 1; % ms
    txPower = 0.1; % transmission power (watt)
    n0 = 1e-16; % cannot change this value (hard code in CalChannelGain)
    N = str2num(in_numCams); % number of total cameras
    W = 180; % kHz
    rho = str2num(in_overRange);
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
    
    while(1)
        % Cal the head metric by each camera's best out edge
        vecBestOutEdge = FindBestOutEdge( vecAdjGraph,matCost );
        vecHeadMetric = zeros(1,N);
        for cam = 1:N
            m_node = vecAdjGraph(cam);
            if m_node.ifIFrame == -1
                m_headMetric = - m_node.weight;
                for i = 1:N
                    if vecBestOutEdge(i) == cam
                        m_headMetric = m_headMetric + ( vecBits(i) - matCost(i,cam) );
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
                    if vecAdjGraph(refcam).ifIFrame == 1 && matCost(cam,refcam) < m_cost
                        m_candidateI = refcam;
                        m_cost = matCost(cam,refcam);
                    end
                end
            
                pFlag = 1;
                for i = 1:length(m_outEdge)
                    refcam = m_outEdge(i);
                    if matCost(cam,refcam) < m_cost && vecAdjGraph(refcam).ifIFrame ~= 0
                        pFlag = 0;
                    end
                end
            
                if pFlag == 1
                    m_node.ifIFrame = 0;
                    m_node.cost = matCost(cam,m_candidateI);
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
    bestSelection = [];
    for i = 1:N
        %vecAdjGraph(i)
        m_node = vecAdjGraph(i);
        totalCost = totalCost + m_node.cost;
        if m_node.ifIFrame == 1
            bestSelection = [bestSelection i];
        end
    end

    bestSelection
    totalCost
    improveRatio = (sum(vecBits(1:N))-totalCost)/sum(vecBits(1:N))
    %finalTxBits = CalExactCost(bestSelection,matCost);
    saveFileName = ['mat/MDSProposedOutput2_test' in_testVersion '_cam' num2str(N) '_rng' in_searchRange '_rho' in_overRange '.mat'];
    save(saveFileName);
end
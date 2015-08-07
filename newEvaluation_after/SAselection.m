function [improveRatio_real improveRatio_geoTech] = SAselection (in_ifSave,in_numCams,in_testVersion,in_searchRange,in_overRange,in_iterLimit)
    %clc;
    %clear;
    %in_numCams = '20';
    %in_testVersion = '12';
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
    numIntersections = 4; % only for test version 12
    initNumCams = 24; % only for test version 12
    N = str2num(in_numCams); % number of total cameras
    rho = str2num(in_overRange);
    iterLimit = str2num(in_iterLimit);
    d_GeoTech = 50;
    % Parameters for SA
    SA_INIT_TEMP = 3.0;
    SA_FIN_TEMP = 0.5;
    SA_COOL_PARAM = exp(SA_INIT_TEMP/SA_FIN_TEMP) - iterLimit;
    SA_ADD = 5000;
    SA_DISCARD = 30000;
    SA_RAND_MAX = SA_ADD + SA_DISCARD;
    
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
    
    % Calculate initial reference structure as the input of SA
    %initSelection = find(randi(2,1,N)==2); % initial I-frame cameras set
    %initSelection = [find(vecBits == min(vecBits))];
    initSelection = 1:N;
    lowestPayoff = CalSAPayoff( initSelection, N, pos, bsX, bsY, rho, matCost );
    bestSelection = initSelection;
    lowestPayoff_GeoTech = CalSAPayoff( initSelection, N, pos, bsX, bsY, rho, matCost_GeoTech );
    bestSelection_GeoTech = initSelection;
    
    vecRecordPayoff = [];
    payoffNew = lowestPayoff;
    % Start SA (add, discard) using real encoded bits
    currSelection = initSelection;
    for iter = 1:iterLimit
        vecRecordPayoff = [vecRecordPayoff payoffNew];
        SA_CURR_TEMP = SA_INIT_TEMP/log(iter+SA_COOL_PARAM);
        if rand*SA_RAND_MAX <= SA_ADD % do add
            if length(currSelection) == N
                continue;
            end
            m_CamSet = 1:N;
            m_CamSet(currSelection) = [];
            % Select one camera to add according to the inverse of its payoff
            vecPayoff = zeros(1,length(m_CamSet));
            for i = 1:length(m_CamSet)
                camToAdd = m_CamSet(i);
                vecPayoff(i) = CalSAPayoff( [currSelection camToAdd], N, pos, bsX, bsY, rho, matCost );
            end
            vecProb = zeros(1,length(m_CamSet));
            for i = 1:length(m_CamSet)
                vecProb(i) = (1/vecPayoff(i))/(sum(1./vecPayoff));
            end
            camToAdd = MySelectionAccordingToProb(vecProb,m_CamSet);
            % Determine if we should change cameras selection
            payoffOld = CalSAPayoff( currSelection, N, pos, bsX, bsY, rho, matCost );
            payoffNew = CalSAPayoff( [currSelection camToAdd], N, pos, bsX, bsY, rho, matCost );
            probChange = min(1,exp( (payoffOld-payoffNew)/SA_CURR_TEMP ));
            if MySelectionAccordingToProb([probChange 1-probChange],[1 0]) == 1 % add camera
                currSelection = [currSelection camToAdd];
                if payoffNew < lowestPayoff
                    lowestPayoff = payoffNew;
                    bestSelection = currSelection;
                end
            elseif MySelectionAccordingToProb([probChange 1-probChange],[1 0]) == 0 % no adding
                continue;
            else
                disp('Error while determining whether we should add');
                return;
            end
        elseif rand*SA_RAND_MAX <= SA_ADD + SA_DISCARD % do discard
            if length(currSelection) == 0
                continue;
            end
            % Select one camera to discard according to the inverse of its payoff
            vecPayoff = zeros(1,length(currSelection));
            for i = 1:length(currSelection)
                tempSelection = currSelection;
                tempSelection(i) = [];
                vecPayoff(i) = CalSAPayoff( tempSelection, N, pos, bsX, bsY, rho, matCost );
            end
            vecProb = zeros(1,length(currSelection));
            for i = 1:length(currSelection)
                vecProb(i) = (1/vecPayoff(i))/(sum(1./vecPayoff));
            end
            camToDiscard = MySelectionAccordingToProb(vecProb,currSelection);
            % Determine if we should change cameras selection
            payoffOld = CalSAPayoff( currSelection, N, pos, bsX, bsY, rho, matCost );
            tempSelection = currSelection;
            tempSelection(find(tempSelection==camToDiscard)) = [];
            payoffNew = CalSAPayoff( tempSelection, N, pos, bsX, bsY, rho, matCost );
            probChange = min(1,exp( (payoffOld-payoffNew)/SA_CURR_TEMP ));
            if MySelectionAccordingToProb([probChange 1-probChange],[1 0]) == 1 % discard camera
                currSelection = tempSelection;
                if payoffNew < lowestPayoff
                    lowestPayoff = payoffNew;
                    bestSelection = currSelection;
                end
            elseif MySelectionAccordingToProb([probChange 1-probChange],[1 0]) == 0 % no discarding
                continue;
            else
                disp('Error while determining whether we should add');
                return;
            end
        else
            disp('Error when selecting neighbor operator');
            return;
        end
    end
    
    % Start SA (add, discard) using geometric correlation matrix
    currSelection = initSelection;
    tempSelection = initSelection;
    vecRecordPayoff_GeoTech = [];
    payoffNew = lowestPayoff;
    for iter = 1:iterLimit
        vecRecordPayoff_GeoTech = [vecRecordPayoff_GeoTech CalSAPayoff( tempSelection, N, pos, bsX, bsY, rho, matCost )];
        SA_CURR_TEMP = SA_INIT_TEMP/log(iter+SA_COOL_PARAM);
        if rand*SA_RAND_MAX <= SA_ADD % do add
            if length(currSelection) == N
                continue;
            end
            m_CamSet = 1:N;
            m_CamSet(currSelection) = [];
            % Select one camera to add according to the inverse of its payoff
            vecPayoff = zeros(1,length(m_CamSet));
            for i = 1:length(m_CamSet)
                camToAdd = m_CamSet(i);
                vecPayoff(i) = CalSAPayoff( [currSelection camToAdd], N, pos, bsX, bsY, rho, matCost_GeoTech );
            end
            vecProb = zeros(1,length(m_CamSet));
            for i = 1:length(m_CamSet)
                vecProb(i) = (1/vecPayoff(i))/(sum(1./vecPayoff));
            end
            camToAdd = MySelectionAccordingToProb(vecProb,m_CamSet);
            % Determine if we should change cameras selection
            payoffOld = CalSAPayoff( currSelection, N, pos, bsX, bsY, rho, matCost_GeoTech );
            tempSelection = [currSelection camToAdd];
            payoffNew = CalSAPayoff( tempSelection, N, pos, bsX, bsY, rho, matCost_GeoTech );
            probChange = min(1,exp( (payoffOld-payoffNew)/SA_CURR_TEMP ));
            if MySelectionAccordingToProb([probChange 1-probChange],[1 0]) == 1 % add camera
                currSelection = tempSelection;
                if payoffNew < lowestPayoff_GeoTech
                    lowestPayoff_GeoTech = payoffNew;
                    bestSelection_GeoTech = currSelection;
                end
            elseif MySelectionAccordingToProb([probChange 1-probChange],[1 0]) == 0 % no adding
                continue;
            else
                disp('Error while determining whether we should add');
                return;
            end
        elseif rand*SA_RAND_MAX <= SA_ADD + SA_DISCARD % do discard
            if length(currSelection) == 0
                continue;
            end
            % Select one camera to discard according to the inverse of its payoff
            vecPayoff = zeros(1,length(currSelection));
            for i = 1:length(currSelection)
                tempSelection = currSelection;
                tempSelection(i) = [];
                vecPayoff(i) = CalSAPayoff( tempSelection, N, pos, bsX, bsY, rho, matCost_GeoTech );
            end
            vecProb = zeros(1,length(currSelection));
            for i = 1:length(currSelection)
                vecProb(i) = (1/vecPayoff(i))/(sum(1./vecPayoff));
            end
            camToDiscard = MySelectionAccordingToProb(vecProb,currSelection);
            % Determine if we should change cameras selection
            payoffOld = CalSAPayoff( currSelection, N, pos, bsX, bsY, rho, matCost_GeoTech );
            tempSelection = currSelection;
            tempSelection(find(tempSelection==camToDiscard)) = [];
            payoffNew = CalSAPayoff( tempSelection, N, pos, bsX, bsY, rho, matCost_GeoTech );
            probChange = min(1,exp( (payoffOld-payoffNew)/SA_CURR_TEMP ));
            if MySelectionAccordingToProb([probChange 1-probChange],[1 0]) == 1 % discard camera
                currSelection = tempSelection;
                if payoffNew < lowestPayoff_GeoTech
                    lowestPayoff_GeoTech = payoffNew;
                    bestSelection_GeoTech = currSelection;
                end
            elseif MySelectionAccordingToProb([probChange 1-probChange],[1 0]) == 0 % no discarding
                continue;
            else
                disp('Error while determining whether we should add');
                return;
            end
        else
            disp('Error when selecting neighbor operator');
            return;
        end
    end

    bestSelection;
    bestSelection_GeoTech;
    
    gg1 = CalSAPayoff( bestSelection, N, pos, bsX, bsY, rho, matCost );
    gg2 = CalSAPayoff( bestSelection_GeoTech, N, pos, bsX, bsY, rho, matCost );
    improveRatio_real = (sum(vecBits) - gg1)/sum(vecBits);
    improveRatio_geoTech = (sum(vecBits)-gg2)/sum(vecBits);
    
    if ifSaveFile == 1
        saveFileName = ['mat/SA/SAselectionGuided_test' in_testVersion '_cam' num2str(N) '_rng' in_searchRange '_rho' in_overRange '_iter' in_iterLimit '.mat'];
        save(saveFileName);
    end
end
function [improveRatio_real] = SAselection (in_ifSave,in_numCams,in_testVersion,in_searchRange,in_overRange,in_iterLimit)
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
    iterLimit = str2num(in_iterLimit);
    % Parameters for SA
    SA_INIT_TEMP = 110;
    SA_FIN_TEMP = 0.2;
    SA_COOL_PARAM = exp(SA_INIT_TEMP/SA_FIN_TEMP) - iterLimit;
    SA_ADD = 5000;
    SA_DISCARD = 30000;
    SA_RAND_MAX = SA_ADD + SA_DISCARD;

    % Initialize matCost according to N
    for i = 1:length(vecBits)
        matCost(i,i) = vecBits(i);
    end
    matCost = matCost(1:N,1:N);
    vecBits = vecBits(1:N);
    
    % Calculate initial reference structure as the input of SA
    initSelection = 1:N;
    initSelection = find(randi(2,1,N)==2); % random init selection
    lowestPayoff = CalSAPayoff( initSelection, N, pos, bsX, bsY, rho, matCost );
    improvNew = 100*(sum(vecBits)-lowestPayoff)/sum(vecBits);
    bestSelection = initSelection;
    
    vecRecordPayoff = [];
    vecRecordImprovement = [];
    vecRecordProb = [];
    payoffNew = lowestPayoff;
    % Start SA (add, discard) using real encoded bits
    currSelection = initSelection;
    ifRecord = 1;
    probChange = 1;
    iter = 0;
    counter = 0;
    while iter < iterLimit
        counter = counter + 1;
        iter = iter + 1;
        if counter > 5*iterLimit
            iter;
        end
        vecRecordProb = [ vecRecordProb probChange ];
        if ifRecord == 1
            vecRecordPayoff = [vecRecordPayoff payoffNew];
            vecRecordImprovement = [vecRecordImprovement improvNew];
        end
        SA_CURR_TEMP = SA_INIT_TEMP/log(iter+SA_COOL_PARAM);
        if length(currSelection) == N % do discard
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
            improvOld = 100*(sum(vecBits)-payoffOld)/sum(vecBits);
            tempSelection = currSelection;
            tempSelection(find(tempSelection==camToDiscard)) = [];
            payoffNew = CalSAPayoff( tempSelection, N, pos, bsX, bsY, rho, matCost );
            improvNew = 100*(sum(vecBits)-payoffNew)/sum(vecBits);
            probChange = min(1,exp( -(improvOld-improvNew)/SA_CURR_TEMP ));
            probChange = abs(probChange);
            if MySelectionAccordingToProb([probChange 1-probChange],[1 0]) == 1 % discard camera
                ifRecord = 1;
                currSelection = tempSelection;
                if payoffNew < lowestPayoff
                    lowestPayoff = payoffNew;
                    bestSelection = currSelection;
                end
            else
                ifRecord = 0;
                iter = iter - 1;
                continue;
            end
        elseif length(currSelection) == 0 % do add
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
            improvOld = 100*(sum(vecBits)-payoffOld)/sum(vecBits);
            payoffNew = CalSAPayoff( [currSelection camToAdd], N, pos, bsX, bsY, rho, matCost );
            improvNew = 100*(sum(vecBits)-payoffNew)/sum(vecBits);
            probChange = min(1,exp( -(improvOld-improvNew)/SA_CURR_TEMP ));
            probChange = abs(probChange);
            if MySelectionAccordingToProb([probChange 1-probChange],[1 0]) == 1 % add camera
                ifRecord = 1;
                currSelection = [currSelection camToAdd];
                if payoffNew < lowestPayoff
                    lowestPayoff = payoffNew;
                    bestSelection = currSelection;
                end
            else
                ifRecord = 0;
                iter = iter - 1;
                continue;
            end
        elseif rand*SA_RAND_MAX <= SA_ADD % do add
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
            improvOld = 100*(sum(vecBits)-payoffOld)/sum(vecBits);
            payoffNew = CalSAPayoff( [currSelection camToAdd], N, pos, bsX, bsY, rho, matCost );
            improvNew = 100*(sum(vecBits)-payoffNew)/sum(vecBits);
            probChange = min(1,exp( -(improvOld-improvNew)/SA_CURR_TEMP ));
            probChange = abs(probChange);
            if MySelectionAccordingToProb([probChange 1-probChange],[1 0]) == 1 % add camera
                ifRecord = 1;
                currSelection = [currSelection camToAdd];
                if payoffNew < lowestPayoff
                    lowestPayoff = payoffNew;
                    bestSelection = currSelection;
                end
            else
                ifRecord = 0;
                iter = iter - 1;
                continue;
            end
        elseif rand*SA_RAND_MAX <= SA_ADD + SA_DISCARD % do discard
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
            improvOld = 100*(sum(vecBits)-payoffOld)/sum(vecBits);
            tempSelection = currSelection;
            tempSelection(find(tempSelection==camToDiscard)) = [];
            payoffNew = CalSAPayoff( tempSelection, N, pos, bsX, bsY, rho, matCost );
            improvNew = 100*(sum(vecBits)-payoffNew)/sum(vecBits);
            probChange = min(1,exp( -(improvOld-improvNew)/SA_CURR_TEMP ));
            probChange = abs(probChange);
            if MySelectionAccordingToProb([probChange 1-probChange],[1 0]) == 1 % discard camera
                ifRecord = 1;
                currSelection = tempSelection;
                if payoffNew < lowestPayoff
                    lowestPayoff = payoffNew;
                    bestSelection = currSelection;
                end
            else
                ifRecord = 0;
                iter = iter - 1;
                continue;
            end
        else
            disp('Error when selecting neighbor operator');
            return;
        end
    end
    
    %{
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
    %}
    
    bestSelection;
    %bestSelection_GeoTech;
    
    gg1 = CalSAPayoff( bestSelection, N, pos, bsX, bsY, rho, matCost );
    improveRatio_real = (sum(vecBits) - gg1)/sum(vecBits);
    
    if ifSaveFile == 1
        saveFileName = ['mat/SA/SAselectionGuided_test' in_testVersion '_cam' num2str(N) '_rng' in_searchRange '_rho' in_overRange '_iter' in_iterLimit '.mat'];
        save(saveFileName);
    end
end
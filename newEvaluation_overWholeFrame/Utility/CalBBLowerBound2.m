function [ lb ] = CalBBLowerBound2( vecX, matCost )
    % vecX(i) = 1 means camera i is encoded as an I-frame
    % vecX(i) = 0 means camera i is encoded as a P-frame
    % vecX(i) = -1 means camera i has not determined yet
    lb = 0;
    N = length(vecX);
    iFrame = find(vecX == 1);
    pFrame = find(vecX == 0);
    unDetermined = find(vecX == -1);
    if length([iFrame pFrame unDetermined]) ~= N
        disp('Error in CalBBLowerBound2!! dimension not matched');
    end
    mod_matCost = matCost;
    
    % Cost for I-frame
    for i = 1:length(iFrame)
        cam = iFrame(i);
        lb = lb + matCost(cam,cam);
    end
    
    % update cost matrix for P-frame
    for i = 1:length(pFrame);
        cam = pFrame(i);
        
        mod_matCost(1:(cam-1),cam) = inf;
        mod_matCost((cam+1):N,cam) = inf; 
    end
    
    % Initialize cost and ref for P-frames and undetermined frames
    vecCandidateCost = zeros(1,N);
    vecCandidateRef = zeros(1,N);
    vecCams = [pFrame unDetermined];
    for i = 1:length(vecCams)
        cam = vecCams(i);
        vecCandidateRef(cam) = find( mod_matCost(cam,:) == min(mod_matCost(cam,:)) );
        vecCandidateCost = min(mod_matCost(cam,:));
    end
    
    % If deadlock exists, change reference with the lower increment cost
    while (1)
        [ ifDeadlock, matDeadlockPair ] = CheckIfDeadlock( vecCandidateRef );
        if ifDeadlock == 0
            break;
        end
        for i = 1:length(matDeadlockPair(:,1))
            cam1 = matDeadlockPair(i,1);
            cam2 = matDeadlockPair(i,2);
            
        end
    end
    
    % Cost lb for undetermined frames and p-frames
    for i = 1:length(unDetermined)
        cam = unDetermined(i);
        lb = lb + min(matCost(cam,:));
    end
end


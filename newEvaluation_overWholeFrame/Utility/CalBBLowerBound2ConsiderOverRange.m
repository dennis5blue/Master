function [ lb ] = CalBBLowerBound2ConsiderOverRange( vecX, matCost, pos, bsX, bsY, rho )
    % tighter lower bound (avoid deadlock)
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
    
    % check overhearing constraint
    for i = 1:N
        for j = 1:N
            if i~=j
                if IfCanOverhear( pos(i,1),pos(i,2),pos(j,1),pos(j,2),bsX,bsY,rho ) == 0
                    mod_matCost(i,j) = inf;
                end
            end
        end
    end
    
    % Initialize cost and ref for P-frames and undetermined frames
    vecCandidateCost = zeros(1,N);
    vecCandidateRef = zeros(1,N);
    vecCams = [pFrame unDetermined];
    for i = 1:length(vecCams)
        cam = vecCams(i);
        [val idx] = sort(mod_matCost(cam,:),'ascend');
        vecCandidateRef(cam) = idx(1);
        vecCandidateCost(cam) = val(1);
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
            [val1 idx1] = sort(mod_matCost(cam1,:),'ascend');
            [val2 idx2] = sort(mod_matCost(cam2,:),'ascend');
            if val1(2) - vecCandidateCost(cam1) < val2(2) - vecCandidateCost(cam2)
                vecCandidateRef(cam1) = idx1(2);
                vecCandidateCost(cam1) = val1(2);
                mod_matCost(cam1,idx1(1)) = inf;
            else
                vecCandidateRef(cam2) = idx2(2);
                vecCandidateCost(cam2) = val2(2);
                mod_matCost(cam2,idx2(1)) = inf;
            end
        end
    end
    
    % Cost lb for undetermined frames and p-frames
    lb = lb + sum(vecCandidateCost);
end


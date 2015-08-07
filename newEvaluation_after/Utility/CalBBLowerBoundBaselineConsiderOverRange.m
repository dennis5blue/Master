function [ lb ] = CalBBLowerBoundBaselineConsiderOverRange( vecX, matCost, pos, bsX, bsY, rho )
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
    
    % Initialize cost for P-frames and undetermined frames
    vecCandidateCost = zeros(1,N);
    vecCams = [pFrame unDetermined];
    for i = 1:length(vecCams)
        cam = vecCams(i);
        [val idx] = sort(mod_matCost(cam,:),'ascend');
        vecCandidateCost(cam) = val(1);
    end

    % Cost lb for undetermined frames and p-frames
    lb = lb + sum(vecCandidateCost);
end


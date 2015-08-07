function [ cost ] = CalExactCostConsiderOverRange( vecX, matCost, pos, bsX, bsY, rho )
    % vecX(i) = 1 means camera i is encoded as an I-frame
    % vecX(i) = 0 means camera i is encoded as a P-frame
    % vecX(i) = -1 means camera i has not determined yet
    N = length(vecX);
    iFrames = find(vecX == 1);
    numClusters = length(iFrames);
    pFrames = find(vecX == 0);
    if length(iFrames)+length(pFrames)~=N
        disp('Error, number of cameras does not matched!!');
    end
    
    vecRefStruc = zeros(1,N);
    for i = 1:N
        if ismember(i,iFrames)
            vecRefStruc(i) = i;
        else
            vecTmpCost = [];
            for j = 1:numClusters
                iCam = iFrames(j);
                if IfCanOverhear( pos(i,1),pos(i,2),pos(iCam,1),pos(iCam,2),bsX,bsY,rho ) == 1
                    vecTmpCost = [vecTmpCost matCost(i,iCam)];
                else
                    vecTmpCost = [vecTmpCost inf];
                end
            end
            [val idx] = sort(vecTmpCost,'ascend');
            if length(idx) > 0
                vecRefStruc(i) = iFrames(idx(1));
            else
                vecRefStruc(i) = i;
            end
        end
    end
    
    cost = 0;
    for i = 1:N
        cost = cost + matCost(i,vecRefStruc(i));
    end
end


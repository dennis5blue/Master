function [ vecImprovement ] = CalImprovementForEachCam( vecX, matCost, pos, bsX, bsY, rho )
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
            vecRefStruc(i) = iFrames(idx(1));
        end
    end
    
    vecImprovement = zeros(1,N);
    for i = 1:N
        vecImprovement(i) = (matCost(i,i)-matCost(i,vecRefStruc(i)))/matCost(i,i);
    end

end


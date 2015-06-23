function [ vecBestSche, vecBestRefStruc ] = BruteForcePFrameScheduling( GOP, matCost, pos, bsX, bsY, rho )
    vecPCams = GOP.pFrames;
    matAllSche = perms(vecPCams);
    vecIndepBits = [];
    for i = 1:length(matCost(:,1))
        vecIndepBits = [vecIndepBits matCost(i,i)];
    end
    
    % Brute force searching
    vecBestSche = [];
    vecBestRefStruc = [];
    minCost = inf;
    for i = 1:length(matAllSche(:,1))
        vecSche = matAllSche(i,:);
        vecRefStr = GOP.refStructure;
        for j = 1:length(vecSche)
            pCam = vecSche(j);
            orgRef = vecRefStr(find(vecPCams==pCam));
            iCam = orgRef;
            vecCanHearCams = FindCanHearCamsSet( pCam, iCam, vecRefStr, GOP, [iCam vecSche(1:j-1)], pos, bsX, bsY, rho );
            % update the reference camera if a better one is found
            refCost = matCost(pCam,orgRef);
            for k = 1:length(vecCanHearCams)
                if matCost(pCam,vecCanHearCams(k)) < refCost
                    newRef = vecCanHearCams(k);
                    refCost = matCost(pCam,newRef);
                    vecRefStr(find(vecPCams==pCam)) = newRef;
                end                
            end
        end
        newGOP = GOP;
        newGOP.refStructure = vecRefStr;
        [ costRefI, costRefP ] = CalCostByRefStructure( matCost, vecIndepBits, newGOP );
        if costRefP <= minCost
            minCost = costRefP;
            vecBestSche = vecSche;
            vecBestRefStruc = vecRefStr;
        end
    end
end


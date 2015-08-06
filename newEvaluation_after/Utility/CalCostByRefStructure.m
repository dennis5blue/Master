function [ costRefI, costRefP ] = CalCostByRefStructure( matCost, vecIndepBits, vecGOP )
    costRefI = 0;
    costRefP = 0;
    for i = 1:length(vecIndepBits)
        matCost(i,i) = vecIndepBits(i);
    end
    
    for gg = 1:length(vecGOP)
        iCam = vecGOP(gg).iFrame;
        pCamSet = vecGOP(gg).pFrames;
        refStr = vecGOP(gg).refStructure;
        costRefI = costRefI + vecIndepBits(iCam);
        costRefP = costRefP + vecIndepBits(iCam);
        for i = 1:length(refStr)
            pCam = pCamSet(i);
            refCam = refStr(i);
            if matCost(pCam,refCam) < matCost(pCam,iCam)
                costRefP = costRefP + matCost(pCam,refCam);
                costRefI = costRefI + matCost(pCam,iCam);
            else
                costRefP = costRefP + matCost(pCam,iCam);
                costRefI = costRefI + matCost(pCam,iCam);
            end
        end
    end
end


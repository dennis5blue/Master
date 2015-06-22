function [ vecMetric ] = CalPFrameSchedulingMetric( pCamSet, vecRefCam, GOP, matCost )
    % calculate the scheduling metric for each pCamera
    vecMetric = [];
    for i = 1:length(pCamSet)
        pCam = pCamSet(i);
        pCamDerRef = vecRefCam(find(GOP.pFrames==pCam));
        metric = 1;
        % reduction if scheduled later
        candidateReduction = [];
        for rr = 1:length(pCamSet)
            if pCamSet(rr) ~= pCam
                m_reduc = matCost(pCam,pCamDerRef) - matCost(pCam,pCamSet(rr));
                candidateReduction = [candidateReduction m_reduc];
            end
        end
        metric = metric*max(1,max(candidateReduction));
        
        % reduction for other cameras if scheduled now
        m_reduc = 0;
        for jj = 1:length(pCamSet)
            if pCamSet(jj) ~= pCam
                orgRef = vecRefCam(find(GOP.pFrames==pCamSet(jj)));
                m_reduc = m_reduc + matCost(pCamSet(jj),orgRef) - matCost(pCamSet(jj),pCam);
            end
        end
        aveReduc = m_reduc/(length(pCamSet)-1);
        metric = metric*max(1,aveReduc);
        vecMetric = [vecMetric metric];
    end
end


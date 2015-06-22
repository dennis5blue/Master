function [ vecMetric ] = CalPFrameSchedulingMetric2( pCamSet, vecRefCam, GOP, matCost )
    % calculate the scheduling metric for each pCamera
    vecMetric = [];
    for i = 1:length(pCamSet)
        pCam = pCamSet(i);
        metric = 1;     
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


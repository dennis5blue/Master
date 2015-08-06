function [ vecMetric ] = CalPFrameSchedulingMetric3( pCamSet, pos, bsX, bsY )
    % calculate the scheduling metric for each pCamera
    vecMetric = [];
    for i = 1:length(pCamSet)
        cam = pCamSet(i);
        metric = (pos(cam,1)-bsX)^2 + (pos(cam,2)-bsY)^2;
        vecMetric = [vecMetric metric];
    end
end


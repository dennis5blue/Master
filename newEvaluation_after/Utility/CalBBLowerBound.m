function [ lb ] = CalBBLowerBound( vecX, matCost )
    % vecX(i) = 1 means camera i is encoded as an I-frame
    % vecX(i) = 0 means camera i is encoded as a P-frame
    % vecX(i) = -1 means camera i has not determined yet
    lb = 0;
    N = length(vecX);
    iFrame = find(vecX == 1);
    for i = 1:length(iFrame)
        cam = iFrame(i);
        lb = lb + matCost(cam,cam);
    end
    pFrameCandidate = [1:N];
    pFrameCandidate(iFrame) = [];
    for i = 1:length(pFrameCandidate)
        cam = pFrameCandidate(i);
        lb = lb + min(matCost(cam,:));
    end
end


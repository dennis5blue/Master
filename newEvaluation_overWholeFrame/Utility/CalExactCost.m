function [ cost ] = CalExactCost( vecX, matCost )
    % vecX(i) = 1 means camera i is encoded as an I-frame
    % vecX(i) = 0 means camera i is encoded as a P-frame
    % vecX(i) = -1 means camera i has not determined yet
    cost = 0;
    N = length(vecX);
    iFrame = find(vecX == 1);
    pFrame = find(vecX == 0);
    if length(iFrame)+length(pFrame)~=N
        disp('Error, number of cameras does not matched!!');
    end
    for i = 1:length(iFrame)
        cam = iFrame(i);
        cost = cost + matCost(cam,cam);
    end
    for i = 1:length(pFrame)
        cam = pFrame(i);
        candidateCost = matCost(cam,iFrame);
        cost = cost + min(candidateCost);
    end
end


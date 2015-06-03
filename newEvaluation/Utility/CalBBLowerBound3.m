function [ lb ] = CalBBLowerBound3( route, matCost, inputPath, matsBits, reg, N )
    lb = CalTxBits(inputPath, route, matsBits, reg);
    unScheCams = [];
    for i = 1:N
        if ismember(i,route) == 0
            unScheCams = [unScheCams i];
        end
    end
    startCam = route(length(route));
    while length(unScheCams) > 0
        nextCam = 0;
        cost = inf;
        for i = 1:length(unScheCams)
            candidateCam = unScheCams(i);
            if matCost(startCam,candidateCam) < cost
                cost = matCost(startCam,candidateCam);
                nextCam = candidateCam;
            end
        end
        lb = lb + matCost(startCam,nextCam);
        startCam = nextCam;
        unScheCams(find(unScheCams==nextCam)) = [];
    end
end


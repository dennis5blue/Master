function [ ans ] = GetJointEntropy( camsVec, H )
    schedule = []; % cameras schedule for calculating joint entropy
    temp = H(1).indep(camsVec(1));
    firstCam = camsVec(1);
    for i=2:length(camsVec)
        cam = camsVec(i);
        if temp > H(1).indep(cam)
            firstCam = cam;
            temp = H(1).indep(cam);
        end
    end
    schedule = [schedule firstCam];
    ans = temp;
    camsVec(find(camsVec==firstCam)) = [];
    while length(camsVec) > 0
        nextCam = camsVec(1);
        temp = H(1).corr(nextCam,schedule(length(schedule)));
        if length(camsVec) >= 2
            for i=2:length(camsVec)
                cam = camsVec(i);
                if temp > H(1).corr(cam,schedule(length(schedule)))
                    nextCam = cam;
                    temp = H(1).corr(cam,schedule(length(schedule)));
                end
            end
        end
        ans = ans + temp;
        schedule = [schedule nextCam];
        camsVec(find(camsVec==nextCam)) = [];
    end         
end


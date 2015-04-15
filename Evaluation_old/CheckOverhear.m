function [ ans ] = CheckOverhear( targetCam, scheduleValue, pos, n0, txPower, H, t, W )
    prev = scheduleValue{length(scheduleValue)};
    if prev.frameMode == 1
        snr = txPower*CalChannelGain(pos(targetCam,1),pos(targetCam,2), ...
                pos(prev.cam,1),pos(prev.cam,2))/n0;
        slotsNeeded = ceil(H(1).indep(prev.cam)/(t*W*log2(1+snr)));
        if slotsNeeded <= prev.slotsNeeded
            ans = 1;
        else
            ans = 0;
        end
    else if prev.frameMode == 0
        for i=length(scheduleValue):1
            if scheduleValue{i}.frameMode == 1
                break;
            end
        end
        ans = 1;
        for j=i:length(scheduleValue)
            snr = txPower*CalChannelGain(pos(targetCam,1),pos(targetCam,2), ...
                pos(scheduleValue{j}.cam,1),pos(scheduleValue{j}.cam,2))/n0;
            slotsNeeded = ceil(scheduleValue{j}.transBytes/(t*W*log2(1+snr)));
            if slotsNeeded > scheduleValue{j}.slotsNeeded
                ans = 0;
            end
        end
    end
end
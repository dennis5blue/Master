function [ unschedule ] = FindUnscheduled( numCam, sched )
    ans = [];
    for i=1:numCam
        if length(find(sched == i)) == 0
            ans = [ans i];
        end
    end
    unschedule = ans;
end


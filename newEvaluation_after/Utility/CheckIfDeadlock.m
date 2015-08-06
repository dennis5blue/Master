function [ ifDeadlock, matDeadlockPair ] = CheckIfDeadlock( vecCandidateRef )
    % check if i->j & j->i exists
    ifDeadlock = 0;
    matDeadlockPair = [];
    for cam = 1:length(vecCandidateRef)
        refCam = vecCandidateRef(cam);
        if refCam ~= 0 && refCam ~= cam
            if vecCandidateRef(refCam) == cam
                ifDeadlock = 1;
                matDeadlockPair = [cam refCam;];
                vecCandidateRef(refCam) = 0;
            end
        end
    end
end


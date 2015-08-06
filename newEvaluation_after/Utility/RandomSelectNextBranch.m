function [ cam ] = RandomSelectNextBranch( vecX )
    candidate = find(vecX == -1);
    cam = candidate(randi(numel(candidate))); % random pick from the array candidate
end


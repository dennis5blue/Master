function [corrMatrix] = GetCorrMatrixRegion(targetCam, refCam, ifShow)
    if targetCam.numX ~= refCam.numX || targetCam.numY ~= refCam.numY
        disp('Dimentions of pixels does not match');
        return;
    end
    if targetCam.cam == refCam.cam
        corrMatrix = -1*ones(targetCam.numY,targetCam.numX);
        return;
    end
    
    corrMatrix = zeros(targetCam.numY,targetCam.numX);
    % Start checking correlated regions
    for i = 1:refCam.numX
        for j = 1:refCam.numY
            %[j i]
            refCam.x = i; refCam.y = j;
            PSNR = PredictTwoRegions(targetCam, refCam, ifShow);
            if PSNR > 18
                corrMatrix(j,i) = 1;
            end
        end
    end 
end

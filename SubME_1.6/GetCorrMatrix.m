function [corrMatrix] = GetCorrMatrix(targetCam, refCam, ifShow)
    if targetCam.numX ~= refCam.numX || targetCam.numY ~= refCam.numY
        disp('Dimentions of pixels does not match');
        return;
    end
    if targetCam.cam == refCam.cam
        corrMatrix = ones(targetCam.numY,targetCam.numX);
        return;
    end
    
    corrMatrix = zeros(targetCam.numY,targetCam.numX);
    % Start checking correlated regions
    for xx = 1:targetCam.numX
        for yy = 1:targetCam.numY
            %[yy xx]
            PSNR = 0;
            targetCam.x = xx; targetCam.y = yy;
            for i = 1:refCam.numX
                for j = 1:refCam.numY
                    %[j i]
                    refCam.x = i; refCam.y = j;
                    PSNR = PredictTwoRegions(targetCam, refCam, ifShow);
                    if PSNR > 20
                        break;
                    end
                end
                if PSNR > 20
                    corrMatrix(yy,xx) = 1;
                    break;
                end
            end
        end
    end
end

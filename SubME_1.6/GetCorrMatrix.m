function [corrMatrix] = GetCorrMatrix(myOpts, numCam, ifShow)
    corrMatrix = [];
    refOpts = myOpts;
    for i = 0:numCam-1
        PSNR = 0;
        refOpts.cam = i;
        for xx = 1:myOpts.numX
            for yy = 1:myOpts.numY
                refOpts.x = xx;
                refOpts.y = yy;
                PSNR_new = PredictTwoRegions(myOpts, refOpts, ifShow);
                % Update PSNR
                if PSNR_new > PSNR
                    PSNR = PSNR_new;
                end
                if PSNR > 20
                    break;
                end
            end
            if PSNR > 20
                %disp(['Break, since PSNR = ',num2str(PSNR)])
                break;
            end
        end
        
        % Record binary correlation variable
        if PSNR > 20
            corrMatrix = [corrMatrix 1];
        else
            corrMatrix = [corrMatrix 0];
        end
        
    end
end

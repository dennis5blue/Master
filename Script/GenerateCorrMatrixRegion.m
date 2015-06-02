function GenerateCorrMatrixRegion( c0, c1 )
    %addpath('../SubME_1.6');
    % r0: which region of c0
    cam0 = str2num(c0);
    cam1 = str2num(c1);
    
    % For resolution 1280*720
    numX = 16;  numY = 9;
    
    targetCam.cam = cam0;
    targetCam.numX = numX;
    targetCam.numY = numY;
    targetCam.x = 1;
    targetCam.y = 1;
    
    refCam = targetCam;
    refCam.cam = cam1;
    
    ifShow = 0;
    
    for xx = 1:numX
        for yy = 1:numY
            targetCam.x = xx;
            targetCam.y = yy;
            tempCorrMatrix = GetCorrMatrixRegion(targetCam,refCam,ifShow);
            eval(['corrMatrix_' num2str(xx) '_' num2str(yy) '= tempCorrMatrix;']);
        end
    end
    save(['./mat7/corrMatrices_' num2str(c0) '_' num2str(c1) '.mat']);
end

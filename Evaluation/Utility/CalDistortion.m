function [ aveDistortion ] = CalDistortion( imgPath, sched, unsched, numCams, rate, res, reg )
    %sched
    %unsched
    aveDistortion = 0;
    for i = 1:length(unsched)
        rate(unsched(i)) = 0;
    end
    
    for i = 1:length(sched)
        cam = sched(i);
        I = imread([imgPath 'camera_' num2str(cam) '.png']);
        mean     = sum(I(:))/length(I(:));
        variance = sum((I(:) - mean).^2)/(length(I(:)) - 1);
        distortion = variance*(2^(-2*rate(cam)));
        aveDistortion = aveDistortion + distortion;
    end
    
    for i = 1:length(unsched)
        phiMatrix = [];
        cam = unsched(i);
        I = imread([imgPath 'camera_' num2str(cam) '.png']);
        mean     = sum(I(:))/length(I(:));
        variance = sum((I(:) - mean).^2)/(length(I(:)) - 1);
        
        for j = 1:numCams
            corrMatrix = load([imgPath 'mat/corrMatrix_' num2str(cam) '_' num2str(j) '.mat'],'corrMatrix');
            corrMatrix = corrMatrix.corrMatrix;
            phiMatrix = [phiMatrix corrMatrix(:)];
        end
        D = phiMatrix*rate;
        sumDistortion = 0;
        for k = 1:length(D)
            distortion = variance*(2^(-2*( double(sum(D(k,:))) ) ));
            sumDistortion = sumDistortion + distortion;
        end
        aveDistortion = aveDistortion + sumDistortion;
    end
    aveDistortion = aveDistortion/numCams;
end


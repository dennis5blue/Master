function [ bits ] = CalTxBits( inputPath, schedule, matsBits, reg )
% overhear only one previous camera
    nCams = length(schedule);
    for i = 1:nCams
        eval(['txRegs.cam' num2str(i) '=zeros(reg.Y,reg.X);']);
    end
    
    % first camera needs to transmit all regions
    cam = schedule(1);
    eval(['bits = sum(sum(matsBits.cam' num2str(cam) '));']);
    eval(['txRegs.cam' num2str(cam) '=ones(reg.Y,reg.X);']);
    
    % other cameras can overhear one previous camera
    for k = 2:nCams
        prev = schedule(k-1);
        cam = schedule(k);
        load([inputPath 'mat/corrMatrices_' num2str(cam) '_' num2str(prev) '.mat']);
        eval(['prevTxRegs = txRegs.cam' num2str(prev) ';']);
        nextTxRegs = ones(reg.Y,reg.X);
        for xx = 1:reg.X
            for yy = 1:reg.Y
                eval(['temp = prevTxRegs.*corrMatrix_' num2str(xx) '_' num2str(yy) ';']);
                if sum(sum(temp)) > 0
                    nextTxRegs(yy,xx) = 0;
                end
            end
        end
        eval(['txRegs.cam' num2str(cam) '=nextTxRegs;']);
        eval(['bits = bits + sum(sum(nextTxRegs.*matsBits.cam' num2str(cam) '));']);
    end
end


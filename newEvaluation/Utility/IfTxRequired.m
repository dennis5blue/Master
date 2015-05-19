function [ txRegs ] = IfTxRequired( inputPath, cam, ref, refCamTxRegs, reg )
% return regions that required to be transmitted (cam overhear ref)
    txRegs = ones(reg.Y,reg.X);
    for xxx = 1:reg.X
        for yyy = 1:reg.Y
            load([inputPath 'mat/corrMatrices_' num2str(cam) '_' num2str(ref) '.mat']);
            eval(['temp = refCamTxRegs.*corrMatrix_' num2str(xxx) '_' num2str(yyy) ';']);
            if sum(sum(temp)) > 0
                txRegs(yyy,xxx) = 0;
            end
        end
    end
end


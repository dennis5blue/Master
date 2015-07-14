import sys
from subprocess import call
from subprocess import Popen, PIPE

encoderPath = "/home/dennisyu/Documents/JMVC/bin/H264AVCEncoderLibTestStaticd"
configurePath = "./cfg/"

def main(argc=None):
    run = 10
    if run == 1:
        vecRefStru = [2,2,2,5,5,6,5,5,9,2]
    elif run == 2:
        vecRefStru = [10,3,3,3,7,7,7,10,10,10]
    elif run == 3:
        vecRefStru = [6,3,3,5,5,6,6,5,9,10]
    elif run == 4:
        vecRefStru = [10,3,3,3,10,7,7,7,10,10]
    elif run == 5:
        vecRefStru = [10,3,3,3,10,7,7,7,10,10]
    elif run == 6:
        vecRefStru = [3,3,3,5,5,7,7,7,7,10]
    elif run == 7:
        vecRefStru = [3,3,3,5,5,7,7,7,5,10]
    elif run == 8:
        vecRefStru = [10,3,3,3,10,7,7,7,10,10]
    elif run == 9:
        vecRefStru = [3,3,3,5,5,7,7,7,9,5]
    elif run == 10:
        vecRefStru = [3,3,3,5,5,7,7,7,9,5]

    outFileIndep = open("./outFiles/indep_round"+str(run)+".txt","w+")
    outFileOver = open("./outFiles/over_round"+str(run)+".txt","w+")
    for i in range(len(vecRefStru)):
        cam = i + 1
        ref = vecRefStru[i]
        print "Encode: "+str(cam)+" independently"
        call(["rm","./tmp_0.yuv"])
        call(["rm","./rec_0.yuv"])
        call(["rm","./stream_0.264"])
        call(["cp","./yuv/run"+str(run)+"/camera_"+str(cam)+".yuv","./tmp_0.yuv"])
        output_0 =  Popen([encoderPath,"-vf",configurePath+"01cam1Diff.cfg","0"],stdout=PIPE).communicate()[0]
        lines = [line for line in output_0.split('\n') if "encoded" in line]
        #print lines
        psnrInfo = " ".join(lines[0].strip().replace("[","").replace("]","").split())
        Y = float(psnrInfo[20:27])
        U = float(psnrInfo[33:40])
        V = float(psnrInfo[46:53])
        avePsnrIndep = (Y+U+V)/3
        print "Average PSNR = "+str(avePsnrIndep)
        outFileIndep.write(str(avePsnrIndep)+"\n")

        if cam == ref:
            print str(cam)+" = "+str(ref)
            outFileOver.write(str(avePsnrIndep)+"\n")
            continue

        print "Encode: "+str(cam)+" by referencing: "+str(ref)
        call(["rm","./tmp_0.yuv","./tmp_1.yuv"])
        call(["rm","./rec_0.yuv","./rec_1.yuv"])
        call(["rm","./stream_0.264","./stream_1.264"])
        call(["cp","./yuv/run"+str(run)+"/camera_"+str(cam)+".yuv","./tmp_1.yuv"])
        call(["cp","./yuv/run"+str(run)+"/camera_"+str(ref)+".yuv","./tmp_0.yuv"])
        output_0 =  Popen([encoderPath,"-vf",configurePath+"01cam1Diff.cfg","0"],stdout=PIPE).communicate()[0]
        output_1 =  Popen([encoderPath,"-vf",configurePath+"01cam1Diff.cfg","1"],stdout=PIPE).communicate()[0]
        lines = [line for line in output_1.split('\n') if "encoded" in line]
        #print lines
        psnrInfo = " ".join(lines[0].strip().replace("[","").replace("]","").split())
        Y = float(psnrInfo[20:27])
        U = float(psnrInfo[33:40])
        V = float(psnrInfo[46:53])
        avePsnrOver = (Y+U+V)/3
        print "Average PSNR = "+str(avePsnrOver)
        outFileOver.write(str(avePsnrOver)+"\n")

if __name__ == "__main__":
    sys.exit(main())

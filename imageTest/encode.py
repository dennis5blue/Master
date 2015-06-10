#!/usr/bin/python2.7

from subprocess import Popen, PIPE
from subprocess import call
import re
import sys

encoderPath = "/home/dennisyu/Documents/JMVC/bin/H264AVCEncoderLibTestStaticd"
configurePath = "./cfg/"
yuvPath = "./yuv/"
outputPath = "./"
	
# Correlation discovering
def corrDiscover(encodeCam, processList, outFile):
    print "Encoding Camera: ",encodeCam
    idx = int(re.sub(r'camera_|\.yuv','',encodeCam))
    print "idx = "+str(idx)
	
    for cam in processList:
        refIdx = int(re.sub(r'camera_|\.yuv','',cam))
        refCam = cam
        call(["rm","./cam"+str(idx)+"tmp_0.yuv","./cam"+str(idx)+"tmp_1.yuv"])
        call(["rm","./cam"+str(idx)+"rec_0.yuv","./cam"+str(idx)+"rec_1.yuv"])
	call(["rm","./cam"+str(idx)+"stream_0.264","./cam"+str(idx)+"stream_1.264"])
	call(["rm","./cam"+str(idx)+"tmp_0.yuv","./cam"+str(idx)+"tmp_1.yuv"])
	call(["cp",yuvPath+refCam, "./cam"+str(idx)+"tmp_0.yuv"])
	output_0 =  Popen([encoderPath,"-vf",configurePath+"01cam"+str(idx)+"Diff.cfg","0"],stdout=PIPE).communicate()[0]
	call(["cp",yuvPath+encodeCam, "./cam"+str(idx)+"tmp_1.yuv"])
	output_1 =  Popen([encoderPath,"-vf",configurePath+"01cam"+str(idx)+"Diff.cfg","1"],stdout=PIPE).communicate()[0]
		
	print "ref: ", refCam,"code: ", encodeCam
	lines = [line for line in output_1.split('\n') if "byte" in line]
	print lines
	byteInfo = " ".join(lines[0].strip().replace("[","").replace("]","").split())
	outFile.write("Ref "+str(refIdx)+" Code: "+str(idx)+" "+byteInfo+"\n")


def main(argv = None): 
    if sys.argv[1].startswith('--'):
        option = sys.argv[1][2:]
	if option == "yuv":
            encodeCam = sys.argv[2]
        else:
            print "Error: please verify the input yuv file"
            exit()
	output = Popen(["ls", yuvPath],stdout=PIPE).communicate()[0] 
	fileList = output.split('\n')
	fileList = filter(None,fileList)
        print "fileList = "
	print fileList
        print "\n"
		
        call(["rm","./rec_0.yuv","./rec_1.yuv"])
	outFile = open(outputPath+"_camera_"+str(1)+".out","w+")
	corrDiscover(encodeCam, fileList, outFile)
        
if __name__ == "__main__":
    sys.exit(main())

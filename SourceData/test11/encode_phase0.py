#!/usr/bin/python2.7

from subprocess import Popen, PIPE
from subprocess import call
import re
import sys

encoderPath = "/home/dennisyu/Documents/JMVC/bin/H264AVCEncoderLibTestStaticd"
configurePath = "./cfg/"
yuvPath = "./yuv/"
outputPath = "./outFiles/rng32/"

# Independent coding
def idtCoding(processList, outFile):
    output = ""
    for i in range(len(processList)):
        cam = "camera_"+str(i+1)+".yuv"
        call(["cp",yuvPath+cam, "./jmvcTempFiles/tmp_0.yuv"])
	print(yuvPath+cam)
	output = Popen([encoderPath,"-vf",configurePath+"01Ex4Idt.cfg","0"],stdout=PIPE).communicate()[0]
	print (output)        
	print "encode: ", i
	lines = [line for line in output.split('\n') if "byte" in line]
	byteInfo = " ".join(lines[0].strip().replace("[","").replace("]","").split())
	outFile.write(" Code: "+str(i)+" "+byteInfo+"\n")

def main(argv = None): 
    output = Popen(["ls", yuvPath],stdout=PIPE).communicate()[0] 
    fileList = output.split('\n')
    fileList = filter(None,fileList)
    #print (fileList)
    call(["rm","./jmvcTempFiles/*.yuv","./jmvcTempFiles/*.264"])
    outFile = open(outputPath+"phase_"+str(0)+".txt","w+")
    result = idtCoding(fileList, outFile)
        
if __name__ == "__main__":
    sys.exit(main())

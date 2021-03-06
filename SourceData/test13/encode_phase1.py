#!/usr/bin/python2.7

from subprocess import Popen, PIPE
from subprocess import call
import re
import sys

encoderPath = "/home/dennisyu/Documents/JMVC/bin/H264AVCEncoderLibTestStaticd"
configurePath = "./cfg/"
yuvPath = "./yuv/"
outputPath = "./outFiles/"
	
# Correlation discovering
def corrDiscover(encodeCam, processList, outFile, degree):
    print "Encoding Camera: ",encodeCam
    idx = int(re.sub(r'camera_|\.yuv','',encodeCam))
    #print "idx = "+str(idx)
    subYuvPath = yuvPath+str(degree)+"/"
	
    for i in range(len(processList)):
        refIdx = i+1
        #print refIdx
        refCam = "camera_"+str(refIdx)+".yuv"
        call(["rm","./jmvcTempFiles/cam"+str(idx)+"tmp_0.yuv","./jmvcTempFiles/cam"+str(idx)+"tmp_1.yuv"])
        call(["rm","./jmvcTempFiles/cam"+str(idx)+"rec_0.yuv","./jmvcTempFiles/cam"+str(idx)+"rec_1.yuv"])
	call(["rm","./jmvcTempFiles/cam"+str(idx)+"stream_0.264","./jmvcTempFiles/cam"+str(idx)+"stream_1.264"])
	call(["rm","./jmvcTempFiles/cam"+str(idx)+"tmp_0.yuv","./jmvcTempFiles/cam"+str(idx)+"tmp_1.yuv"])
	call(["cp",subYuvPath+refCam, "./jmvcTempFiles/cam"+str(idx)+"tmp_0.yuv"])
	output_0 =  Popen([encoderPath,"-vf",configurePath+"01cam"+str(idx)+"Diff.cfg","0"],stdout=PIPE).communicate()[0]
	call(["cp",subYuvPath+encodeCam, "./jmvcTempFiles/cam"+str(idx)+"tmp_1.yuv"])
	output_1 =  Popen([encoderPath,"-vf",configurePath+"01cam"+str(idx)+"Diff.cfg","1"],stdout=PIPE).communicate()[0]
		
	print "ref: ", refCam,"code: ", encodeCam
	lines = [line for line in output_1.split('\n') if "byte" in line]
	#print lines
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
        for degree in [0,5,10,15,20,25,30,35,40,45]:
	    output = Popen(["ls", yuvPath+str(degree)+"/"],stdout=PIPE).communicate()[0] 
	    fileList = output.split('\n')
	    fileList = filter(None,fileList)
            print "Degree = "+str(degree)
            print "fileList = "
	    print fileList
            print "\n"
            idx = int(re.sub(r'camera_|\.yuv','',encodeCam))	
            call(["rm","./jmvcTempFiles/rec_0.yuv","./jmvcTempFiles/rec_1.yuv"])
	    outFile = open(outputPath+str(degree)+"/camera"+str(idx)+"_phase"+str(1)+".txt","w+")
	    corrDiscover(encodeCam, fileList, outFile, degree)
        
if __name__ == "__main__":
    sys.exit(main())

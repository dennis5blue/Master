#!/usr/bin/python2.7

from subprocess import Popen, PIPE
from subprocess import call
import re
import sys

def main(argv=None):
	pngSeqPath = "./png/"
	yuvSeqPath = "./yuv/"
	
	output = Popen(["ls", pngSeqPath],stdout=PIPE).communicate()[0] 
	fileList = output.split('\n')
	fileList = filter(None,fileList)
 
	processList = len(fileList)*[None] 
	for i in range(len(fileList)):
		idx = int(re.sub(r'camera_|\.png','',fileList[i]))-1 # minus 1 since python index start at 0
		processList[idx] = re.sub(r'\.png','',fileList[i])
		#print (processList[idx])
		#print (len(processList))

	for i in range(len(fileList)):
        	print pngSeqPath+processList[i]+".png"
        	print yuvSeqPath+processList[i]+".yuv"
        	call(["/home/dennisyu/Documents/ffmpeg", "-s", "1280x720", "-pix_fmt", "yuv420p", "-i", pngSeqPath+processList[i]+".png", yuvSeqPath+processList[i]+".yuv"])
        	#call(["/home/dennisyu/Documents/ffmpeg","-i", "temp.mp4",yuvSeqPath+processList[i]+".yuv"])

if __name__ == "__main__":
	sys.exit(main())

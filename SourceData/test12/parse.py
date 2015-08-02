#!/usr/bin/python2.7

import re
import sys

def main(argv=None):
	indepFile = "./outFiles/phase_0.txt"
	corrFilePrefix = "./outFiles/camera"
	outFilePath = "./"

        N = 24 # number of cameras

	indepCompression = open(indepFile,"r")
	indepByte = open(outFilePath+"indepByte.txt","w+")

	lines = indepCompression.readlines();
	for line in lines:
		tokens = re.split(' |\[',line)
		tokens = filter(None,tokens);
		indepByte.write(str(int(tokens[7]))+'\n') #tokens[7] is number of Bytes if indep encoding

	for camera in range(N):
		corrCompression = open(corrFilePrefix+str(camera+1)+"_phase1.txt","r")
		corrMatrix = open(outFilePath+"corrMatrix.txt","a+")
		lines = corrCompression.readlines()
		for line in lines:
			tokens = re.split(' |\[',line)
			tokens = filter(None,tokens)
			corrMatrix.write(str(int(tokens[9]))+" ")
		corrMatrix.write('\n') #c_{ij} is obtain by Ref j to code i

if __name__ == "__main__":
	sys.exit(main())

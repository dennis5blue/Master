#!/usr/bin/python2.7

import re
import sys

def main(argv=None):
    inputFile = "./log.txt"
    outFilePath = "./"
    N = 30 # number of cameras

    log = open(inputFile,"r")
    camPos = open(outFilePath+"pos.txt","w+")
    camDir = open(outFilePath+"dir.txt","w+")

    counter = 1
    lines = log.readlines();
    for line in lines:
        if (counter % 2) == 0:
            tokens = re.split(' |\[',line)
            tokens = filter(None,tokens);
            #print tokens
            camPos.write(str(int(float(tokens[1])*100))+" "+str(int(float(tokens[2])*100))+'\n')
            camDir.write(str(float(tokens[7]))+'\n')
        else:
            ifPrint = 1
        counter += 1

if __name__ == "__main__":
    sys.exit(main())

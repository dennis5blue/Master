#!/usr/bin/python2.7

import re
import sys

def main(argv=None):
    for deg in [0,5,10,15,20,25,30,35,40,45]:
        inputFile = "./log_"+str(deg)+".txt"
        outFilePath = "./"
        N = 8 # number of cameras

        log = open(inputFile,"r")
        camPos = open(outFilePath+"pos_"+str(deg)+".txt","w+")
        camDir = open(outFilePath+"dir_"+str(deg)+".txt","w+")

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

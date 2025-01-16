#!/usr/bin/python3
import sys
import numpy as np

# need this snippet to calculate the principal axes of a set of points

if __name__ == '__main__':
    #sort out the given argument
    arrin = list(sys.argv[1].split(" "))    
    #take the input string, make into array, get eigenvectors out
    arr =  np.array(arrin[3:],dtype = float).reshape(int(arrin[1]),int(arrin[2]))
    val = np.concatenate((np.array([2,3,3]),list(np.linalg.eig(arr)[1].flatten())))
    #write to stdout
    sys.stdout.write(' '.join(str(i) for i in val))


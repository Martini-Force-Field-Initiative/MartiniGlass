#!/usr/bin/python3
# Copyright 2020 University of Groningen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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


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

import pathlib

def index_writing(system):
    """
    Write a .ndx file for a system without water
    Parameters
    ----------
    system: str
        the .gro file to read and write the non-water index for

    Returns
    -------

    """

    if system.suffix != ".gro":
        raise TypeError('Must provide a file in .gro format')

    print("Writing a waterless index file. Here're some helpful commands for reference:\n"
          "\tgmx trjconv -f traj_comp.xtc -s topol.tpr -pbc mol -n index.ndx -e 0 -o vis.gro\n"
          "\tgmx trjconv -f traj_comp.xtc -s topol.tpr -pbc mol -n index.ndx -o vis.xtc"
          )

    # read the file, take the number of the line if it doesn't have water in
    with open(f"{system}", 'r') as file:
        lines = file.readlines()
    # this skips the header and footer of the file
    file = [j for (j, k) in enumerate(lines[2:-1], start=1) if k[10:15].strip() != "W"]
    # split the lines every 12th index as gromacs requires
    lines_out = [file[x:x + 12] for x in range(0, len(file), 12)]

    # write the index file
    with open('index.ndx', 'w') as fout:
        fout.write('[ not water ]\n')
        for lineout in lines_out:
            fout.write(' '.join(map(str, lineout)) + ' \n')

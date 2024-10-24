# Copyright 2024 University of Groningen
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

import textwrap
import numpy as np


def parse_fixed_width_line(line):
    # fixed widths in a gro file
    field_widths = [5, 5, 5, 5, 8, 8, 8, 8, 8, 8]  # Field widths derived from the C format specifiers
    field_types = ['int', 'str', 'str', 'int', 'float', 'float', 'float', 'float', 'float', 'float']  # Data types
    fields = []
    start = 0
    for width, f_type in zip(field_widths, field_types):
        field = line[start:start+width].strip()  # Slice the line and strip spaces
        try:
            if f_type == 'int':
                fields.append(int(field))  # Convert to integer
            elif f_type == 'float':
                fields.append(float(field))  # Convert to float
            else:
                fields.append(field)  # Leave as string
        except ValueError:
            pass
        start += width
    return fields


def get_positions(coord_file):
    with open(coord_file, 'r') as f:
        lines = [parse_fixed_width_line(i)[4:7] for i in f.readlines()[2:-1]]  # gets the coordinates
    return np.array(lines)


def file_write(coord_file, topology_contents, bonds_dictionary, mol_lens):
    """
    coord file: input coordinate file of system
    topology_contents
    bonds_dictionary: dict
        dictionary of all index based external network bonds for all molecules in system
    mol_lens: dict
        dictionary of the number of nodes of each molecule
    """
    coords = get_positions(coord_file)

    # need to loop over this list because the order the topology file was processed in matters
    mols_list = [i['name'] for i in topology_contents['molecules']]

    cylinder_string = "\n"
    start = 0
    for mol in mols_list:
        entry = [i for i in topology_contents['molecules'] if i['name'] == mol]
        n_mols = entry[0]['n_mols']

        # this is the starting indices of each molecule in the system
        start_indices = np.arange(start, start+(int(n_mols) * int(mol_lens[mol])), int(mol_lens[mol]))
        start += int(n_mols) * int(mol_lens[mol])

        cylinder_string += f"\n# starting bonds for {mol} here"
        for bond in bonds_dictionary[mol]:

            starts = np.array(start_indices+bond[0])
            ends = np.array(start_indices+bond[1])
            coord_pairs = np.stack([[i, j] for i, j in zip(coords[starts], coords[ends])])

            for position in coord_pairs:
                # need the conversion here to make it back into gromacs for some reason
                pos0_str = ' '.join([f'{j*10:.3f}' for j in position[0]])
                pos1_str = ' '.join([f'{j*10:.3f}' for j in position[1]])

                cylinder_string += f'\ngraphics 0 cylinder "{pos0_str}" "{pos1_str}" radius $radius resolution 50'

    msg = textwrap.dedent(
                            """
                            # Colour of the cylinder. 16 is black.
                            set colorID 16
                        
                            # Cylinder radius 
                            set radius 0.3
                            
                            graphics 0 color $colorID"
                        
                            # Draw a cylinder between the points listed
                            {cylinders}
                            """
                            )

    with open('network_cylinders.tcl', 'w') as f:
        f.write(textwrap.dedent(msg.format(cylinders=cylinder_string)))

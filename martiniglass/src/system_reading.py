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

from vermouth.gmx import read_itp
from vermouth.forcefield import ForceField
from .topology import input_topol_reader
import re


def output_str(pairs):
    op_str = '{'
    for i in pairs:
        op_str += f'\u007b{i[0]} {i[1]}\u007d '
    return op_str[:-1] + '}'


def secondary_structure_parsing(lines, molname):

    header = []
    # this should ensure we only get the header
    for line in lines:
        if line[0] == ';':
            # ignore the ; at the start and the \n at the end
            header.append(line[1:-1].strip())
        else:
            break

    ss_string = ''
    # this should get the code
    for line in header:
        if line.upper() == line:
            ss_string = line

    helices = [i.span() for i in re.finditer('([H|G|I]{3,})', ss_string)]
    sheets = [i.span() for i in re.finditer('([B|E]{3,})', ss_string)]

    vmd_excl_str = ''
    for i in helices+sheets:
        vmd_excl_str += f'(resid > {i[0]} and resid < {i[1]}) or '
    vmd_excl_str = vmd_excl_str[:-4]

    hlx_col_str = ''
    for i in helices:
        hlx_col_str += f'(resid > {i[0]} and resid < {i[1]}) or '
    hlx_col_str = hlx_col_str[:-4]

    sht_col_str = ''
    for i in sheets:
        sht_col_str += f'(resid > {i[0]} and resid < {i[1]}) or '
    sht_col_str = sht_col_str[:-4]

    if len(helices) > 2 or len(sheets) > 2:
        with open(f'{molname}_cgsecstruct.txt', 'w') as f:
            f.write("suggested commands for viewing you molecule with cg_secondary_structure.tcl:\n")
            f.write(f'cg_helix {output_str(helices)} -hlxcolor "purple" -hlxfilled yes -hlxrad 3 -hlxmethod cylinder -hlxmat "AOChalky" -hlxres 50\n')
            f.write(f'cg_sheet {output_str(sheets)} -shtfilled "yes" -shtmat "AOChalky" -shtres 50 -shtcolor "red" -shtmethod flatarrow -shtarrwidth 5 -shtheadsize 10 -shtarrthick 3 -shtsides "sharp"\n')
            f.write('\nAdditionally, use the following command to remove the BB string from your molecule:\n')
            f.write(f'name BB and not ({vmd_excl_str})')
            f.write('\nThese commands will have to be modified to specify molid if you have multiple proteins in your system\n')
            f.write('\nAlternatively use the following to just colour the backbone:')
            f.write(f'\nhelices: name BB and ({hlx_col_str})')
            f.write(f'\nsheets: name BB and ({sht_col_str})')


def _misc_file_reader(lines):
    """
    Try to handle miscellaneous files which can't be read into the force field by read_itp

    Parameters
    ----------
    lines: list
        list of lines from the input .itp file


    Returns
    -------
    defines: dict
        dictionary of definition: parameters for bonded terms that have been externally defined
    others: list
        lines from an input itp that don't have #define in them

    if others == lines, None is returned, because the input file doesn't contain anything interesting
    """
    defines = {i.split()[1]: i.split(';')[0].split()[2:5] for i in lines if '#define' in i}
    others = [line for line in lines if '#define' not in line]
    if others == lines:
        return None
    else:
        return defines, others


def system_reading(topology):

    """
    read a .top file's contents into a ForceField
    """

    # get the topology file
    print(f"Reading input {topology}")
    topol_lines = input_topol_reader(topology)

    # for each molecule in the system, read in the itp
    d = {}
    for i, j in enumerate(topol_lines['core_itps']):
        with open(j) as f:
            d[i] = f.readlines()

    # read the molecules into the forcefield
    ff = ForceField('martini3001')

    system_defines = {}
    for i, j in enumerate(d.keys()):
        try:
            read_itp(d[j], ff)
            secondary_structure_parsing(d[j], list(ff.blocks)[-1])
        except OSError:
            '''
            if we can't read the file into the system directly, we have something that isn't strictly a molecule
            most likely its the force field definition file (eg. martini_v3.0.0.itp) but we can't be sure
            a common one is something with #defines in for generic molecule bonded terms
            '''
            misc_result = _misc_file_reader(d[j])
            if misc_result is None:
                # if [ defaults ] is found, then it's martini_v3.0.0.itp or similar. ignore it.
                if "[ defaults ]" not in [k.strip() for k in d[j]]:
                    print(f"Error reading {topol_lines['core_itps'][i]}. Will ignore and exclude from output system.")
            else:
                # this means we've separated things out successfully and can read the actual itp content now
                # tracking system_defines is useful for when we sort the #TODOs below.
                for key, value in misc_result[0].items():
                    system_defines[key] = value
                read_itp(misc_result[1], ff)

    return ff, topol_lines, system_defines

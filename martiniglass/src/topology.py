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

import os

def input_topol_reader(file):
    inclusions = []
    molecules = []
    system = []
    go = []
    # read the topology file, find the header lines which are not core martini itps
    with open(file) as f:
        mols = False
        sys = False
        for line in f.readlines():
            if '#include' in line:
                if 'go' not in line:
                    inclusions.append(line.split('"')[1])
                else:
                    go.append(line.split('"')[1])
            if mols:
                if len(line.split()) > 0:
                    molecules.append({'name': line.split()[0],
                                      'n_mols': line.split()[1]})
            if 'molecules' in line:
                mols = True
                sys = False
                system.append(line)
            if 'system' in line:
                sys = True
            if sys:
                system.append(line)
    topol_lines = {'core_itps': inclusions,
                   'system': system,
                   'molecules': molecules}

    if len(go) > 0:
        topol_lines['go'] = go

    return topol_lines


def topol_writing(topol_lines, written_mols, ext='vis', w_include=None):
    """

    Write new .top file based on the input one

    Parameters
    ----------
    topol_lines: dict
        lines from the input topology file split up into different keys, as per input_topol_reader
    ext: str
        the extension to use in looking for new file names to add to the output .top file
    w_include
        if W_include is not None (ie. args.system has been given something)
        then the line for water is not written out in the .top file

    Returns
    -------
    None
    """
    # this will write everything and is gross but it should work
    # because everything will be included
    new_topol_head = []
    # make a new header for the .top file to write the absolute paths
    # for i in topol_lines['core_itps']:
    #     new_topol_head.append(f'#include "{os.path.abspath(i)}"\n')
    # get the new vis files to write for the topology header
    for i in written_mols:
        new_topol_head.append(f'#include "{os.path.abspath(i)}"\n')

    # correct the [ molecules ] directive of the top file to correct for the new molecule names.
    topol_rest_vis = []
    original_mols = [i.split(f'_{ext}')[0] for i in written_mols]
    if w_include is not None:
        try:
            original_mols.remove('W')
        except ValueError:
            print('No water to remove!')
            pass
    for i in topol_lines['molecules']:
        if any(mol in i['name'] for mol in original_mols):
            topol_rest_vis.append(i['name'] + f'_{ext}\t' + i['n_mols'] + '\n')
    # combine the sections of the vis.top and write it out.
    vis_topol = new_topol_head + topol_lines['system'] + topol_rest_vis

    with open(f'{ext}.top', 'w') as f:
        f.writelines(vis_topol)


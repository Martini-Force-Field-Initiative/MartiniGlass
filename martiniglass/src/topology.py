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

import os
from vermouth.parser_utils import split_comments


def input_topol_reader(file):
    """
    Read a GROMACS .top file and extract include paths, system section, and
    molecule list.

    Parameters
    ----------
    file: str or path-like
        Path to the .top file.

    Returns
    -------
    dict with keys:
        'core_itps': list[str]
            Absolute paths of all ``#include``d files, resolved relative to
            the directory containing ``file``.
        'system': list[str]
            Original lines of the ``[ system ]`` section plus the
            ``[ molecules ]`` header line (used verbatim when writing output).
        'molecules': list[dict]
            One ``{'name': str, 'n_mols': str}`` entry per molecule entry in
            the ``[ molecules ]`` section.
    """
    top_dir = os.path.dirname(os.path.abspath(file))

    inclusions = []
    molecules = []
    system = []
    current_section = None

    with open(file, encoding='utf-8') as f:
        for line in f:
            # Strip inline ';' comments; keep the original line for verbatim output.
            data, _ = split_comments(line, ';')

            # --- preprocessor directives -----------------------------------------
            if data.startswith('#'):
                if data.startswith('#include'):
                    parts = data.split('"')
                    if len(parts) >= 2:
                        include_path = parts[1]
                        resolved = os.path.normpath(os.path.join(top_dir, include_path))
                        inclusions.append(resolved)
                # All other directives (#define, #ifdef, …) are skipped.
                continue

            # Skip blank lines (after comment stripping).
            if not data:
                continue

            # --- section headers --------------------------------------------------
            if data.startswith('[') and data.endswith(']'):
                section_name = data.strip('[ ]').casefold()
                if section_name == 'moleculetype':
                    raise IOError(
                        "Your topology file contains [ moleculetype ] directives, "
                        "which this file parser cannot process. Please split your "
                        "system into multiple itp files."
                    )
                current_section = section_name
                # Collect the header line verbatim for sections needed in output.
                if current_section in ('system', 'molecules'):
                    system.append(line)
                continue

            # --- section content --------------------------------------------------
            if current_section == 'system':
                system.append(line)
            elif current_section == 'molecules':
                parts = data.split()
                if len(parts) >= 2:
                    molecules.append({'name': parts[0], 'n_mols': parts[1]})

    return {'core_itps': inclusions,
            'system': system,
            'molecules': molecules}


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
            # print('No water to remove!')
            pass
    for i in topol_lines['molecules']:
        if any(mol in i['name'] for mol in original_mols):
            topol_rest_vis.append(i['name'] + f'_{ext}\t' + i['n_mols'] + '\n')
    # combine the sections of the vis.top and write it out.
    vis_topol = new_topol_head + topol_lines['system'] + topol_rest_vis

    with open(f'{ext}.top', 'w', encoding='utf-8') as f:
        f.writelines(vis_topol)


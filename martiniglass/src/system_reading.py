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

from vermouth.gmx import read_itp
from vermouth.forcefield import ForceField
from .topology import input_topol_reader
from vermouth.parser_utils import split_comments
from os.path import exists
import re


def output_str(pairs):
    op_str = '{'
    for i in pairs:
        op_str += f'\u007b{i[0]} {i[1]}\u007d '
    return op_str[:-1] + '}'


def secondary_structure_parsing(lines, molname):

    # stop if we've already looked at this block
    if exists(f'{molname}_cgsecstruct.txt'):
        return

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
        with open(f'{molname}_cgsecstruct.txt', 'w', encoding='utf-8') as f:
            f.write("suggested commands for viewing you molecule with cg_bonds-v6.tcl:\n")
            f.write(f'cg_helix {output_str(helices)} -hlxcolor "purple" -hlxfilled yes -hlxrad 3 -hlxmethod cylinder -hlxmat "AOChalky" -hlxres 50\n')
            f.write(f'cg_sheet {output_str(sheets)} -shtfilled "yes" -shtmat "AOChalky" -shtres 50 -shtcolor "red" -shtmethod flatarrow -shtarrwidth 5 -shtheadsize 10 -shtarrthick 3 -shtsides "sharp"\n')
            f.write('\nAdditionally, use the following command to remove the BB string from your molecule:\n')
            f.write(f'name BB and not ({vmd_excl_str})')
            f.write('\nThese commands will have to be modified to specify molid if you have multiple proteins in your system\n')
            f.write('\nAlternatively use the following to just colour the backbone:')
            f.write(f'\nhelices: name BB and ({hlx_col_str})')
            f.write(f'\nsheets: name BB and ({sht_col_str})')


def _collect_defines(lines):
    """
    Scan *lines* for ``#define`` directives and return a mapping of macro
    name to the list of replacement tokens.

    Uses ``split_comments`` to strip inline ``;`` comments before
    matching, so macro-looking text inside comments is not collected.
    Returns an empty dict if no ``#define`` directives are present.

    Parameters
    ----------
    lines: list[str]

    Returns
    -------
    dict[str, list[str]]
    """
    defines = {}
    for line in lines:
        data, _ = split_comments(line, ';')
        if data.startswith('#define'):
            parts = data.split()
            if len(parts) >= 3:
                defines[parts[1]] = parts[2:]
    return defines


def _substitute_defines(ff, defines):
    """
    Expand single-token ``#define`` macro parameters in every interaction
    stored in *ff* using the mapping in *defines*.

    After ``read_itp`` parses a molecule whose interaction lines reference
    ``#define``d names (e.g. ``b_RIB1_RIB2``), those names are stored
    verbatim as single-element parameter lists.  This function replaces
    them with the actual token lists collected from the force-field
    parameter files.

    Parameters
    ----------
    ff: vermouth.forcefield.ForceField
    defines: dict[str, list[str]]
    """
    if not defines:
        return
    for block in ff.blocks.values():
        for interactions in block.interactions.values():
            for idx, interaction in enumerate(interactions):
                params = interaction.parameters
                if len(params) == 1 and params[0] in defines:
                    interactions[idx] = interaction._replace(
                        parameters=list(defines[params[0]])
                    )


def system_reading(topology):
    """
    Read a .top file's contents into a ForceField.
    """
    print(f"Reading input {topology}")
    topol_lines = input_topol_reader(topology)

    # Load all included ITP files.
    d = {}
    for i, path in enumerate(topol_lines['core_itps']):
        try:
            with open(path, encoding="utf-8") as f:
                d[i] = f.readlines()
        except FileNotFoundError:
            raise FileNotFoundError(
                f"Could not find included file '{path}'. "
                "Check that all #include paths in your .top file are correct."
            )

    ff = ForceField('martini3001')
    system_defines = {}

    for i, lines in enumerate(d.values()):
        try:
            read_itp(lines, ff)
            for molname in ff.blocks.keys():
                secondary_structure_parsing(lines, molname)
        except OSError:
            # File isn't a parseable molecule ITP — could be a force-field
            # definition file ([ defaults ]) or a file of #define macros for
            # bonded parameters.  Collect any macros and, if molecule content
            # is present alongside them, try to parse it without the defines.
            defines = _collect_defines(lines)
            system_defines.update(defines)

            if not defines:
                # No macros — probably a force-field file (martini_v3.0.0.itp).
                if not any('[ defaults ]' in l for l in lines):
                    print(f"Error reading {topol_lines['core_itps'][i]}."
                          " Will ignore and exclude from output system.")
                continue

            # Strip #define lines and attempt to parse any molecule content
            # that may be present in the same file alongside the defines.
            non_define_lines = [
                l for l in lines
                if not split_comments(l, ';')[0].startswith('#define')
            ]
            try:
                read_itp(non_define_lines, ff)
            except OSError:
                pass  # No parseable molecule content — expected for ff parameter files.

    # Substitute #define macro names with their actual parameter values in
    # every interaction that was read from the molecule ITP files.
    _substitute_defines(ff, system_defines)

    return ff, topol_lines, system_defines

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

from vermouth.gmx import write_molecule_itp

def go_writer(ff, molname, go_bonds, ext):
    """
    write a go network only topology for a particular molecule

    Parameters
    ----------
    ff: vermouth forcefield
        vermouth force field containing the input system
    molname: str
        name of the molecule to separate out
    go_bonds: list
        list of go  bonds to write out

    Returns
    -------
    None
    """
    # remove all interactions from the molecule
    for interaction_type in list(ff.blocks[molname].interactions):
        del ff.blocks[molname].interactions[interaction_type]

    # add the elastic network bonds back in
    for bond in go_bonds:
        ff.blocks[molname].add_interaction('bonds', [bond[0], bond[1]], list(bond[2:]))

    # write the file out
    mol_out = ff.blocks[molname].to_molecule()
    mol_out.meta['moltype'] = molname + '_go'

    if ext:

        ext_bonds_list = [i.atoms for i in mol_out.interactions['bonds']]
        stout = ''.join([f'{i[0]}\t{i[1]}\n' for i in ext_bonds_list])
        with open(f'{molname}_go_bonds.txt', 'w') as bonds_list_out:
            bonds_list_out.write(stout)

    header = [f'Elastic network topology for {molname}', 'NOT FOR SIMULATIONS']

    with open(molname + '_go.itp', 'w') as fout:
        write_molecule_itp(mol_out, outfile=fout, header=header)
        return fout.name
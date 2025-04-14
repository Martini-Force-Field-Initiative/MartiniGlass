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

from vermouth.gmx import write_molecule_itp
import networkx as nx


def network_writer(ff, molname, bonds, ext, network_type):
    """
    write an elastic network only topology for a particular molecule

    Parameters
    ----------
    ff: vermouth forcefield
        vermouth force field containing the input system
    molname: str
        name of the molecule to separate out
    bonds: list
        list of elastic/Go network bonds to write out
    network_type: str
        should be either "Go" or "elastic" to denote the name of the network

    Returns
    -------
    None
    """
    graph = nx.Graph()
    graph.add_nodes_from(ff.blocks[molname].nodes)
    graph.add_edges_from(bonds)

    removed = []

    '''
    for each node in the graph, check its degree
    if its degree is > 12, remove the 'excess' number of edges from
    that node
    '''
    for node in graph.nodes:
        degree = graph.degree[node]
        to_remove = degree - 12
        if to_remove > 0:
            removal_list = list(graph.edges(node))[:to_remove]
            removed.append([sorted(i) for i in removal_list])
            graph.remove_edges_from(removal_list)

    all_removed = sorted([i for j in removed for i in j])

    assert max([graph.degree[node] for node in graph.nodes]) < 13

    for interaction_type in list(ff.blocks[molname].interactions):
        del ff.blocks[molname].interactions[interaction_type]

    for bond in graph.edges:
        ff.blocks[molname].add_interaction('bonds', [bond[0], bond[1]], ['1', '1', '1000'])

    if len(all_removed) > 0:
        with open(molname + f'_surplus_{network_type}.txt', 'w') as extra_en:
            if network_type == 'en':
                network_type_write = "elastic"
            elif network_type == 'go':
                network_type_write = "go"
            extra_en.writelines(f"{network_type_write} network bonds removed from {molname}_{network_type}.itp\n"
                                "This is for noting in visualisation, not for simulation\n\n"
                                f"These bonds will be missing if you load {molname}_{network_type}.itp in vmd\n"
                                "having been present in your simulation. If you're inspecting your\n"
                                f"{network_type_write} network because you suspect some simulation error\n"
                                f"as a result of how it was constructed, bear this in mind.\n\n"
                                "This has been done because by default VMD does not draw more than 12 bonds\n"
                                "per atom in an interactive manner (i.e. the bonds are not rendered as static geometry).\n"
                                "To view all bond (in a static manner) the bonds can be rendered using the -cyl flag of MartiniGlass.")

            extra_en.write('     i      j func b0 kb\n')

            for i in all_removed:
                extra_en.writelines(f'{i[0]:6d}\t{i[1]:6d}\n')

    # write the file out
    mol_out = ff.blocks[molname].to_molecule()
    mol_out.meta['moltype'] = molname + f'_{network_type}'

    if ext:

        ext_bonds_list = [i.atoms for i in mol_out.interactions['bonds']]
        stout = ''.join([f'{i[0]}\t{i[1]}\n' for i in ext_bonds_list])
        with open(f'{molname}_{network_type}_bonds.txt', 'w') as bonds_list_out:
            bonds_list_out.write(stout)

    header = [f'{network_type} network topology for {molname}', 'NOT FOR SIMULATIONS']

    with open(molname + f'_{network_type}.itp', 'w') as fout:
        write_molecule_itp(mol_out, outfile=fout, header=header)

    return fout.name

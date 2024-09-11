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
import networkx as nx

def en_writer(ff, molname, en_bonds, ext):
    """
    write an elastic network only topology for a particular molecule

    Parameters
    ----------
    ff: vermouth forcefield
        vermouth force field containing the input system
    molname: str
        name of the molecule to separate out
    en_bonds: list
        list of elastic network bonds to write out

    Returns
    -------
    None
    """
    # remove all interactions from the molecule
    for interaction_type in list(ff.blocks[molname].interactions):
        del ff.blocks[molname].interactions[interaction_type]

    # add the elastic network bonds back in
    edges = []
    for bond in en_bonds:
        edges.append(bond.atoms)
        ff.blocks[molname].add_interaction('bonds', bond.atoms, bond.parameters)

    # make a graph, look at the degrees of the nodes
    graph = nx.Graph()
    graph.add_nodes_from(ff.blocks[molname].nodes)
    graph.add_edges_from(edges)
    degrees = [graph.degree[node] for node in graph.nodes]
    # handle the points where more EN bonds have been written than VMD can handle (12)
    if any([i > 12 for i in [graph.degree[node] for node in graph.nodes]]):

        print(f"There are atoms in {molname} which have > 12 elastic network bonds."
              " Some will be removed and recorded for posterity")

        over_limit_ind = []
        over_limit_num = []
        for i, j in enumerate(degrees):
            if j > 12:
                over_limit_ind.append(i)
                over_limit_num.append(j-12)

        l0 = []
        l1 = []
        l2 = []
        for interaction in ff.blocks[molname].interactions['bonds']:
            cond0 = (interaction.atoms[0] in over_limit_ind)
            cond1 = (interaction.atoms[1] in over_limit_ind)
            if cond0 and not cond1:
                l0.append([interaction, interaction.atoms[0]])
            elif cond1 and not cond0:
                l1.append([interaction, interaction.atoms[1]])
            elif cond0 and cond1:
                l2.append([interaction, interaction.atoms[0], interaction.atoms[1]])
        all_interactions = [i[0] for i in l0]+[i[0] for i in l1]+[i[0] for i in l2]+[i[0] for i in l2]
        all_indices = [i[1] for i in l0]+[i[1] for i in l1]+[i[1] for i in l2]+[i[2] for i in l2]
        sorted_indices_interactions = [list(x) for x in sorted(zip(all_indices, all_interactions),
                                                               key=lambda pair: pair[0])]

        # make sure we have a consistent set of indices to remove edges from
        s0 = set([x[0] for x in sorted_indices_interactions])
        s1 = set(over_limit_ind)

        assert s0.difference(s1) == s1.difference(s0)

        removed = []
        sorted_atoms = [x[0] for x in sorted_indices_interactions]
        sorted_interactions = [x[1] for x in sorted_indices_interactions]
        print_err = True
        for index, value in enumerate(over_limit_ind):
            inds = [i for i, x in enumerate(sorted_atoms) if x == value]
            r_inds = iter(range(len(inds)))
            target = over_limit_num[index]
            target_interactions = [sorted_interactions[i] for i in inds]

            while target > 0:
                try:
                    i = next(r_inds)
                    removed.append(target_interactions[i])
                    graph.remove_edge(target_interactions[i].atoms[0],
                                      target_interactions[i].atoms[1]
                                      )
                    ff.blocks[molname].remove_interaction('bonds', target_interactions[i].atoms)
                    target -= 1
                except nx.exception.NetworkXError:
                    if print_err:
                        print('Something went wrong while removing excess elastic network bonds.'
                              ' This is a placeholder statement while things are fixed.')
                    print_err = False
                    pass

        try:
            assert not any([i > 12 for i in [graph.degree[node] for node in graph.nodes]])
        except AssertionError:
            print("Couldn't remove all bonds necessary, probably can't network in VMD")

        with open(molname + '_surplus_en.txt', 'w') as extra_en:
            extra_en.write(f'Elastic network bonds removed from {molname}_en.itp\n')
            extra_en.write('This is for noting in visualisation, not for simulation\n\n')
            extra_en.write(f'These bonds will be missing if you load {molname}_en.itp in vmd\n')
            extra_en.write("having been present in your simulation. If you're inspecting your\n")
            extra_en.write('elastic network because you suspect some error because of it, bear this in mind.\n')

            extra_en.write('   i    j func b0 kb\n')

            for i in removed:
                extra_en.writelines(f'{i.atoms[0]:4d} {i.atoms[1]:4d} ' +
                                    f'{i.parameters[0]:1s} {i.parameters[1]:5s} {i.parameters[2]:5s}' +
                                    '\n')

    # write the file out
    mol_out = ff.blocks[molname].to_molecule()
    mol_out.meta['moltype'] = molname + '_en'

    if ext:

        ext_bonds_list = [i.atoms for i in mol_out.interactions['bonds']]
        stout = ''.join([f'{i[0]}\t{i[1]}\n' for i in ext_bonds_list])
        with open(f'{molname}_elastic_bonds.txt', 'w') as bonds_list_out:
            bonds_list_out.write(stout)

    header = [f'Elastic network topology for {molname}', 'NOT FOR SIMULATIONS']

    with open(molname + '_en.itp', 'w') as fout:
        write_molecule_itp(mol_out, outfile=fout, header=header)
        return fout.name

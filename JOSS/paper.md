---
title: 'MartiniGlass: a tool for enabling visualisation of coarse-grained Martini topologies'
tags:
  - Python
  - Molecular Dynamics
  - Visualisation
  - Martini
authors: 
  - name: Christopher Brasnett
    orcid: 0000-0001-9235-1673
    affiliation: 1
  - name: Siewert Jan Marrink
    orcid: 0000-0001-8423-5277
    affiliation: 1
affiliations:
 - name: Groningen Biomolecular Sciences and Biotechnology Institute, University of Groningen, Nijenborgh 7, 9747 AG Groningen, The Netherlands
   index: 1
date: 11 September 2024
bibliography: paper.bib

---

# Introduction

Coarse-grained molecular dynamics simulations have significant advantages over higher resolution ones 
in accessing timescales and processes that are otherwise difficult to reach 
[@borges-araujo_pragmatic:2023; @souza:2021]. However, in communicating the results of coarse-grained 
simulations, the use of standard simulation visualisation software such as VMD [@humphrey:1996] can 
prove challenging. With atomistic structures, bonds can be drawn automatically between atoms based on either 
distance recognition or bonded information in structure files. Such automated methods are not possible at 
coarse-grained resolutions, as the apparent atoms (i.e. coarse-grain beads) in the system are necessarily 
further apart, and bonded information is not (usually) stored in trajectory files. Users can overcome this 
challenge by various means, whether by representing their molecules as a series of overlapping spheres to make 
it looked joined (figure \autoref{fig:fig1} A-C), or in the case of coarse-grained proteins, by laborious editing of pdb files 
to ensure that CONECT records are written for the necessary bonds.


Here, we present a tool, MartiniGlass, which facilitates the better visualisation of simulations with the 
Gromacs software using the popular Martini forcefield 
[@abraham:2015; @marrink:2023; @souza:2021]. MartiniGlass was chosen as a name because 
without a glass, you can neither see nor drink a martini of your choice. The tool enables molecules to be 
visualised as continuous chains using the licorice or CPK styles of VMD (figure \autoref{fig:fig1} D,E). MartiniGlass builds 
on previous work using a tcl script, cg_bonds, which had drawn both bonds and tertiary structure restraints 
by reading topology information from simulation files (“CG bonds,” n.d.). Alternatively in the case of tertiary
structure, the apparent bonds could also be illustrated using in-script calculation. In recent years, however,
the use and maintenance of this script has proven increasingly challenging for two principal reasons. Firstly, 
the format of Gromacs topology (tpr) files changes with each release, so reading topology information from the 
gmx dump tool requires regular updating. Secondly, many of the new models that have been developed for the 
latest version of Martini force field now make extensive use of topology constructs such as virtual sites, 
which are not trivial to read from topology information
[@borges-araujo_martini:2023; @grunewald:2022; @vainikka:2023; @vainikka:2021].

![Figure 1. Examples of visualisation of Martini molecules. A-C) using spheres to represent coarse-grained beads.
A) DNA, B) ErbB1 TM domains in a lipid bilayer, C) a TDP-43 protein 
[@ingolfsson:2023; @javanainen:2017; @uusitalo:2015]. D,E) a condensate of proteins 
illustrated with D) spheres, and E) licorice styles, demonstrating the cleaner appearance of a continuous
style in dense linked systems. \label{fig:fig1}](figures/fig1.png)


# MartiniGlass


![Figure 2. Visualisation of coarse-grained proteins. A,B) Choosing how to illustrate virtual sites in a 
short peptide. A) the virtual site of the tryptophan side chain is illustrated with a transparent bead, 
and all other bonds are illustrated as usual. B) Using the default behaviour of MartiniGlass, the virtual 
site has bonds drawn to its constructing atoms. C-G) Ubiquitin (PDB code: 1UBQ) illustrated atomistically 
with secondary structure (C), the coarse-grained model overlaid (D), and with the elastic network (E). F) 
shows the coarse-grained protein and elastic network on its own, while G) shows the Gō model for the same 
protein, complete with the virtual backbone sites where the network arises from. \label{fig:fig2}](figures/fig2.png)

Beyond the challenges in visualising direct topology information, Martini protein models continue to make use 
of tertiary structure constraints through various means such as elastic networks, Gō models, and pair 
potentials between native contacts [@pedersen:2024; @periole:2009; @souza:2024]. 
Understanding the restraints that these networks put on simulation input models, and their physical 
relevance to the underlying protein structure can be an important challenge in optimising models. For
example, the initial input structure to a program such as martinize2 (which generates Martini protein
topologies) may result in elastic network bonds being drawn between folded and disordered domains of a 
protein, because they happen to be close in a starting structure [@kroon:2022]. In reality - and 
in atomistic simulations - the two domains would likely move apart after a short space of time and no such 
bond should be generated in the first place, highlighting the need for visual checks during optimisation. 

Drawing these networks then is an important consideration in the visualisation of coarse-grained Martini 
proteins, but is also a further challenge in visualisation. The so-called bonds in these networks have i) 
significantly longer lengths, and ii) are explicitly not drawn between numerically adjacent atoms from the
structure file, and are therefore only included in the topology information. The recent development of the
MArtini Database Server (MAD) for interactive generation of Martini proteins has gone some way to helping 
users refine the initial topologies generated by martinize2 [@hilpert:2023]. MAD allows users to 
interact with the generated elastic network through a visualisation facilitated by the online NGL Viewer
package, so users can choose, add or delete elastic network bonds as they require [@rose:2015].
Externally to the MAD, NGL viewer offers some automatic detection of coarse grained bonds, but has drawbacks 
in necessarily being used via online notebooks, and does not easily facilitate viewing of secondary structure
networks.

MartiniGlass overcomes the issues of visualisation discussed above by processing topology files for the
system of interest for ready and rapid local viewing in VMD. The new topology files are based on the bonded
information present in the simulation input files, and pared down to exclude information not relevant for 
the purposes of visualisation. Moreover, it flexibly handles topology aspects such as virtual sites, and
makes it possible to also separately superimpose the tertiary structure restraints of proteins. 

Topology processing is made possible by the use of the Vermouth library, primarily developed to power 
martinize2, but with further topology processing and manipulation functionalities [@kroon:2022]. 
At its simplest, MartiniGlass reads a simulation system topology (.top) file, and processes all the included 
topology (.itp) files describing the molecules present in the system. After processing, the program writes 
out both the system and included topology information for the dedicated visualisation topologies for viewing
in VMD. Viewing in VMD is still fundamentally facilitated by the cg_bonds tcl script, the latest version of 
which has been optimised for use in conjunction with MartiniGlass. For ease of reference, both the cg_bonds 
and an associated vmd visualisation state can be written locally when MartiniGlass is executed.

Visualisation topologies contain only three Gromacs directives: the molecule type, atoms, and bonds 
[@abraham:2015]. As no other topology information is required for visualisation, they are removed
from the molecule description. However, this requires decisions to be made about how some of the challenges
discussed above are to be addressed. In the case of virtual sites, users are able to decide whether virtual
sites should have bonds drawn between them and all their constructing atoms, or left as free-floating, 
which in certain cases may be more desirable (figure \autoref{fig:fig2}A,B). 

The most significant feature that MartiniGlass enables in topology handling is the distinction of 
tertiary structure networks for protein models (figure \autoref{fig:fig2}C-F). If the requisite process is specified,
MartiniGlass will generate separate topology files for the direct bonded network of a protein, and its
tertiary structure non-bonded interactions (in the case of Gō or OLIVE models) or bonds (in the case of
elastic networks). Where the tertiary structure is maintained by specific non-bonded interactions, 
non-bonded interactions are read from the associated file and converted to bonds in an input topology 
file distinct from the direct bonded network of the protein. For elastic networks, elastic bonds are 
firstly identified by the unique force constant that is specified by martinize2. Once these bonds have
been identified, MartiniGlass will perform additional checks on the elastic network to ensure that the
model can be viewed in VMD. VMD has an upper limit - 12 - on the possible number of bonds an atom can 
have. As elastic networks generated by martinize2 are drawn arbitrarily by a distance cut off, it is
possible for backbone atoms to have more than 12 bonds, causing a fault in the visualisation. In cases
where more than 12 bonds are found, the network is edited to ensure that apparent excess bonds are removed
and noted, enabling straightforward visualisation of the elastic network in VMD. As tertiary structure bond
networks are written separately to the principle topology of the protein, they can be loaded into VMD 
separately, and switched on and off in visualisations as required. 

A further challenge for the visualisation of coarse grained proteins is indicating their secondary 
structure. This was also facilitated by a second tcl script to draw basic geometric objects in the 
place of secondary structure elements. Examples of how this information can be visualised are shown 
in figure \autoref{fig:fig3}, either through the additional overlay of objects representing secondary structure, or 
by recolouring parts of the backbone of the protein. When protein topologies with secondary structure
information are provided to MartiniGlass, information about how to conduct such visualisations are 
written for users to use as they wish.


![Figure 3: Visualising secondary structure elements of a protein. A) UBQ1 shown as a continuous backbone 
ribbon. B) Coloured by secondary structure (helices in purple, sheets in red). C) Arrows (for sheets) 
and cylinders (for helices) overlaid on a backbone ribbon. D) As in C, but with backbone removed from 
underneath the overlaid geometry objects. \label{fig:fig3}](figures/fig3.png)

![Figure 4: Non-protein systems. A) The molecular motor of Vainikka and Marrink, a synthetic molecule with
complex topology, showing the how the beads are connected [@vainikka:2023]. B) Several 
molecular motors together with a lipid bilayer of several different lipid types. 
 \label{fig:fig4}](figures/fig4.png)


| Description                                                                                                                           | Command                                  |
|---------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------|
| Basic execution                                                                                                                       | `MartiniGlass -p topol.top`              |
| Output a non-water index file for trajectory processing                                                                               | `MartiniGlass -p topol.top -f frame.gro` |
 | Don’t write bonds between virtual sites and their constructing atoms                                                                  | `MartiniGlass -p topol.top -vs`          |
| Process protein elastic networks (identified with a unique force constant of 500 kJ/mol/nm^2) into separate visualisation topologies  | `MartiniGlass -p topol.top -el -ef 500`  |
| Process Gō networks in proteins, as defined in nonbond.itp into separate visualisation topologies                                     | `MartiniGlass -p topol.top -go -gf nonbond.itp`                                         |
| Write out visualisation associated files (cg_bonds-v6.tcl, vis.vmd) in the current directory                                        | `MartiniGlass -p topol.top -vf`                                         |

# Conclusions

Here, we have presented an overview of a new tool, MartiniGlass, which makes it possible to better visualise
coarse-grained molecules from the Martini forcefield, and their simulations. A selection of how MartiniGlass
may be used to generate visualisable topology files is shown in table 1. While MartiniGlass takes extensive 
care over how tertiary structure networks in proteins are handled to ensure that their visualisation is both
possible and flexible, it is really built to handle any kind of molecule parameterised with the Martini force
field, from proteins and DNA, lipids and sugars, through to deep eutectic solvents and molecular motors, to 
ensure that their bonded connections are truly visible. Although much of above has shown how MartiniGlass is
particularly useful for the visualisation of proteins, we further show in Figure 4 that the tool is applicable
to generic and complex systems. Here we have focused on an application for molecules in the Martini force 
field, but there is no reason why in future this method could not be expanded to other coarse-grained force
fields that use Gromacs. Similarly, while MartiniGlass has been particularly designed for visualising coarse
grained simulations with VMD, its functionality allows for bond atom indices to be written to text file to 
read into other visualisation software such as pymol or ngl viewer [@schrodinger_llc:2015].

# Acknowledgements

We thank the fellow members of the Marrink group for testing earlier versions of MartiniGlass, and their 
suggestions and comments during development.

# References

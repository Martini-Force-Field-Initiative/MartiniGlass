# MartiniGlass
![Martinizing a protein (Ubiquitin, PBD: 1UBQ) and visualising its elastic network.
left to right: atomistic representation of the protein. 
Martini representation of the protein overlaid on the atomistic one, showing the direct backbone and side chain.
Martini representation of the protein overlaid on the atomistic one, showing all bonds, with the elastic network in black.
Martini representation of the protein, showing all bonds.](image.png "Visualising elastic networks")

Scripts to aid the visualisation of coarse-grained Martini trajectories.

MartiniGlass uses [vermouth](https://github.com/marrink-lab/vermouth-martinize) to stably rewrite your input topology files as ones that can be used for visualisation in VMD.

Previously, `cg_bonds-vX.tcl` was able to read in Martini system topology information and draw it directly in VMD.
However, many Martini models now make extensive use of interaction types like virtual sites, which can't be handled
by the topology reading capabilities of this script directly. Martini_vis handles these and more by rewriting 
virtual sites as bonded atoms for visualisation purposes.

Thanks to [Jan Stevens](https://github.com/jan-stevens) for `vis.vmd`

If the solution here isn't working for you, please open an issue!

## Disclaimers

This code's mainly been tested on relatively simple systems.
It hasn't been tested extensively for larger/more complex systems with 
big mixtures of lipids and proteins, so if you're looking at something big, it's likely there'll be an error.

If you find an error, please open an issue so it can be fixed!

## Installation

### Installation with _pip_

```commandline
python3 -m venv venv && source venv/bin/activate # Not required, but often convenient.
pip install git+https://github.com/csbrasnett/MartiniGlass
```

### From repository source 

```commandline
git clone https://github.com/Martini-Force-Field-Initiative/MartiniGlass.git
cd MartiniGlass
python3 -m venv venv && source venv/bin/activate
pip install .
```

## Usage

1) Run e.g. `MartiniGlass -p topol.top`. This will produce:
   1) Edited *_vis.itp files for all the molecules in your system described in the input .top file.  
      * NB. by default, virtual sites will be rewritten as "real", with bonds between the sites and their constructing atoms. 
      To stop this, use the `-vs` flag.
   2) `vis.top`, a new .top file for your system and the visualisable topologies. `cg_bonds-v6.tcl` requires absolute paths to your itps, which is solved by running the script.
   3) Optionally by providing the .gro file you plan to visualise, you can write an index file without containing your system without water to use in processing your trajectory. 
   Something like `gmx trjconv -f traj_comp.xtc -s topol.tpr -n index.ndx -pbc mol -o vis.xtc` will write new trajectory using the index file provided. As there is only one index group,
   no further interaction with `trjconv` is required. 
      * NB. if you use this option, then `vis.top` will not contain an entry for the waters in your system at all.
2) Load your simulation into vmd:
   * To get ready access to `cg_bonds-v6.tcl` and `vis.vmd`, add the `-vf` flag to `MartiniGlass` and have these files written to the current directory.
   * `vmd frame.gro trajectory.xtc -e vis.vmd` will load your new topologies automatically, assuming `cg_bonds-v6.tcl` exists in some form in the directory you're looking at.
   Otherwise you'll have to interact with VMD directly: 
      1) load your system: `vmd frame.gro trajectory.xtc`
      2) load cg_bonds: `source cg_bonds6.tcl`
      3) load your visualisable topologies: `cg_bonds -top vis.top`
3) Visualise your simulation with bonds in Martini!

## Notes on using `MartiniGlass`

### Input
We assume the input topology looks like something as follows:

```
#include "martini_v3.0.0.itp"
#include "martini_v3.0.0_solvents_v1.itp"
#include "martini_v3.0.0_ions_v1.itp"
#include "my_protein.itp"
#include "something_else.itp"

[ system ]
system name

[ molecules ]
Protein 10
W         1000
something_else   10
NA               10
CL               10
```

### Output

Running `MartiniGlass -p topol.top -f frame.gro` on the above system, together with a .gro file that you want an index file for
will produce the following output:

```
#include "/absolute/path/to/file/my_protein_vis.itp"
#include "/absolute/path/to/file/something_else_vis.itp"
#include "/absolute/path/to/file/NA_vis.itp"
#include "/absolute/path/to/file/CL_vis.itp"

[ system ]
system name

[ molecules ]
Protein_vis 10
something_else_vis   10
NA_vis               10
CL_vis               10
```
So the differences are:
1) The input topologies are:
   * Now written with absolute paths to the directory they were found in
   * For the molecules of interest in your system, new visualisable topologies have been written and included
2) The [ molecules ] directive of the file:
   * Lists the new names of the visualising topologies
   * No longer has an entry for the water in the system, because a water-less index file was written.

## I want to see my elastic network!

`cg_bonds-v6.tcl` draws elastic networks in the same way that martinize2 generates them*:
finding pairs of atoms within a cutoff distance. I'm not certain this is guaranteed to either exactly
reproduce the underlying topology of the simulation, or be very quick. Here, there is the option to 
separate the elastic network generated by martinize2 out for special visualisation using the `-el` and `-ef` flags.

These make some assumptions about what your network looks like, primarily that the force - given by `-ef`, 
and by default 700 for Martini 3 proteins - used for the network is unique in your molecule, ie.
you don't have sidechains/ligands which are bound with the same force constant. Similarly, the short/long 
elastic network bonds for beta sheets are identified by their distance parameter, which is encoded in the force
field. I haven't extensively checked this degeneracy assumption, so if it breaks for you, please let me know.

One other complication with looking at elastic networks is that VMD can't handle atoms with more than 12 bonds attached.
`MartiniGlass` handles this by inspecting the elastic network and - if any such atoms are found - removing these
"excessive" bonds. This means that while you'll be able to look at your protein with its network in VMD, the network you
see won't contain all the elastic network bonds that were applied during your simulation. The bonds that were removed
get written to a separate text file for noting in case they're of interest to you.

&ast; at least I'm pretty certain it does

So in summary, there's no straightforward way to visualise your elastic network like I show in the
picture at the top. However, should you still want it, here's a hack:

1) run `MartiniGlass` with `-el` and `-ef` for your system
2) load your system in vmd as described above to see the direct bonded network of your system
3) load your system a second time into vmd
4) run `cg_bonds -top en.top` on your new molecule, to now see the elastic network.

The vmd settings in each system should then be something like
`not resname ION` for the whole protein in the first molecule, and `name BB and not resname protein` for the 
elastic network specific molecule in the second. Play around to your heart's content. Either way, you should 
now be able to see your protein as a joined-up molecule rather than a series of spheres.

## What about my Gō network?

Seeing your Gō network works in much the same way as seeing an elastic network. 
Simply use the `-go` flag, and your Gō network bonds should be written out in a
second itp that can be used to look at a second imposed molecule in vmd.

By default, it's assumed the file will be called `go_nbparams.itp` as per the 
latest version of martinize2, where the Gō parameters are calculated internally.
If you're using a different version of the Gō model where this file is called something
different, you can specify that with the `-gf` flag

## FAQs

### The bonds are going everywhere

This probably means that the molecules in your system are not pbc complete. 
If you do some trajectory processing as described above then hopefully it'll look better

### I did trajectory processing but my molecule doesn't look whole?

In this case, I would guess you have some kind of multimer in your system. Add fake bonds
to the topology for processing, then it can be recognised as such by gromacs.

### my system loads but I get an error!

if you get the following error:
```
atomsel : setbonds: Need one bondlist for each selected atom
```

you likely have a discrepancy between your vis.top being read by cg_bonds-v6.tcl and 
the .gro file of your system that you're actually trying to view in VMD. Ensure that 
what's in one is in the other, then this should go away.




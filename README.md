# MartiniGlass
![Martinizing a protein (Ubiquitin, PBD: 1UBQ) and visualising its elastic network.
left to right: atomistic representation of the protein. 
Martini representation of the protein overlaid on the atomistic one, showing the direct backbone and side chain.
Martini representation of the protein overlaid on the atomistic one, showing all bonds, with the elastic network in black.
Martini representation of the protein, showing all bonds.](image.png "Visualising elastic networks")

Scripts to aid the visualisation of coarse-grained Martini trajectories.

MartiniGlass uses [vermouth](https://github.com/marrink-lab/vermouth-martinize) to stably rewrite your input topology files as ones that can be used for visualisation in VMD.
Although the examples here show proteins, and the program has a particular focus on being able to visualise protein secondary/tertiary structure networks, MartiniGlass can in fact 
be used to reconstruct bonded networks of **any** Martini molecule!

Previously, `cg_bonds-vX.tcl` was able to read in Martini system topology information and draw it directly in VMD.
However, many Martini models now make extensive use of interaction types like virtual sites, which can't be handled
by the topology reading capabilities of this script directly. Martini_vis handles these and more by rewriting 
virtual sites as bonded atoms for visualisation purposes.

Thanks to [Jan Stevens](https://github.com/jan-stevens) for `vis.vmd`

If the solution here isn't working for you, please open an issue!

## Installation

```commandline
python3 -m venv venv && source venv/bin/activate # Not required, but often convenient.
pip install martiniglass
```

## Usage

Most likely, you can use MartiniGlass with a simple command:

```
martiniglass -p topol.top
```

But if you have proteins with complex tertiary structure networks that you also want to see, you might need to give some extra options. More comprehensive documentation is
available at the [wiki](https://github.com/Martini-Force-Field-Initiative/MartiniGlass/wiki). If you think something is broken or have a feature request, please open an 
[issue](https://github.com/Martini-Force-Field-Initiative/MartiniGlass/issues).

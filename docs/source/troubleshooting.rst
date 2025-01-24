Troubleshooting
***************

The bonds stopped loading
=========================

If you have an error message along the lines of:

.. code-block::

    atomsel: setbonds: too many bonds in bondlist: 2 6 27 29 31 33 35 133 135 138 140 142 144 5
    Maximum of 12 bonds

Then it is likely that the system was not processed by MartiniGlass correctly. For example, the
``-el`` or ``-go`` flags may not have been included to properly process the proteins in the system.

The bonds are going everywhere across periodic boundaries
=========================================================

This probably means that the molecules in your system are not pbc complete. If you process your
trajectory using ``gmx trjconv`` including the ``-pbc`` flag, then that should solve the issue.


I did trajectory processing but my molecule doesn't look whole?
===============================================================

If a molecule still doesn't appear whole after trajectory processing, then it is likely not
connected in the way that is expected. This is an issue when, for example, using Go Martini with a
multimeric protein, where the quaternary structure of the protein is retained with the Go network.
Gromacs doesn't consider such a system as "bonded", so further processing may be required.

My system loads but I get an error!
===================================

if you get the following error:

.. code-block::

    atomsel : setbonds: Need one bondlist for each selected atom

you likely have a discrepancy between your vis.top being read by cg_bonds-v6.tcl and the .gro file
of your system that you're actually trying to view in VMD. Ensure that what's in one is in the other,
then this should go away.

Two reasons this may occur are:

* You have a go model with virtual sites on the backbone, but the pdb you load has been made without them. So the number of atoms in the itp/top files are not the same as are actually in the pdb file that you load, so cg_bonds throws this error
* You've processed a large structure file to remove all solvent. MartiniGlass removes the "W" entry from the top file, but not any ions (maybe in future, feel free to make a PR). Make sure you've removed the whole solvent index group from the top file, and then it should be fine.

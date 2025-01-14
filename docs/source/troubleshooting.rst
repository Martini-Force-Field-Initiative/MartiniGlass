Troubleshooting
===============


The bonds are going everywhere
------------------------------

This probably means that the molecules in your system are not pbc complete. If you do some trajectory
processing as described above then hopefully it'll look better


I did trajectory processing but my molecule doesn't look whole?
---------------------------------------------------------------

In this case, I would guess you have some kind of multimer in your system. Add fake bonds to the
topology for processing, then it can be recognised as such by gromacs.


My system loads but I get an error!
-----------------------------------

if you get the following error:

.. code-block::

    atomsel : setbonds: Need one bondlist for each selected atom

you likely have a discrepancy between your vis.top being read by cg_bonds-v6.tcl and the .gro file
of your system that you're actually trying to view in VMD. Ensure that what's in one is in the other,
then this should go away.

Two reasons this may occur are:

* You have a go model with virtual sites on the backbone, but the pdb you load has been made without them. So the number of atoms in the itp/top files are not the same as are actually in the pdb file that you load, so cg_bonds throws this error
* You've processed a large structure file to remove all solvent. MartiniGlass removes the "W" entry from the top file, but not any ions (maybe in future, feel free to make a PR). Make sure you've removed the whole solvent index group from the top file, and then it should be fine.

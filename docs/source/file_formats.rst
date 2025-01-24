File formats
************

.. _inputfiles:
Input files
===========

As described in :ref:`getting_started`, the primary input file for MartiniGlass is a Gromacs
topology file. The example here shows a system containing three default ``.itp`` files from
the Martini 3 force field, followed by a protein produced by `Martinize2 <https://github.com/marrink-lab/vermouth-martinize>`_
at coarse-grained resolution, and another molecule called ``something_else`` that the user has developed.

Note that in the file here, the paths to the master ``.itp`` files are relative. As VMD requires
absolute paths, MartiniGlass will resolve these and write them out.

The format of the topology file given to MartiniGlass is strictly required to be in the format described here.
At the present time, it is not possible to parse a topology file which also contains ``[ moleculetype ]``
directives and associated molecule descriptions in a single file.

.. code-block::

    #include "../martini_v3.0.0.itp"
    #include "../martini_v3.0.0_solvents_v1.itp"
    #include "../martini_v3.0.0_ions_v1.itp"
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

Output files
============

.top files
----------

The structure of output topology files - ready to be read by the ``cg_bonds`` program in VMD
- generally follows the same structure as the input one. For example, the input .top file described above
will result in the following output:

.. code-block::

    #include "/absolute/path/to/my_protein_vis.itp"
    #include "/absolute/path/to/something_else_vis.itp"
    #include "/absolute/path/to/W_vis.itp"
    #include "/absolute/path/to/NA_vis.itp"
    #include "/absolute/path/to/CL_vis.itp"

    [ system ]
    system name

    [ molecules ]
    Protein_vis 10
    W_vis         1000
    something_else_vis   10
    NA_vis               10
    CL_vis               10

The differences here are:

* The molecules have been given new names. The new names are the same as in the ``[ moleculetype ]`` of the new included topology files
* The paths to the files have been written as absolute paths for ``cg_bonds`` to read.

One possible difference is when MartiniGlass is run with an input structure file using the ``-f`` flag.
In this case, it is expected that the user wishes to visualise their system without water. As such, the
lines relating to water in the topology file are removed in anticipation:


.. code-block::

    #include "/absolute/path/to/my_protein_vis.itp"
    #include "/absolute/path/to/something_else_vis.itp"
    #include "/absolute/path/to/NA_vis.itp"
    #include "/absolute/path/to/CL_vis.itp"

    [ system ]
    system name

    [ molecules ]
    Protein_vis 10
    something_else_vis   10
    NA_vis               10
    CL_vis               10


.itp files
----------

itp files will be written out for all the components of the input system, with an appropriate suffix.
These follow the standard structure of the `Gromacs defined format <https://manual.gromacs.org/2024.0/reference-manual/topologies/topology-file-formats.html>`_.
For the purposes of visualisation, they contain only three directives:

* ``[ moleculetype ]``: the name of the molecule, taken from the input name and given an appropriate suffix.
* ``[ atoms ]``: the atoms of the molecule, identical to the input file
* ``[ bonds ]``: the bonds of the molecule as appropriate

The core functionality of MartiniGlass is asserting that the ``[ bonds ]`` directive is correct and readable
by the ``cg_bonds`` program in VMD. By "correct", it is meant that the contents of the directive is edited
such that bond types such as elastic network bonds are removed from the primary visualisation topology,
and written elsewhere.

Note that the generated topologies **should not** be used as input files for simulations. None of the input
parameters are correct for this purpose, which will likely result in:

1) The simulation crashing almost immediately
2) Unphysical behaviour should 1) not happen.

Auxillary files
---------------

MartiniGlass may write several more files with the ``-vf`` (Visualisation Files) flag. These are described
further in the :ref:`state files<state_files>` section of the :doc:`Advanced Options <advanced_options>` page.









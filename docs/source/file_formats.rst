File formats
============

.. _inputfiles:

Input files
------------

As described in :ref:`getting_started`, the primary input file for MartiniGlass is a Gromacs
topology file. The example here shows a system containing three default ``.itp`` files from
the Martini 3 force field, followed by a protein produced by `Martinize2 <https://github.com/marrink-lab/vermouth-martinize>`_
at coarse-grained resolution, and another molecule called ``something_else`` that the user has developed.

Note that in the file here, the paths to the master ``.itp`` files are relative. As VMD requires
absolute paths, MartiniGlass will resolve these and write them out.

.. code-block:: console

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
------------


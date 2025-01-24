Non protein systems
*******************

The selection of output files for this tutorial is available from the
`MartiniGlass examples folder <https://github.com/Martini-Force-Field-Initiative/MartiniGlass/tree/main/examples/non_protein>`_.

Most of the functionality of MartiniGlass is focused on proteins to enable visualisation of
secondary and tertiary structure elements. However, the program enables rapid generation of
robust topology files for visualisation for *any* Martini system. This first tutorial shows
both how simple MartiniGlass commands can be used to rapidly generate visualisable topology
files, and the diversity of systems to which it can be applied.

This is best demonstrated by the protein-less system in the
`non protein <https://github.com/Martini-Force-Field-Initiative/MartiniGlass/tree/main/examples/non_protein>`_
example folder. The system here contains a number of different lipids, water, ions, and several
copies of a synthetic molecule, a molecular motor as described by
`Vainikka and Marrink <https://pubs.acs.org/doi/10.1021/acs.jctc.2c00796>`_.

Running MartiniGlass
====================

With no proteins to take care of in this system, MartiniGlass only strictly requires the ``-p``
flag to specify the input topology. However, because visualising the water is not of interest,
and the visualisation files are required, the ``-f`` and ``-vf`` flags are used respectively.
Note the ``-f`` flag requires the ``.gro`` file associated with the system.

.. code-block::

    $ martiniglass -p system.top -f mixed.gro -vf


This generates a number of files as outputs:

* ``..._vis.itp``: the direct bonded topology of all of the molecules to be visualised.
* ``vis.top``: a topology file for the direct bonded networks of the system
* ``index.ndx``: a Gromacs index file for the system containing one index group for lipids, molecular motors, and ions. (I.E. everything that's not water)


Processing the structure file
=============================

The index file can be used to make a structure file :ref:`without water<nowater>` for convenient visualisation.

.. code-block::

    $ gmx trjconv -f mixed.gro -s mixed.gro -n index.ndx -o vis.gro

Note that for an index file with only a single index group, no further interaction with ``gmx trjconv`` is necessary.

Viewing in VMD
==============

With the topology processed, and a water-less structure file generated for viewing, the system
is ready to be loaded into VMD:

.. code-block::

    $ vmd vis.gro -e vis.vmd

Which will load the system along with the default visualisations provided, and should show
the system as rendered below.

.. note::

    If by accident the file loaded into vmd is the original ``mixed.gro`` as:

    .. code-block::

        $ vmd mixed.gro -e vis.vmd

    then the following error should be expected:

    .. code-block::

        atomsel : setbonds: Need one bondlist for each selected atom

    This error arises because the ``vis.top`` file, loaded into VMD by ``vis.vmd``
    does *not* contain an entry for the water molecules in the system.


.. image::
    https://github.com/user-attachments/assets/7e366c7c-11f3-4ef3-9c41-2ff5b4c69dc0

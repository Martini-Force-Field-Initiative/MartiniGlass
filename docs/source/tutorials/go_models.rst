Go models
****************


Example from step by step tutorial: Martini model of protein 1UBQ in blue with the nonbonded Go
interactions between backbone beads illustrated in black.

.. image::
    https://github.com/user-attachments/assets/5c116782-46cd-437c-a964-fa18f7225f06




Quickstart
==========

To process a system containing a protein with a Go model and visualise it,
the following command can be used:

.. code-block::

    $ martiniglass -p topol.top -f frame.gro -vf -go -gf go_nbparams.itp

Where ``frame.gro`` should have the name of your desired input structure file.

Subsequently the system can be loaded into VMD as usual:

.. code-block::

    $ vmd frame.gro -e vis.vmd

This command will load the given structure file twice, and apply the two
visualisation topologies (``vis.top`` and ``en.top`` respectively) to the two systems in VMD.

If a trajectory file is to be visualised along with the static structure, the following commands
can be used:

.. code-block::

    $ martiniglass -p topol.top -f frame.gro -vf -el -traj trajectory.xtc
    $ vmd frame.gro trajectory.xtc -e vis.vmd

which will enable dynamic visualisation of elastic network bonds through the course
of the simulation.


Step by step tutorial
=====================

The selection of output files for this tutorial is available from the
`MartiniGlass examples folder <https://github.com/Martini-Force-Field-Initiative/MartiniGlass/tree/main/examples/protein_go_model>`_.

The expected output can be generated in one go using the ``generate_expected_files.sh`` script run inside
the input folder.

Step 1: Martinize your protein
------------------------------

Create a martini model of a protein following the standard martinize2 protocol:

.. code-block::

    $ wget https://files.rcsb.org/download/1ubq.pdb
    $ grep "^ATOM" 1ubq.pdb > 1UBQ_clean.pdb
    $ wget https://raw.githubusercontent.com/Martini-Force-Field-Initiative/MartiniGlass/refs/heads/main/examples/protein_go_model/expected_output/contact_map.out
    $ martinize2 -f 1UBQ_clean.pdb -o topol.top -x 1UBQ_cg.pdb -go contact_map.out

These commands:
 1. Download a 1ubq.pdb from the protein database

 2. Prepare it to be martinized

 3. Obtain the pre-calculated contact map for this protein

 4. Create a coarse grained model of the protein

From this, you should expect the following files:

* ``1UBQ_cg.pdb``: a pdb file with the coordinates of the coarse grained beads
* ``topol.top``: a gromacs topology file describing your system
* ``molecule.itp``: the coarse grained topology of the 1ubq protein
* ``go_atomtypes.itp``: the atomtypes of the Go model
* ``go_nbparams.itp``: the additional nonbonded network describing the Go model of the protein

Without any further additions, ``topol.top`` only contains a single copy of your protein.

For more information on the Go model, see the tutorial in the `Vermouth documentation <https://vermouth-martinize.readthedocs.io/en/latest/tutorials/go_models.html>`_


Step 2: Run MartiniGlass
------------------------

The system is now ready to be processed by MartiniGlass. In this case, we have:

* a protein with a go model

Therefore, the command we need to process with MartiniGlass is:

.. code-block::

    $ martiniglass -p topol.top -go -gf go_nbparams.itp -vf

This will generate the following files describing your system:

* ``molecule_0_go.itp``: the go network of the protein
* ``molecule_0_vis.itp``: the direct bonded topology of the protein
* ``go.top``: a topology file for the go network of the system
* ``vis.top``: a topology file for the direct bonded networks of the system

Alongside these file, several files have been written to enable the topology to be loaded into VMD through
the use of the ``-vf`` (Visualisation Files) flag:

* ``vis.vmd``: VMD visualisation state file
* ``cg_bonds-v6.tcl``: vmd commands to draw bonds between atoms
* ``eigen.py``: auxiliary python script required by ``cg_bonds-v6.tcl``

Step 3: Loading your system in VMD
----------------------------------

Step 3a: Loading the initial system
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To fully view an elastic network in VMD using the files provided, the system needs to be loaded twice in VMD.

1. Load the system in VMD from the command line using the visualisation state file provided:

.. code-block::

    $ vmd 1UBQ_cg.pdb -e vis.vmd

This will load your system into VMD using the suggested visualisation mode.

``vis.vmd`` includes commands that will:

* Load the commands described in ``cg_bonds-v6.tcl``
* Read in the visualisation topology described in ``vis.top`` for your system.

The image in VMD you now see should look something like this

.. image::
    https://github.com/user-attachments/assets/90541ec1-1f90-4844-994e-6f7aad03519e

where the backbone of the protein has been rendered as a continuous object.


Step 3b: Loading the Go model
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Next, the system must be loaded a second time. Open the *Molecule File Browser* from the VMD menu
(File -> New Molecule...) and load the same input structure file, into a New Molecule:

.. image::
    https://github.com/user-attachments/assets/7d27ba23-3c5d-4512-bd36-13f945efb320

The system should now appear twice in the VMD main menu. With the system loaded a second time, the
elastic network topology can be loaded onto it. Open the Tk console from the VMD menu
(Extensions -> Tk Console), and load the topology using the ``cg_bonds`` program:

.. code-block::

    % cg_bonds -top go.top

This will load the topology information into the second system loaded. The bonds are then best visible
by changing the graphics of the second molecule. Load the Graphical Representations menu from the VMD
main menu (Graphics -> Representations...). Making sure you have the second molecule selected, change
the Drawing Method to bonds, and pick a colour of your choice.

Applying these will ensure that the go network is now visible:

.. image::
    https://github.com/user-attachments/assets/e9af0c57-06a3-485b-b505-dd55b79d8606

Although this may look identical to the elastic network shown previously, the contacts are in fact
not the same. Additionally because of the way the Go contact map calculation works, the Go network
model will never face the same issue of having atoms with > 12 bonds, and having to write
auxiliary visualisation file to see the entire network.




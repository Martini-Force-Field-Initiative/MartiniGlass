Static cylinder networks
========================

Occaisionally when Martinize2 generates elastic networks, some atoms require a large number of elastic
bonds to keep them in the place of their initial structure. However, when such a structure is loaded
into vmd, an error message along these lines will be raised:

.. code-block::

    atomsel: setbonds: too many bonds in bondlist: 2 6 27 29 31 33 35 133 135 138 140 142 144 5
    Maximum of 12 bonds

This error arises because VMD has a limit of showing 12 bonds on a single atom. As described in the
:doc:`elastic network tutorial <elastic_networks>`, the elastic network processor edits the network
to ensure that no atoms have more than 12 bonds, and writes them out as a separate file for noting.

To overcome this limitation in VMD, MartiniGlass can process static structures and topologies together
to draw an apparent bonded network with a set of cylinders instead. This is indicated by the ``-cyl``
flag when running MartiniGlass.

Step 1: Running MartiniGlass
----------------------------

For this tutorial we will use the same ``1UBQ_cg.pdb`` input file and topology as in the
:doc:`elastic network tutorial <elastic_networks>`. First the pdb file needs to be converted to the
``.gro`` format (for example using ``gmx editconf``:

.. code-block::

    $ gmx editconf -f 1UBQ_cg.pdb -c -d 2 -o frame.gro

In the ``.gro`` format, it is ready to be read by MartiniGlass, along with the options for elastic
network analysis and cylinder generation file:

.. code-block::

    $ martiniglass -p topol.top -f frame.gro -el -cyl

Alongside the usual files written as before in the :doc:`elastic network tutorial <elastic_networks>`,
one further file is written, ``network_cylinders.tcl``.

Step 2: Loading the system into VMD
-----------------------------------


As usual, the system can now be loaded into VMD:

.. code-block::

    $ vmd frame.gro -e vis.vmd

.. image::
    https://github.com/user-attachments/assets/90541ec1-1f90-4844-994e-6f7aad03519e


Step 3: Load the static network
-------------------------------

With the system loaded in VMD, the static network of drawn cylinders can be simply loaded in through
the vmd Tk Console:

.. code-block::

    % source network_cylinders.tcl

Which will immediately result in the following image displayed:

.. image::
    https://github.com/user-attachments/assets/55584d20-0230-429d-8f0b-1b4c61052c00


Although this looks almost identical to the image we saw of the elastic network previously, the system now
differs in two ways:

1. The entire elastic network is drawn, so even atoms with > 12 bonds attached now have all elastic bonds drawn.
2. The network is static. If a simulation trajectory was also loaded into the system, the static cylindrical network will stay in the positions it was drawn.







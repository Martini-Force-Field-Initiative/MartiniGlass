Protein bead sizes
******************

One feature of the Martini 3 force field is the multiple so-called 'bead sizes' available with which
to construct molecules. The tiny, small, and regular sizes of beads are designed to represent different
numbers of underlying atoms, usually between 2 for tiny, 3 for small, and 4 for regular.

In some situations, it may be advantageous to visualise the different sized beads with their corresponding
size, particularly for protein structures. The image shown below shows an example protein with an elastic
network, with the backbone and side chain beads shown in the appropriate size as written into the force field.
The protein backbone beads are coloured in pink, and side chains in purple. The backbones are in two sizes,
as Glycine is represented by a small bead (for example in the top right of the image), and all others are
the same size representing regular beads.

Side chains in the Martini 3 are represented across all three bead sizes, which can be seen across the beads
throughout the image. For example, a tyrosine in the centre of the image has four tiny beads, while two
methionines at the bottom have a single regular bead.

.. image::
    https://github.com/user-attachments/assets/cf160541-3d13-4b70-ad36-36cf28c75aa7

Visualising proteins with appropriate bead sizes
================================================

To produce a VMD state file to view proteins with the above state, the ``-pf`` ("protein file")
flag can be used in addition to the ``-vf`` flag. For example:

.. code-block::

    $ martiniglass -p topol.top -el -vf -pf -f frame.gro

will result in the usual visualisable topologies and visualisation files described in earlier tutorials,
as well as a file, ``proteins.vmd``. ``proteins.vmd`` can then be used the same as other state files to
load an input structure into VMD:

.. code-block::

    $ vmd frame.gro -e proteins.vmd

which will automatically load in any secondary networks for proteins (as shown in earlier tutorials),
and set appropriate bead sizes for all protein residues in the system. If you have other molecules
present in your system, then their bead sizes may need to be set following the same graphics representation
format as shown for proteins.












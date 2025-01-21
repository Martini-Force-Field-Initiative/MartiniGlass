Usage
=====

.. _install:

Installation
------------

To use MartiniGlass, first install it using pip:

.. code-block:: console

    (.venv) $ pip install martiniglass

.. _getting_started:

Getting started
---------------

Using MartiniGlass
^^^^^^^^^^^^^^^^^^

As a starter, all MartiniGlass requires to process your system is a gromacs topology file in the
``.top`` format.

For example:

.. code-block:: console

    $ martiniglass -p topol.top

Note that martiniglass expects that the file provided includes the system's molecules
in a series of include topology (``.itp``) files, rather than storing the ``[ moleculetype ]`` directives
of the system in the ``.top`` file directly. Further information about the format of the input file is
described in :ref:`<inputfiles>`.

If your system requires no further description in MartiniGlass, you should expect the following outputs:

1)  A series of ``.itp`` files corresponding to the molecules listed in the ``[ molecules ]``
    directive of your input system topology (above called ``topol.top``). The files will retain
    their original name appended by ``_vis``.
2)  A file called ``vis.top``, corresponding to the input ``topol.top``, which now includes the new
    set of ``.itp`` files.


Visualising your system
^^^^^^^^^^^^^^^^^^^^^^^

Once MartiniGlass has processed your system, you should be ready to load it into VMD.
Load your structure and trajectory as with any other:

.. code-block:: console

    $ vmd frame.gro trajectory.xtc

Once VMD has loaded your system, you can begin to improve your visualisation using the files generated
by MartiniGlass. Firstly, open the Tk console in VMD from the menu: Extensions -> Tk console.

Once the VMD console is open, a tcl script called ``cg_bonds-v6.tcl`` is required to load your topology. This script
is packaged with MartiniGlass and is available `here <https://github.com/Martini-Force-Field-Initiative/MartiniGlass/blob/main/martiniglass/data/cg_bonds-v6.tcl>`_.
Load the script in the VMD Tk console using:

.. code-block::

    % source cg_bonds-v6.tcl

With the extra commands and routines available in ``cg_bonds``, the topology processed by MartiniGlass
can be loaded, and continuous molecules are now possible:

.. code-block::

    % cg_bonds -top vis.top

Now the visualisable system topology is loaded into VMD, molecules can be viewed as before using standard
VMD selections, and the licorice or CPK drawing methods may be used.



What next?
^^^^^^^^^^

This section is a basic guide to how MartiniGlass may be used in conjunction with VMD to better visualise
your Martini system. Almost certainly, systems naively processed by MartiniGlass in this way will not load
as intended into VMD.

MartiniGlass has several further options to help better process your input topology for the best visualisation
of your system. These are described in :doc:`Advanced options <advanced_options>`. There are further tutorials
available on the :doc:`Tutorials page <tutorials/index>`.

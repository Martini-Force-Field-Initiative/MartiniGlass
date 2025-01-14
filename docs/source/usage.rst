Usage
=====

.. _installation:

Installation
------------

To use MartiniGlass, first install it using pip:

.. code-block:: console

    (.venv) $ pip install martiniglass


Getting started
---------------

As a starter, all MartiniGlass requires to process your system is a gromacs topology file in the
``.top`` format.

For example:

.. code-block:: console

    $ martiniglass -p topol.top

Note that martiniglass expects that the file provided includes the system's molecules
in a series of include topology (``.itp``) files, rather than storing the ``[ moleculetype ]`` directives
of the system in the ``.top`` file directly.


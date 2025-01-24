Welcome to the documentation for MartiniGlass!
**********************************************

.. image::
    https://github.com/user-attachments/assets/7de8a35f-c808-493c-b412-1674d2c0ed74

**MartiniGlass** is a Python library for aiding with the visualisation
of simulations performed with the `Martini <https://cgmartini.nl/>`_ coarse grained force field
using `VMD <https://www.ks.uiuc.edu/Research/vmd/>`_.

Molecular visualisation software packages are generally developed to assume atomistic detail in input
structures. When it comes to showing coarse grained models, this means that features such as bonds
between contiguous beads are missed, because the distance between them is much larger than
at atomistic resolution. Rendering quality images of coarse grained models - including
Martini - is therefore a challenge.

MartiniGlass helps users overcome this challenge by preprocessing systems to prepare a set of
input files for VMD. The files prepared enable VMD to draw bonds between coarse grained beads
and show continuous molecules, rather than leaving users to render complex systems are a series
of overlapping spheres to try to render a similar effect. Furthermore, MartiniGlass helps users
visualise additional aspects of their systems that are common in Martini models, such as elastic
network bonds necessary for retaining secondary and tertiary structure at coarse grained
resolution.

The :doc:`usage` section provides basic information about the package.
There are details about how to :ref:`install <install>` MartiniGlass, and a basic example of
how to get started.

.. note::

   This project is under active development.

Contents
========

.. toctree::
    :maxdepth: 1

    introduction
    file_formats
    advanced_options
    tutorials/index
    troubleshooting

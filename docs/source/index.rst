Welcome to the documentation for MartiniGlass!
==============================================

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
network bonds that are necessary for retaining secondary and tertiary structure at coarse grained
resolution.

Check out the :doc:`usage` section for further information, including
how to :ref:`installation` the project.

.. note::

   This project is under active development.

Contents
--------

.. toctree::

    usage
    file_formats
    tutorials/index

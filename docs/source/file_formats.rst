File formats
============

.. _inputfiles:

Input files
------------
As described in :ref:`getting_started`, the primary input file for MartiniGlass is a Gromacs
topology file. The example here shows a


```
#include "martini_v3.0.0.itp"
#include "martini_v3.0.0_solvents_v1.itp"
#include "martini_v3.0.0_ions_v1.itp"
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
```


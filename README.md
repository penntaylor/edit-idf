edit-idf
========

WARNING:
--------
This code is in no shape to be cloned yet. Most of what's here is 
proof-of-concept and prototyping that I'm using to help work out the 
specifications and eventual interfaces (in both the api sense and the gui 
sense). Everything is in Ruby right now, but I haven't decided whether this
project will stick with Ruby beyond the prototyping stage.

Summary
-------
edit-idf provides a way to edit EnergyPlus IDF files, somewhat like the 
Windows-only application IdfEditor which is packaged with the Windows binaries 
of EnergyPlus. Unlike IdfEditor, edit-idf operates on GNU/Linux and OSX as well
as Windows. Its primary purpose is to enable a GNU/Linux-only worflow for 
handling IDFs and EnergyPlus simulation.

What it isn't
-------------
edit-idf is not intended to provide exact feature parity with IdfEditor, nor
is it intended to look exactly like IdfEditor; however, if you're comfortable
editing IDFs in IdfEditor, edit-idf will make perfect sense.

Implementation details
----------------------
edit-idf is written in Ruby (for now) and uses Digia's Qt libraries
via the `qtbindings` gem.
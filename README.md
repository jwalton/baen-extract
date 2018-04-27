bean-extract
============

[![Greenkeeper badge](https://badges.greenkeeper.io/jwalton/baen-extract.svg)](https://greenkeeper.io/)

What is it?
-----------

When you purchase multiple books from [Baen](http://www.baenebooks.com/) at the
same time, you can download all your books together in a single format.  You
can grab all your books as LRF files, for example, in a file typically called
L_ORDER_xxxx.zip.

If you want to download a book in multiple formats, and then import each book
into Calibre, this can be a tedious and time consuming operation.  This program
will automatically extract multiple Baen zip files into a directory structure
that is easy to import into Calibre.

Usage:
------

    coffee ./src/app.coffee [--out outFolder] [inFolder]

Where:

* `inFolder` is a folder containing one or more Baen zip files, each containing
  multiple books.  `inFolder` might be, for example, a folder containing
  E_ORDER_99323.zip and L_ORDER_99323.zip, if you've downloaded your books
  in ePub and LRF formats.
* `outFolder` is optional, and is the folder to extract books to.  If not
  specified, defaults to "inFolder/extracted".

baen-extract expects each ORDER zip file to contain a collection of zip files,
each of which contains a single book file (excpet for H_ORDER_*.* files, which
are treated specially.)  baen-extract will create a folder for each book title
in the destination folder, and unzip each book zip file into this folder.
Any zip files inside a H_ORDER_*.* file will be copies into the book folder
and renamed to "* HTML.zip" instead of being extracted.

You should be able to import all the books in your order into Calibre by
clicking the down arrow next to "Add books", and picking "Add books from
directories, including sub-directories (One book per directory, assumes every
ebook file is the same book in a different format)."

Todo:
-----

Right now to run this you need to know a bit about Node.js and Coffee-Script.
Need to make this easy for anyone to install and run.  Possibly rewrite in
golang.

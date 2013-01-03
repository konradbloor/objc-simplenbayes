objc-SimpleNBayes
=================

Introduction
------------
I used a Naive-Bayes classifier by oasic (https://github.com/oasic/nbayes) in another project and found it useful,
and wanted something similar in Objective-C.  I found BayesianKit (https://github.com/lok/BayesianKit) which was great,
but that also had a dependency on ParseKit and I wanted something exceptionally simple.  Since oasic's classifier served
me well previously, I thought it would be a worthwhile exercise to port it to Objective-C.

So to clarify, there is not really any original work here - this is a derivative work of oasic's nbayes project where
I have applied mostly the same tests, and the functionality should be exactly the same, although I have changed where
some functionality lies by factoring out some logic, or sometimes introducing functions to substitute when a ruby function
that was used that had no counterpart that I could find in Foundation.

To-do
-----

- classifiers can be easily saved and retrieved according to idiomatic Cocoa


Author
-------
Konrad Bloor (<kb@konradbloor.com>)

Credits
-------
Oasic (https://github.com/oasic) for creating the original Ruby version which I've found so useul

License
-------

Copyright (c) 2012 Konrad Bloor

Licensed under the MIT License.
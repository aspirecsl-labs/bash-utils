# Common IO Functions

This module contains scripts that have some of the commonly used bash IO functions. These functions manipulate data in an array, file etc.
Source (dot) these files in a script to use these functions.

# sh-utils-arrays.sh
This script contains some commonly used array functions
- arrayContainsElement: function to check if an array contains an element
  - returns zero if the array has the element or 1 if it doesn't
  - Usage: arrayContainsElement <element> <array>; if [ $? -eq 0 ]; then echo PRESENT; else echo NOT PRESENT; fi

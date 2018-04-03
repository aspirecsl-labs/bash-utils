# Common IO Functions

This module contains scripts that have some of the commonly used bash IO functions. These functions manipulate data in an array, file etc.
Source (dot) these files in a script to use these functions.

# sh-utils-arrays.sh
This script contains some commonly used array functions
- arrayContainsElement: function to check if an array contains an element
  - returns zero if the array has the element or 1 if it doesn't
  - **Usage: arrayContainsElement _element_ _array_**
- replaceInAllInArray: function to replace a string in all the elements of an array
  - returns 1 if the function was invoked with incorrect number of arguments, or 0 if it completes normally
  - **Usage: replaceInAllInArray _original-string_ _replacement-string_ _array_**
- removeInAllInArray: function to remove a string from all the elements of an array
  - returns 1 if the function was invoked with incorrect number of arguments, or 0 if it completes normally
  - **Usage: removeInAllInArray _string-to-remove_ _array_**

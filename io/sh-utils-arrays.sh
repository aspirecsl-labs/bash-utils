#!/bin/bash
#set -x
####################################################################
#                                                                  #
# Author       :  AspireCSL Labs                                   #
# Description  :  Script with general purpose functions for arrays #
#                                                                  #
####################################################################

# checks if an element exists in an array
# input parameters:
#     1. element to check if in the array
#     2. array of all elements 
arrayContainsElement() {

  local element
  for element in "${@:2}"
  do
    [[ "$element" == "$1" ]] && return 0
  done
  
  return 1

}

# replaces the occurence of a given string in all elements in an array
# input parameters:
#     1. string to replace
#     2. replacement string 
#     3. the array to modify
replaceInAllInArray() {

  if [ $# -lt 3 ]
  then
    echo ""
    return 1
  fi
  
  echo "${@:3}" \
    | awk \
        -v string_to_match=$1 \
        -v replacement_string=$2 \
        '{
          gsub(string_to_match, replacement_string); 
          print;
        }'
  
  return 0

}

# removes the occurence of a given string in all elements in an array
# input parameters:
#     1. string to remove
#     2. the array to modify
removeInAllInArray() {

  if [ $# -lt 2 ]
  then
    echo ""
    return 1
  fi
  
  replaceInAllInArray "$1" "" "${@:2}"
  
  return 0

}

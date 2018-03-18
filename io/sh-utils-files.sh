#!/bin/bash
#set -x
####################################################################
#                                                                  #
# Author       :  AspireCSL Labs                                   #
# Description  :  Script with general purpose functions for files  #
#                                                                  #
####################################################################

# prints the value of a field in a record in a csv file
# 
# if there are multiple records with the same value for the given field,
# then only the first match is considered
#
# input parameters:
#     1. file name
#     2. field number to match
#     3. field value to match
#     4. field number to print
#     5. [OPTIONAL] field separator string 
#     6. [OPTIONAL] comment marker in the file
getFieldFromARecordInFile(){
  
  local FIELD_SEPARATOR=":"
  local COMMENT_MARKER="#"
  
  local optname
  local OPTIND
  while getopts c:f: optname; 
  do
      case $optname in
          c)
            COMMENT_MARKER=$OPTARG;;          
          f)
            FIELD_SEPARATOR=$OPTARG;;             
          *)
            echo ""
            return 1;;          
      esac 
  done
  
  shift $(($OPTIND - 1))
  
  local number_regex='^[0-9]+$'
  if [[ $# -ne 4 || ! -r $1 || ! $2 =~ $number_regex || ! $4 =~ $number_regex ]]
  then
    echo ""
    return 1
  fi
  
  echo `cat $1 \
    | grep -v "^$COMMENT_MARKER" \
      | awk -F "$FIELD_SEPARATOR" \
            -v field_to_match=$2 \
            -v field_matcher_str=$3 \
            -v field_to_print=$4 \
            '{
              if ($field_to_match == field_matcher_str)
              {
                print $field_to_print;
                exit;
              }
            }'`
  
  return 0
  
}

# prints the values of a field in all records in a csv file
#
# if the field values have whitespaces, 
# then they are replaced by the string _BLANKS_
# if a different replacement string is to be used, 
# then pass it as an optional parameter with -r option
#
# input parameters:
#     1. file name
#     2. field number
#     3. [OPTIONAL] field separator string 
#     4. [OPTIONAL] comment marker in the file
#     5. [OPTIONAL] string to replace whitespaces in field values
getFieldAsArrayFromFile(){
  
  local FIELD_SEPARATOR=":"
  local COMMENT_MARKER="#"
  local WHITESPACE_REPLACEMENT_STR="_BLANKS_"
  
  local optname
  local OPTIND
  while getopts c:f:r: optname; 
  do
      case $optname in
          c)
            COMMENT_MARKER=$OPTARG;;          
          f)
            FIELD_SEPARATOR=$OPTARG;;   
          r)
            WHITESPACE_REPLACEMENT_STR=$OPTARG;;                        
          *)
            echo ""
            return 1;;          
      esac 
  done
  
  shift $(($OPTIND - 1))
  
  local number_regex='^[0-9]+$'
  if [[ $# -ne 2 || ! -r $1 || ! $2 =~ $number_regex ]]
  then
    echo ""
    return 1
  fi
  
  echo `cat $1 \
    | grep -v "^$COMMENT_MARKER" \
      | awk -F "$FIELD_SEPARATOR" \
            -v field_number=$2 \
            -v blanks_replacement=$WHITESPACE_REPLACEMENT_STR \
            '{
              gsub(/[ \t]+/, blanks_replacement, $field_number);
              printf("%s ", $field_number);
            }'`
  
  return 0
  
}

# prints the values of all fields in a record in a csv file
# 
# if there are multiple records with the same value for the given field,
# then only the first match is considered
#
# if the field values have whitespaces, 
# then they are replaced by the string _BLANKS_
# if a different replacement string is to be used, 
# then pass it as an optional parameter with -r option
#
# input parameters:
#     1. file name
#     2. field number to match
#     3. field value to match
#     4. [OPTIONAL] field separator string 
#     5. [OPTIONAL] comment marker in the file
#     6. [OPTIONAL] string to replace whitespaces in field values
getFieldsInARecordAsArray(){
  
  local FIELD_SEPARATOR=":"
  local COMMENT_MARKER="#"
  local WHITESPACE_REPLACEMENT_STR="_BLANKS_"
  
  local optname
  local OPTIND
  while getopts c:f:r: optname; 
  do
      case $optname in
          c)
            COMMENT_MARKER=$OPTARG;;          
          f)
            FIELD_SEPARATOR=$OPTARG;;      
          r)
            WHITESPACE_REPLACEMENT_STR=$OPTARG;;                    
          *)
            echo ""
            return 1;;          
      esac 
  done
  
  shift $(($OPTIND - 1))
  
  local number_regex='^[0-9]+$'
  if [[ $# -ne 3 || ! -r $1 || ! $2 =~ $number_regex ]]
  then
    echo ""
    return 1
  fi

  echo `cat $1 \
    | grep -v "^$COMMENT_MARKER" \
      | awk -F "$FIELD_SEPARATOR" \
            -v field_to_match=$2 \
            -v field_matcher_str=$3 \
            -v blanks_replacement=$WHITESPACE_REPLACEMENT_STR \
            '{
              if ($field_to_match == field_matcher_str)
              { 
                for(i=1; i<=NF; i++)
                {
                  gsub(/[ \t]+/, blanks_replacement, $i);
                  printf("%s ", $i);
                }
                exit;
              }
            }'`
  
  return 0
  
}

# prints the value of a property in a file
# 
# if there are multiple records with the same property key,
# then only the first match is considered
#
# input parameters:
#     1. property file FQN
#     2. property key
#     3. [OPTIONAL] default value for the property
#     4. [OPTIONAL] field separator string 
#
readProperty() {

  local FIELD_SEPARATOR="="
  local DEFAULT_VALUE=""

  local optname
  local OPTIND
  while getopts d:f: optname;
  do
      case $optname in
          d)
            DEFAULT_VALUE=$OPTARG;;
          f)
            FIELD_SEPARATOR=$OPTARG;;
          *)
            echo ""
            return 1;;
      esac
  done

  shift $(($OPTIND - 1))

  if [[ $# -ne 2 || ! -r $1 ]]
  then
    echo ${DEFAULT_VALUE:-""}
    return 1
  fi

  PROP_VAL=`awk -F "$FIELD_SEPARATOR" \
                -v PROP_KEY=$2 \
                '{
                   if ($1 == PROP_KEY)
                   {
                     print $2;
                     exit;
                   }
                }' $1`

  echo ${PROP_VAL:-$DEFAULT_VALUE}

  return 0

}

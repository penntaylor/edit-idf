EPTools Design
==============

IDF data structure
------------------
An idf is parsed into a hash containing an array of arrays.

The hash keys are the idd class names. Since each idd class name must be 
globally unique -- idd groups do not provide a namespace -- key names are
guaranteed to be unique.

The top-level array of a key's value contains a sequence of class instances,
or objects.

Each object is represented as an array of field values.

    {
       "class_a" : [[obj1_f1,obj1_f2],[obj2_f1,obj2_f2],[obj3_f1,obj3_f2]],
       "class_b" : [[obj1_f1,obj1_f2],[obj2_f1,obj2_f2],[obj3_f1,obj3_f2]]
    }
    
An equivalent way to think of this is that each hash value is a column-major
table where a column represents an object, and a row represents a single field
within the object.


IDD data structure
------------------
The idd is represented as a hash of hash of hash of hash. (Whew!)

* The top-level keys of the hash are groups.
* The second-level keys are the class names.
* The third-level keys are the field names.
* The fourth-level keys are the field-level attribute names. The attribute 
  values may be either single values or arrays.

Each class has a special field-level hash with the key "`__self__`" which
contains class-level attributes, such as a description of the class.


Parsing the idf
---------------
When parsing the idf, we need to look at the class name of each entry, and 
use that to look at the idd model. We iterate through the idd for the class.
For each field, if the vartype is N, we look at the type. If it is integer, 
on the class field value we call #to_i, if real, we call #to_f. If a class
value doesn't exist for the field, we push a nil into the array for that
instance.


Handling Item Delegates for editing table entries
-------------------------------------------------
When a class is selected for viewing, we:

* Call set_class on the idf data model so that all (row, column) indices
  point into the arrays of the proper class.
* Examine the idd model for this class and instantiate a Choicer with
  appropriate combobox entries for every field that has type: choice.
  Initially, we will just populate with the field's "key" attributes.
  Later, we will need to figure out how to build a hash of all the reference
  names in the idd and look for those to build options for fields that are of
  type: object-list.
* Examine the idd model for this class and instantiate an IntRanger with 
  appropriate min max specs for every field with type: integer
* Examine the idd model for this class and instantiate a FloatRanger with
  apprropriate min max specs for every field with vartype: N and type: real
  or no type set.
* Set the Choicer, IntRanger, and FloatRanger on the DelegateCustomizer

For clarity, a single instance of Choicer contains choices for every 
type: choice field in a given class. Likewise for *Ranger: a single class will
result in the creation of one Choicer, one IntRanger, and one FloatRanger.

The DelegateCustomizer will be called each time the user selects a field to 
edit. It will create a combobox if the Choicer has choices for the field, an 
Int spinbox if IntRanger has minmax for the field, or a Double spinbox if 
FloatRanger has minmax for the field.


Saving out an altered idf
-------------------------
We iterate through the idf data model. For each class name, we look up its
group in the idd and write out a group banner. Then we iterate through the class
array. For each object, we start at the end of the array and work backwards,
popping off the entry for anything with a nil value until we reach a non-nil 
value. Then we strip every line to remove any errant whitespace. Then we add a 
comma to the end of every line except the last, to which we instead add a 
semicolon. Then we write each line to the file, followed by a blank line.


Desired Features
----------------
* Filter the objects in a class by keys.
* Change the value of a field in multiple ojects simultaneously.
* Filter geometry by computed keys such as "South-facing"
* Indicate default values via tooltips. Set this at Item Delegate stage?
* Validate an idf against the idd.
* Reorder objects in a class alphabetically by name.

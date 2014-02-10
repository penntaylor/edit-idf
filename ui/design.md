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
table where a column represents an object, and a row represents a single 
field within the object.

IDD data structure
------------------
The idd is represented as a hash of hash of hash.

The top-level keys of the hash are groups.

The second-level keys are the class names.

The third-level keys are the field names.

The fourth-level keys are the field-level attribute names. The values of 

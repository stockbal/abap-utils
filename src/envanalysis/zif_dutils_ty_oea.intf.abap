"! <p class="shorttext synchronized" lang="en">Types for Object environment analysis</p>
INTERFACE zif_dutils_ty_oea
  PUBLIC .

  "! <p class="shorttext synchronized" lang="en">Detailed source object for analysis</p>
  TYPES BEGIN OF ty_source_object_db.
  INCLUDE TYPE zdutilsoea_so.
  TYPES END OF ty_source_object_db.

  "! <p class="shorttext synchronized" lang="en">Extended source object for analysis</p>
  TYPES BEGIN OF ty_source_object_ext.
  INCLUDE TYPE ty_source_object_db.
  TYPES: package          TYPE devclass,
         needs_processing TYPE abap_bool.
  TYPES END OF ty_source_object_ext.

  "! <p class="shorttext synchronized" lang="en">Used object</p>
  TYPES BEGIN OF ty_used_object_db.
  INCLUDE TYPE zdutilsoea_uo.
  TYPES END OF ty_used_object_db.

  "! <p class="shorttext synchronized" lang="en">Object environment analysis info</p>
  TYPES BEGIN OF ty_analysis_info_db.
  INCLUDE TYPE zdutilsoea_ai.
  TYPES END OF ty_analysis_info_db.

  TYPES:
    "! <p class="shorttext synchronized" lang="en">Aggregation level for analysis</p>
    ty_aggregation_level  TYPE c LENGTH 1,

    "! <p class="shorttext synchronized" lang="en">Mode for environment analysis</p>
    ty_analysis_mode      TYPE c LENGTH 1,

    "! <p class="shorttext synchronized" lang="en">Extended Source Objects</p>
    ty_source_objects_ext TYPE STANDARD TABLE OF ty_source_object_ext WITH EMPTY KEY,

    "! List of detailed source objects for analysis
    ty_source_objects_db  TYPE STANDARD TABLE OF ty_source_object_db WITH EMPTY KEY,

    "! Result from environment analysis
    BEGIN OF ty_used_object,
      type             TYPE seu_obj,
      name             TYPE seu_objkey,
      enclosing_object TYPE sobj_name,
      calling_object   TYPE sobj_name,
    END OF ty_used_object,

    ty_used_objects    TYPE STANDARD TABLE OF ty_used_object WITH EMPTY KEY,

    "! <p class="shorttext synchronized" lang="en">List of used objects</p>
    ty_used_objects_db TYPE STANDARD TABLE OF ty_used_object_db WITH EMPTY KEY.

ENDINTERFACE.

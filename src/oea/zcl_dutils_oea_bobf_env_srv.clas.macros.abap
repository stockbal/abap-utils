*"* use this source file for any macro definitions you need
*"* in the implementation part of the class
DEFINE _add_used_obj.
  add_used_object(
    EXPORTING used_obj_name = &1
              external_type = &2
    CHANGING  used_objects  = used_objects ).
END-OF-DEFINITION.

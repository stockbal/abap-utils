"! <p class="shorttext synchronized" lang="en">Data Access for object environment analysis</p>
CLASS zcl_dutils_oea_dac DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES:
      zif_dutils_oea_dac.

    CLASS-METHODS:
      get_instance
        RETURNING
          VALUE(result) TYPE REF TO zif_dutils_oea_dac.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      instance TYPE REF TO zcl_dutils_oea_dac.
ENDCLASS.


CLASS zcl_dutils_oea_dac IMPLEMENTATION.

  METHOD get_instance.
    IF instance IS INITIAL.
      instance = NEW #( ).
    ENDIF.

    result = instance.
  ENDMETHOD.

  METHOD zif_dutils_oea_dac~delete_by_analysis_ids.
    CHECK analysis_ids IS NOT INITIAL.

    DELETE FROM zdutilsoea_ai WHERE analysis_id IN analysis_ids.
    DELETE FROM zdutilsoea_so WHERE analysis_id IN analysis_ids.
    DELETE FROM zdutilsoea_uo WHERE analysis_id IN analysis_ids.
  ENDMETHOD.

  METHOD zif_dutils_oea_dac~insert_analysis_info.
    CHECK analysis_info IS NOT INITIAL.

    INSERT zdutilsoea_ai FROM analysis_info.
  ENDMETHOD.

  METHOD zif_dutils_oea_dac~insert_source_object.
    CHECK source_object IS NOT INITIAL.

    INSERT zdutilsoea_so FROM source_object.
  ENDMETHOD.

  METHOD zif_dutils_oea_dac~insert_source_objects.
    CHECK source_objects IS NOT INITIAL.

    INSERT zdutilsoea_so FROM TABLE source_objects.
  ENDMETHOD.

  METHOD zif_dutils_oea_dac~insert_used_objects.
    CHECK used_objects IS NOT INITIAL.

    INSERT zdutilsoea_uo FROM TABLE used_objects.
  ENDMETHOD.


ENDCLASS.

"! <p class="shorttext synchronized" lang="en">Global Type Definitions</p>
INTERFACE zif_dutils_ty_global
  PUBLIC .

  TYPES:
    "! <p class="shorttext synchronized" lang="en">List of Package Names</p>
    ty_package_names            TYPE STANDARD TABLE OF devclass WITH EMPTY KEY,
    "! <p class="shorttext synchronized" lang="en">Range of Package Name</p>
    ty_package_name_range       TYPE RANGE OF devclass,
    "! <p class="shorttext synchronized" lang="en">Range of Application Component </p>
    ty_appl_comp_range          TYPE RANGE OF ufps_posid,
    "! <p class="shorttext synchronized" lang="en">Range of Software Component</p>
    ty_software_comp_range      TYPE RANGE OF dlvunit,
    "! <p class="shorttext synchronized" lang="en">Range of Transport Layer</p>
    ty_transport_layer_range    TYPE RANGE OF devlayer,
    "! <p class="shorttext synchronized" lang="en">Range of Source System</p>
    ty_source_system_range      TYPE RANGE OF srcsystem,
    "! <p class="shorttext synchronized" lang="en">Range of Responsible Person</p>
    ty_responsible_person_range TYPE RANGE OF responsibl,
    "! <p class="shorttext synchronized" lang="en">Range of Class/Interface Name</p>
    ty_class_intf_range         TYPE RANGE OF seoclsname,
    "! <p class="shorttext synchronized" lang="en">Range of Function Group Name</p>
    ty_func_group_name_range    TYPE RANGE OF rs38l_area,
    "! <p class="shorttext synchronized" lang="en">Range of Report Name</p>
    ty_report_name_range        TYPE RANGE OF programm,
    "! <p class="shorttext synchronized" lang="en">Range of Web Dynpro Component Name</p>
    ty_wdyn_comp_name_range     TYPE RANGE OF wdy_component_name,
    "! <p class="shorttext synchronized" lang="en">Range of DDIC Type</p>
    ty_ddic_type_range          TYPE RANGE OF tabname,
    "! <p class="shorttext synchronized" lang="en">Range of Type Group Name</p>
    ty_type_group_range         TYPE RANGE OF typegroup,
    "! <p class="shorttext synchronized" lang="en">Range of Generation Flag</p>
    ty_genflag_range            TYPE RANGE OF tadir-genflag,
    "! <p class="shorttext synchronized" lang="en">Range of TADIR-OBJECT - Object Type</p>
    ty_tadir_type_range         TYPE RANGE OF tadir-object,
    "! <p class="shorttext synchronized" lang="en">Range of Tabname</p>
    ty_table_range              TYPE RANGE OF dd02l-tabname,
    "! <p class="shorttext synchronized" lang="en">Range of Viewname</p>
    ty_view_range               TYPE RANGE OF dd25l-viewname,
    "! <p class="shorttext synchronized" lang="en">Range of DDL Name</p>
    ty_ddlname_range            TYPE RANGE OF ddddlsrc-ddlname.
ENDINTERFACE.

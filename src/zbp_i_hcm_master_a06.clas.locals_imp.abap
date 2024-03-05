CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CONSTANTS: created TYPE c LENGTH 1 VALUE 'C',
               updated TYPE c LENGTH 1 VALUE 'U',
               deleted TYPE c LENGTH 1 VALUE 'D'.

    TYPES: BEGIN OF ty_buffer_master.
             INCLUDE TYPE zhcm_master_a06 AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer_master.

    TYPES: tt_master TYPE SORTED TABLE OF ty_buffer_master WITH UNIQUE KEY e_number.

    CLASS-DATA mt_buffer_master TYPE tt_master.
ENDCLASS.

CLASS lhc_HCMMaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR HCMMaster RESULT result.

    METHODS:  create FOR MODIFY IMPORTING entities FOR CREATE HCMMaster,
      update FOR MODIFY IMPORTING entities FOR UPDATE HCMMaster,
      delete FOR MODIFY IMPORTING keys FOR DELETE HCMMaster.

    METHODS read FOR READ IMPORTING keys FOR READ HCMMaster RESULT result.

    METHODS lock FOR LOCK IMPORTING keys FOR LOCK HCMMaster.

ENDCLASS.

CLASS lhc_HCMMaster IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    GET TIME STAMP FIELD DATA(lv_time_stamp).
    DATA(lv_uname) = cl_abap_context_info=>get_user_technical_name(  ).

    SELECT MAX( e_number ) FROM zhcm_master_a06
            INTO @DATA(lv_max_employee_number).

    LOOP AT entities INTO DATA(ls_entities).

      ls_entities-%data-crea_date_time = lv_time_stamp.
      ls_entities-%data-crea_uname     = lv_uname.
      ls_entities-%data-e_number       = lv_max_employee_number + 1 .

      INSERT VALUE #( flag = lcl_buffer=>created
                      data = CORRESPONDING #( ls_entities-%data ) ) INTO TABLE  lcl_buffer=>mt_buffer_master.

      IF NOT ls_entities-%cid IS INITIAL.

        INSERT VALUE #( %cid = ls_entities-%cid
                        e_number = ls_entities-e_number ) INTO TABLE mapped-hcmmaster.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    GET TIME STAMP FIELD DATA(lv_time_stamp).
    DATA(lv_uname) = cl_abap_context_info=>get_user_technical_name(  ).



    LOOP AT entities INTO DATA(ls_entities).

      SELECT SINGLE * FROM zhcm_master_a06
            WHERE e_number EQ @ls_entities-%data-e_number
            INTO @DATA(ls_ddbb).

      ls_entities-%data-lchg_date_time = lv_time_stamp.
      ls_entities-%data-crea_uname     = lv_uname.

      INSERT VALUE #( flag = lcl_buffer=>updated
                      data = VALUE #( e_number = ls_entities-%data-e_number
                                      e_name = COND #( WHEN ls_entities-%control-e_name EQ if_abap_behv=>mk-on
                                                       THEN ls_entities-%data-e_name
                                                       ELSE ls_ddbb-e_name )
                                      e_departament = COND #( WHEN ls_entities-%control-e_departament EQ if_abap_behv=>mk-on
                                                       THEN ls_entities-%data-e_departament
                                                       ELSE ls_ddbb-e_departament )
                                      status = COND #( WHEN ls_entities-%control-status EQ if_abap_behv=>mk-on
                                                       THEN ls_entities-%data-status
                                                       ELSE ls_ddbb-status )
                                      job_title = COND #( WHEN ls_entities-%control-job_title EQ if_abap_behv=>mk-on
                                                       THEN ls_entities-%data-job_title
                                                       ELSE ls_ddbb-job_title )
                                      start_date = COND #( WHEN ls_entities-%control-start_date EQ if_abap_behv=>mk-on
                                                       THEN ls_entities-%data-start_date
                                                       ELSE ls_ddbb-start_date )
                                      end_date = COND #( WHEN ls_entities-%control-end_date EQ if_abap_behv=>mk-on
                                                       THEN ls_entities-%data-end_date
                                                       ELSE ls_ddbb-end_date )
                                      email = COND #( WHEN ls_entities-%control-email EQ if_abap_behv=>mk-on
                                                       THEN ls_entities-%data-email
                                                       ELSE ls_ddbb-email )
                                      m_number = COND #( WHEN ls_entities-%control-m_number EQ if_abap_behv=>mk-on
                                                       THEN ls_entities-%data-m_number
                                                       ELSE ls_ddbb-m_number )
                                      m_name = COND #( WHEN ls_entities-%control-m_name EQ if_abap_behv=>mk-on
                                                       THEN ls_entities-%data-m_name
                                                       ELSE ls_ddbb-m_name )
                                      m_department = COND #( WHEN ls_entities-%control-m_department EQ if_abap_behv=>mk-on
                                                       THEN ls_entities-%data-m_department
                                                       ELSE ls_ddbb-m_department )
                                     crea_date_time = ls_ddbb-crea_date_time
                                     crea_uname = ls_ddbb-crea_uname
                                                     ) ) INTO TABLE  lcl_buffer=>mt_buffer_master.

      IF NOT ls_entities-e_number IS INITIAL.

        INSERT VALUE #( %cid     = ls_entities-%data-e_number
                        e_number = ls_entities-%data-e_number ) INTO TABLE mapped-hcmmaster.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_keys).
      INSERT VALUE #( flag = lcl_buffer=>deleted
                      data = VALUE #( e_number = ls_keys-e_number ) ) INTO TABLE lcl_buffer=>mt_buffer_master.

      IF NOT ls_keys-e_number IS INITIAL.

        INSERT VALUE #( %cid = ls_keys-%key-e_number
                        e_number = ls_keys-%key-e_number ) INTO TABLE mapped-hcmmaster.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_HCMMaster DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS: finalize          REDEFINITION,
      check_before_save REDEFINITION,
      save              REDEFINITION,
      cleanup           REDEFINITION,
      cleanup_finalize  REDEFINITION.

ENDCLASS.

CLASS lsc_HCMMaster IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    DATA: lt_data_created TYPE STANDARD TABLE OF zhcm_master_a06,
          lt_data_updated TYPE STANDARD TABLE OF zhcm_master_a06,
          lt_data_deleted TYPE STANDARD TABLE OF zhcm_master_a06.

    lt_data_created = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
    WHERE ( flag = lcl_buffer=>created ) ( <row>-data ) ).

    IF NOT lt_data_created IS INITIAL.
      INSERT zhcm_master_a06 FROM TABLE @lt_data_created.
    ENDIF.

    lt_data_updated = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
    WHERE ( flag = lcl_buffer=>updated ) ( <row>-data ) ).

    IF NOT lt_data_updated IS INITIAL.
      UPDATE zhcm_master_a06 FROM TABLE @lt_data_updated.
    ENDIF.

    lt_data_deleted = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
    WHERE ( flag = lcl_buffer=>deleted ) ( <row>-data ) ).

    IF NOT lt_data_deleted IS INITIAL.
      DELETE zhcm_master_a06 FROM TABLE @lt_data_deleted.
    ENDIF.

    CLEAR lcl_buffer=>mt_buffer_master.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

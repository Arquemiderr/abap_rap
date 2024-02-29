CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS:
      get_instance_features FOR INSTANCE FEATURES IMPORTING keys REQUEST requested_features FOR Travel RESULT result,
      acceptTravel FOR MODIFY IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result,
      rejectTravel FOR MODIFY IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS:
      validateCustomer FOR VALIDATE ON SAVE IMPORTING keys FOR Travel~validateCustomer,
      validateDates FOR VALIDATE ON SAVE IMPORTING keys FOR Travel~validateDates,
      validateStatus FOR VALIDATE ON SAVE IMPORTING keys FOR Travel~validateStatus.

    METHODS  get_instance_authorizations FOR INSTANCE AUTHORIZATION IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF z_i_travel_a06
    ENTITY Travel
    FIELDS ( travel_id overall_status )
        WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
        RESULT DATA(lt_travel_result).

    result = VALUE #( FOR ls_travel IN lt_travel_result (
                     %key                  = ls_travel-%key
                     %field-travel_id      = if_abap_behv=>fc-f-read_only
                     %field-overall_status = if_abap_behv=>fc-f-read_only
                     %assoc-_Booking       = if_abap_behv=>fc-o-enabled
                     %action-acceptTravel  = COND #( WHEN ls_travel-overall_status = 'A'
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled )
                     %action-rejectTravel  = COND #( WHEN ls_travel-overall_status = 'X'
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled )  ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.

* CB9980000562

*    DATA lv_authh TYPE c LENGTH 2.
*
*    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).
*    IF lv_user EQ 'CB9980000562'.
*      lv_authh = if_abap_behv=>auth-allowed.
*    ELSE.
*      lv_authh = if_abap_behv=>auth-unauthorized.
*    ENDIF.
*

    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name(  ) EQ 'CB9980000562'
                            THEN if_abap_behv=>auth-allowed
                            ELSE if_abap_behv=>auth-unauthorized  ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).

      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result> = VALUE #( %key                           = <ls_keys>-%key
                             %op-%update                    = lv_auth
                             %delete                        = lv_auth
                             %action-acceptTravel           = lv_auth
                             %action-rejectTravel           = lv_auth
                             %action-createTravelByTemplate = lv_auth
                             %assoc-_Booking                = lv_auth ).

    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.

*
* Modify in local mode - BO - related updates there are not relevant for authorization objects
    MODIFY ENTITIES OF z_i_travel_a06 IN LOCAL MODE
           ENTITY Travel
           UPDATE FIELDS ( overall_status )
           WITH VALUE #( FOR key_row IN keys ( travel_id = key_row-travel_id
                                               overall_status = 'A' ) )
           FAILED failed
           REPORTED reported.

    READ ENTITIES OF z_i_travel_a06 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( agency_id
             customer_id
             begin_date
             end_date
             booking_fee
             total_price
             currency_code
             overall_status
             description
             created_by
             created_at
             last_changed_by
             last_changed_at )
             WITH VALUE #( FOR key_row1 IN keys ( travel_id = key_row1-travel_id ) )
             RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel ( travel_id = ls_travel-travel_id
                                                   %param = ls_travel ) ).

    LOOP     AT  lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_travel_msg) = <ls_travel>-travel_id.

      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.

      APPEND VALUE #( travel_id = <ls_travel>-travel_id
                              %msg  = new_message( id = 'Z_MC_TRAVEL_A06'
                                                   number = '005'
                                                   v1 = lv_travel_msg
                                                   severity = if_abap_behv_message=>severity-success )
                                                   %element-customer_id = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD createTravelByTemplate.

*  keys[ 1 ]
*  result[ 1 ]
*  mapped-
*  failed-
*  reported-

    READ ENTITIES OF z_i_travel_a06
    ENTITY Travel
    FIELDS ( travel_id agency_id customer_id booking_fee total_price currency_code )
    WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
    RESULT DATA(lt_read_entity_travel)
    FAILED failed
    REPORTED reported.


*    READ ENTITY z_i_travel_a06
*    FIELDS ( travel_id agency_id customer_id booking_fee total_price currency_code )
*    WITH VALUE #( for row_key in keys ( %key = row_key-%key ) )
*    RESULT lt_read_entity_travel
*    FAILED failed
*    REPORTED reported.

    DATA lt_create_travel TYPE TABLE FOR CREATE z_i_travel_a06\\Travel.

    SELECT MAX( travel_id ) FROM ztravel_a06
            INTO @DATA(lv_travel_id).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    lt_create_travel = VALUE #( FOR  create_row IN lt_read_entity_travel INDEX INTO idx
                                ( travel_id = lv_travel_id + idx
                                agency_id = create_row-agency_id
                                customer_id = create_row-customer_id
                                begin_date = lv_today
                                end_date = lv_today + 30
                                booking_fee = create_row-booking_fee
                                total_price = create_row-total_price
                                currency_code = create_row-currency_code
                                description = 'Add comments'
                                overall_status = 'O' ) ).

    MODIFY ENTITIES OF z_i_travel_a06
        IN LOCAL MODE ENTITY Travel
        CREATE FIELDS ( travel_id
                        agency_id
                        customer_id
                        begin_date
                        end_date
                        booking_fee
                        total_price
                        currency_code
                        description
                        overall_status )
            WITH lt_create_travel
            MAPPED mapped
            FAILED failed
            REPORTED reported.

    result = VALUE #( FOR result_row IN lt_create_travel INDEX INTO idx
                        ( %cid_ref  = keys[ idx ]-%cid_ref
                          %key = keys[ idx ]-%key
                          %param = CORRESPONDING #( result_row ) ) ).

  ENDMETHOD.

  METHOD rejectTravel.

*
* Modify in local mode - BO - related updates there are not relevant for authorization objects
    MODIFY ENTITIES OF z_i_travel_a06 IN LOCAL MODE
           ENTITY Travel
           UPDATE FIELDS ( overall_status )
           WITH VALUE #( FOR key_row IN keys ( travel_id = key_row-travel_id
                                               overall_status = 'X' ) ) "Rejected
           FAILED failed
           REPORTED reported.

    READ ENTITIES OF z_i_travel_a06 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( agency_id
             customer_id
             begin_date
             end_date
             booking_fee
             total_price
             currency_code
             overall_status
             description
             created_by
             created_at
             last_changed_by
             last_changed_at )
             WITH VALUE #( FOR key_row1 IN keys ( travel_id = key_row1-travel_id ) )
             RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel ( travel_id = ls_travel-travel_id
                                                   %param = ls_travel ) ).

    LOOP     AT  lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_travel_msg) = <ls_travel>-travel_id.

      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.

      APPEND VALUE #( travel_id = <ls_travel>-travel_id
                              %msg  = new_message( id = 'Z_MC_TRAVEL_A06'
                                                   number = '006'
                                                   v1 = lv_travel_msg
                                                   severity = if_abap_behv_message=>severity-success )
                                                   %element-customer_id = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCustomer.
    READ ENTITIES OF z_i_travel_a06 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( customer_id )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = customer_id EXCEPT * ).
    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer FIELDS customer_id
    FOR ALL ENTRIES IN @lt_customer
    WHERE customer_id EQ @lt_customer-customer_id
    INTO TABLE @DATA(lt_customer_db).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-customer_id IS INITIAL
          OR NOT line_exists( lt_customer_db[ customer_id = <ls_travel>-customer_id ] ).

        APPEND VALUE #( travel_id = <ls_travel>-travel_id ) TO failed-travel.

        APPEND VALUE #( travel_id = <ls_travel>-travel_id
                        %msg  = new_message( id = 'Z_MC_TRAVEL_A06'
                                             number = '001'
                                             v1 = <ls_travel>-travel_id
                                             severity = if_abap_behv_message=>severity-error )
                                             %element-customer_id = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITY z_i_travel_a06\\Travel
        FIELDS ( begin_date end_date )
        WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
        RESULT DATA(lt_travel_results).

    LOOP AT lt_travel_results INTO DATA(ls_travel_result).

      IF ls_travel_result-end_date LT ls_travel_result-begin_date. "end_date before begin_date

        APPEND VALUE #( %key = ls_travel_result-%key
                        travel_id = ls_travel_result-travel_id ) TO failed-travel.

        APPEND VALUE #( %key = ls_travel_result-%key
                        %msg = new_message( id       = 'Z_MC_TRAVEL_A06'
                                            number   = '004'
                                            v1       = ls_travel_result-begin_date
                                            v2       = ls_travel_result-end_date
                                            v3       = ls_travel_result-travel_id
                                            severity = if_abap_behv_message=>severity-error )
                         %element-begin_date = if_abap_behv=>mk-on
                         %element-end_date = if_abap_behv=>mk-on ) TO reported-travel.

      ELSEIF ls_travel_result-begin_date < cl_abap_context_info=>get_system_date(  ).

        APPEND VALUE #( %key = ls_travel_result-%key
                        travel_id = ls_travel_result-travel_id ) TO failed-travel.

        APPEND VALUE #( %key = ls_travel_result-%key
                        %msg = new_message( id       = 'Z_MC_TRAVEL_A06'
                                            number   = '002'
                                            severity = if_abap_behv_message=>severity-error )
                         %element-begin_date = if_abap_behv=>mk-on
                         %element-end_date = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY z_i_travel_a06\\Travel
         FIELDS ( overall_status )
         WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
         RESULT DATA(lt_travel_result).


    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      CASE ls_travel_result-overall_status.

        WHEN 'O'. "Open
        WHEN 'X'. "Cancelled
        WHEN 'A'. "Accepted
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.

          APPEND VALUE #( %key = ls_travel_result-%key
                          %msg = new_message( id = 'Z_MC_TRAVEL_A06'
                                              number = '003'
                                              v1 = ls_travel_result-overall_status
                                              severity = if_abap_behv_message=>severity-error )
                          %element-overall_status = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_A06 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PUBLIC SECTION.
    CONSTANTS: create TYPE string VALUE 'CREATE',
               update TYPE string VALUE 'UPDATE',
               delete TYPE string VALUE 'DELETE'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_A06 IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_travel_a06   TYPE STANDARD TABLE OF zlog_a06,
          lt_travel_a06_u TYPE STANDARD TABLE OF zlog_a06.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).

    IF NOT create-travel IS INITIAL.

      lt_travel_a06 = CORRESPONDING #( create-travel ).


      LOOP AT lt_travel_a06 ASSIGNING FIELD-SYMBOL(<ls_travel_a06>).

        GET TIME STAMP FIELD <ls_travel_a06>-created_at.
        <ls_travel_a06>-changing_operation = lsc_z_i_travel_a06=>create.

        READ TABLE create-travel WITH TABLE KEY entity COMPONENTS travel_id = <ls_travel_a06>-travel_id
        INTO DATA(ls_travel).

        IF sy-subrc EQ 0.

          IF ls_travel-%control-booking_fee EQ cl_abap_behv=>flag_changed.

            <ls_travel_a06>-changed_field_name = 'booking_fee'.
            <ls_travel_a06>-changed_value      = ls_travel-booking_fee.
            <ls_travel_a06>-user_mod           = lv_user.
            TRY.
                <ls_travel_a06>-change_id          = cl_system_uuid=>create_uuid_x16_static(  ).
              CATCH cx_uuid_error.
            ENDTRY.
            APPEND <ls_travel_a06> TO lt_travel_a06_u.
          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDIF.

    IF NOT update-travel IS INITIAL.

      lt_travel_a06 = CORRESPONDING #( update-travel ).

      LOOP AT update-travel INTO DATA(ls_update_travel).

        ASSIGN lt_travel_a06[ travel_id = ls_update_travel-travel_id ] TO FIELD-SYMBOL(<ls_travel_a06_bd>).

        GET TIME STAMP FIELD <ls_travel_a06_bd>-created_at.
        <ls_travel_a06_bd>-changing_operation = lsc_z_i_travel_a06=>update.

        IF ls_update_travel-%control-customer_id EQ cl_abap_behv=>flag_changed.

          <ls_travel_a06_bd>-changed_field_name = 'customer_id'.
          <ls_travel_a06_bd>-changed_value      = ls_update_travel-customer_id.
          <ls_travel_a06_bd>-user_mod           = lv_user.
          TRY.
              <ls_travel_a06_bd>-change_id          = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
          ENDTRY.

          APPEND <ls_travel_a06_bd> TO lt_travel_a06_u.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF NOT delete-travel IS INITIAL.

      lt_travel_a06 = CORRESPONDING #( delete-travel ).

      LOOP AT lt_travel_a06 ASSIGNING FIELD-SYMBOL(<ls_travel_a06_del>).
        GET TIME STAMP FIELD <ls_travel_a06_del>-created_at.
        <ls_travel_a06_del>-changing_operation = lsc_z_i_travel_a06=>delete.
        <ls_travel_a06_del>-user_mod = lv_user.
        TRY.
            <ls_travel_a06_del>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
        ENDTRY.
        APPEND <ls_travel_a06_del> TO lt_travel_a06_u.
      ENDLOOP.
    ENDIF.


    IF NOT lt_travel_a06_u IS INITIAL.
      INSERT zlog_a06 FROM TABLE @lt_travel_a06_u.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

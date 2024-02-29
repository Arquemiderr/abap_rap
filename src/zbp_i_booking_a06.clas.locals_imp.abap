CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calcularTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calcularTotalFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

    METHODS get_instance_features FOR FEATURES IMPORTING keys REQUEST requested_features FOR booking RESULT result.
ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calcularTotalFlightPrice.

    IF NOT keys IS INITIAL.

      zcl_aux__travel_a06=>calculate_price( it_travel_id = VALUE #( FOR GROUPS <booking> OF booking_key IN keys
                                                                        GROUP BY booking_key-travel_id WITHOUT MEMBERS ( <booking> ) ) ).

    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.

    READ  ENTITIES OF z_i_travel_a06
          ENTITY Booking
          FIELDS ( booking_id  booking_date booking_status )
              WITH VALUE #( FOR keyval IN keys ( %key = keyval-%key ) )
          RESULT DATA(lt_booking_result).

    result = VALUE #( FOR ls_travel IN lt_booking_result
                        ( %key  = ls_travel-%key
                        %assoc-_BookSupplement = if_abap_behv=>fc-o-enabled ) ).
  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY z_i_travel_a06\\Booking
          FIELDS ( booking_status )
          WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
          RESULT DATA(lt_booking_result).


    LOOP AT lt_booking_result INTO DATA(ls_booking_result).

      CASE ls_booking_result-booking_status.

        WHEN 'N'. "Open
        WHEN 'X'. "Cancelled
        WHEN 'B'. "Accepted
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_booking_result-%key ) TO failed-booking.

          APPEND VALUE #( %key = ls_booking_result-%key
                          %msg = new_message( id = 'Z_MC_TRAVEL_A06'
                                              number = '007'
                                              v1 = ls_booking_result-booking_id
                                              severity = if_abap_behv_message=>severity-error )
                          %element-booking_status = if_abap_behv=>mk-on ) TO reported-booking.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

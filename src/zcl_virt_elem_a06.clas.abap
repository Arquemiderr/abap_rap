CLASS zcl_virt_elem_a06 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_virt_elem_a06 IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF iv_entity = 'Z_C_TRAVEL_A06'.

      LOOP AT it_requested_calc_elements INTO DATA(ls_calc_elements).

        IF ls_calc_elements = 'DISCOUNTPRICE'.

          APPEND 'TOTALPRICE' TO et_requested_orig_elements.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.


    data lt_otiginal_data TYPE STANDARD TABLE OF z_c_travel_a06 WITH DEFAULT KEY.

    lt_otiginal_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_otiginal_data ASSIGNING FIELD-SYMBOL(<ls_original_data>).

    <ls_original_data>-DiscountPrice = <ls_original_data>-TotalPrice - ( <ls_original_data>-TotalPrice * ( 1 / 10 ) ).

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_otiginal_data ).

  ENDMETHOD.

ENDCLASS.

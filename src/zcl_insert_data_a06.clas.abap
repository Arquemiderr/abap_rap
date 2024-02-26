CLASS zcl_insert_data_a06 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_insert_data_a06 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA: lt_travel   TYPE TABLE OF ztravel_a06,
          lt_booking  TYPE TABLE OF zbooking_a06,
          lt_book_sup TYPE TABLE OF zbooksuppl_a06.
    SELECT travel_id, agency_id, customer_id, begin_date,
   end_date,
    booking_fee, total_price, currency_code, description,
    status AS overall_status, createdby AS created_by,
    createdat AS created_at, lastchangedby AS
   last_changed_by,
    lastchangedat AS last_changed_at
    FROM /dmo/travel INTO CORRESPONDING FIELDS OF TABLE
   @lt_travel
    UP TO 15 ROWS.
    SELECT * FROM /dmo/booking INTO CORRESPONDING FIELDS OF
   TABLE @lt_booking.
    SELECT * FROM /dmo/book_suppl INTO CORRESPONDING FIELDS OF
   TABLE @lt_book_sup.
    DELETE FROM: ztravel_a06,
    zbooking_a06,
    zbooksuppl_a06.

    INSERT:
 ztravel_a06 FROM TABLE @lt_travel,
 zbooking_a06 FROM TABLE @lt_booking,
 zbooksuppl_a06 FROM TABLE @lt_book_sup.
    out->write( sy-dbcnt ).
    out->write( 'DONE!' ).

  ENDMETHOD.
ENDCLASS.

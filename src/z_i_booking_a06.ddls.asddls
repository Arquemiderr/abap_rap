@AbapCatalog.sqlViewName: 'ZVW_I_BOOK_A06'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interfaces - Booking'
define view Z_I_BOOKING_A06
  as select from zbooking_a06 as Booking
  association        to parent Z_I_TRAVEL_A06 as _Travel     on  $projection.travel_id = _Travel.travel_id
  composition [0..*] of Z_I_BOOKSUPPL_A06     as _BookSupplement
  association [1..1] to /DMO/I_Customer       as _Customer   on  $projection.customer_id = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier        as _Carrier    on  $projection.carrier_id = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection     as _Connection on  $projection.carrier_id    = _Connection.AirlineID
                                                             and $projection.connection_id = _Connection.ConnectionID

{
      //Booking
  key travel_id,
  key booking_id,
      booking_date,
      customer_id,
      carrier_id,
      connection_id,
      flight_date,
      flight_price,
      currency_code,
      booking_status,
      last_changed_at,
      /* Associations */
      _Travel,
      _BookSupplement,
      _Customer,
      _Carrier,
      _Connection
}

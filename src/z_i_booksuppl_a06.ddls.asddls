@AbapCatalog.sqlViewName: 'ZV_BOOKSUPPL_A06'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interfaces - Booking Supplement'
define view Z_I_BOOKSUPPL_A06
  as select from zbooksuppl_a06 as BookingSupplement
  association        to parent Z_I_BOOKING_A06 as _Booking        on  $projection.travel_id  = _Booking.travel_id
                                                                  and $projection.booking_id = _Booking.booking_id
  association [1..1] to Z_I_TRAVEL_A06         as _Travel         on  $projection.travel_id = _Travel.travel_id
  association [1..1] to /DMO/I_Supplement      as _Product        on  $projection.supplement_id = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText  as _SupplementText on  $projection.supplement_id = _SupplementText.SupplementID
{
      //BookingSupplement
  key travel_id,
  key booking_id,
  key booking_supplement_id,
      supplement_id,
      @Semantics.amount.currencyCode: 'currency_code'
      price,
      @Semantics.currencyCode: true
      currency_code,

      @Semantics.systemDateTime.lastChangedAt: true
      /* Associations */
      _Travel.last_changed_at,
      _Booking,
      _Travel,
      _Product,
      _SupplementText

}

@EndUserText.label: 'Consumption - Travel'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity z_c_travel_a06
  as projection on Z_I_TRAVEL_A06
{
  key     travel_id          as TravelID,
          @ObjectModel.text.element: [ 'AgencyName' ]
          agency_id          as AgencyID,
          _Agency.Name       as AgencyName,
          @ObjectModel.text.element: [ 'CustomerName' ]
          customer_id        as CustomerID,
          _Customer.LastName as CustomerName,
          begin_date         as BeginDate,
          end_date           as EndDate,
          @Semantics.amount: {currencyCode: 'CurrencyCode'}
          booking_fee        as BookingFee,
          @Semantics.amount: {currencyCode: 'CurrencyCode'}
          total_price        as TotalPrice,
          currency_code      as CurrencyCode,
          overall_status     as TravelStatus,
          description        as Description,
          last_changed_at    as LastChangedAt,
          @Semantics.amount: {currencyCode: 'CurrencyCode'}
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_ELEM_A06'
  virtual DiscountPrice : /dmo/total_price,
          /* Associations */
          _Booking : redirected to composition child z_c_booking_a06,
          _Agency,
          _Customer
}

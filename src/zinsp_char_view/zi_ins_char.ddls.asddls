@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inspection Character Interface View'
define root view entity ZI_INS_CHAR as select from zinsp_char_db
composition [0..*] of ZINS_CHAR_ITEM as _Root
{
    key z_product_uuid as ZProductUuid,
    @EndUserText.label: 'Product ID' 
    z_mainproductid as ZMainproductid,
    @EndUserText.label: 'Price' 
    z_mainproductprice as ZMainproductprice,
    @EndUserText.label: 'Currency' 
    z_mainproductpricecur as ZMainproductpricecur,
    z_created_by as ZCreatedBy,
    z_created_at as ZCreatedAt,
    z_last_changed_by as ZLastChangedBy,
    z_last_changed_at as ZLastChangedAt,
    z_local_last_changed_at as ZLocalLastChangedAt,
    _Root // Make association public
}

@EndUserText.label: 'Consumption Inspection Char Item View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_INS_CHAR_ITEM as projection on ZINS_CHAR_ITEM
{
    key ZSubproductUuid,
    ZProductUuid,
    ZSupProductid,
    ZProductType,
    ZSupprdPrice,
    ZSupprdCur,
    ZMainproductid,
    ZCreatedBy,
    ZCreatedAt,
    ZLastChangedBy,
    ZLastChangedAt,
    ZLocalLastChangedAt,
    /* Associations */
    _Item:redirected to parent ZC_INS_CHAR 
}

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inspection Character Item Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZINS_CHAR_ITEM as select from zinsp_charitm_db
association to parent ZI_INS_CHAR as _Item on 
$projection.ZProductUuid = _Item.ZProductUuid
{
    key z_subproduct_uuid as ZSubproductUuid,
    z_product_uuid as ZProductUuid,
    @EndUserText.label: 'Components' 
    z_sup_productid as ZSupProductid,
    @EndUserText.label: 'Product Type' 
    z_product_type as ZProductType,
    @EndUserText.label: 'Price' 
    z_supprd_price as ZSupprdPrice,
    @EndUserText.label: 'Currency' 
    z_supprd_cur as ZSupprdCur,
    @EndUserText.label: 'Product ID' 
    z_mainproductid as ZMainproductid,
    z_created_by as ZCreatedBy,
    z_created_at as ZCreatedAt,
    z_last_changed_by as ZLastChangedBy,
    z_last_changed_at as ZLastChangedAt,
    z_local_last_changed_at as ZLocalLastChangedAt,
    _Item
}

@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTBONE'
define root view entity ZCDSDEMO1RAP1
  as select from ztbone as RAP1
{
  key po_id as PoID,
  vendor_name as VendorName,
  purchase_org as PurchaseOrg,
  cur_code as CurCode,
  created_by as CreatedBy,
  created_on as CreatedOn,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}

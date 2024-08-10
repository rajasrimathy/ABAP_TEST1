@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZCDSDEMO1RAP1'
@ObjectModel.semanticKey: [ 'PoID' ]
define root view entity ZC_TBONE000
  provider contract transactional_query
  as projection on ZCDSDEMO1RAP1
{
  key PoID,
  VendorName,
  PurchaseOrg,
  CurCode,
  CreatedBy,
  CreatedOn,
  LastChangedAt
  
}

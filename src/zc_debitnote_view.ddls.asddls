@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Debit Note Consumption View'
@Metadata.allowExtensions: true
define root view entity ZC_DEBITNOTE_VIEW 
provider contract transactional_query 
as projection on ZI_DEBITNOTE_VIEW
{

    key ZDebitNoteUuid,
    ZDebitNoteID,
    ZDebitmemoreqtype,
    ZSalesorganization,
    ZDistributionchannel,
    ZOrganizationdivision,
    ZSoldtoparty,
    ZCreatedBy,
    ZCreatedAt,
    ZLastChangedBy,
    ZLastChangedAt,
    ZLocalLastChangedAt
}

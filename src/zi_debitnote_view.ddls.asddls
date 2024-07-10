@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Debit Note Interface View'
define root view entity ZI_DEBITNOTE_VIEW as select from zdebitnote_root

{
       key z_debitnoteuuid as ZDebitNoteUuid,
     z_debitnoteid  as ZDebitNoteID,
    z_debitmemoreqtype as ZDebitmemoreqtype,
    z_salesorganization as ZSalesorganization,
    z_distributionchannel as ZDistributionchannel,
    z_organizationdivision as ZOrganizationdivision,
    z_soldtoparty as ZSoldtoparty,
    z_created_by as ZCreatedBy,
    z_created_at as ZCreatedAt,
    z_last_changed_by as ZLastChangedBy,
    z_last_changed_at as ZLastChangedAt,
    z_local_last_changed_at as ZLocalLastChangedAt
   
}

//composition of target_data_source_name as _association_name

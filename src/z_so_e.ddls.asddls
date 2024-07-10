@AbapCatalog.sqlViewAppendName: 'Z_SO_E'
@EndUserText.label: 'E_SALESDOCUMENTBASIC'
extend view E_SalesDocumentBasic with Z_SO_E
{
    Persistence.zz_extfield_sdh
}

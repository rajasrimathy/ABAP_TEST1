@AbapCatalog.sqlViewName: 'ZSQLVIEW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Testing CDS'
define view ztab_cds as select from ztab_table1
{
    key sno as Serial_no,
      firstname  as fname,
      lastname  as lname,
      grade      ,
      address   
}

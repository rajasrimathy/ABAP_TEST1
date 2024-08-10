@AbapCatalog.sqlViewName:'ZDEMO1RAP'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'First Demo prg on RAP'
@UI.headerInfo : {typeNamePlural : 'Purchase Order'}
define view zdemo1rap1 as select from ztbone
{
 @UI.facet: [{ purpose: #STANDARD,
 type: #IDENTIFICATION_REFERENCE,
 label : 'Purchase Order' , position : 10 }]  
 @UI.selectionField: [{position : 10 }]
 @UI.lineItem: [{position : 10 }] 
 @UI.identification: [{position : 10 }]
 key po_id   , 
 @UI.facet: [{ purpose: #STANDARD,
 type: #IDENTIFICATION_REFERENCE,
 label : 'Purchase ID' , position : 20 }] 
  @UI.selectionField: [{position : 20 }]
 @UI.lineItem: [{position : 20 }] 
 @UI.identification: [{position : 20 }]
 vendor_name  ,
  @UI.selectionField: [{position : 30 }]
 @UI.lineItem: [{position : 30 }] 
 @UI.identification: [{position : 30 }]
  purchase_org ,
  @UI.selectionField: [{position : 40 }]
 @UI.lineItem: [{position : 40 }] 
 @UI.identification: [{position : 40 }]
  cur_code     ,
  @UI.selectionField: [{position : 50 }]
 @UI.lineItem: [{position : 50 }] 
 @UI.identification: [{position : 50 }]
  created_by   ,
  @UI.selectionField: [{position : 60 }]
 @UI.lineItem: [{position : 60 }] 
 @UI.identification: [{position : 60 }]
  created_on  
   }

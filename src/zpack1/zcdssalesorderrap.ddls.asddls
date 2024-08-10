@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS View for Sales order RAP'



define root view entity zcdssalesorderrap as select from zsalesorderrap
{       
  
  
  @UI.facet: [{ purpose : #STANDARD,
  type :#IDENTIFICATION_REFERENCE,
  label : 'Sales OrderID' ,position: 1  }]
  @UI.identification: [{ position: 1 }]    
  @UI.selectionField: [{position : 1 }]
  @UI.lineItem: [{position : 1 }]    
  key so_id     as So_Id,
  
  @UI.facet: [{ purpose : #STANDARD,
  type :#IDENTIFICATION_REFERENCE,
  label : 'Customer' ,position: 2  }]
  @UI.identification: [{ position: 2 }]
  @UI.selectionField: [{position : 2 }]
  @UI.lineItem: [{position : 2 }]    
  customer      as Customer,
  
  @EndUserText.label: 'Abap Currency' 
  @UI.identification: [{ position: 3 }]
  currency_code  as Currency,
  
  @UI.identification: [{ position: 4 }]
  @EndUserText.label: 'Sales Organisation' 
  sales_org    as Sales_Org    
}

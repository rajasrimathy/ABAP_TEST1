@AbapCatalog.viewEnhancementCategory : [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for student table'
@Metadata.ignorePropagatedAnnotations :true
@ObjectModel.usageType: {
serviceQuality : #X,
sizeCategory : #S,
dataClass :#MIXED
}
define root view entity ZCDSTAB2 as select from ztab2
{
 key id as ID,
 first_name as FirstName,
 last_name as LastName,
 age as Age,
 course as Course,
 course_desc as Course_Desc,
 status as Status,
 gender as Gender,
 dob as Dob,
 created_name as CreatedName,
 created_date as CreatedDate,
 changed_name as ChangeddName,
 changed_date as ChangeddDate
}

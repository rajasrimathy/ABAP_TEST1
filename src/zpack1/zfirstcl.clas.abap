CLASS zfirstcl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES : IF_OO_ADT_CLASSRUN.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZFIRSTCL IMPLEMENTATION.


METHOD IF_OO_ADT_CLASSRUN~main.

DATA : LT_PO TYPE STANDARD TABLE OF ZTBONE.


       lt_po = VALUE #( ( po_id = '1234' vendor_name = 'Rekha'  purchase_org = 'abc'
       cur_code = 'USD' created_by = 'pricol' created_on = '20240405111111' )

       (  po_id = '1235' vendor_name = 'Reethu'  purchase_org = 'abc'
       cur_code = 'USD' created_by = 'pricol' created_on = '20240405111111' )

       ( po_id = '1236' vendor_name = 'Raja'  purchase_org = 'abc'
       cur_code = 'USD' created_by = 'pricol' created_on = '20240405111111' )

       (  po_id = '1237' vendor_name = 'Reebhu'  purchase_org = 'abc'
       cur_code = 'USD' created_by = 'pricol' created_on = '20240405111111' ) ).


       DELETE from ztbone.
       insert ztbone from TABLE @lt_po.

       out->write( 'Records Inserted' )  .


ENDMETHOD.
ENDCLASS.

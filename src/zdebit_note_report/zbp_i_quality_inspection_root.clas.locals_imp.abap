CLASS lsc_zi_quality_inspection_root DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_quality_inspection_root IMPLEMENTATION.

  METHOD save_modified.
*    DATA: lt_ZI_QUALITY_INSPECTION_ROOT TYPE STANDARD TABLE OF zi_quality_inspection_root,
*
*          ls_item1                      TYPE zi_quality_inspection_item,
*          total_price                   TYPE p DECIMALS 2 VALUE 0,
*          total_price_up                TYPE p DECIMALS 2 VALUE 0.
*
*    " Handle creation if required
*    IF create-qualityinsroot IS NOT INITIAL.
*      lt_ZI_QUALITY_INSPECTION_ROOT = CORRESPONDING #( create-qualityinsroot ).
*    ENDIF.
*
*    " Handle updates
*    IF update-qualityinsroot IS NOT INITIAL.
*      lt_ZI_QUALITY_INSPECTION_ROOT = CORRESPONDING #( update-qualityinsroot ).
*LOOP AT lt_ZI_QUALITY_INSPECTION_ROOT INTO DATA(ls_ZI_QUALITY_INSPECTION_ROOT).
*        CLEAR: total_price, total_price_up.
*
*
*
*          READ ENTITIES OF zi_quality_inspection_root  IN LOCAL MODE
*           ENTITY QualityInsRoot ALL FIELDS
*           WITH CORRESPONDING #( update-qualityinsroot )
*           RESULT DATA(lt_zr_yso_hdr_e022).
*          IF lt_zr_yso_hdr_e022 IS NOT INITIAL.
*
*
*UPDATE zqualityins_root SET z_after_qc = '2345' WHERE z_inspectionlot_uuid
*= @ls_ZI_QUALITY_INSPECTION_ROOT-ZInspectionlotUuid.
*
*


*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.



  ENDMETHOD.



ENDCLASS.

CLASS lhc_qualityinsitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS CreateItmaction FOR DETERMINE ON SAVE                       "Item Creation time
      IMPORTING keys FOR QualityInsItem~CreateItmaction.

ENDCLASS.

CLASS lhc_qualityinsitem IMPLEMENTATION.

  METHOD CreateItmaction.
    "Item creation time - Set the InfoField1 values
*    LOOP AT keys INTO DATA(ls_key).
*
*      MODIFY ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
*      ENTITY QualityInsItem
*      UPDATE SET FIELDS WITH VALUE #( ( ZItemUuid = ls_key-ZItemUuid
*      ZTotalWeight = '752' ) )
*      REPORTED DATA(update_reported).
*      reported = CORRESPONDING #( DEEP update_reported ).
*   ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_QualityInsRoot DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR QualityInsRoot RESULT result.
    METHODS calculatetotalweight FOR MODIFY
      IMPORTING keys FOR ACTION qualityinsroot~calculatetotalweight.
    METHODS createdebitnote FOR MODIFY
      IMPORTING keys FOR ACTION qualityinsroot~createdebitnote.
    METHODS createitemcharacteristics FOR DETERMINE ON SAVE
      IMPORTING keys FOR qualityinsroot~createitemcharacteristics.



ENDCLASS.

CLASS lhc_QualityInsRoot IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.



  METHOD calculateTotalWeight.

    LOOP AT keys INTO DATA(ls_key).




*Current Root Instance
      READ ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
       ENTITY QualityInsRoot ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(Insproot).
      IF Insproot IS NOT INITIAL.
        LOOP AT Insproot INTO DATA(ls_Insproot).

*retrieves only the first row that matches the selection criteria
*Inspection Lot Details
          SELECT SINGLE FROM i_inspectionlot
          FIELDS PurchasingDocument,PurchasingDocumentItem,InspectionLotActualQuantity,InspectionLotSampleQuantity,
          InspLotQtyToFree,Material,MaterialDocument,MaterialDocumentItem,
          InspectionLotSampleUnit,\_InspLotUsageDecision-InspLotUsgeDcsnSelectedSet,\_InspLotUsageDecision-InspectionLotUsageDecisionCode
          WHERE InspectionLot = @ls_Insproot-ZInspectionlotId
          INTO @DATA(ltdata).

*Purchase Order Details
          SELECT SINGLE FROM I_PurchaseOrderItemAPI01
        FIELDS NetPriceAmount,DocumentCurrency
        WHERE PurchaseOrder = @ltdata-PurchasingDocument AND PurchaseOrderItem = @ltdata-PurchasingDocumentItem
       INTO @DATA(ltpodata).

*Material Document Details
          SELECT SINGLE FROM I_MaterialDocumentItem_2
          FIELDS QuantityInEntryUnit,TotalGoodsMvtAmtInCCCrcy,EntryUnit,CompanyCodeCurrency
          WHERE MaterialDocument = @ltdata-MaterialDocument AND MaterialDocumentItem = @ltdata-MaterialDocumentItem
          INTO @DATA(matdocitem).

*Update Root table with the above details
          MODIFY ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
           ENTITY QualityInsRoot
           UPDATE SET FIELDS WITH VALUE #( ( %tky = ls_key-%tky
           ZPurchaseorderId = ltdata-PurchasingDocument
           ZUnrestrictedQty = ltdata-InspLotQtyToFree
           ZSamplesize = ltdata-InspectionLotSampleQuantity
           ZSamplesizeUnit = ltdata-InspectionLotSampleUnit
            ZGrnQty = matdocitem-QuantityInEntryUnit
            ZGrnQtyUnit = matdocitem-EntryUnit
           ZGrnId = ltdata-MaterialDocument
           ZPOPrice = ltpodata-NetPriceAmount
           ZPOPriceCurrency = ltpodata-DocumentCurrency
           ZInitialBillAmnt = matdocitem-TotalGoodsMvtAmtInCCCrcy
           ZInitialBillAmntCurrency = matdocitem-CompanyCodeCurrency ) )
           REPORTED DATA(update_reported).
          reported = CORRESPONDING #( DEEP update_reported ).


*Inspection Characteristics details (Result Record)
*Consider only info fields 1
          SELECT FROM i_inspectioncharacteristic
            FIELDS InspSpecInformationField1,InspSpecInformationField2,InspSpecInformationField3,InspectionCharacteristic,InspectionCharacteristicText,
            \_InspectionResult-InspectionResultMeanValue,\_InspectionResult-InspResultHasMaximumValue
            WHERE InspectionLot = @ls_Insproot-ZInspectionlotId AND InspSpecInformationField1 IN ('DNMP', 'DNSP', 'DNOP')
           INTO TABLE @DATA(lt_customeritems1).



*Create the item table using above data
          LOOP AT lt_customeritems1 INTO DATA(ls_item).

            DATA: resultmean    TYPE p DECIMALS 2,   " Packed number with 2 decimal places
                  unrestricted  TYPE p DECIMALS 2,   " Packed number with 2 decimal places
                  sample        TYPE p DECIMALS 2,   " Packed number with 2 decimal places
                  div           TYPE p DECIMALS 2,   " Packed number with 2 decimal places
                  POPrice       TYPE p DECIMALS 2,   " Packed number with 2 decimal places
                  POPriceCurr   TYPE c LENGTH 3,      " 3-character string for currency code
                  SuppPrice     TYPE p DECIMALS 2,   " Packed number with 2 decimal places
                  SuppPriceCurr TYPE c LENGTH 3,      " 3-character string for currency code
                  TotalAmnt     TYPE p DECIMALS 2,
                  TotalAmntCurr TYPE c LENGTH 3.






            POPrice = ltpodata-NetPriceAmount.
            POPriceCurr = ltpodata-DocumentCurrency.

            CLEAR: resultmean,unrestricted,sample,div,SuppPrice,SuppPriceCurr,TotalAmnt,TotalAmntCurr.

            resultmean = ls_item-InspectionResultMeanValue.
            unrestricted = ltdata-InspLotQtyToFree.
            sample = ltdata-InspectionLotSampleQuantity.
            div = ( resultmean * unrestricted ) / sample.

            IF ls_item-InspSpecInformationField1 = 'DNMP'.
              SuppPrice = POPrice.
              SuppPricecurr = POPriceCurr.
            ENDIF.
            DATA: lt_product_table TYPE TABLE OF zinsp_charitm_db,
                  ls_product_table TYPE zinsp_charitm_db,
                  lv_product_id    TYPE PurchasingDocument,
                  lv_supproductid  TYPE PurchasingDocument.
            IF ls_item-InspSpecInformationField1 = 'DNOP'.


* Set the product ID you are querying for
              lv_product_id = '10069'.  " Replace with actual product ID
              lv_supproductid = '3'.
* Clear the product table
              CLEAR lt_product_table.

* Query the custom table
*            SELECT * FROM ZINSP_CHAR_DB
*              WHERE z_mainproductid = @ls_item-InspSpecInformationField2
*              INTO TABLE @lt_product_table.

              SELECT * FROM zinsp_charitm_db
            WHERE z_mainproductid = @lv_product_id AND z_sup_productid = @lv_supproductid
            INTO TABLE @lt_product_table.

* Check if data is found
              IF sy-subrc = 0.
                LOOP AT lt_product_table INTO ls_product_table.
                  IF ls_product_table-z_product_type = 'Variable'.
                    SuppPrice =   POPrice + ls_product_table-z_supprd_price.
                  ELSEIF ls_product_table-z_product_type = 'Fixed'.
                    SuppPrice =   ls_product_table-z_supprd_price.

                  ENDIF.


                ENDLOOP.


              ENDIF.

            ENDIF.

            IF ls_item-InspSpecInformationField1 = 'DNSP'.
              div = ls_item-InspectionResultMeanValue.
* Set the product id you are querying for
              lv_product_id = '10069'.  " Replace with actual product ID
              lv_supproductid = '4'.
* Clear the product table
              CLEAR lt_product_table.

* Query the custom table


              SELECT * FROM zinsp_charitm_db
              WHERE z_mainproductid = @lv_product_id AND z_sup_productid = @lv_supproductid
              INTO TABLE @lt_product_table.

* Check if data is found
              IF sy-subrc = 0.
                LOOP AT lt_product_table INTO ls_product_table.
                  IF ls_product_table-z_product_type = 'Variable'.
                    SuppPrice =   POPrice + ls_product_table-z_supprd_price.
                  ELSEIF ls_product_table-z_product_type = 'Fixed'.
                    SuppPrice =   ls_product_table-z_supprd_price.

                  ENDIF.


                ENDLOOP.


              ENDIF.
            ENDIF.


            TotalAmnt = div * SuppPrice.

            MODIFY ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
              ENTITY QualityInsRoot

              CREATE BY \_inspectionLotItm FROM VALUE #( (

                               ZInspectionlotUuid = ls_key-ZInspectionlotUuid
                               %target = VALUE #( ( %cid = '080'

                                                    ZMatDescription = ls_item-InspectionCharacteristicText
                                                    ZInspectionlotUuid = ls_key-ZInspectionlotUuid
                                                    ZInfoField1 = ls_item-InspSpecInformationField1
                                                    ZInfoField2 = ls_item-InspSpecInformationField2
                                                    ZTotalWeight = div
                                                    ZTotalPrice = SuppPrice
                                                    ZTotalAmount = TotalAmnt
                                                    %control = VALUE #(
                                                                          ZMatDescription = if_abap_behv=>mk-on
                                                                        ZInspectionlotUuid = if_abap_behv=>mk-on
                                                                        ZInfoField1 = if_abap_behv=>mk-on
                                                                        ZInfoField2 = if_abap_behv=>mk-on
                                                                        ZTotalWeight = if_abap_behv=>mk-on
                                                                        ZTotalPrice = if_abap_behv=>mk-on
                                                                        ZTotalAmount = if_abap_behv=>mk-on
                                                                      )
                                                  )
                                              )
                                          ) )
        MAPPED DATA(lt_mapped)
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).
            DATA: total_price      TYPE p DECIMALS 2 VALUE 0,
                  total_price_supp TYPE p DECIMALS 2 VALUE 0.
            IF ls_item-InspSpecInformationField1 <> 'DNSP'.
              total_price = total_price + SuppPrice.  " Example calculation
            ELSEIF ls_item-InspSpecInformationField1 = 'DNSP'.
              total_price_supp = total_price_supp + SuppPrice.
            ENDIF.






          ENDLOOP.
        ENDLOOP.

* calculateZafterac
*    DATA: total_price_up TYPE p DECIMALS 2 VALUE 0,
        DATA: Diff         TYPE p DECIMALS 2 VALUE 0,
              supp_prd_add TYPE p DECIMALS 2 VALUE 0.

        IF SuppPrice IS NOT INITIAL.
          DATA: lt_quality_inspection_root TYPE TABLE OF zi_quality_inspection_root,
                ls_quality_inspection_root TYPE zi_quality_inspection_root.






          zbp_i_quality_inspection_root=>total_price_up = ls_Insproot-ZAfterQC + total_price.  " Example calculation
          IF zbp_i_quality_inspection_root=>total_price_up IS NOT INITIAL.

            supp_prd_add = zbp_i_quality_inspection_root=>total_price_up + total_price_supp.
            Diff = ls_Insproot-ZInitialBillAmnt - supp_prd_add.

            MODIFY ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
              ENTITY QualityInsRoot
              UPDATE SET FIELDS WITH VALUE #( ( %tky = ls_key-%tky
                                                     ZAfterQC =  zbp_i_quality_inspection_root=>total_price_up
                                                     ZDifferenceDebit = Diff
                                                     ) )
                    REPORTED DATA(update_reported1).
            reported = CORRESPONDING #( DEEP update_reported1 ).
          ENDIF.



        ENDIF.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.



  METHOD CreateDebitNote.

    "ROOT STRUCTURE
    DATA: BEGIN OF root,
            DebitMemoRequestType TYPE string,
            SalesOrganization    TYPE string,
            DistributionChannel  TYPE string,
            OrganizationDivision TYPE string,
            SoldToParty          TYPE string,
            TotalNetAmount       TYPE string,
            TransactionCurrency  TYPE string,
          END OF root.

    "ITEM STRUCTURE
    DATA: BEGIN OF item,
            DebitMemoRequestItem TYPE string,
            Material             TYPE string,
            RequestedQuantity    TYPE string,
          END OF item.

    "INTERNAL TABLES
    DATA it_root LIKE TABLE OF root.
    DATA it_item LIKE TABLE OF item.

    "WORK AREAS
    DATA wa_root LIKE root.
    DATA wa_item LIKE item.

    "ROOT DATA
    wa_root-debitmemorequesttype = 'DR'.
    wa_root-salesorganization =  'SCSO'.
    wa_root-distributionchannel = 'C1'.
    wa_root-organizationdivision = 'D1'.
    wa_root-soldtoparty = '1000002'.
    wa_root-totalnetamount = '100'.
    wa_root-transactioncurrency = 'INR'.
    APPEND wa_root TO it_root.
    CLEAR wa_root.

    "ITEM DATA
    wa_item-material = '30002'.
    wa_item-debitmemorequestitem = '10'.
    wa_item-requestedquantity = '2'.
    APPEND wa_item TO it_item.
    CLEAR wa_item.

    wa_item-material = '30002'.
    wa_item-debitmemorequestitem = '20'.
    wa_item-requestedquantity = '2'.
    APPEND wa_item TO it_item.
    CLEAR wa_item.

    wa_item-material = '30002'.
    wa_item-debitmemorequestitem = '30'.
    wa_item-requestedquantity = '2'.
    APPEND wa_item TO it_item.
    CLEAR wa_item.

    "JSON (ROOT)
    DATA jsonbody_root TYPE string.

    LOOP AT it_root INTO DATA(lwa_root).
      IF lwa_root IS NOT INITIAL.
        jsonbody_root =  '"DebitMemoRequestType": "' &&  lwa_root-debitmemorequesttype && '",' && '"SalesOrganization": "' &&  lwa_root-salesorganization && '",' && '"DistributionChannel": "' &&  lwa_root-distributionchannel && '",' &&
'"OrganizationDivision": "' &&  lwa_rooT-organizationdivision && '",' && '"SoldToParty": "' &&  lwa_root-soldtoparty && '",' && '"TotalNetAmount": "' &&  lwa_root-totalnetamount && '",' && '"TransactionCurrency": "' &&  lwa_root-transactioncurrency &&
'",'.
      ENDIF.
    ENDLOOP.

    "JSON (ITEM)
    DATA jsonbody_item TYPE string.
    LOOP AT it_item INTO DATA(lwa_item).
      IF lwa_item IS NOT INITIAL.
        IF jsonbody_item IS NOT INITIAL.
          jsonbody_item = jsonbody_item && ',{"DebitMemoRequestItem": "' &&  lwa_item-debitmemorequestitem && '",' && '"Material": "' &&  lwa_item-material && '",' && '"RequestedQuantity": "' &&  lwa_item-requestedquantity && '"}'.
        ELSE.
          jsonbody_item =  '{"DebitMemoRequestItem": "' &&  lwa_item-debitmemorequestitem && '",' && '"Material": "' &&  lwa_item-material && '",' && '"RequestedQuantity": "' &&  lwa_item-requestedquantity && '"}'.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF jsonbody_item IS NOT INITIAL.
      jsonbody_item = '"to_Item": [' && jsonbody_item && ']'.
    ENDIF.


    "PREPARING JSON
    jsonbody_root = '{' && jsonbody_root && jsonbody_item && '}'.


    DATA: lo_http_destination       TYPE REF TO if_http_destination,
          lo_web_http_client        TYPE REF TO if_web_http_client,
          lo_web_http_get_request   TYPE REF TO if_web_http_request,
          lo_web_http_get_response  TYPE REF TO if_web_http_response,
          lo_web_http_post_request  TYPE REF TO if_web_http_request,
          lo_web_http_post_response TYPE REF TO if_web_http_response,
          lv_response               TYPE string,
          lv_response_code          TYPE string,
          lv_csrf_token             TYPE string.

    TRY.
        lo_http_destination = cl_http_destination_provider=>create_by_comm_arrangement( comm_scenario = 'ZDEBITNOTE_CS' ).

        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).

        lo_web_http_get_request = lo_web_http_client->get_http_request( ).

        lo_web_http_get_request->set_header_fields( VALUE #( ( name = 'x-csrf-token' value = 'fetch' ) ) ).

        lo_web_http_get_response = lo_web_http_client->execute( if_web_http_client=>get ).

        lv_csrf_token = lo_web_http_get_response->get_header_field( i_name = 'x-csrf-token' ).

        IF lv_csrf_token IS NOT INITIAL.

          lo_web_http_post_request = lo_web_http_client->get_http_request( ).

          lo_web_http_post_request->set_header_fields( VALUE #( ( name = 'x-csrf-token' value = lv_csrf_token ) ) ).

          lo_web_http_post_request->set_content_type( content_type = 'application/json' ).
          IF jsonbody_root IS NOT INITIAL.
            lo_web_http_post_request->set_text( jsonbody_root ).

            lo_web_http_post_response = lo_web_http_client->execute( if_web_http_client=>post ).

            lv_response = lo_web_http_post_response->get_text( ).
            lv_response_code = lo_web_http_post_response->get_status( )-code.
          ENDIF.
        ENDIF.

      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.

    ENDTRY.

  ENDMETHOD.

  METHOD CreateItemCharacteristics.


  ENDMETHOD.



ENDCLASS.

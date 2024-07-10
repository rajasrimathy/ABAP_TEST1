CLASS lhc_zi_debitnote_view DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_debitnote_view RESULT result.
    METHODS get_access_token FOR MODIFY
      IMPORTING keys FOR ACTION zi_debitnote_view~get_access_token.

    METHODS upload_data FOR MODIFY
      IMPORTING keys FOR ACTION zi_debitnote_view~upload_data.

ENDCLASS.

CLASS lhc_zi_debitnote_view IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_access_token.

*    READ ENTITIES OF zi_debitnote_view IN LOCAL MODE
*    ENTITY zi_debitnote_view ALL FIELDS
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(zr_web_db_ret).
*    LOOP AT zr_web_db_ret INTO DATA(zr_web_db_ins).
*      APPEND VALUE #( %tky = zr_web_db_ins-%tky
*      %msg = new_message_with_text(
*      severity =
*     if_abap_behv_message=>severity-success
*      text = 'Get Access Token called.' )
*      ) TO reported-zi_debitnote_view.
*    ENDLOOP.


    "Variables
    DATA: lo_http_destination      TYPE REF TO if_http_destination,
          lo_web_http_client       TYPE REF TO if_web_http_client,
          lo_web_http_get_request  TYPE REF TO if_web_http_request,
          lo_web_http_get_response TYPE REF TO if_web_http_response,
          lv_response              TYPE string,
          lv_response_code         TYPE string,
          lv_csrf_token            TYPE string.
    READ ENTITIES OF zi_debitnote_view IN LOCAL MODE
    ENTITY zi_debitnote_view ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(zr_web_db_ret).
    LOOP AT zr_web_db_ret INTO DATA(zr_web_db_ins).
      TRY.
          lo_http_destination = cl_http_destination_provider=>create_by_comm_arrangement( comm_scenario = 'ZCS_DEBITNOTE' ).

          lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).

          lo_web_http_get_request = lo_web_http_client->get_http_request( ).

          lo_web_http_get_request->set_header_fields( VALUE #( ( name = 'x-csrf-token' value = 'fetch' ) ) ).

          lo_web_http_get_response = lo_web_http_client->execute( if_web_http_client=>get ).
          lv_csrf_token = lo_web_http_get_response->get_header_field( i_name = 'x-csrf-token' ).
          IF lv_csrf_token IS NOT INITIAL.
            APPEND VALUE #( %tky = zr_web_db_ins-%tky
            %msg = new_message_with_text(
            severity =
           if_abap_behv_message=>severity-success
            text = 'Access Token ' &&
           cl_abap_char_utilities=>newline && lv_csrf_token &&
           cl_abap_char_utilities=>newline && 'Granted.' )
            ) TO reported-zi_debitnote_view.
          ENDIF.
        CATCH cx_http_dest_provider_error cx_web_http_client_error
       cx_web_message_error.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD upload_data.
*    READ ENTITIES OF zi_debitnote_view IN LOCAL MODE
*   ENTITY zi_debitnote_view ALL FIELDS
*   WITH CORRESPONDING #( keys )
*   RESULT DATA(zr_web_db_ret).
*    LOOP AT zr_web_db_ret INTO DATA(zr_web_db_ins).
*      APPEND VALUE #( %tky = zr_web_db_ins-%tky
*      %msg = new_message_with_text(
*      severity =
*     if_abap_behv_message=>severity-success
*      text = 'Upload called.' )
*      ) TO reported-zi_debitnote_view.
*    ENDLOOP.

    "Variables
    DATA: lo_http_destination       TYPE REF TO if_http_destination,
          lo_web_http_client        TYPE REF TO if_web_http_client,
          lo_web_http_get_request   TYPE REF TO if_web_http_request,
          lo_web_http_get_response  TYPE REF TO if_web_http_response,
          lo_web_http_post_request  TYPE REF TO if_web_http_request,
          lo_web_http_post_response TYPE REF TO if_web_http_response,
          lv_response               TYPE string,
          lv_response_code          TYPE string,
          lv_csrf_token             TYPE string,
          lv_json                   TYPE string,
          lv_upload_bool            TYPE abap_bool,
          lv_csrf_token_bool        TYPE abap_bool,
          lv_responce_objid         TYPE string,
          lv_responce_error         TYPE string.
    lv_upload_bool = abap_false.
    lv_csrf_token_bool = abap_false.
    READ ENTITIES OF zi_debitnote_view IN LOCAL MODE
    ENTITY zi_debitnote_view ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(zr_web_db_ret).
    LOOP AT zr_web_db_ret INTO DATA(zr_web_db_ins).
      TRY.
          lo_http_destination =
         cl_http_destination_provider=>create_by_comm_arrangement( comm_scenario =
         'ZCS_DEBITNOTE' ).
          lo_web_http_client =
         cl_web_http_client_manager=>create_by_http_destination( lo_http_destination
         ).
          lo_web_http_get_request = lo_web_http_client->get_http_request(
         ).
          lo_web_http_get_request->set_header_fields( VALUE #( ( name = 'x-csrf-token' value = 'fetch' ) ) ).
          lo_web_http_get_response = lo_web_http_client->execute(
         if_web_http_client=>get ).
          lv_csrf_token = lo_web_http_get_response->get_header_field(
         i_name = 'x-csrf-token' ).
          IF lv_csrf_token IS NOT INITIAL.
            lv_csrf_token_bool = abap_true.
            IF zr_web_db_ins-zdebitnoteid IS NOT INITIAL.
              IF zr_web_db_ins-zdebitmemoreqtype IS NOT INITIAL.
                TRY.
                    lo_web_http_post_request = lo_web_http_client->get_http_request( ).
                    lo_web_http_post_request->set_header_fields( VALUE #( (
                   name = 'x-csrf-token' value = lv_csrf_token ) ) ).
                    lo_web_http_post_request->set_content_type(
                   content_type = 'application/json' ).
                    lv_json = '{"DebitMemoRequestType": "DR","SalesOrganization": "4710","DistributionChannel": "10","OrganizationDivision": "00","SoldToParty": "KPG_001","PurchaseOrderByCustomer": "","CustomerPaymentTerms": "","to_Item":[{"DebitMem' &&
'oRequestItem": "10","Material": "42","RequestedQuantity": "1","to_PricingElement": [{"ConditionType": "PPR0","ConditionRateValue": "11"}] }]}'.
                    lo_web_http_post_request->set_text( lv_json ).
                    lo_web_http_post_response = lo_web_http_client->execute( if_web_http_client=>post ).
                    lv_response = lo_web_http_post_response->get_text( ).
                    lv_response_code = lo_web_http_post_response->get_status( )-code.
                    IF lv_response_code = 201.
                      lv_upload_bool = abap_true.
                    ENDIF.
                  CATCH cx_http_dest_provider_error
                 cx_web_http_client_error cx_web_message_error.
                ENDTRY.
              ELSE.
                LOOP AT zr_web_db_ret INTO zr_web_db_ins.
                  APPEND VALUE #( %tky = zr_web_db_ins-%tky
                  %msg = new_message_with_text(
                  severity =
                 if_abap_behv_message=>severity-error
                  text = 'Debit Note Type is Empty!!' )
                  ) TO reported-zi_debitnote_view.
                ENDLOOP.
              ENDIF.
            ELSE.
              LOOP AT zr_web_db_ret INTO zr_web_db_ins.
                APPEND VALUE #( %tky = zr_web_db_ins-%tky
                %msg = new_message_with_text(
                severity =
               if_abap_behv_message=>severity-error
                text = 'Debit Note is Empty!!' )
                ) TO reported-zi_debitnote_view.
              ENDLOOP.
            ENDIF.
          ENDIF.
        CATCH cx_http_dest_provider_error cx_web_http_client_error
       cx_web_message_error.
      ENDTRY.
    ENDLOOP.
    "Return
    IF lv_csrf_token_bool = abap_true.
      IF lv_upload_bool = abap_true.
        LOOP AT zr_web_db_ret INTO zr_web_db_ins.
          "Creating XML
          DATA(lv_resp_xml) = cl_abap_conv_codepage=>create_out( )->convert( lv_response ).
          "iXML
          DATA(lo_ixml_pa) = cl_ixml_core=>create( ).
          DATA(lo_stream_factory_pa) = lo_ixml_pa->create_stream_factory(
         ).
          DATA(lo_document_pa) = lo_ixml_pa->create_document( ).
          "XML Parser
          DATA(lo_parser_pa) = lo_ixml_pa->create_parser(
          istream = lo_stream_factory_pa->create_istream_xstring( string = lv_resp_xml )
          document = lo_document_pa
          stream_factory = lo_stream_factory_pa ).
          "Check XML Parser
          DATA(lv_parsing_check) = lo_parser_pa->parse( ).
          "IF XML Parser contains no error
          IF lv_parsing_check = 0.
            "Iterator
            DATA(lo_iterator_pa) = lo_document_pa->create_iterator( ).
            DO.
              DATA(lv_node_i) = lo_iterator_pa->get_next( ).
              IF lv_node_i IS INITIAL.
                EXIT.
              ELSE.
                IF lv_node_i->get_name( ) = 'DebitMemoRequest'.
                  lv_responce_objid = lv_node_i->get_value( ).
                  EXIT.
                ENDIF.
              ENDIF.
            ENDDO.
          ENDIF.
          APPEND VALUE #( %tky = zr_web_db_ins-%tky
          %msg = new_message_with_text(
          severity =
         if_abap_behv_message=>severity-success
          text = 'Upload Succeed' &&
         cl_abap_char_utilities=>newline && 'Debit Note ID' &&
         cl_abap_char_utilities=>newline && lv_responce_objid )
          ) TO reported-zi_debitnote_view.
        ENDLOOP.
      ELSE.
        LOOP AT zr_web_db_ret INTO zr_web_db_ins.
          "Creating XML
          lv_resp_xml = cl_abap_conv_codepage=>create_out( )->convert(
         lv_response ).
          "iXML
          lo_ixml_pa = cl_ixml_core=>create( ).
          lo_stream_factory_pa = lo_ixml_pa->create_stream_factory( ).
          lo_document_pa = lo_ixml_pa->create_document( ).
          "XML Parser
          lo_parser_pa = lo_ixml_pa->create_parser(
          istream = lo_stream_factory_pa->create_istream_xstring( string = lv_resp_xml )
          document = lo_document_pa
          stream_factory = lo_stream_factory_pa ).
          "Check XML Parser
          lv_parsing_check = lo_parser_pa->parse( ).
          "IF XML Parser contains no error
          IF lv_parsing_check = 0.
            "Iterator
            lo_iterator_pa = lo_document_pa->create_iterator( ).
            DO.
              lv_node_i = lo_iterator_pa->get_next( ).
              IF lv_node_i IS INITIAL.
                EXIT.
              ELSE.
                IF lv_node_i->get_name( ) = 'message'.
                  lv_responce_error = lv_node_i->get_value( ).
                  EXIT.
                ENDIF.
              ENDIF.
            ENDDO.
          ENDIF.
          APPEND VALUE #( %tky = zr_web_db_ins-%tky
          %msg = new_message_with_text(
          severity =
         if_abap_behv_message=>severity-error
          text = lv_responce_error )
          ) TO reported-zi_debitnote_view.
        ENDLOOP.
      ENDIF.
    ELSE.
      LOOP AT zr_web_db_ret INTO zr_web_db_ins.
        APPEND VALUE #( %tky = zr_web_db_ins-%tky
        %msg = new_message_with_text(
        severity =
       if_abap_behv_message=>severity-error
        text = 'Access Token Generation Failed.' )
        ) TO reported-zi_debitnote_view.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.




ENDCLASS.

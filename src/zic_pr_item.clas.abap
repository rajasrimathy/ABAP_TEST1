CLASS zic_pr_item DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_mm_pur_s4_pr_modify_item .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZIC_PR_ITEM IMPLEMENTATION.


  METHOD if_mm_pur_s4_pr_modify_item~modify_item.
* IF purchaserequisitionitem-plant EQ '1710'.
*
*
* "Variables
*    DATA: lo_http_destination      TYPE REF TO if_http_destination,
*          lo_web_http_client       TYPE REF TO if_web_http_client,
*          lo_web_http_get_request  TYPE REF TO if_web_http_request,
*          lo_web_http_get_response TYPE REF TO if_web_http_response,
*          lv_response              TYPE string,
*          lv_response_code         TYPE string,
*          lv_csrf_token            TYPE string.
*
*      TRY.
*          lo_http_destination = cl_http_destination_provider=>create_by_comm_arrangement( comm_scenario = 'Z_CUSTOM_DEBITNOTE' ).
*
*          lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
*
*          lo_web_http_get_request = lo_web_http_client->get_http_request( ).
*
*          lo_web_http_get_request->set_header_fields( VALUE #( ( name = 'x-csrf-token' value = 'fetch' ) ) ).
*
*          lo_web_http_get_response = lo_web_http_client->execute( if_web_http_client=>get ).
*          lv_csrf_token = lo_web_http_get_response->get_header_field( i_name = 'x-csrf-token' ).
*          IF lv_csrf_token IS NOT INITIAL.
*
*          ENDIF.
*        CATCH cx_http_dest_provider_error cx_web_http_client_error
*       cx_web_message_error.
*      ENDTRY.
*ENDIF.
  ENDMETHOD.
ENDCLASS.

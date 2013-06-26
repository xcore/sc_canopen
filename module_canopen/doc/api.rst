.. _canopen_api:

API
====

Object Dictionary 
-----------------
These are the functions that are called to read or write data to the object dictionary entries

.. doxygenfunction:: od_find_data_length

.. doxygenfunction:: od_find_index

.. doxygenfunction:: od_write_data

.. doxygenfunction:: od_read_data

.. doxygenfunction:: od_find_access_of_index

.. doxygenfunction:: od_find_no_of_si_entries


SDO (Service Data Objects)
--------------------------
These are the functions that are used for SDO communication

.. doxygenfunction:: sdo_upload_expedited_data

.. doxygenfunction:: sdo_send_download_response

.. doxygenfunction:: sdo_download_segment_response

.. doxygenfunction:: sdo_initiate_upload_response

.. doxygenfunction:: sdo_upload_segmented_data

.. doxygenfunction:: sdo_send_abort_code

The SDO Requests have COB-ID (Communication Object ID) as 0x580 + CANOPEN_NODE_ID based on
the command identifier in the Data field the SDO request is identified.

The following SDO command identifers are used to identify the type of SDO request. 

.. doxygenenum:: sdo_request_types

If an error is identified in the received SDO request, then the SDO abort code
is sent to the Master indicating the request cannot be processed. The following 
SDO Abort codes are transmitted based on the error type.

.. doxygenenum:: sdo_abort_codes


PDO (Process Data Objects)
--------------------------
These are the functions that are used for PDO communication

.. doxygenfunction:: pdo_find_cob_id

.. doxygenfunction:: pdo_transmit_data

.. doxygenfunction:: pdo_read_data_from_od

.. doxygenfunction:: pdo_receive_application_data

.. doxygenfunction:: pdo_find_transmission_type

.. doxygenfunction:: pdo_send_data_to_application

.. doxygenfunction:: pdo_write_data_to_od

.. doxygenfunction:: pdo_find_event_type

.. doxygenfunction:: pdo_find_inhibit_time

PDO Communication Types:
++++++++++++++++++++++++

   +------------+-----------------------+
   | Value      | Communication Type    |
   +============+=======================+
   | 0          | Acyclic Synchronous   |
   +------------+-----------------------+
   | 1-240      | Cyclic Synchronous    |
   +------------+-----------------------+
   | 241-251    | Reserved              |
   +------------+-----------------------+
   | 252	| Synchronous RTR only  |
   +------------+-----------------------+
   | 253	| Asynchronous RTR only |
   +------------+-----------------------+
   | 254-255	| Asynchronous          |
   +------------+-----------------------+

Object Dictionary address for PDOs are as below

.. doxygenenum:: pdo_parameters
     
     
NMT (Network Management)
------------------------
These are the functions that are used for NMT communication

.. doxygenfunction:: nmt_initialize

.. doxygenfunction:: nmt_send_heartbeat_message

.. doxygenfunction:: nmt_send_nodeguard_message

.. doxygenfunction:: nmt_send_boot_up_message

SYNC (Synchronous Data)
-----------------------

The functions are used to transmit or receive PDO data based on
SYNC messages

.. doxygenfunction:: sync_pdo_data_transmit

.. doxygenfunction:: sync_pdo_data_receive


LSS (Layer Service Settings)
----------------------------

These are the functions that are used for LSS communication

.. doxygenfunction:: lss_send_node_id

.. doxygenfunction:: lss_inquire_vendor_id_response

.. doxygenfunction:: lss_inquire_product_code

.. doxygenfunction:: lss_inquire_revision_number

.. doxygenfunction:: lss_inquire_serial_number

The LSS Requests have COB-ID (Communication Object ID) as 0x7E5 + CANOPEN_NODE_ID based on
the command identifier in the Data field the SDO request is identified.

The following LSS command identifers are used to identify the type of LSS request. 

.. doxygenenum:: lss_commands


EMCY (Emergency Messages)
-------------------------
These are the functions that are used for EMCY message communication

.. doxygenfunction:: emcy_send_emergency_message

.. doxygenfunction:: emcy_reset_error_register

Based on the error type and error code the emergency message is transmitted on to the network
to indicate the master that an error has occurred.

.. doxygenenum:: error_type

.. doxygenenum:: emcy_messages

CANopen functions
-----------------

The CANopen manager receives Messages and based on COB-ID it descides the request type.
Different type of message types supported are as shown below

.. doxygenenum:: cob_id

After rceiving the message based on COB-ID the canopen manager cheks if the received
message is of proper message length. Message length of different messages are below

.. doxygenenum:: message_length

Client functions
----------------
These are the functions that are called from the application and are included in ``canopen_client.h``.

.. doxygenfunction:: canopen_client_send_data_to_stack

.. doxygenfunction:: canopen_client_receive_data_from_stack


.. _canopen_api:

API
====

.. _sec_conf_defines:

Configuration Defines
---------------------

#. The file ``can_conf.h`` must be provided in the application source code, and it must define:

   PROP_SEG,
   PHASE_SEG1,
   PHASE_SEG2,
   CAN_CLOCK_DIVIDE

   information on configuration of these parameters are available in the API section of ``module_can``. Example configuration settings are shown below: 

   .. literalinclude:: module_canopen/can_conf_example.h
      :start-after: //::CAN Conf
      :end-before: //::CAN Conf End

#. The file ``canopen_conf.h`` must be provided in the application source code, it must define :

   CANOPEN_NODE_ID,
   HEARTBEAT_SUPPORTED,
   CANOPEN_NUMBER_OF_TPDOS_SUPPORTED,
   CANOPEN_NUMBER_OF_RPDOS_SUPPORTED,
   CANOPEN_MAX_DATA_BUFFER_LENGTH

   **CANOPEN_NODE_ID**
      Node ID of CANopen Slave device.
      
   **HEARTBEAT_SUPPORTED**
      Define this as 1 to select Heartbeat monitoring. If defined as 0, Node guard is implemented. 
   
   **CANOPEN_NUMBER_OF_TPDOS_SUPPORTED**
      Number of transmit PDOs required by the application.
      
   **CANOPEN_NUMBER_OF_RPDOS_SUPPORTED**
      Number of receive PDOs required by the application.
   
   **CANOPEN_MAX_DATA_BUFFER_LENGTH**
      Maximum Data buffer length for data in object dictionary.
      
   Example configuration defines in canopen_conf.h file are as shown:
 
   .. literalinclude:: module_canopen/canopen_conf_example.h
      :start-after: //::Conf
      :end-before: //::Conf End
 
#. The file ``object_dictionary.h`` must be provided in the application source code. This file is generated automatically based on the Electronic Data Sheet(EDS) file. Details on how to genaret the ``object_dictionary.h`` file is available in the Programming section of the Document.

  
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


Process Data Objects (PDO)
--------------------------
These are the functions that are used for PDO communication

.. doxygenfunction:: pdo_find_cob_id

.. doxygenfunction:: pdo_transmit_data

.. doxygenfunction:: pdo_read_data_from_od

.. doxygenfunction:: pdo_find_transmission_type

.. doxygenfunction:: pdo_send_data_to_application

.. doxygenfunction:: pdo_write_data_to_od

.. doxygenfunction:: pdo_find_event_type

.. doxygenfunction:: pdo_find_inhibit_time

*void* pdo_receive_application_data(char *pdo_number*, char *length*, char *data[]*, NULLABLE_ARRAY_OF(tpdo_inhibit_time, *tpdo_inhibit_time_values*), chanend *c_rx_tx*)

    pdo_receive_application_data is the function to receive pdo data from the application.
    
   **Parameters:**   
                - **pdo_number -** pdo number.
                - **length -** pdo length of data bytes.
                - **data -** data buffer.
                - **c_rx_tx -** channel to communicate with bus module like CAN.
                - **tpdo_inhibit_time_values -** structure with inhibit time values of TPDOs.

   **Returns:** - none



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
     
     
Network Management (NMT)
------------------------
These are the functions that are used for NMT communication

.. doxygenfunction:: nmt_send_heartbeat_message

.. doxygenfunction:: nmt_send_nodeguard_message

.. doxygenfunction:: nmt_send_boot_up_message

*void* nmt_initialize(NULLABLE_ARRAY_OF(tx_sync_timer, *sync_timer*), NULLABLE_ARRAY_OF(pdo_event_timer, *pdo_event*), NULLABLE_ARRAY_OF(tpdo_inhibit_time, *tpdo_inhibit_time_values*), unsigned *&sync_window_length*, unsigned *&guard_time*, unsigned *&life_time*, unsigned *&producer_heart_beat*, char *&heart_beat_active*)

    nmt_initialize is the function to initialize the parameters of canopen slave using object dictionary entries.

    **Parameters:**	
        - **sync_timer -** sync timer to check if the sync communication is whith in synchronous window length
        - **pdo_event -** structure with Events of PDOs
        - **tpdo_inhibit_time_values -** Structure with Inhibit time value of TPDOs
        - **sync_window_length �** synchronous window time
        - **guard_time -** node guard time
        - **life_time -** lie time of node guard
        - **producer_heart_beat -** heartbeat time of the slave
        - **heart_beat_active -** heartbeat active flag

    **Returns:** - none
    

Synchronization Data (SYNC)
---------------------------

The functions are used to transmit or receive PDO data based on
SYNC messages

*void* sync_pdo_data_transmit(char *pdo_number*, unsigned *rtr_check*, timer *sync_window_timer*, unsigned *sync_time_start*, unsigned *sync_time_current*, unsigned *sync_window_length*, unsigned *time_difference_sync*, NULLABLE_ARRAY_OF(tx_sync_timer, *sync_timer*), NULLABLE_ARRAY_OF(tpdo_inhibit_time, *tpdo_inhibit_time_values*), chanend *c_rx_tx*)

    sync_pdo_data_transmit is the function to transmit synchronous pdo data.
  
   **Parameters:**	

        - **pdo_number -** PDO number
        - **rtr_check -** RTR bit check
        - **sync_window_timer -** Timer moniters sync window time
        - **sync_time_start -** time value when the sync transmission is started
        - **sync_time_current -** Current sync time value
        - **sync_window_length -** Sync. window length time
        - **time_difference_sync -** Time difference current time and sync start time
        - **sync_timer -** Structure having sync timer values
        - **tpdo_inhibit_time_values -** Structure having Inhibit time values
        - **c_rx_tx -** channel to communicate with bus module like CAN

   **Returns:** - none

*void* sync_pdo_data_receive(char *pdo_number*, NULLABLE_ARRAY_OF(rx_sync_mesages, *sync_messages_rx*), timer *sync_window_timer*, unsigned *sync_time_current*, unsigned *sync_time_start*, unsigned *sync_window_length*, streaming chanend *c_application*)

    sync_pdo_data_receive is the function to receive synchronous pdo data.

    **Parameters:**	

        - **pdo_number -** PDO number
        - **sync_messages_rx -** Structure containing information about receive types
        - **sync_window_timer -** Timer monitors sync window time
        - **sync_time_start -** time value when the sync transmission is started
        - **sync_time_current -** Current sync time value
        - **sync_window_length -** Sync. window length time
        - **c_application -** Channel connecting to Application

   **Returns:** -  none
   

Layer Settings Service (LSS)
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


Emergency Messages (EMCY)
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

After rceiving the message based on COB-ID the canopen manager checks if the received
message is of proper message length. Message length of different messages are below

.. doxygenenum:: message_length

Client functions
----------------
These are the functions that are called from the application and are included in ``canopen_client.h``.

.. doxygenfunction:: canopen_client_send_data_to_stack

*void* canopen_client_receive_data_from_stack(streaming chanend *c_application*, unsigned char *&data_length*, NULLABLE_ARRAY_OF(unsigned char, *data*))

    canopen_client_receive_data_from_stack is the function to receive data from canopen module.

   **Parameters:**	

        - **c_application -* channel to receive data from the application
        - **data_length -* length of data
        - **data -* data buffer which contains receive data

   **Returns:** - none

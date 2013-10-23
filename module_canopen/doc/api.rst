.. _canopen_api:

API
====

.. _sec_conf_defines:

Client functions
----------------
These functions may be called from user application code and are included in ``canopen_client.h``.

.. doxygenfunction:: canopen_client_send_data_to_stack

void **canopen_client_receive_data_from_stack** (streaming chanend *c_application*, unsigned char *&data_length*, NULLABLE_ARRAY_OF(unsigned char, *data*))

    canopen_client_receive_data_from_stack is the function to receive data from CANopen module.

   **Parameters:**	

        - **c_application -** channel to receive data from the application
        - **data_length -** length of data
        - **data -** data buffer which contains receive data

   **Returns:** - none


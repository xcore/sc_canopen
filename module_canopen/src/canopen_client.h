
#ifndef __canopen_client_h__
#define __canopen_client_h__

#include <xccompat.h>

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 * canopen_client_send_data_to_stack is the function to send data to canopen
 * module.
 *
 * \param c_application channel to send data to the application
 * \param pdo_number pdo number the data corresponds to
 * \param data_length length of data
 * \param data data buffer which contains transmit data
 * \return none
 **/
void canopen_client_send_data_to_stack(streaming chanend c_application,
                                               unsigned char pdo_number,
                                               unsigned char data_length,
                                               unsigned char data[]);

/*==========================================================================*/
/**
 * canopen_client_receive_data_from_stack is the function
 * to receive data from canopen module.
 *
 * \param c_application channel to receive data from the application
 * \param data_length length of data
 * \param data data buffer which contains receive data
 * \return none
 **/
void canopen_client_receive_data_from_stack(streaming chanend c_application,
                                                   REFERENCE_PARAM(unsigned char,
                                                                   data_length),
                                                   NULLABLE_ARRAY_OF(unsigned char,
                                                                     data));

#endif /* canopen_client_h_ */

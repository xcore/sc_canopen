
#ifndef __pdo_h__
#define __pdo_h__

#include <xccompat.h>
/*---------------------------------------------------------------------------
typedefs
---------------------------------------------------------------------------*/

/**
* \enum pdo_parameters
* \brief CANOpen pdo parameter values
*/
enum pdo_parameters
{
  RPDO_0_COMMUNICATION_PARAMETER = 0x1400, /**<CANOpen communication parameter index of receive PDO 0 */
  RPDO_1_COMMUNICATION_PARAMETER = 0x1401, /**<CANOpen communication parameter index of receive PDO 1 */
  RPDO_2_COMMUNICATION_PARAMETER = 0x1402, /**<CANOpen communication parameter index of receive PDO 2 */
  RPDO_3_COMMUNICATION_PARAMETER = 0x1403, /**<CANOpen communication parameter index of receive PDO 3 */
  RPDO_0_MAPPING_PARAMETER       = 0x1600, /**<CANOpen mapping parameter index of receive PDO 0 */
  RPDO_1_MAPPING_PARAMETER       = 0x1601, /**<CANOpen mapping parameter index of receive PDO 1 */
  RPDO_2_MAPPING_PARAMETER       = 0x1602, /**<CANOpen mapping parameter index of receive PDO 2 */
  RPDO_3_MAPPING_PARAMETER       = 0x1603, /**<CANOpen mapping parameter index of receive PDO 3 */
  TPDO_0_COMMUNICATION_PARAMETER = 0x1800, /**<CANOpen communication parameter index of transmit PDO 0 */
  TPDO_1_COMMUNICATION_PARAMETER = 0x1801, /**<CANOpen communication parameter index of transmit PDO 1 */
  TPDO_2_COMMUNICATION_PARAMETER = 0x1802, /**<CANOpen communication parameter index of transmit PDO 2 */
  TPDO_3_COMMUNICATION_PARAMETER = 0x1803, /**<CANOpen communication parameter index of transmit PDO 3 */
  TPDO_0_MAPPING_PARAMETER       = 0x1A00, /**<CANOpen mapping parameter index of transmit PDO 0 */
  TPDO_1_MAPPING_PARAMETER       = 0x1A01, /**<CANOpen mapping parameter index of transmit PDO 1 */
  TPDO_2_MAPPING_PARAMETER       = 0x1A02, /**<CANOpen mapping parameter index of transmit PDO 2 */
  TPDO_3_MAPPING_PARAMETER       = 0x1A03  /**<CANOpen mapping parameter index of transmit PDO 3 */
};

/**
* The structure to represent transmit sync timer
*/
typedef struct tx_sync_timer
{
  unsigned comm_parameter;    /**< CANOpen TPDO communication parameter */
  unsigned mapping_parameter; /**< CANOpen TPDO mapping parameter */
  char sync_counter;          /**< CANOpen TPDO counter value */
  char sync_value;            /**< CANOpen TPDO sync value */
  char tx_data_ready;         /**< CANOpen TPDO transmit data ready signal */
}tx_sync_timer;


/**
* The structure to represent receive sync messages
*/
typedef struct rx_sync_messages
{
  char sync_counter;  /**< CANOpen RPDO sync counter value */
  char sync_value;    /**< CANOpen RPDO actual sync configured value */
  char rx_data_ready; /**< CANOpen RPDO receive data ready signal */
  char data_length;   /**< CANOpen RPDO data length of data to receive */
  char data[8];       /**< CANOpen RPDO data buffer */
}rx_sync_mesages;

/**
* The structure to represent tpdo event timer value
*/
typedef struct pdo_event_timer
{
    unsigned event_type; /**<  CANOpen TPDO event type */
    unsigned counter;    /**<  CANOpen TPDO counter value */
}pdo_event_timer;

/**
* The structure to represent tpdo event timer value
*/
typedef struct tpdo_inhibit_time
{
    unsigned inhibit_time;    /**<  CANOpen TPDO inhibit time */
    unsigned inhibit_counter; /**<  CANOpen TPDO inhibit time counter */
}tpdo_inhibit_time;

/*---------------------------------------------------------------------------
prototypes
---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
* pdo_find_cob_id is the function in order to find cob id of pdo from the
* object dictionary.
*
* \param address index of pdo in the object dictionary
* \return returns cob id of pdo
**/
unsigned pdo_find_cob_id(int address);

/*==========================================================================*/
/**
* pdo_transmit_data is the function in order to transmit pdo data on to the
* canbus.
*
* \param comm_parameter pdo communication parameter
* \param mapping_parameter pdo mapping parameter
* \param c_rx_tx channel to communicate to the can module
* \return none
**/
void pdo_transmit_data(unsigned comm_parameter,
                       unsigned mapping_parameter,
                       chanend c_rx_tx);

/*==========================================================================*/
/**
* pdo_read_data_from_od is the function in order to read pdo data from the
* object dictionary.
*
* \param comm_parameter pdo communication parameter
* \param mapping_parameter pdo mapping parameter
* \param data_buffer data buffer to save the read data.
* \return data length
**/
char pdo_read_data_from_od(unsigned comm_parameter,
                           unsigned mapping_parameter,
                           char data_buffer[8]);

/*==========================================================================*/
/**
* pdo_receive_application_data is the function to receive pdo data from the
* application.
*
* \param pdo_number pdo number
* \param length pdo length of data bytes
* \param data data buffer
* \param c_rx_tx channel to communicate to can module
* \param tpdo_inhibit_time_values structure with inhibit time values of TPDOs
* \return none
**/
void pdo_receive_application_data(char pdo_number,
                              char length,
                              char data[],
                              NULLABLE_ARRAY_OF(tpdo_inhibit_time, tpdo_inhibit_time_values),
                              chanend c_rx_tx);

/*==========================================================================*/
/**
* pdo_find_transmission_type is the function to find the tarnsmission type of
* pdo.
*
* \param address address of the pdo
* \return returns transmit type of the pdo
**/
int pdo_find_transmission_type(int address);

/*==========================================================================*/
/**
* pdo_send_data_to_application is the function to transmit pdo data to the
* application.
*
* \param mapping_parameter pdo mapping parameter
* \param data data to be transmitted to the application
* \param data_length data length of the data to be be transmitted
* \param c_application channel to communicate to application
* \return none
**/
void pdo_send_data_to_application(unsigned mapping_parameter,
                                  char data[],
                                  char data_length,
                                  streaming chanend c_application);


/*==========================================================================*/
/**
* pdo_write_data_to_od is the function in order to write pdo data to the
* object dictionary.
*
* \param address address od pdo
* \param data_buffer data to be written to the object dictionary
* \return length of data that is written to the object dictionary
**/
char pdo_write_data_to_od(int address, char data_buffer[]);

/*==========================================================================*/
/**
* pdo_find_event_type is the function to find the event type of
* pdo.
*
* \param address address of the pdo
* \return returns transmit type of the pdo
**/
unsigned pdo_find_event_type(int address);

/*==========================================================================*/
/**
* pdo_find_inhibit_time is the function to find the inhibit time of
* pdo.
*
* \param address address of the pdo
* \return pdo_tx_type returns transmit type of the pdo
**/
unsigned pdo_find_inhibit_time(int address);

#endif /* pdo_h_ */

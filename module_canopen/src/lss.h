
#ifndef __lss_h__
#define __lss_h__

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/**
 * \enum lss_commands
 * \brief Different LSS commands supported according to DS 305 standard
 */
enum lss_commands
{
  SWITCH_MODE_GLOBAL_COMMAND = 0x04,      /**<CANOpen LSS switch mode global command */
  INQUIRE_NODE_ID = 0x5E,                 /**<CANOpen LSS enquire node id command */
  CONFIGURE_NODE_ID = 0x11,               /**<CANOpen LSS configure node id command */
  CONFIGURE_BIT_TIMING_PARAMETERS = 0x13, /**<CANOpen LSS configure bit time parameters command */
  STORE_CONFIGURATION_SETTINGS = 0x17,    /**<CANOpen LSS store configuration settings command */
  INQUIRE_VENDOR_ID = 0x5A,               /**<CANOpen LSS inquire vendor id command */
  INQUIRE_PRODUCT_CODE = 0x5B,            /**<CANOpen LSS inquire product code command */
  INQUIRE_REVISION_NUMBER = 0x5C,         /**<CANOpen LSS inquire revision number command */
  INQUIRE_SERIAL_NUMBER = 0x5D            /**<CANOpen LSS inquire serial number command */
};

/**
 * \enum lss_bit_rate
 * \brief Different LSS bit time supported according to DS 305 standard
 */
enum lss_bit_rate
{
  BIT_RATE_1000 = 1000, /**<CANOpen LSS 1000 bits per second */
  BIT_RATE_800 = 800,   /**<CANOpen LSS 800 bits per second */
  BIT_RATE_500 = 500,   /**<CANOpen LSS 500 bits per second */
  BIT_RATE_250 = 250,   /**<CANOpen LSS 250 bits per second */
  BIT_RATE_125 = 125,   /**<CANOpen LSS 125 bits per second */
  BIT_RESERVED = 0,     /**<CANOpen LSS reserved */
  BIT_RATE_50 = 50,     /**<CANOpen LSS 50 bits per second */
  BIT_RATE_20 = 20,     /**<CANOpen LSS 20 bits per second */
  BIT_RATE_10 = 10      /**<CANOpen LSS 10 bits per second */
};

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 * lss_send_node_id is the function in order to transmit current device node id
 * value on the canbus.
 *
 * \param c_rx_tx Channel connecting to can module
 * \return none
 **/
void lss_send_node_id(chanend c_rx_tx);

/*==========================================================================*/
/**
 * lss_configure_node_id_response is the function in order to configure current device node id
 * value based on LSS configure command.
 *
 * \param c_rx_tx Channel connecting to can module
 * \param configuration_status current configuration status
 * \return none
 **/
void lss_configure_node_id_response(chanend c_rx_tx, char configuration_status);

/*==========================================================================*/
/**
 * lss_configure_bit_timing_response is the function in order to configure bit time of
 * can bus communication using LSS configure command.
 *
 * \param c_rx_tx Channel connecting to can module
 * \param configuration_status current configuration status
 * \return none
 **/
void lss_configure_bit_timing_response(chanend c_rx_tx,
                                       char configuration_status);

/*==========================================================================*/
/**
 * lss_store_config_setttings_response is the function in order to store the received
 * configuratioon settings received using LSS configure command.
 *
 * \param c_rx_tx Channel connecting to can module
 * \param configuration_status current configuration status
 * \return none
 **/
void lss_store_config_settings_response(chanend c_rx_tx,
                                        char configuration_status);

/*==========================================================================*/
/**
 * lss_inquire_vendor_id_response is the function in order to send vendor id
 * to the LSS master.
 *
 * \param c_rx_tx Channel connecting to can module
 * \param canopen_state State of CANopen node
 * \param error_index_pointer Pointer pointing to the error register
 * \return none
 **/
void lss_inquire_vendor_id_response(chanend c_rx_tx,
                                    REFERENCE_PARAM(char, canopen_state),
                                    REFERENCE_PARAM(unsigned char,
                                                    error_index_pointer));

/*==========================================================================*/
/**
 * lss_inquire_product_coode is the function in order to send product code id
 * to the LSS master.
 *
 * \param c_rx_tx Channel connecting to can module
 * \param canopen_state State of CANopen node
 * \param error_index_pointer Pointer pointing to the error register
 * \return none
 **/
void lss_inquire_product_code(chanend c_rx_tx,
                              REFERENCE_PARAM(char, canopen_state),
                              REFERENCE_PARAM(unsigned char,
                                              error_index_pointer));

/*==========================================================================*/
/**
 * lss_inquire_revision_number is the function in order to send revision number
 * to the LSS master.
 *
 * \param c_rx_tx Channel connecting to can module
 * \param canopen_state State of CANopen node
 * \param error_index_pointer Pointer pointing to the error register
 * \return none
 **/
void lss_inquire_revision_number(chanend c_rx_tx,
                                 REFERENCE_PARAM(char, canopen_state),
                                 REFERENCE_PARAM(unsigned char,
                                                 error_index_pointer));

/*==========================================================================*/
/**
 * lss_inquire_serial_number is the function in order to send serial number
 * to the LSS master.
 *
 * \param c_rx_tx Channel connecting to can module
 * \param canopen_state State of CANopen node
 * \param error_index_pointer Pointer pointing to the error register
 * \return none
 **/
void lss_inquire_serial_number(chanend c_rx_tx,
                               REFERENCE_PARAM(char, canopen_state),
                               REFERENCE_PARAM(unsigned char,
                                               error_index_pointer));

#endif /* lss_h_ */

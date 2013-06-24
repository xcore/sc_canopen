
#ifndef __emcy_h__
#define __emcy_h__


/*---------------------------------------------------------------------------
typedefs
---------------------------------------------------------------------------*/

/**
* \enum error_types
* \brief CANOpen Different types of errors
*/
enum error_type
{
  ERR_TYPE_GENERIC_ERROR = 0,             /**<CANOpen generic error */
  ERR_TYPE_CURRRENT_ERROR = 1,            /**<CANOpen low or high current error */
  ERR_TYPE_VOLTAGE_ERROR = 2,             /**<CANOpen low or high voltage error */
  ERR_TYPE_TEMPERATURE_ERROR = 3,         /**<CANOpen exceeded temperature limits error */
  ERR_TYPE_COMMUNICATION_ERROR = 4,       /**<CANOpen communication error */
  ERR_TYPE_DEVICE_PROFILE_DEF_ERROR = 5,  /**<CANOpen device profile definition error */
  ERR_TYPE_MANUFACTURE_SPECIFIC_ERROR = 7 /**<CANOpen manufacture specific error */
};


/**
* \enum emcy_messages
* \brief emergency messages supported by DS 301 standard
*/
enum emcy_messages
{
  ERROR_RESET_NO_ERR = 0x0,                    /**<CANOpen Error is reset no errors */
  GENERIC_ERROR = 0x1000,                      /**<CANOpen generic error occurred */
  CURRENT_GENERIC_ERROR = 0x2000,              /**<CANOpen generic regerading current occurred */
  CURRENT_INPUT_ERROR = 0x2100,                /**<CANOpen input current error */
  CURRENT_DEVICE_GENERIC_ERROR = 0x2200,       /**<CANOpen device generic error */
  CURRENT_DEVICE_OUTPUT_ERROR = 0x2300,        /**<CANOpen generic output error */
  VOLTAGE_GENERIC_ERROR = 0x3000,              /**<CANOpen voltage generic error */
  VOLTAGE_MAINS_GENERIC_ERROR = 0x3100,        /**<CANOpen voltage mains generic error */
  VOLTAGE_DEVICE_GENERIC_ERROR = 0x3300,       /**<CANOpen voltage device generic error */
  TEMPERATURE_GENERIC_ERROR = 0x4000,          /**<CANOpen temperature generic error */
  TEMPERATURE_AMBIENT_GENERIC_ERROR = 0x4100,  /**<CANOpen ambient temperature generic error */
  TEMPERATURE_DEVICE_ERROR = 0x4200,           /**<CANOpen temperature device error */
  HARDWARE_GENERIC_ERROR = 0x5000,             /**<CANOpen hardware generic error */
  SOFTWARE_GENERIC_ERROR = 0x6000,             /**<CANOpen software generic error */
  SOFTWARE_INTERNAL_GENERIC_ERROR = 0x6100,    /**<CANOpen internal generic error */
  SOFTWARE_USER_GENERIC_ERROR = 0x6200,        /**<CANOpen software user level generic error */
  DATA_SET_GENRIC_ERROR = 0x6300,              /**<CANOpen data set generic error */
  ADDITIONAL_MODULES_GENERIC = 0x7000,         /**<CANOpen additional modules generic error */
  MONITORING_GENERIC_ERROR = 0x8000,           /**<CANOpen monitoring all generic error */
  COMMUNICATION_GENERIC_ERROR = 0x8100,        /**<CANOpen communication generic error */
  CAN_OVERRUN_ERROR = 0x8110,                  /**<CANOpen object lost error */
  CAN_ERROR_PASSIVE_MODE_ERROR = 0x8120,       /**<CANOpen error passive mode error */
  LIFE_GUARD_HEARTBEAT_ERROR = 0x8130,         /**<CANOpen lifeguard or heartbeat error */
  RECOVERED_FROM_BUS_OFF_ERROR = 0x8140,       /**<CANOpen recovered from busoff error */
  CAN_ID_COLLISION_ERROR = 0x8150,             /**<CANOpen canid collision error */
  PROTOCOL_ERROR_GENERIC = 0x8200,             /**<CANOpen protocol generic error */
  PDO_NOT_PROCESS_LENGTH_ERROR = 0x8210,       /**<CANOpen pdo is not process length error */
  PDO_LENGTH_EXCEEDED_ERROR = 0x8220,          /**<CANOpen pdo length exceeded error */
  SYNC_DATA_LENGTH_ERROR = 0x8240,             /**<CANOpen sync data length error */
  RPDO_TIME_OUT_ERROR = 0x8250,                /**<CANOpen rpdo timeout error */
  EXTERNAL_ERROR_GENERIC_ERROR = 0x9000,       /**<CANOpen external generic error */
  ADDITIONAL_FUNCTIONS_GENERIC_ERROR = 0xF000, /**<CANOpen additional generic error */
  DEVICE_SPECIFIC_GENERIC_ERROR = 0xFF00       /**<CANOpen device specification generic error */
};

/**
* \enum error_behaviour_states
* \brief error states of CANOpen node
*/
enum error_behaviour_states
{
  ERR_SWITCH_TO_PRE_OPERATIONAL = 0x00, /**<CANOpen switch to pre operatrional state */
  ERR_SWITCH_TO_STOPPED         = 0x02  /**<CANOpen switch to stopped state */
};


/*---------------------------------------------------------------------------
prototypes
---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
* emcy_reset_error_register is function to reset the error values and error registers
*
* \param none
* \return none
**/
void emcy_reset_error_register();

/*==========================================================================*/
/**
* emcy_send_emergency_message is the function to transmit error messages
* on the canopen network
*
* \param c_rx_tx Channel connecting to can module
* \param error_type type of error occurred
* \param emergency_code emergency code to be transmitted on to the network
* \param error_index_pointer points to the current value of error register
* \param canopen_state current CANOpen node state
* \return none
**/
void emcy_send_emergency_message(chanend c_rx_tx,
                            char error_type,
                            unsigned emergency_code,
                            REFERENCE_PARAM(char, error_index_pointer),
                            REFERENCE_PARAM(char, canopen_state));

#endif /* emcy_h_ */

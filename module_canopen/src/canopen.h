/**
* The copyrights, all other intellectual and industrial
* property rights are retained by XMOS and/or its licensors.
* Terms and conditions covering the use of this code can
* be found in the Xmos End User License Agreement.
*
* Copyright XMOS Ltd 2012
*
* In the case where this code is a modification of existing code
* under a separate license, the separate license terms are shown
* below. The modifications to the code are still covered by the
* copyright notice above.
*
**/

#ifndef __can_open_h__
#define __can_open_h__

/*---------------------------------------------------------------------------
nested include files
---------------------------------------------------------------------------*/

#include "common.h"
#include "can.h"
#include <xccompat.h>

/*---------------------------------------------------------------------------
globals
---------------------------------------------------------------------------*/
#define MAX_NO_OF_PDOS 512

/*---------------------------------------------------------------------------
typedefs
---------------------------------------------------------------------------*/

/**
* \enum condition_values
* \brief CANOpen Condition values
*/
enum condition_values
{
  TRUE  = 1, /**<CANOpen condition is TRUE */
  FALSE = 0  /**<CANOpen condition is FALSE */
};

/**
* \enum message_length
* \brief Message length of different CANOpen message types
* application.
*/
enum message_length
{
  NMT_MESSAGE_LENGTH       = 2, /**<CANOpen NMT Message length */
  LSS_MESSAGE_LENGTH       = 8, /**<CANOpen LSS Message length */
  SYNC_MESSAGE_LENGTH      = 0, /**<CANOpen SYNC Message length */
  HEARTBEAT_MESSAGE_LENGTH = 0, /**<CANOpen Heartbeat Message length */
  SDO_MESSAGE_LENGTH       = 8  /**<CANOpen SDO Message length */
};

/**
* \enum states_canopen
* \brief Different CANOpen states supported by this module according to DS 301
* application.
*/
enum states_canopen
{
  INITIALIZATION      = 0x00, /**<CANOpen NMT Intitialization state */
  PRE_OPERATIONAL     = 0x80, /**<CANOpen NMT pre-operational state */
  OPERATIONAL         = 0x01, /**<CANOpen NMT operational satate */
  STOPPED             = 0x02, /**<CANOpen NMT stopped satate */
  RESET_NODE          = 0x81, /**<CANOpen NMT reset-node satate */
  RESET_COMMUNICATION = 0x82  /**<CANOpen NMT reset communication satate */
};


/**
* \enum node_guard_states
* \brief CANOpen Noduguard / Heartbeat respsonses sent to the Master
* application.
*/
enum node_guard_states
{
  NG_BOOT_UP         = 0x00, /**<CANOpen NMT Nodeguard response bootup state */
  NG_STOPPED         = 0x04, /**<CANOpen NMT Nodeguard response stopped state */
  NG_OPERATIONAL     = 0x05, /**<CANOpen NMT Nodeguard response operational state */
  NG_PRE_OPERATIONAL = 0x7F  /**<CANOpen NMT Nodeguard response pre operational state */
};


/**
* \enum cob_id
* \brief COB-ID supported by CANOpen module according to DS 301
* application.
*/
enum cob_id
{
  NMT_MESSAGE           = 0     + CANOPEN_NODE_ID, /**<CANOpen COB-ID nmt state Message*/
  NMT_MESSAGE_BROADCAST = 0,                       /**<CANOpen COB-ID nmt Broadcast Message*/
  SYNC                  = 0x80  + CANOPEN_NODE_ID, /**<CANOpen COB-ID sync Message */
  TIME_STAMP            = 0x100 + CANOPEN_NODE_ID, /**<CANOpen COB-ID timestamp Message */
  NG_HEARTBEAT          = 0x700 + CANOPEN_NODE_ID, /**<CANOpen COB-ID heartbeat / nodeguard Message */
  EMERGENCY_MESSAGE     = 0x80,                    /**<CANOpen COB-ID emergency Message */
  TPDO_0_MESSAGE        = 0x180 + CANOPEN_NODE_ID, /**<CANOpen COB-ID transmit pdo 0 Message */
  RPDO_0_MESSAGE        = 0x200 + CANOPEN_NODE_ID, /**<CANOpen COB-ID receive pdo 0 Message */
  TPDO_1_MESSAGE        = 0x280 + CANOPEN_NODE_ID, /**<CANOpen COB-ID transmit pdo 1 Message */
  RPDO_1_MESSAGE        = 0x300 + CANOPEN_NODE_ID, /**<CANOpen COB-ID receive pdo 1 Message */
  TPDO_2_MESSAGE        = 0x380 + CANOPEN_NODE_ID, /**<CANOpen COB-ID transmit pdo 2 Message */
  RPDO_2_MESSAGE        = 0x400 + CANOPEN_NODE_ID, /**<CANOpen COB-ID receive pdo 2 Message */
  TPDO_3_MESSAGE        = 0x480 + CANOPEN_NODE_ID, /**<CANOpen COB-ID transmit pdo 3 Message */
  RPDO_3_MESSAGE        = 0x500 + CANOPEN_NODE_ID, /**<CANOpen COB-ID receive pdo 3 Message */
  TSDO_MESSAGE          = 0x580 + CANOPEN_NODE_ID, /**<CANOpen COB-ID transmit sdo Message */
  RSDO_MESSAGE          = 0x600 + CANOPEN_NODE_ID, /**<CANOpen COB-ID receive sdo Message */
  RLSS_MESSAGE          = 0x7E5 + CANOPEN_NODE_ID, /**<CANOpen COB-ID receive LSS Message */
  TLSS_MESSAGE          = 0x7E4                    /**<CANOpen COB-ID transmit LSS Message */
};

/*---------------------------------------------------------------------------
prototypes
---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
* canopen manager is the top level function in order to transmit/receive device
* values on the canbus. This function will send:
* chanend : channel to communicate between canopen and can modules
* streaming chanend : channel to communicate between canopen module and application
*
* \param c_rx_tx Channel connecting to can module
* \param c_application Channel to communicate to application
* \return none
**/
void canopen_manager(REFERENCE_PARAM(can_ports, p),
                     port shut,
                     streaming chanend c_application);



#endif

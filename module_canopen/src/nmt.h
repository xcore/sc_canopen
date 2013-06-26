
#ifndef __nmt_h__
#define __nmt_h__


/*---------------------------------------------------------------------------
prototypes
---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
* nmt_initialize is the function to initialize the parameters of canopen
* slave using object dictionary entries
*
* \param sync_timer sync timer to check if the sync communication is
*   whith in synchronous window length
* \param pdo_event structure with Events of PDOs
* \param tpdo_inhibit_time_values Structure with Inhibit time value of TPDOs
* \param sync_window_length synchronous window time
* \param guard_time node guard time
* \param life_time lie time of node guard
* \param producer_heart_beat heartbeat time of the slave
* \param heart_beat_active heartbeat active flag
* \return none
**/
void nmt_initialize(NULLABLE_ARRAY_OF(tx_sync_timer, sync_timer),
                NULLABLE_ARRAY_OF(pdo_event_timer, pdo_event),
                NULLABLE_ARRAY_OF(tpdo_inhibit_time, tpdo_inhibit_time_values),
                REFERENCE_PARAM(unsigned, sync_window_length),
                REFERENCE_PARAM(unsigned, guard_time),
                REFERENCE_PARAM(unsigned, life_time),
                REFERENCE_PARAM(unsigned, producer_heart_beat),
                REFERENCE_PARAM(char, heart_beat_active ));

/*==========================================================================*/
/**
* nmt_send_heartbeat_message is the function to transmit heartbeat
* messages on the canbus
*
* \param c_rx_tx Channel connecting to bus module like CAN
* \param frame canframe to transmit on bus module like CAN
* \param canopen_state current state of canopen node
* \return none
**/
void nmt_send_heartbeat_message(chanend c_rx_tx,
                            can_frame frame,
                            unsigned char canopen_state);

/*==========================================================================*/
/**
* nmt_send_nodeguard_message is the function to transmit nodeguard
* messages on the bus modules like CAN. This function will send:
*
* \param c_rx_tx channel to communicate with bus module like CAN
* \param frame canframe to transmit on bus moduels like CAN
* \param toggle toggle bit that toggles with every node guard message received
* \param state current state of canopen node
* \return none
**/
void nmt_send_nodeguard_message(chanend c_rx_tx,
                            can_frame frame,
                            char toggle,
                            unsigned char state);

/*==========================================================================*/
/**
* nmt_send_boot_up_message is the function to transmit bootup
* message on the bus modules like CAN after initialisation
*
* \param c_rx_tx channel to communicate with bus module like CAN
* \return none
**/
void nmt_send_boot_up_message(chanend c_rx_tx);


#endif /* nmt_h_ */

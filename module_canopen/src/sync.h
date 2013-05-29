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

#ifndef __sync_h__
#define __sync_h__

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 * sync_pdo_data_transmit is the function in order to transmit synchronous pdo
 * data.
 *
 * \param pdo_number PDO number
 * \param rtr_check RTR bit check
 * \param sync_window_timer Timer moniters sync window time
 * \param sync_time_start time value when the sync transmission is started
 * \param sync_time_current Current sync time value
 * \param sync_window_length Sync. window length time
 * \param time_difference_sync Time difference current time and sync start time
 * \param sync_timer Structure having sync timer values
 * \param tpdo_inhibit_time_values Structure having Inhibit time values
 * \param c_rx_tx Channel connecting to can module
 * \return none
 **/
void sync_pdo_data_transmit(char pdo_number,
                            unsigned rtr_check,
                            timer sync_window_timer,
                            unsigned sync_time_start,
                            unsigned sync_time_current,
                            unsigned sync_window_length,
                            unsigned time_difference_sync,
                            NULLABLE_ARRAY_OF(tx_sync_timer, sync_timer),
                            NULLABLE_ARRAY_OF(tpdo_inhibit_time,
                                              tpdo_inhibit_time_values),
                            chanend c_rx_tx);

/*==========================================================================*/
/**
 * sync_pdo_data_receive is the function in order to receive synchronous pdo
 * data.
 *
 * \param pdo_number PDO number
 * \param sync_messages_rx Structuyre containing inforamion about receive types
 * \param sync_window_timer Timer moniters sync window time
 * \param sync_time_start time value when the sync transmission is started
 * \param sync_time_current Current sync time value
 * \param sync_window_length Sync. window length time
 * \param c_application Channel connecting to Application
 * \return none
 **/
void sync_pdo_data_receive(char pdo_number,
                          NULLABLE_ARRAY_OF(rx_sync_mesages, sync_messages_rx),
                          timer sync_window_timer,
                          unsigned sync_time_current,
                          unsigned sync_time_start,
                          unsigned sync_window_length,
                          streaming chanend c_application);


#endif /* sync_h_ */

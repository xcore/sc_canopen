/**
* The copyrights, all other intellectual and industrial
* property rights are retained by XMOS and/or its licensors.
*
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


/*---------------------------------------------------------------------------
nested include files
---------------------------------------------------------------------------*/
#include "canopen.h"
#include "pdo.h"
#include <xccompat.h>

/*---------------------------------------------------------------------------
 Transmit SYNC PDO(TPDO) data from the object dictionary on to CAN network
 ---------------------------------------------------------------------------*/
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
                            chanend c_rx_tx)
{
  if (rtr_check == TRUE) //pdo exists and no RTR set
  {
    sync_timer[pdo_number].sync_counter = sync_timer[pdo_number].sync_counter
        + 1; //increment sync counter
    if ((sync_timer[pdo_number].tx_data_ready == TRUE)
        && (sync_timer[pdo_number].sync_value == 0)) //check if data avialable for transmit
    {
      sync_window_timer:>sync_time_current;
      if (sync_time_start < sync_time_current)
      {
        time_difference_sync = sync_time_current - sync_time_start;
      }
      else
      {
        time_difference_sync = sync_time_start - sync_time_current;
      }
      if ((time_difference_sync < sync_window_length) || (sync_window_length
          == 0)) //check if tx is in sync window length

      {
        if ((tpdo_inhibit_time_values[pdo_number].inhibit_time
            < tpdo_inhibit_time_values[pdo_number].inhibit_counter)
            || (tpdo_inhibit_time_values[pdo_number].inhibit_time == 0)) //check if inhibit time is reached
        {
          pdo_transmit_data(sync_timer[pdo_number].comm_parameter,
                            sync_timer[pdo_number].mapping_parameter,
                            c_rx_tx); //transmit data
          sync_timer[pdo_number].tx_data_ready = FALSE;
          tpdo_inhibit_time_values[pdo_number].inhibit_counter = 0;
        }
      }
    }
    else if ((sync_timer[pdo_number].sync_counter
        == sync_timer[pdo_number].sync_value)
        && (sync_timer[pdo_number].sync_value <= 240)) //sync messages
    {
      sync_window_timer:>sync_time_current;
      if (sync_time_start < sync_time_current)
      {
        time_difference_sync = sync_time_current - sync_time_start;
      }
      else
      {
        time_difference_sync = sync_time_start - sync_time_current;
      }
      if ((time_difference_sync < sync_window_length) || (sync_window_length
          == 0))
      {
        if ((tpdo_inhibit_time_values[pdo_number].inhibit_time
            < tpdo_inhibit_time_values[pdo_number].inhibit_counter)
            || (tpdo_inhibit_time_values[pdo_number].inhibit_time == 0))
        {
          pdo_transmit_data(sync_timer[pdo_number].comm_parameter,
                            sync_timer[pdo_number].mapping_parameter,
                            c_rx_tx);
          sync_timer[pdo_number].sync_counter = 0; //send data and reset sync counters
          tpdo_inhibit_time_values[pdo_number].inhibit_counter = 0;
        }
      }
    }
    else if ((sync_timer[pdo_number].sync_value == 252)
        && (sync_timer[pdo_number].tx_data_ready == TRUE)) //RTR request
    {
      sync_window_timer:>sync_time_current;
      if (sync_time_start < sync_time_current)
      {
        time_difference_sync = sync_time_current - sync_time_start;
      }
      else
      {
        time_difference_sync = sync_time_start - sync_time_current;
      }
      if ((time_difference_sync < sync_window_length) || (sync_window_length
          == 0))
      {
        if ((tpdo_inhibit_time_values[pdo_number].inhibit_time
            < tpdo_inhibit_time_values[pdo_number].inhibit_counter)
            || (tpdo_inhibit_time_values[pdo_number].inhibit_time == 0))
        {
          pdo_transmit_data(sync_timer[pdo_number].comm_parameter,
                            sync_timer[pdo_number].mapping_parameter,
                            c_rx_tx); //transmit data
          sync_timer[pdo_number].tx_data_ready = FALSE;
          tpdo_inhibit_time_values[pdo_number].inhibit_counter = 0;
        }
      }
    }
  }
}

/*---------------------------------------------------------------------------
 Transmit SYNC PDO(TPDO) data from the object dictionary on to CAN network
 ---------------------------------------------------------------------------*/
void sync_pdo_data_receive(char pdo_number,
                           NULLABLE_ARRAY_OF(rx_sync_mesages, sync_messages_rx),
                           timer sync_window_timer,
                           unsigned sync_time_current,
                           unsigned sync_time_start,
                           unsigned sync_window_length,
                           streaming chanend c_application)
{
  unsigned time_difference_sync;
  if ((sync_messages_rx[pdo_number].rx_data_ready == TRUE)
      && (sync_messages_rx[pdo_number].sync_value == 0))
  {
    sync_window_timer:>sync_time_current;
    if (sync_time_start < sync_time_current)
    {
      time_difference_sync = sync_time_current - sync_time_start;
    }
    else
    {
      time_difference_sync = sync_time_start - sync_time_current;
    }
    if (time_difference_sync < sync_window_length)
    {
      sync_messages_rx[pdo_number].rx_data_ready = FALSE;
      pdo_send_data_to_application(RPDO_0_MAPPING_PARAMETER + pdo_number,
                                   sync_messages_rx[pdo_number].data,
                                   sync_messages_rx[pdo_number].data_length,
                                   c_application);
    }
  }
  else
  {
    if (sync_messages_rx[pdo_number].rx_data_ready == TRUE)
    {
      sync_messages_rx[pdo_number].sync_counter
          = sync_messages_rx[pdo_number].sync_counter + 1; //increment sync counter
      if (sync_messages_rx[pdo_number].sync_counter
          == sync_messages_rx[pdo_number].sync_value) //check if counter reached sync value

      {
        sync_window_timer:>sync_time_current;
        if (sync_time_start < sync_time_current)
        {
          time_difference_sync = sync_time_current - sync_time_start;
        }
        else
        {
          time_difference_sync = sync_time_start - sync_time_current;
        }
        if (time_difference_sync < sync_window_length)
        {
          pdo_send_data_to_application(RPDO_0_MAPPING_PARAMETER + pdo_number,
                                       sync_messages_rx[pdo_number].data,
                                       sync_messages_rx[pdo_number].data_length,
                                       c_application);
          sync_messages_rx[pdo_number].rx_data_ready = FALSE;
        }
      }
    }
  }
}

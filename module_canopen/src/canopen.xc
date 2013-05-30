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

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include "canopen.h"
#include "can.h"
#include "sdo.h"
#include "pdo.h"
#include "od.h"
#include "lss.h"
#include "nmt.h"
#include "emcy.h"
#include "sync.h"
#include "common.h"
#include <xccompat.h>

/*---------------------------------------------------------------------------
 Function prototypes
 ---------------------------------------------------------------------------*/
static void
receive_rpdo_message(unsigned char canopen_state,
                     char pdo_number,
                     can_frame frame,
                     NULLABLE_ARRAY_OF(rx_sync_mesages, sync_messages_rx),
                     NULLABLE_ARRAY_OF(tx_sync_timer, sync_timer),
                     REFERENCE_PARAM(char, error_index_pointer),
                     chanend c_rx_tx,
                     streaming chanend c_application);

static void
    receive_tpdo_rtr_request(can_frame frame,
                             char pdo_number,
                             NULLABLE_ARRAY_OF(tx_sync_timer, sync_timer),
                             NULLABLE_ARRAY_OF(tpdo_inhibit_time, tpdo_inhibit_time_values),
                             chanend c_rx_tx);

static void
lss_state_machine(can_frame frame,
                  char lss_configuration_mode,
                  chanend c_rx_tx,
                  REFERENCE_PARAM(char, canopen_state),
                  REFERENCE_PARAM(unsigned char, error_index_pointer));

/*---------------------------------------------------------------------------
 CANOpen Manager communicates with CAN module and application core
 ---------------------------------------------------------------------------*/
#pragma ordered
void canopen_manager(chanend c_rx_tx, streaming chanend c_application)
{
  can_frame frame;
  tx_sync_timer sync_timer[CANOPEN_NUMBER_OF_TPDOS_SUPPORTED];
  rx_sync_mesages sync_messages_rx[CANOPEN_NUMBER_OF_RPDOS_SUPPORTED];
  pdo_event_timer pdo_event[CANOPEN_NUMBER_OF_TPDOS_SUPPORTED];
  tpdo_inhibit_time tpdo_inhibit_time_values[CANOPEN_NUMBER_OF_TPDOS_SUPPORTED];
  char app_tpdo_number, app_length, app_data[8], app_counter = 0,
      lss_configuration_mode = FALSE;
  char hb_toggle = 0, od_sub_index, data_length, sdo_toggle;
  char data_buffer[CANOPEN_MAX_DATA_BUFFER_LENGTH], no_of_bytes,
      segmented_rx_last_frame, count, pdo_number = 0;
  char heart_beat_active;
  int od_index, index;
  unsigned char error_index_pointer = 0, timer_interrupt_counter = 0;
  char canopen_state = INITIALIZATION, sdo_message_type;
  unsigned sdo_timeout_time_value = 2000000000; //sdo_timeout set to 20 seconds. just for tesing: TODO
  unsigned hb_time, producer_heart_beat, sync_window_length, sync_time_start,
      sync_time_current, ng_time, guard_time, life_time, comm_timeout_time,
      time_difference_sync, timer_pdo_event_time;
  timer heart_beat_timer, sync_window_timer, node_guard_timer,
      timer_communication_timeout, timer_pdo_event;

  heart_beat_timer :> hb_time;
  node_guard_timer:> ng_time;
  timer_pdo_event:> timer_pdo_event_time;

  while(1)
  {
    if (canopen_state == INITIALIZATION) //Node initializes and send bootup messsgage and goes to pre operation state
    {
      nmt_initialize(sync_timer,
                     pdo_event,
                     tpdo_inhibit_time_values,
                     sync_window_length,
                     guard_time,
                     life_time,
                     producer_heart_beat,
                     heart_beat_active);
      nmt_send_boot_up_message(c_rx_tx);
      canopen_state = PRE_OPERATIONAL;
      sync_window_length = sync_window_length * 1000; //converting sync window length time in to milliseconds
    }
    else if (canopen_state == RESET_NODE) //Node resets and goes to pre operation state
    {
      error_index_pointer = 0;
      timer_interrupt_counter = 0;
      hb_toggle = 0;
      app_counter = 0;
      heart_beat_timer :> hb_time;
      node_guard_timer:> ng_time;
      timer_pdo_event:> timer_pdo_event_time;
      lss_configuration_mode = FALSE;
      nmt_initialize(sync_timer,
                     pdo_event,
                     tpdo_inhibit_time_values,
                     sync_window_length,
                     guard_time,
                     life_time,
                     producer_heart_beat,
                     heart_beat_active);
      emcy_reset_error_register();
      canopen_state = PRE_OPERATIONAL;
      sync_window_length = sync_window_length * 1000; //converting sync window length time in to milliseconds
    }
    else if (canopen_state == RESET_COMMUNICATION) //Node resets communication and goes to pre operation state
    {
      nmt_initialize(sync_timer,
                     pdo_event,
                     tpdo_inhibit_time_values,
                     sync_window_length,
                     guard_time,
                     life_time,
                     producer_heart_beat,
                     heart_beat_active);
      emcy_reset_error_register();
      canopen_state = PRE_OPERATIONAL;
      sync_window_length = sync_window_length * 1000; //converting sync window length time in to milliseconds
    }
    select
    {
      case can_rx_frame(c_rx_tx, frame):
      {
        unsigned char temp_case;
        if ((frame.id >= RPDO_0_MESSAGE) && (frame.id <= (RPDO_0_MESSAGE + 0x100
            * (CANOPEN_NUMBER_OF_RPDOS_SUPPORTED-1))))
        {
          receive_rpdo_message(canopen_state,
                               ((frame.id - RPDO_0_MESSAGE) >> 8),
                               frame,
                               sync_messages_rx,
                               sync_timer,
                               error_index_pointer,
                               c_rx_tx,
                               c_application);
        }
        else if ((frame.id >= TPDO_0_MESSAGE) && (frame.id <= (TPDO_0_MESSAGE
            + 0x100 * (CANOPEN_NUMBER_OF_TPDOS_SUPPORTED-1))))
        {
          receive_tpdo_rtr_request(frame,
                                   ((frame.id - TPDO_0_MESSAGE) >> 8),
                                   sync_timer,
                                   tpdo_inhibit_time_values,
                                   c_rx_tx); //TPDO RTR request
        }
        else
        {
          switch(frame.id)
          {
            case NMT_MESSAGE: //receive NMT message and change state accordingly
            if(frame.dlc != NMT_MESSAGE_LENGTH)
            {
              emcy_send_emergency_message(c_rx_tx,
                  ERR_TYPE_COMMUNICATION_ERROR,
                  PROTOCOL_ERROR_GENERIC,
                  error_index_pointer,
                  canopen_state);
            }
            else
            {
              if((frame.data[1] == 0) || (frame.data[1] == CANOPEN_NODE_ID)) //check if message is for this node or broadcast message

              {
                if((frame.data[0] == INITIALIZATION) ||
                    (frame.data[0] == PRE_OPERATIONAL) ||
                    (frame.data[0] == OPERATIONAL) ||
                    (frame.data[0] == STOPPED) ||
                    (frame.data[0] == RESET_COMMUNICATION) ||
                    (frame.data[0] == RESET_NODE))
                {
                  canopen_state=frame.data[0];
                }
              }
            }
            break;

            case RLSS_MESSAGE: // LSS messsages
            if(frame.dlc != LSS_MESSAGE_LENGTH)
            {
              emcy_send_emergency_message(c_rx_tx,
                  ERR_TYPE_COMMUNICATION_ERROR,
                  PROTOCOL_ERROR_GENERIC,
                  error_index_pointer,
                  canopen_state);
            }
            else
            {
              lss_state_machine(frame, lss_configuration_mode,c_rx_tx, canopen_state, error_index_pointer);
            }
            break;

            case SYNC:
            if(canopen_state == OPERATIONAL)
            {
              if(frame.dlc != SYNC_MESSAGE_LENGTH)
              {
                emcy_send_emergency_message(c_rx_tx,
                    ERR_TYPE_COMMUNICATION_ERROR,
                    SYNC_DATA_LENGTH_ERROR,
                    error_index_pointer,
                    canopen_state);
              }
              else
              {
                sync_window_timer:>sync_time_start;
                pdo_number = 0;
                while(pdo_number != CANOPEN_NUMBER_OF_RPDOS_SUPPORTED)
                {
                  unsigned rtr_check;
                  rtr_check = pdo_find_cob_id(sync_timer[pdo_number].comm_parameter);
                  if(rtr_check != -1)
                  {
                    rtr_check = ((rtr_check >> 30) &0x3);
                    sync_pdo_data_transmit(pdo_number, rtr_check, sync_window_timer,
                        sync_time_start, sync_time_current,
                        sync_window_length, time_difference_sync,
                        sync_timer, tpdo_inhibit_time_values,
                        c_rx_tx);
                    pdo_number++;
                  }
                }//tpdos

                pdo_number = 0;
                while(pdo_number != CANOPEN_NUMBER_OF_TPDOS_SUPPORTED)
                {
                  sync_pdo_data_receive(pdo_number,
                      sync_messages_rx,
                      sync_window_timer,
                      sync_time_current,
                      sync_time_start,
                      sync_window_length,
                      c_application);
                  pdo_number++;
                }//rpdos
              }
            }
            break;

            case NG_HEARTBEAT:
            if(( canopen_state == PRE_OPERATIONAL) ||
                ( canopen_state == OPERATIONAL) ||
                ( canopen_state == STOPPED))
            {
              if(!heart_beat_active)
              {
                node_guard_timer:>ng_time;
                if(frame.dlc != HEARTBEAT_MESSAGE_LENGTH)
                {
                  emcy_send_emergency_message(c_rx_tx,
                      ERR_TYPE_COMMUNICATION_ERROR,
                      PROTOCOL_ERROR_GENERIC,
                      error_index_pointer, canopen_state);
                }
                else
                {
                  if(frame.remote == TRUE)
                  nmt_send_nodeguard_message(c_rx_tx, frame, hb_toggle, canopen_state);
                }
              }
            }
            break;

            case RSDO_MESSAGE:
            if((canopen_state == PRE_OPERATIONAL) || (canopen_state == OPERATIONAL))
            {
              if(frame.dlc != SDO_MESSAGE_LENGTH)
              {
                emcy_send_emergency_message(c_rx_tx,
                    ERR_TYPE_COMMUNICATION_ERROR,
                    PROTOCOL_ERROR_GENERIC,
                    error_index_pointer,
                    canopen_state);
              }
              else
              {
                sdo_message_type = frame.data[0];
                switch(sdo_message_type)
                {
                  case EXPEDITED_DWNLD_RQST_4BYTES: //expedited download
                  case EXPEDITED_DWNLD_RQST_3BYTES:
                  case EXPEDITED_DWNLD_RQST_2BYTES:
                  case EXPEDITED_DWNLD_RQST_1BYTE:
                  od_index = (frame.data[1]) | (frame.data[2]<<8);
                  od_sub_index = frame.data[3];
                  index = od_find_index(od_index);
                  if(index == -1)
                  {
                    emcy_send_emergency_message(c_rx_tx,
                        ERR_TYPE_COMMUNICATION_ERROR,
                        SDO_NO_OBJECT_IN_OD,
                        error_index_pointer,
                        canopen_state);
                  }
                  else
                  {
                    no_of_bytes = 4 - ((frame.data[0] >> 2) & 0x03); //number of bytes that do not have data in the can frame
                    data_length = od_find_data_length(index, od_sub_index);
                    data_buffer[0] = frame.data[4];
                    data_buffer[1] = frame.data[5];
                    data_buffer[2] = frame.data[6];
                    data_buffer[3] = frame.data[7];
                    if(no_of_bytes == data_length)
                    {
                      if(od_find_access_of_index(index, od_sub_index) == RO) //READ ONLY

                      {
                        emcy_send_emergency_message(c_rx_tx,
                            ERR_TYPE_COMMUNICATION_ERROR,
                            SDO_ATTEMPR_TO_WRITE_RO_OD,
                            error_index_pointer,
                            canopen_state);
                      }
                      else if(od_find_access_of_index(index, od_sub_index) == CONST) //CONSTANT Data type

                      {
                        emcy_send_emergency_message(c_rx_tx,
                            ERR_TYPE_COMMUNICATION_ERROR,
                            SDO_UNSUPPORTED_ACCESS_OD,
                            error_index_pointer,
                            canopen_state);
                      }
                      else
                      {
                        od_write_data(index, od_sub_index, data_buffer,data_length);
                        sdo_send_download_response(od_index, od_sub_index,c_rx_tx);
                      }
                    }
                    else
                    {
                      emcy_send_emergency_message(c_rx_tx,
                          ERR_TYPE_COMMUNICATION_ERROR,
                          SDO_DATA_TYPE_DOES_NOT_MATCH,
                          error_index_pointer,
                          canopen_state);
                    }
                  }
                  break;

                  case NON_EXPEDITED_DWNLD_REQUEST: //non expedited download
                  case NON_EXPEDITED_DWNLD_SEGMENTED_REQUEST:
                  od_index = (frame.data[1]) | (frame.data[2]<<8);
                  od_sub_index = frame.data[3];
                  index = od_find_index(od_index);
                  if(index == -1)
                  {
                    emcy_send_emergency_message(c_rx_tx,
                        ERR_TYPE_COMMUNICATION_ERROR,
                        SDO_NO_OBJECT_IN_OD,
                        error_index_pointer,
                        canopen_state);
                  }
                  else
                  {
                    sdo_send_download_response(od_index, od_sub_index,c_rx_tx);
                    segmented_rx_last_frame = FALSE;
                    sdo_toggle=0;
                    count=0;
                    while(segmented_rx_last_frame == FALSE) //check if this is last segment or not
                    {
                      timer_communication_timeout:> comm_timeout_time;
                      select
                      {
                        case can_rx_frame(c_rx_tx,frame):
                        if(((frame.data[0]>>4)&0x01) == sdo_toggle) //check for sdo toggle bit

                        {
                          if((frame.data[0]&0x01) == 1) //check if last segment or not

                          {
                            char od_data_length=0;
                            char temp_counter=0;
                            segmented_rx_last_frame = TRUE;
                            no_of_bytes = 7 - ((frame.data[0] >> 1) & 0x07); //find how many bytes have valid data in the frame
                            while(temp_counter != no_of_bytes)
                            {
                              data_buffer[count+temp_counter] = frame.data[temp_counter];
                              temp_counter++;
                            }
                            od_data_length = od_find_data_length(index,od_sub_index);
                            if(od_data_length == (count + temp_counter))
                            {
                              if(od_find_access_of_index(index, od_sub_index) == RO) //Check if Object is Read only
                              {
                                emcy_send_emergency_message(c_rx_tx,
                                    ERR_TYPE_COMMUNICATION_ERROR,
                                    SDO_ATTEMPR_TO_WRITE_RO_OD,
                                    error_index_pointer,
                                    canopen_state);
                              }
                              else if(od_find_access_of_index(index, od_sub_index) == CONST) //Check if Object is CONSTANT
                              {
                                emcy_send_emergency_message(c_rx_tx,
                                    ERR_TYPE_COMMUNICATION_ERROR,
                                    SDO_UNSUPPORTED_ACCESS_OD,
                                    error_index_pointer,
                                    canopen_state);
                              }
                              else
                              {
                                od_write_data(index, od_sub_index, data_buffer,data_length); //write data to object Dictionary
                              }
                            }
                            else
                            {
                              emcy_send_emergency_message(c_rx_tx,
                                  ERR_TYPE_COMMUNICATION_ERROR,
                                  SDO_VALUE_RANGE_PARAMETER_EXCEEDED,
                                  error_index_pointer,
                                  canopen_state);
                            }
                          }
                          else
                          {
                            data_buffer[0+count] = frame.data[1];
                            data_buffer[1+count] = frame.data[2];
                            data_buffer[2+count] = frame.data[3];
                            data_buffer[3+count] = frame.data[4];
                            data_buffer[4+count] = frame.data[5];
                            data_buffer[5+count] = frame.data[6];
                            data_buffer[6+count] = frame.data[7];
                            count+= 7;
                          }
                          sdo_download_segment_response(c_rx_tx, sdo_toggle);
                          sdo_toggle=!sdo_toggle;
                        }
                        else
                        {
                          emcy_send_emergency_message(c_rx_tx,
                              ERR_TYPE_COMMUNICATION_ERROR,
                              SDO_TOGGLE_BIT_NOT_ALTERED,
                              error_index_pointer,
                              canopen_state);
                          segmented_rx_last_frame = TRUE;
                        }
                        timer_communication_timeout:> comm_timeout_time;
                        break;

                        case timer_communication_timeout when timerafter(comm_timeout_time+ sdo_timeout_time_value):> void:
                        timer_communication_timeout:> comm_timeout_time;
                        emcy_send_emergency_message(c_rx_tx,
                            ERR_TYPE_COMMUNICATION_ERROR,
                            SDO_PROTOCOL_TIME_OUT,
                            error_index_pointer,
                            canopen_state);
                        break;
                      }//select
                    }
                  }
                  break;

                  case INITIATE_SDO_UPLOAD_REQUEST: //initiate sdo upload
                  {
                    char counter=0, number_of_segments;
                    sdo_toggle=0;
                    od_index = (frame.data[1]) | (frame.data[2]<<8);
                    od_sub_index = frame.data[3];
                    index = od_find_index(od_index);
                    if(index != -1)
                    {
                      data_length = od_find_data_length(index, od_sub_index);
                      if(data_length <= 4) //check if data to be uploaded les than 4 bytes
                      {
                        if(od_find_access_of_index(index, od_sub_index) == WO) //check OD access type
                        {
                          emcy_send_emergency_message(c_rx_tx,
                              ERR_TYPE_COMMUNICATION_ERROR,
                              SDO_ATTEMPT_TO_READ_WO_OD,
                              error_index_pointer, canopen_state);
                        }
                        else if(od_find_access_of_index(index, od_sub_index) == CONST) //check id OD access type is CONSTANT or not
                        {
                          emcy_send_emergency_message(c_rx_tx,
                              ERR_TYPE_COMMUNICATION_ERROR,
                              SDO_UNSUPPORTED_ACCESS_OD,
                              error_index_pointer, canopen_state);
                        }
                        else
                        {
                          od_read_data(index, od_sub_index, data_buffer,data_length);
                          sdo_upload_expedited_data(c_rx_tx, od_index, od_sub_index,data_length, data_buffer); //if data is less than 4 bytes do expedited transfer
                        }
                      }
                      if(data_length > 4) //if data is more than 4 bytes do segmented transfer
                      {
                        if(od_find_access_of_index(index, od_sub_index) == WO) //check access type
                        {
                          emcy_send_emergency_message(c_rx_tx,
                              ERR_TYPE_COMMUNICATION_ERROR,
                              SDO_ATTEMPT_TO_READ_WO_OD,
                              error_index_pointer, canopen_state);
                        }
                        else
                        {
                          od_read_data(index, od_sub_index, data_buffer,data_length);
                          sdo_initiate_upload_response(c_rx_tx, od_index, od_sub_index, data_length);
                          if(data_length % 7 == 0)
                            number_of_segments = (data_length/7); //no. of segments = data length/7 as we can tx only 7 bytes of data in segmented tx.
                          else
                            number_of_segments = (data_length/7) + 1;
                          while(counter != number_of_segments)
                          {
                            timer_communication_timeout:> comm_timeout_time;
                            select
                            {
                              case can_rx_frame(c_rx_tx,frame):
                              if(((frame.data[0]>>4)&0x01) == sdo_toggle) //check sdo toggle bit is correct or not

                              {
                                sdo_upload_segmented_data(c_rx_tx,od_index,od_sub_index,sdo_toggle,data_length,data_buffer,counter);
                                sdo_toggle=!sdo_toggle;
                                counter++;
                              }
                              else
                              {
                                emcy_send_emergency_message(c_rx_tx, ERR_TYPE_COMMUNICATION_ERROR, SDO_TOGGLE_BIT_NOT_ALTERED, error_index_pointer, canopen_state);
                              }
                              timer_communication_timeout:> comm_timeout_time;
                              break;

                              case timer_communication_timeout when timerafter(comm_timeout_time+ sdo_timeout_time_value):> void:
                              timer_communication_timeout:>comm_timeout_time;
                              emcy_send_emergency_message(c_rx_tx, ERR_TYPE_COMMUNICATION_ERROR, SDO_PROTOCOL_TIME_OUT, error_index_pointer, canopen_state);
                              counter = number_of_segments;
                              break;
                            }//select
                          }//while
                        }
                      }
                    }
                    break;
                  }
                  default:
                  emcy_send_emergency_message(c_rx_tx, ERR_TYPE_COMMUNICATION_ERROR, SDO_COMMAND_SPECIFIER_NOT_VALID, error_index_pointer, canopen_state);
                  break;
                }
                break;
              }
            }
            break;

            default:
            emcy_send_emergency_message(c_rx_tx, ERR_TYPE_COMMUNICATION_ERROR, PROTOCOL_ERROR_GENERIC, error_index_pointer, canopen_state);
            break;
          }
        }
        break;
      }

      case timer_pdo_event when timerafter(timer_pdo_event_time+10000):> void: //100 usec timer event
      {
        char pdo_number=0;
        timer_pdo_event:> timer_pdo_event_time;
        while(pdo_number != CANOPEN_NUMBER_OF_TPDOS_SUPPORTED)
        {
          if(tpdo_inhibit_time_values[pdo_number].inhibit_time != 0)
          tpdo_inhibit_time_values[pdo_number].inhibit_counter+=100;
          pdo_number++;
        }
        if(canopen_state == OPERATIONAL)
          timer_interrupt_counter++;
        if(timer_interrupt_counter == 10) //check if time is 1 msec
        {
          unsigned event_type;
          pdo_number = 0;
          timer_interrupt_counter=0;
          while(pdo_number != CANOPEN_NUMBER_OF_TPDOS_SUPPORTED)
          {
            if(pdo_event[pdo_number].event_type != 0)
            {
              pdo_event[pdo_number].counter++;
              if(pdo_event[pdo_number].counter == pdo_event[pdo_number].event_type)
              {
                if(tpdo_inhibit_time_values[pdo_number].inhibit_time ==
                    tpdo_inhibit_time_values[pdo_number].inhibit_counter)
                {
                  pdo_transmit_data(TPDO_0_COMMUNICATION_PARAMETER + pdo_number,
                      TPDO_0_MAPPING_PARAMETER + pdo_number,
                      c_rx_tx);
                  pdo_event[pdo_number].counter = 0;
                  tpdo_inhibit_time_values[pdo_number].inhibit_counter = 0;
                }
              }
            }
            pdo_number++;
          }
        }
      }
      break;

      case heart_beat_active => heart_beat_timer when timerafter(hb_time+producer_heart_beat * 100):> void:
      heart_beat_timer:> hb_time;
      if(( canopen_state == PRE_OPERATIONAL) ||
          ( canopen_state == OPERATIONAL) ||
          ( canopen_state == STOPPED))
      {
        nmt_send_heartbeat_message(c_rx_tx, frame, canopen_state);
      }
      break;

      case !heart_beat_active => node_guard_timer when timerafter(ng_time + guard_time *100 * life_time):> ng_time:
      if(( canopen_state == PRE_OPERATIONAL) ||
          ( canopen_state == OPERATIONAL) ||
          ( canopen_state == STOPPED))
      {
        emcy_send_emergency_message(c_rx_tx,
            ERR_TYPE_COMMUNICATION_ERROR,
            LIFE_GUARD_HEARTBEAT_ERROR,
            error_index_pointer, canopen_state);
      }
      break;

      case c_application:> app_tpdo_number: //receives data from the application
      if(canopen_state == OPERATIONAL)
      {
        c_application:> app_length;
        app_counter=0;
        while(app_counter != app_length)
        {
          c_application:> app_data[app_counter];
          app_counter++;
        }
        pdo_receive_application_data(app_tpdo_number,
            app_length,
            app_data,
            tpdo_inhibit_time_values,
            c_rx_tx);
        sync_timer[app_tpdo_number].tx_data_ready = TRUE;
      }
      break;
    } //Select
  }//While
}

/*---------------------------------------------------------------------------
 Receive PDO messages and transmit based on the transmit type and inhibit time
 ---------------------------------------------------------------------------*/
static void receive_rpdo_message(unsigned char canopen_state,
                                 char pdo_number,
                                 can_frame frame,
                                 NULLABLE_ARRAY_OF(rx_sync_mesages, sync_messages_rx),
                                 NULLABLE_ARRAY_OF(tx_sync_timer, sync_timer),
                                 REFERENCE_PARAM(char, error_index_pointer),
                                 chanend c_rx_tx,
                                 streaming chanend c_application)
{
  if (canopen_state == OPERATIONAL)
  {
    char pdo_rx_length, rpdo_tx_type;
    pdo_rx_length = pdo_write_data_to_od(RPDO_0_MAPPING_PARAMETER + pdo_number,
                                         frame.data);
    if (pdo_rx_length != frame.dlc)
    {
      emcy_send_emergency_message(c_rx_tx,
                                  ERR_TYPE_COMMUNICATION_ERROR,
                                  PROTOCOL_ERROR_GENERIC,
                                  error_index_pointer,
                                  canopen_state);
    }
    else
    {
      rpdo_tx_type = pdo_find_transmission_type(RPDO_0_COMMUNICATION_PARAMETER
          + pdo_number);
      if (rpdo_tx_type != -1)
      {
        if ((rpdo_tx_type == 254) || (rpdo_tx_type == 255)) //check if async message
        {
          pdo_send_data_to_application(RPDO_0_MAPPING_PARAMETER + pdo_number,
                                       frame.data,
                                       frame.dlc,
                                       c_application);
          sync_messages_rx[pdo_number].rx_data_ready = FALSE;
        }
        else
        {
          sync_messages_rx[pdo_number].data_length = pdo_rx_length;
          sync_messages_rx[pdo_number].data[0] = frame.data[0];
          sync_messages_rx[pdo_number].data[1] = frame.data[1];
          sync_messages_rx[pdo_number].data[2] = frame.data[2];
          sync_messages_rx[pdo_number].data[3] = frame.data[3];
          sync_messages_rx[pdo_number].data[4] = frame.data[4];
          sync_messages_rx[pdo_number].data[5] = frame.data[5];
          sync_messages_rx[pdo_number].data[6] = frame.data[6];
          sync_messages_rx[pdo_number].data[7] = frame.data[7];
          sync_messages_rx[pdo_number].sync_value = rpdo_tx_type;
          sync_messages_rx[pdo_number].sync_counter = 0;
          sync_messages_rx[pdo_number].rx_data_ready = TRUE;
        }
      }
    }
  }
}

/*---------------------------------------------------------------------------
 Receive TPDO RTR request and transmit data based on the PDO COBID
 ---------------------------------------------------------------------------*/
static void receive_tpdo_rtr_request(can_frame frame,
                                     char pdo_number,
                                     NULLABLE_ARRAY_OF(tx_sync_timer, sync_timer),
                                     NULLABLE_ARRAY_OF(tpdo_inhibit_time, tpdo_inhibit_time_values),
                                     chanend c_rx_tx)
{
  if (frame.remote == TRUE)
  {
    if (sync_timer[pdo_number].sync_value == 253)
    {
      if (tpdo_inhibit_time_values[pdo_number].inhibit_time
          < tpdo_inhibit_time_values[pdo_number].inhibit_counter)
      {
        pdo_transmit_data(TPDO_0_COMMUNICATION_PARAMETER + pdo_number,
                          TPDO_0_MAPPING_PARAMETER + pdo_number,
                          c_rx_tx);
        tpdo_inhibit_time_values[pdo_number].inhibit_counter = 0;
      }
    }
    else if (sync_timer[pdo_number].sync_value == 252)
    {
      sync_timer[pdo_number].tx_data_ready = TRUE;
    }
  }
}

/*---------------------------------------------------------------------------
 LSS State machine. Receives LSS messages and respons based on LSS command
 ---------------------------------------------------------------------------*/
static void lss_state_machine(can_frame frame,
                              char lss_configuration_mode,
                              chanend c_rx_tx,
                              REFERENCE_PARAM(char, canopen_state),
                              REFERENCE_PARAM(unsigned char, error_index_pointer))
{
  char new_node_id;
  unsigned new_baud_rate;
  unsigned bit_timing_table[CANOPEN_BIT_TIME_TABLE_LENGTH] = {
                                                              BIT_RATE_1000, //bit timing table used by LSS
                                                              BIT_RATE_800,
                                                              BIT_RATE_500,
                                                              BIT_RATE_250,
                                                              BIT_RATE_125,
                                                              BIT_RESERVED,
                                                              BIT_RATE_50,
                                                              BIT_RATE_20,
                                                              BIT_RATE_10};
  switch(frame.data[0])
  {
    case SWITCH_MODE_GLOBAL_COMMAND: //set state to lss configuration. DS 305 Standard
    if(frame.data[1] == 0x01)
      lss_configuration_mode = !lss_configuration_mode;
    break;

    case INQUIRE_NODE_ID: //send lss node id
    if(lss_configuration_mode == TRUE)
      lss_send_node_id(c_rx_tx);
    break;

    case CONFIGURE_NODE_ID: //configure node id
    if(lss_configuration_mode == TRUE)
    {
      new_node_id = frame.data[1];
      lss_configure_node_id_response(c_rx_tx, TRUE);//success
    }
    break;

    case CONFIGURE_BIT_TIMING_PARAMETERS: //confure bit timing parameters
    if((lss_configuration_mode == TRUE) && (frame.data[1] == 0x00))
    {
      if( (frame.data[2] < 8) && (frame.data[2] > 0)) //check if received value is correct index of bit parameter table
      {
        new_baud_rate = bit_timing_table[(int)frame.data[2]]; //get bit time from bit time table
        lss_configure_bit_timing_response(c_rx_tx, TRUE);//success
      }
      else
      {
        lss_configure_bit_timing_response(c_rx_tx, FALSE);//success
      }
    }
    break;

    case STORE_CONFIGURATION_SETTINGS:
    if(lss_configuration_mode == TRUE)
    {
      lss_store_config_settings_response(c_rx_tx, TRUE); //store configuaration settings
    }
    break;

    case INQUIRE_VENDOR_ID:
    lss_inquire_vendor_id_response(c_rx_tx, canopen_state, error_index_pointer); //send vendor id
    break;

    case INQUIRE_PRODUCT_CODE:
    lss_inquire_product_code(c_rx_tx, canopen_state, error_index_pointer); //send product code
    break;

    case INQUIRE_REVISION_NUMBER:
    lss_inquire_revision_number(c_rx_tx, canopen_state, error_index_pointer); //send revision number
    break;

    case INQUIRE_SERIAL_NUMBER:
    lss_inquire_serial_number(c_rx_tx, canopen_state, error_index_pointer); //send serial number
    break;
  }
}


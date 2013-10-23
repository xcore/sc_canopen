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
#include "can.h"
#include "canopen.h"
#include "pdo.h"
#include "od.h"
#include <xccompat.h>

/*---------------------------------------------------------------------------
 Send Heartbeat message on to the CAN network
 ---------------------------------------------------------------------------*/
void nmt_send_heartbeat_message(chanend c_rx_tx,
                            can_frame frame,
                            unsigned char canopen_state)
{
  frame.dlc = 1;
  frame.extended = 0;
  frame.remote = 0;
  if (canopen_state == PRE_OPERATIONAL)
  {
    frame.data[0] = NG_PRE_OPERATIONAL;
  }
  else if (canopen_state == OPERATIONAL)
  {
    frame.data[0] = NG_OPERATIONAL;
  }
  else if (canopen_state == STOPPED)
  {
    frame.data[0] = NG_STOPPED;
  }
  else if (canopen_state == INITIALIZATION)
  {
    frame.data[0] = NG_BOOT_UP;
  }
  else if(canopen_state == RESET_COMMUNICATION)
  {
    frame.dlc = 0;
  }
  if(canopen_state != RESET_NODE)
  {
    frame.id = NG_HEARTBEAT;
    can_send_frame(c_rx_tx, frame);
  }
}


/*---------------------------------------------------------------------------
 Send node guard message on to the CAN network
 ---------------------------------------------------------------------------*/
void nmt_send_nodeguard_message(chanend c_rx_tx,
                            can_frame frame,
                            char toggle,
                            unsigned char state)
{
  if (state == OPERATIONAL)
  {
    frame.data[0] = (toggle << 7) | NG_OPERATIONAL;
  }
  else if (state == PRE_OPERATIONAL)
  {
    frame.data[0] = (toggle << 7) | NG_PRE_OPERATIONAL;
  }
  else if (state == INITIALIZATION)
  {
    frame.data[0] = (toggle << 7) | NG_BOOT_UP;
  }
  else if (state == STOPPED)
  {
    frame.data[0] = (toggle << 7) | NG_STOPPED;
  }
  frame.id = NG_HEARTBEAT;
  frame.dlc = 1;
  can_send_frame(c_rx_tx, frame);
  toggle = !toggle;
}


/*---------------------------------------------------------------------------
 Send bootup message on to the CAN network
 ---------------------------------------------------------------------------*/
void nmt_send_boot_up_message(chanend c_rx_tx)
{
  can_frame frame;
  frame.dlc = 0;
  frame.id = NG_HEARTBEAT;
  frame.remote = 0;
  frame.extended = 0;
  can_send_frame(c_rx_tx, frame);
}


/*---------------------------------------------------------------------------
 Initialze the parametrs based on the data available in the object dictioanary
 ---------------------------------------------------------------------------*/
void nmt_initialize(NULLABLE_ARRAY_OF(tx_sync_timer, sync_timer),
                NULLABLE_ARRAY_OF(pdo_event_timer, pdo_event),
                NULLABLE_ARRAY_OF(tpdo_inhibit_time, tpdo_inhibit_time_values),
                REFERENCE_PARAM(unsigned, sync_window_length),
                REFERENCE_PARAM(unsigned, guard_time),
                REFERENCE_PARAM(unsigned, life_time),
                REFERENCE_PARAM(unsigned, producer_heart_beat),
                REFERENCE_PARAM(char, heart_beat_active ))
{
  int index = od_find_index(SYNC_WINDOW_LENGTH_OBJECT);
  unsigned event_type, inhibit_time;
  char data_buffer[8] = {0, 0, 0, 0, 0, 0, 0, 0}, counter = 0;
  if (index != -1)
    od_read_data(index, 0, data_buffer, 4);
  sync_window_length = ((data_buffer[3] << 8) | (data_buffer[2]));
  sync_window_length = (sync_window_length << 16) | ((data_buffer[1] << 8)
      | (data_buffer[0]));
  index = od_find_index(GUARD_TIME_OBJECT);
  if (index != -1)
    od_read_data(index, 0, data_buffer, 2);
  guard_time = ((data_buffer[1] << 8) | (data_buffer[0]));

  index = od_find_index(LIFE_TIME_FACTOR_OBJECT);
  if (index != -1)
    od_read_data(index, 0, data_buffer, 1);
  life_time = data_buffer[0];
  index = od_find_index(PRODUCER_HEARTBEAT_OBJECT);
  if (index != -1)
    od_read_data(index, 0, data_buffer, 2);
  producer_heart_beat = ((data_buffer[1] << 8) | (data_buffer[0]));
  producer_heart_beat = producer_heart_beat * 1000;
  if ((producer_heart_beat != 0) && (guard_time == 0))
    heart_beat_active = 1;
  else
    heart_beat_active = 0;
  while(counter != CANOPEN_NUMBER_OF_TPDOS_SUPPORTED)
  {
    sync_timer[(int)counter].comm_parameter = TPDO_0_COMMUNICATION_PARAMETER+counter;
    sync_timer[(int)counter].mapping_parameter = TPDO_0_MAPPING_PARAMETER+counter;
    index = od_find_index(sync_timer[(int)counter].comm_parameter);
    if (index != -1)
      od_read_data(index, 2, data_buffer, 1);
    sync_timer[(int)counter].sync_value = data_buffer[0];
    sync_timer[(int)counter].tx_data_ready = FALSE;
    sync_timer[(int)counter].sync_counter = 0;
    event_type = pdo_find_event_type(TPDO_0_COMMUNICATION_PARAMETER + counter);
    pdo_event[(int)counter].event_type = event_type;
    inhibit_time = pdo_find_inhibit_time(TPDO_0_COMMUNICATION_PARAMETER + counter);
    tpdo_inhibit_time_values[(int)counter].inhibit_time = inhibit_time;
    tpdo_inhibit_time_values[(int)counter].inhibit_counter = 0;
    counter++;
  }
}

void nmt_reset_registers()
{
  int index = od_find_index(COB_ID_SYNC);
  char od_sub_index = 0, data_length,data_buffer[8];
  if(index != -1)
  {
    data_buffer[0]=0x80;
    data_buffer[1]=0x00;
    data_buffer[2]=0x00;
    data_buffer[3]=0x80;
    data_length=4;
    od_write_data(index, od_sub_index, data_buffer,data_length);
  }
  index = od_find_index(COMMUNICATION_CYCLE_PERIOD);
  if(index != -1)
  {
    data_buffer[0]=0x00;
    data_buffer[1]=0x00;
    data_buffer[2]=0x00;
    data_buffer[3]=0x00;
    data_length=4;
    od_write_data(index, od_sub_index, data_buffer,data_length);
  }
  index = od_find_index(SYNC_WINDOW_LENGTH_OBJECT);
  if(index != -1)
  {
    data_buffer[0]=0x00;
    data_buffer[1]=0x00;
    data_buffer[2]=0x00;
    data_buffer[3]=0x00;
    data_length=4;
    od_write_data(index, od_sub_index, data_buffer,data_length);
  }
  index = od_find_index(GUARD_TIME_OBJECT);
  if(index != -1)
  {
    data_buffer[0]=0x00;
    data_buffer[1]=0x00;
    data_length=2;
    od_write_data(index, od_sub_index, data_buffer,data_length);
  }
  index = od_find_index(LIFE_TIME_FACTOR_OBJECT);
  if(index != -1)
  {
    data_buffer[0]=0x00;
    data_length=1;
    od_write_data(index, od_sub_index, data_buffer,data_length);
  }
  index = od_find_index(PRODUCER_HEARTBEAT_OBJECT);
  if(index != -1)
  {
    data_buffer[0]=0x00;
    data_buffer[1]=0x00;
    data_buffer[2]=0x00;
    data_buffer[3]=0x00;
    data_length=4;
    od_write_data(index, od_sub_index, data_buffer,data_length);
  }

}

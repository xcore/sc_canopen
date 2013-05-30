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
#include "pdo.h"
#include "od.h"

/*---------------------------------------------------------------------------
 Transmit PDO Data
 ---------------------------------------------------------------------------*/
void pdo_transmit_data(unsigned comm_parameter,
                       unsigned mapping_parameter,
                       chanend c_rx_tx)
{
  char data[8];
  can_frame frame;
  char counter = 0;
  unsigned cob_id;
  char data_length = pdo_read_data_from_od(comm_parameter,
                                           mapping_parameter,
                                           data);
  cob_id = pdo_find_cob_id(comm_parameter);
  if(cob_id != -1)
  {
    frame.id = cob_id;
    frame.extended = 0;
    frame.remote = 0;
    frame.dlc = data_length;
    while(counter != 8)
    {
      if (counter < data_length)
        frame.data[counter] = data[counter];
      else
        frame.data[counter] = 0;
      counter++;
    }
    can_send_frame(c_rx_tx, frame);
  }
}

/*---------------------------------------------------------------------------
 Receive Data from Application
 ---------------------------------------------------------------------------*/
void pdo_receive_application_data(char pdo_number,
                                  char length,
                                  char data[],
                                  NULLABLE_ARRAY_OF(tpdo_inhibit_time, tpdo_inhibit_time_values),
                                  chanend c_rx_tx)
{
  char tx_type;
  unsigned cob_id;
  pdo_write_data_to_od(TPDO_0_MAPPING_PARAMETER + pdo_number, data);
  tx_type = pdo_find_transmission_type(pdo_number
      + TPDO_0_COMMUNICATION_PARAMETER);
  if (tx_type != -1)
  {
    cob_id = pdo_find_cob_id(TPDO_0_MAPPING_PARAMETER + pdo_number);
    if ((cob_id >> 30) & 0x01 == 1) //check if RTR bit is set or not
    {
      if ((tx_type == 254) || (tx_type == 255))
      {
        if (tpdo_inhibit_time_values[pdo_number].inhibit_time
            < tpdo_inhibit_time_values[pdo_number].inhibit_counter)
        {
          pdo_transmit_data(TPDO_0_COMMUNICATION_PARAMETER + pdo_number,
                            TPDO_0_MAPPING_PARAMETER + pdo_number,
                            c_rx_tx);
        }
      }
    }
  }
}

/*---------------------------------------------------------------------------
 Sends PDO Data to the Application
 ---------------------------------------------------------------------------*/
void pdo_send_data_to_application(unsigned mapping_parameter,
                                  char data[],
                                  char data_length,
                                  streaming chanend c_application)
{
  char counter = 0;
  c_application<: (char) (mapping_parameter - RPDO_0_MAPPING_PARAMETER);
  c_application<: (char) data_length;
  while(counter != data_length)
  {
    c_application<: (char) data[counter];
    counter++;
  }
}


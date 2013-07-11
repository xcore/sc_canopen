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
#include <platform.h>
#include <xscope.h>
#include <print.h>

#include "canopen.h"
#include "canopen_client.h"
#include "i2c.h"

/*---------------------------------------------------------------------------
 Defines
 ---------------------------------------------------------------------------*/
#define I2C_NO_REGISTER_ADDRESS 1
#define debounce_time XS1_TIMER_HZ/50
#define BUTTON_PRESS_VALUE 2
#define TEMP_SENSOR_INTERVAL 500000000  //5 Sec Timer

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/
on tile[0]: can_ports p = {XS1_PORT_1L, XS1_PORT_1I, XS1_CLKBLK_1};
on tile[0]: port shutdown = XS1_PORT_4E;
on tile[1]: port p_led = XS1_PORT_4A;
on tile[1]: port p_PORT_BUT_1 = XS1_PORT_4C;
on tile[1]: struct r_i2c i2cOne = {XS1_PORT_1F, XS1_PORT_1B, 1000};

/*---------------------------------------------------------------------------
 Function prototypes
 ---------------------------------------------------------------------------*/
void application(streaming chanend c_application);

/*---------------------------------------------------------------------------
 xscope initialization
 ---------------------------------------------------------------------------*/
void xscope_user_init(void)
{
  xscope_register(0, 0, "", 0, "");
  xscope_config_io(XSCOPE_IO_BASIC);
}

/*---------------------------------------------------------------------------
 implementation
 ---------------------------------------------------------------------------*/

int main()
{
  streaming chan c_application;
  chan c_rx_tx;
  par
  {
    on tile[0]:{
          shutdown <: 0;
          can_server(p, c_rx_tx);
    }
    on tile[0]: canopen_server(c_rx_tx, c_application);
    on tile[1]: application(c_application);
  }
  return 0;
}



/*---------------------------------------------------------------------------
 Application Core
 ---------------------------------------------------------------------------*/
void application(streaming chanend c_application)
{
  unsigned button_press_1, button_press_2, time, time_i2c;
  int button = 1;
  char led0 = 0xF, led1 = 0xF, led2 = 0xF, led3 = 0xF;
  timer t, i2c_timer;
  unsigned char data[1] = {0x13}, pdo_number, pdo_data[2];
  unsigned char data1[2];
  int adc_value;
  p_PORT_BUT_1:> button_press_1;
  set_port_drive_low(p_PORT_BUT_1);
  i2c_master_write_reg(0x28, 0x00, data, 1, i2cOne); //Write configuration information to ADC
  t:>time;
  i2c_timer :> time_i2c;
  while(1)
  {
    select
    {
      case button=> p_PORT_BUT_1 when pinsneq(button_press_1):> button_press_1: //checks if any button is pressed
      button=0;
      t:>time;
      break;

      case !button => t when timerafter(time+debounce_time):>void: //waits for 20ms and checks if the same button is pressed or not
      p_PORT_BUT_1:> button_press_2;
      if(button_press_1==button_press_2)
      if(button_press_1 == BUTTON_PRESS_VALUE) //Button 1 is pressed

      {
        pdo_data[0] = 0xFF;
        canopen_client_send_data_to_stack(c_application, 1, 1, pdo_data);
      }
      if(button_press_1 == BUTTON_PRESS_VALUE-1) //Button 2 is pressed

      {
        pdo_data[0] = 0xFF;
        canopen_client_send_data_to_stack(c_application, 2, 1, pdo_data);
      }
      button=1;
      break;

      case c_application:> pdo_number:
      {
        char temp_data;
        char length,data[1];
        canopen_client_receive_data_from_stack(c_application, length,data);
        if((pdo_number >= 0) && (pdo_number <= 3))
        {
          p_led :> temp_data;
          p_led <:  (unsigned) ((temp_data ^ (1 << pdo_number)));
        }
      }
      break;

      case i2c_timer when timerafter(time_i2c + TEMP_SENSOR_INTERVAL):> time_i2c:
      i2c_master_rx(0x28, data1, 2, i2cOne); //Read ADC value using I2C read
      printstrln("Reading Temperature value....");
      data1[0]=data1[0]&0x0F;
      adc_value=(data1[0]<<6)|(data1[1]>>2);
      pdo_data[0] = ((adc_value & 0xFF00)>>8);
      pdo_data[1] = (adc_value & 0xFF);
      canopen_client_send_data_to_stack(c_application, 0, 2, pdo_data);
      break;
    }
  }
}

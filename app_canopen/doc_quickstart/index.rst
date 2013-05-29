CANopen Quickstart Guide
===========================

.. _Slicekit_CANopen_Quickstart:

CANopen app : Quick Start Guide
----------------------------------

This simple demonstration of xTimeComposer Studio functionality uses the ``XA-SK-ISBUS`` and ``XA-SK-GPIO`` sliceCARDs together with the xSOFTip ``module_canopen`` to demonstrate how the module communicates using device profiles DS301 and DS401:

   * Turn GPIO sliceCARD LEDs ON and OFF.
   * Read ADC vale from the Temperature sensor on the GPIO slcieCARD.
   * Read button press from the GPIO sliceCARD. 


Hardware Setup
++++++++++++++

The XP-SKC-L2 Slicekit Core board has four slots with edge connectors: ``SQUARE``, ``CIRCLE``,``TRIANGLE`` and ``STAR``. 

To setup up the system:

   #. Connect XA-SK-ISBUS Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``TRIANGLE``.
   #. Connect XA-SK-GPIO Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``SQUARE``.
   #. Connect the XTAG Adapter to Slicekit Core board, and connect XTAG-2 to the Adapter. 
   #. Connect the XTAG-2 to host PC. Note that the USB cable is not provided with the Slicekit starter kit.
   #. Set the ``XMOS LINK`` to ``ON`` on the XTAG Adapter.
   #. Switch on the power supply to the Slicekit Core board.
   #. Connect the XA-SK-ISBUS to the CANdo USB interface (or any CANbus master) via a DE-9 pass through cable.
   #. Set the jumpers on the ISBUS slice for CAN mode; P7 short between pins 1 and 2(leaving 3 unconnected), P6 short between 2 and 11, 3 and 12, 7 and 16. See hardware setup image for clarification.
   #. Install the CANdo application on a Windows machine (or any CAN bus master) and connect the CANdo dongle to that machine.
   #. Connect the CANdo analyzer cable (usb cable) to the host machine.
	 #. Within the CANdo application:
         #. Click the ``CAN Setup`` tab and set the baud rate to 500k.
         #. Click ``View -> Options`` then ensure the ``Display On `CAN View` Page`` is checked. Then click ``OK``.
         #. Switch to the ``CAN View`` tab.
         #. Click the green run button.


.. figure:: images/hardware_setup.png
   :align: center

   Hardware Setup for CANopen Demo
   
	
Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTimeComposer and open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``'Slicekit CANopen'`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTimeComposer. This will also cause the modules on which this application depends (in this case, module_canopen) to be imported as well. 
   #. Click on the app_canopen item in the Explorer pane then click on the build icon (hammer) in xTimeComposer. Check the console window to verify that the application has built successfully.

For help in using xTimeComposer, try the xTimeComposer tutorials, which you can find by selecting Help->Tutorials from the xTimeComposer menu.

Note that the Developer Column in the xTimeComposer on the right hand side of your screen provides information on the xSOFTip components you are using. Select the ``CANopen`` component in the xSOFTip Browser, and you will see its description together with links to more documentation for this component. Once you have briefly explored this component, you can return to this quickstart guide by re-selecting  ``'Slicekit CANOpen Demo'`` in the xSOFTip Browser and clicking once more on the Quickstart  link for the ``CANopen Demo Quickstart``.
    
EDS settings Used in the Demo(Example Settings):
++++++++++++++++++++++++++++++++++++++++++++++++
   
   #. Heartbeat set to one second. Transmits current state on the CAN network every second.
   #. TPDO0 set to data asynchronously and transmits the Temperature sensor reading on GPIO Board (mapped to 0x6100 sub index 01).
   #. TPDO1 set to acyclic transmission. Whenever Button 1is pressed on GPIO Board, and transmits is done is done after a sync message (mapped to 0x6400 sub index 01).
   #. TPDO2 set for cyclic transmission. The button 2 value is sent after every 5 SYNC messages (mapped to 0x6100 sub index 01).
   #. RPDO0 controls LED0 on GPIO board (mapped to 0x6400 sub-index 01). The LED toggles on reception of this PDO message.
   #. RPDO1 controls LED1 on GPIO board (mapped to 0x6400 sub-index 02). The LED toggles on reception of this RPDO message.
   #. RPDO2 controls LED2 on GPIO board (mapped to 0x6400 sub-index 03). After receiving this, the LED2 will toggle only after 10 SYNC messages are received.
   #. RPDO3 controls LED3 on GPIO board (mapped to 0x6400 sub-index 04). After receiving this PDO message, the LED will toggle only after SYNC message is received. 

   
Run the Application
+++++++++++++++++++
  Import module_can, module_i2c_master, module_mutual_thread_comm and module_canopen to the workspace. Build the application by clicking on the app_canopen folder in the project explorer.

Now that the application has been compiled, the next step is to run it on the Slicekit Core Board using the tools to load the application over JTAG (via the XTAG2 and Xtag Adaptor card) into the xCORE multicore microcontroller.

   #. Right click on the application binary and select run configurations window 
      Select ``xscope`` tab 
      Select ``offline scope`` option and then click on run button. 
      This console will now display ‘Reading Temperature..’ every five seconds.

BOOTUP MESSAGE
..............

Open the CANdoISO application and see the boot up message is displayed with node id as 0.
      Received CAN Message : ``[ID = 0]``.
      
   .. figure:: images/bootup.png
      :align: center
   
   Bootup Message received from CANopen node
   
HEARTBEAT MESSSAGE
..................

You can observe the periodic Heartbeat messages on the analyzer ``[ID = 700, D1=7F (Pre operational state)]``.  

      
      .. figure:: images/heartbeat.png
         :align: center
      
   Heartbeat Message received from CANopen node

OPERATING MODE CHANGE 
.....................

Send the following NMT message to change the state to Operational. Change the State to Operational bys ending the following message
``[ID = 0, DLC = 2, D1 = 1, D2 = 0]``

   .. figure:: images/operating_mode_change.png
      :align: center
      
   Operating mode change Message on CANopen node
   
After sending this message, the heartbeat message will show the new state ``[ID = 700, D1 = 5 (operational)]``. 
The following screen shot shows the heartbeat messages after sending NMT message to change state:

   .. figure:: images/operation_mode.png
      :align: center
      
   Heartbeat message showing Operation mode 

The following NMT messages can be used to move to other states
   #. Message to set to Stopped state:
      ``[ID = 0, DLC = 2, D1 = 3, D2 = 0]``
       After sending this message to the node the node stops sending the heart beat messages.
   #. Message to set to Pre operational state:
      ``[ID = 0, DLC = 2, D1 = 80, D2 = 0]``
      The heart beat messages received will shows the new changed state (pre-operational).

LSS (Layer Service Settings) MESSAGES
......................................

After changing to the device to Operating mode,

   #. LSS Read Vendor ID:
   
      Send the following LSS message to read Vendor ID from the object dictionary. 
      ``[ID = 7E5, DLC = 8, D1 = 5A, D2-D8 = 0]``.
      
         .. figure:: images/lss_read_vendorid_cmd.png
            :align: center
       
   LSS Read Vendor id message 
   
   The response to this message will be 
   ``[ID = 7E4, D1 = 5A, D2 = 34, D3 = 12]``
   The vendor id read is ``0x1234`` (Index = 0x1018, sub-index = 1 of object dictionary) as defined in the EDS file.
   
        .. figure:: images/lss_vendorid_response.png
           :align: center
       
   VendorID response message
 
    #. LSS Read Product code:
 
       Send the following LSS message from the application, to see the Product Code.
       ``[ID = 7E5, DLC = 8, D1 = 5B, D2-D8 = 0]``
       
          .. figure:: images/lss_read_productcode_cmd.png
             :align: center
        
    LSS Read Product code message 
 
 The response to this message will be
 ``[ID = 7E4, D1 = 5B, D2 = CD, D3 = AB]`` 
 The product code read is ``0xABCB`` (Index = 0x1018, sub-index = 2 of object dictionary) as defined in the EDS file.
   
         .. figure:: images/lss_productcode_response.png
            :align: center
       
   Product code response message
   
   #. LSS Read Revision number:
      
      Send the following LSS message from the application, to see the Revision Number Code.
      ``[ID = 7E5, DLC = 8, D1 = 5C, D2-D8 = 0]``
      
         .. figure:: images/lss_read_revnumber_cmd.png
            :align: center
         
    LSS Read Revision number message 
    
    The response to this message will be
    ``[ID = 7E4, D1 = 5C, D2 = BB, D3 =AA]``
    The revision number read is ``0xAABB`` (Index = 0x1018, sub0index = 3 of object dictionary) as defined in the EDS file.

        .. figure:: images/lss_revnumber_response.png
           :align: center
       
   Revision number response message

   #. LSS Read Serial number:
   
      Send the following LSS message from the application, to see the Serial Number.
      ``[ID = 7E5, DLC = 8, D1 = 5D, D2-D8 = 0]``
      
         .. figure:: images/lss_read_sernumber_cmd.png
            :align: center
         
    LSS Read Serial number message 
    
    The response to this message will be
    ``[ID = 7E4, D1 = 5D, D2 = 11, D3 = 11]``
    The product code read is ``0x1111`` (Index = 0x1018, sub-index = 4 of object dictionary) as defined in the EDS file.
  
         .. figure:: images/lss_read_sernumber_response.png
            :align: center
         
    Serial number response message 

TPDO Data (transmit Process data objects)
.........................................

   #. TPDO0 Temperature sensor:
      
      The application dens the Temperature sensor data to CANopen stack every 5 seconds for transmission. The communication parameter for this TPDO is 255 which indicate Async transfer. The CANopen stack sends this TPDO outside the SYNC timer window.
      The following screenshot shows the message (ID = 180) with temperature ADC reading in [D1 and D2]. Place your finger on the temperature sensor (marked as RT1 on GPIO sliceCARD) and check if the value is being changed. This gives the current changed ADC value of temperature sensor.

         .. figure:: images/tpdo0_response.png
            :align: center
         
    Temperature Sensor reading

   #. TPDO1 Button 1:
      Whenever "Button 1" is pressed, the application sends a value of 0xFF to CANOpen stack for transmission. The transmission parameter for this TPDO is 0 which indicates acyclic synchronous transfer. So, the data is transmitted on reception of next SYNC message.
      To observer this message, press Button 1 on GPIO card and then send the following SYNC message.
      ``[ID = 80, DLC = 0]``
      
         .. figure:: images/sync_message.png
            :align: center
         
    SYNC message
    
    The response to this message will be
    ``[ID = 280, D1 = 0xFF]``
    
         .. figure:: images/tpdo1_message.png
            :align: center
         
    Button1 value

   #. TPDO2 Button 2:
      The application sends status (0x00 or 0xFF) of "Button 2" to CANopen stack for transmission. The transmission parameter for this TPDO is 5 which indicate cyclic synchronous transfer. So the data is transmitted after every 5 SYNC messages.

      To get the "Button 2" status, send the following SYNC messages 5 times.
      ``[ID = 80, DLC = 0]``

         .. figure:: images/sync_message.png
            :align: center
         
    SYNC message
    
 After sending 5 SYNC messages, the following message is received
 ``[ID = 380, D1 =0]`` indicting the status of "Button 2". 
 
 
        .. figure:: images/button2_initial.png
           :align: center
          
    Button 2 reading
    
 Now Press the "Button 2" on the GPIO board and send 5 SYNC messages. The following message is received indicating the changed status of "Button 2"
 ``[ID = 380, D1 = 0xFF]``
 
 
       .. figure:: images/button2_pressed.png
          :align: center
          
    Button 2 reading after button is pressed

RPDO (receive Process Data Objects):
...................................

   #. RPDO0 LED0:
      Send the following message RPDO to toggle LED0
      ``[ID = 200, DLC = 1, D1 = 01]``
      
      .. figure:: images/rpdo0_message.png
         :align: center
          
    LED0 toggles with the RPDO message
    
 You can see the LED0 toggles with this message.
 
    #. RPDO 1 LED1:
       Send the following message (RPDO1) to toggle LED 1
       ``[ID = 300, DLC = 1, D1 = 01]``

   #. RPDO 2 LED 2:
      The communication parameter is set as 10. After reception of this RPDO, the CANopen stack waits for 10 SYNC messages before updating the object dictionary. So the LED2 will toggle only after 10 SYNC messages.
      ``[ID = 400, DLC = 1, D1 = 01]``
      
         .. figure:: images/rpdo2_message.png
            :align: center
          
    RPDO2 message
    
LED2 state does not change after this message. Send the following message (SYNC) 10 times to toggle LED2.
``[ID = 80, DLC = 0]``

         .. figure:: images/sync_message.png
            :align: center
         
    SYNC message

   #. RPDO 3 LED 3:
      The communication parameter is set to 0. Which indicates the PDO communication is acyclic and synchronous. Send the following message (RPDO3) message
      ``[ID = 500, DLC = 1, D1 = 01]``

         .. figure:: images/rpdo3_message.png
            :align: center
          
    RPDO3 message

NO change in the state of LED3 is observed
Send the following message (SYNC) to toggle LED3
``[ID = 80, DLC = 0]``

         .. figure:: images/sync_message.png
            :align: center
         
    SYNC message

SDO Data communication (service data objects)
.............................................

   #. SDO expedited upload: 
      Send the following data to read the data at 0x1000 sub index 0. 
      ``[ID = 600, DLC = 8, D1 = 40, D2 = 00, D3 = 10, D4 = 00, D5-D8 = 0]``
 
         .. figure:: images/sdo_1000_exp_upload_rqst.png
            :align: center
         
    SDO Upload Request for index 0x1000
    
    The data read is ``0x070191`` (Index = 0x1000, sub-index = 0 of object dictionary) as EDS file.
    
         .. figure:: images/sdo_1000_exp_response.png
            :align: center
         
    SDO Upload Response for index 0x1000

   #. SDO expedited download 
      Send the following data to read the data at 0x1000 sub index 0.
      ``[ID = 600, DLC = 8, D1 = 23, D2 = 00, D3 = 10, D4 = 00, D5 =01, D6 = 02, D7 = 03, D8 = 04]``
      
    
         .. figure:: images/sdo_1000_exp_download.png
            :align: center
         
    SDO Download Request for index 0x1000

The response to this message will be 
``[ID = 80, DLC = 8, D1 = 0, D2 = 2, D3-D8 = 0]``

This is an Error message as a write attempt to RO data (index = 0x1000, sub-index = 0) as defined in the EDS file.

   
        .. figure:: images/sdo_1000_exp_dwnld_response.png
           :align: center
         
   SDO Download Response for index 0x1000

   #. Read SDO Expedited data: 
      Send the following data to read data at 0x1006 sub index 0.
      ``[ID = 600, DLC = 8, D1 = 40, D2 = 06, D3 = 10, D4 = 00, D5 =00, D6 = 00, D7 = 00, D8 = 00]`` as shown below:
      
         .. figure:: images/sdo_1006_expd_upload_rqst.png
            :align: center
          
    SDO Upload Request for index 0x1006
    
 The response to this message will be
 ``[ID = 580, D1 = 43, D2 = 63, D3 = 10, D4 = 30]``
 The data read is ``0x03`` (index = 0x1006, sub-index = 0) as defined in the EDS file.
 
         .. figure:: images/sdo_1006_expd_response_initial.png
            :align: center
           
    SDO Upload Response for index 0x1006
 
 Send the following message to write the data at 0x1006 sub index 0.
``[ID = 600, DLC = 8, D1 = 23, D2 = 06, D3 = 10, D4 = 00, D5 =01, D6 = 02, D7 = 03, D8 = 04]``

         .. figure:: images/sdo_1006_expd_dwnld_request.png
            :align: center
           
    SDO Download Request for index 0x1006

    The response to this message will be 
    ``[ID = 580, D1 = 60, D2 = 60, D3 = 10]``
    This is ACK message.

         .. figure:: images/sdo_1006_expd_dwnld_request_ack.png
            :align: center
           
    SDO Download Request ACK for index 0x1006

Send the following data to read the data written by the previous command. 
[ID = 600, DLC = 8, D1 = 40, D2 = 06, D3 = 10, D4 = 00, D5 =00, D6 = 00, D7 = 00, D8 = 00]

         .. figure:: images/sdo_1006_expd_upload_request_.png
            :align: center
           
    SDO Upload Request for index 0x1006

The response to this message will be
``[ID = 580, D1 = 43, D2 = 6, D3 = 10, D4 = 0, D5 = 1, D6 = 2, D7 = 3, D8 = 4]``

         .. figure:: images/sdo_1006_expd_upload_response.png
            :align: center
           
    SDO Upload Response for index 0x1006


   #. SDO Read expedited data 0x1009 Write only index:
      Send the following message to read from index 0x1009 sub-index = 0 
      ``[ID = 600, DLC = 8, D1 = 40, D2 = 09, D3 = 10, D4 = 00, D5 =00, D6 = 00, D7 = 00, D8 = 00]``
            
         .. figure:: images/sdo_1009_expd_upload_request.png
            :align: center
           
    SDO Upload Request for index 0x1009
    
The response to this message will be
``[ID = 80, DLC = 8, D1 = 0, D2 = 0, D3 = 10, D4-D8 = 0]``
This is an Error message as a read is attempted from WO index (index = 0x1009, sub-index = 0) as defined in the EDS file.

         .. figure:: images/sdo_1009_expd_upload_response.png
            :align: center
           
    SDO Upload Response for index 0x1009

   #. SDO Segmented upload 0x1008 index:
      Send the following data to read the data at 0x1008 sub index 0.
      ``[ID = 600, DLC = 8, D1 = 40, D2 = 08, D3 = 10, D4 = 00, D5 =00, D6 = 00, D7 = 00, D8 = 00]`` as shown below:
 
         .. figure:: images/sdo_1008_seg_upload_request.png
            :align: center
            
     SDO Upload Request for index 0x1008
    
     After sending the data, we receive the message acknowledgement with command 41 indicating the data is more than 4 bytes and segmented transfer is initiated. The message is as shown below:

        .. figure:: images/sdo_1008_seg_response_initial.png
           :align: center
            
     SDO Upload Response for index 0x1008
      

    Now, to read the first segment of data, we send the request as shown below: 
    ``[ID = 600, DLC = 8, D1 = 60, D2 = 00, D3 = 00, D4 = 00, D5 =00, D6 = 00, D7 = 00, D8 = 00]`` as shown below:
   
       .. figure:: images/sdo_1008_seg_1seg_upload_req.png
          :align: center
            
     SDO Upload First segment Upload Request for index 0x1008

   After sending the data, we receive the first segment of data. The message is as shown below:
   
      .. figure:: images/sdo_1008_seg_upload_1seg_response.png
         :align: center
            
     SDO Upload First segment Upload Response for index 0x1008
   
   Now, to read the second segment of data, we send the request as shown below: 
   ``[ID = 600, DLC = 8, D1 = 70, D2 = 00, D3 = 00, D4 = 00, D5 =00, D6 = 00, D7 = 00, D8 = 00]`` as shown below:
   
      .. figure:: images/sdo_1008_seg_2seg_upload_req.png
         :align: center
            
     SDO Second segment Upload Request for index 0x1008
     
    After sending the data, we receive the second segment of data. The message is as shown below:
   
      .. figure:: images/sdo_1008_seg_2seg_upload_response.png
         :align: center
            
     SDO Second segment Upload Response for index 0x1008

    Now, to read the third segment of data, we send the request as shown below: 
    ``[ID = 600, DLC = 8, D1 = 60, D2 = 00, D3 = 00, D4 = 00, D5 =00, D6 = 00, D7 = 00, D8 = 00]`` as shown below:
    
      .. figure:: images/sdo_1008_seg_3seg_upload_req.png
         :align: center
            
     SDO Third segment Upload Request for index 0x1008

    After sending the data, we receive the third segment of data. The message is as shown below:

      .. figure:: images/sdo_1008_seg_3seg_upload_rsponse.png
         :align: center
            
     SDO Third segment Upload Response for index 0x1008

Next Steps
++++++++++

   #. You can change the parameter of the EDS file and generate an object_dictionary.h file and include it in your application to change the settings and objects of the CANOpen device.
      The name of the EDS file should be ``CO_EDS_401.eds`` to generate an ``object_dictionary.h`` file from a python script.
      The object dictionary generator (python script) is available in the object_dictionary_generator folder of the repository.

Look at the Code
................

   #. Examine the application code. In xTIMEcomposer navigate to the ``src`` directory under ``app_canopen`` and double click on the app_canopen.xc file within it. The file will open in the central editor window.
   #. Find the main function and note that it runs the ``canopen_manager`` function on a single logical core, and a second ``application`` function on a second logical core and a ``can_server`` function on other logical core.

:ref:`Slicekit_CANopen_Quickstart`
   

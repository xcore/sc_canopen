CANopen Stack Component Documentation
=====================================

:scope: Early Development
:description: CANopen Slave Stack 
:keywords: CANopen, CAN
:boards: XA-SK-ISBUS

Description
-----------

This module is implements a CANopen slave suitable for use with the XMOS CANbus controller xSOFTip component or other industrial field busses. It exchanges messages with a CANopen master. The data in the Object dictionary of the CANopen slave can be accessed by the messages depending on their type.

Features
--------

   * Designed for use with other XMOS xSOFTip components for Industrial Fieldbusses such as the CAN Controller component and associated sliceCARDS
   * Includes Object Dictionary Generator utility
   * Fully conformant with the CAN-CiA CAN 301 specification


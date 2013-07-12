CANopen Stack Component 
=======================

:scope: Early Development
:description: CANopen Slave Stack 
:keywords: CANopen, CAN
:boards: XA-SK-ISBUS

Description
-----------

This module is implements a CANopen slave suitable for use with the XMOS CANbus controller xSOFTip component or other industrial Fieldbuses. It exchanges messages with a CANopen master. The data in the Object dictionary of the CANopen slave can be accessed by the messages depending on their type.

Currently the XMOS CANbus controller is the only suitable Fieldbus connectivity layer for use with this component, therefore adding this component to your project will cause the CAN bus controller to also be added. Please see the ``CAN Bus Module`` component in the xSOFip Explorer window for more details about the XMOS CAN bus controller implementation.

Features
--------

   * Designed for use with other XMOS xSOFTip components for Industrial Fieldbuses such as the CAN Controller component and associated sliceCARDS
   * Includes an Object Dictionary Generator utility
   * Conformance with the CAN-CiA CAN 301 specification is pending


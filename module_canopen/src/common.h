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

#ifndef __common_h__
#define __common_h__

#ifdef __canopen_conf_h_exists__
  #include "canopen_conf.h"
#endif

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

#ifndef CANOPEN_NODE_ID
  #define CANOPEN_NODE_ID 0
#endif

#ifndef CANOPEN_NUMBER_OF_TPDOS_SUPPORTED
  #define CANOPEN_NUMBER_OF_TPDOS_SUPPORTED 4
#endif

#ifndef CANOPEN_NUMBER_OF_RPDOS_SUPPORTED
  #define CANOPEN_NUMBER_OF_RPDOS_SUPPORTED 4
#endif

#ifndef CANOPEN_MAX_DATA_BUFFER_LENGTH
  #define CANOPEN_MAX_DATA_BUFFER_LENGTH 100
#endif

#define CANOPEN_BIT_TIME_TABLE_LENGTH 9

enum access
{
  RO = 0,
  WO = 1,
  RW = 2,
  RWR = 3,
  RWW = 4,
  CONST = 5
};

#endif /* common_h_ */

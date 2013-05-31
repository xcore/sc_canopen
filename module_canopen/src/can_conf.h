#ifndef CAN_CONF_H_
#define CAN_CONF_H_

#define CAN_FRAME_BUFFER_SIZE 16
#define CAN_MAX_FILTER_SIZE 16
#define CAN_CLOCK_DIVIDE 2

/*
 * This defines the segment sizes
 * The SYNC segment is defined to be 1 unit
 */
#define PROP_SEG    8
#define PHASE_SEG1  8
#define PHASE_SEG2  8

#endif /* CAN_CONF_H_ */

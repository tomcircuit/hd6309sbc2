/////////////////////////////////////////////////////////////////////////////
// SLABCP2110.h
// For SLABHIDtoUART.dll
// and Silicon Labs CP2110 HID to UART
/////////////////////////////////////////////////////////////////////////////
#ifndef SLAB_CP2110_H
#define SLAB_CP2110_H

/////////////////////////////////////////////////////////////////////////////
// Includes
/////////////////////////////////////////////////////////////////////////////

#include "SLABHIDtoUART.h"

/////////////////////////////////////////////////////////////////////////////
// Pin Definitions
/////////////////////////////////////////////////////////////////////////////

// Pin Config Mode Array Indices
#define CP2110_INDEX_GPIO_0_CLK			            0
#define CP2110_INDEX_GPIO_1_RTS			            1
#define CP2110_INDEX_GPIO_2_CTS			            2
#define CP2110_INDEX_GPIO_3_RS485			        3
#define CP2110_INDEX_GPIO_4_TX_TOGGLE		        4
#define CP2110_INDEX_GPIO_5_RX_TOGGLE		        5
#define CP2110_INDEX_GPIO_6				            6
#define CP2110_INDEX_GPIO_7				            7
#define CP2110_INDEX_GPIO_8				            8
#define CP2110_INDEX_GPIO_9				            9
#define CP2110_INDEX_TX					            10
#define CP2110_INDEX_SUSPEND				        11
#define CP2110_INDEX_SUSPEND_BAR			        12
// Size of the above array pointed to by pinConfig parameter in HidUart_SetPinConfig and HidUart_GetPinConfig
#define CP2110_PIN_CONFIG_SIZE					13

// Pin Bitmasks
#define CP2110_MASK_GPIO_0_CLK				        0x0001
#define CP2110_MASK_GPIO_1_RTS				        0x0002
#define CP2110_MASK_GPIO_2_CTS				        0x0004
#define CP2110_MASK_GPIO_3_RS485			        0x0008
#define CP2110_MASK_TX						        0x0010
#define CP2110_MASK_RX						        0x0020
#define CP2110_MASK_GPIO_4_TX_TOGGLE		        0x0040
#define CP2110_MASK_GPIO_5_RX_TOGGLE		        0x0080
#define CP2110_MASK_SUSPEND_BAR			            0x0100
// NA
#define CP2110_MASK_GPIO_6					        0x0400
#define CP2110_MASK_GPIO_7					        0x0800
#define CP2110_MASK_GPIO_8					        0x1000
#define CP2110_MASK_GPIO_9					        0x2000
#define CP2110_MASK_SUSPEND				            0x4000

/////////////////////////////////////////////////////////////////////////////
// Exported Library Functions
/////////////////////////////////////////////////////////////////////////////

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

// HidUart_SetPinConfig
HID_TO_UART_API HID_UART_STATUS WINAPI
HidUart_SetPinConfig(HID_UART_DEVICE device, BYTE* pinConfig, BOOL useSuspendValues, WORD suspendValue, WORD suspendMode, BYTE rs485Level, BYTE clkDiv);

// HidUart_GetPinConfig
HID_TO_UART_API HID_UART_STATUS WINAPI
HidUart_GetPinConfig(HID_UART_DEVICE device, BYTE* pinConfig, BOOL* useSuspendValues, WORD* suspendValue, WORD* suspendMode, BYTE* rs485Level, BYTE* clkDiv);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // SLAB_CP2110_H

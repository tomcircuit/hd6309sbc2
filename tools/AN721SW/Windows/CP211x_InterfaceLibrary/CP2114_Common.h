//-----------------------------------------------------------------------------
// CP2114_Common.h
//-----------------------------------------------------------------------------
// Copyright 2012 Silicon Laboratories, Inc.
// http://www.silabs.com
//
// Program Description:
//
// Header file shared by both CP2114 firmware and the Configurator.
//
//
// How To Test:    See Readme.txt
//
//
// Target:         C8051F381/T627
// Tool chain:     Keil C51
//                 Silicon Laboratories IDE
// Command Line:   See Readme.txt
// Project Name:   CP2114
//
//-----------------------------------------------------------------------------
#ifndef _CP2114_DATA_COMMON_H_
#define _CP2114_DATA_COMMON_H_

//-----------------------------------------------------------------------------
// PART NUMBER AND VERSION INFO
//-----------------------------------------------------------------------------
#define  PART_NUMBER       0x0E // 0x0E = 14, i.e. CP2114

// Versioning for CP-2114 Firmware, Device API and Configuration Block format.
// These elements are used to verify compatibility between the device and the
// Configurator. If API change is significant enough to require the Configurator
// to change, the firmware API version and the Configurator API version (the integer
// part) must be changed at the same time. Otherwise, Configurator won't connect to
// the device.
//
// Device           FIRMWARE_VERSION    DEV_API_VERSION     CFG_FMT_VERSION
// ----------------------------------------------------------------------------
// CP2114-B01-GM        0x07                0x05                0x01
// CP2114-B02-GM        0x08                0x06                0x02

#define  FIRMWARE_VERSION  0x08 // CP2114-B01: 0x07, CP2114-B02: 0x08
#define  DEV_API_VERSION   0x06 // CP2114-B01: 0x05, CP2114-B02: 0x06
#define  CFG_FMT_VERSION   0x02 // CP2114-B01: 0x01, CP2114-B02: 0x02
//
// END OF VERSION INFO
//

//--------------------------
// Locations
//--------------------------
// Locations must match settings of 'Project -> Toolchain -> Linker cmd line args'
#define DEFAULTDATA_ADDRESS  0x6600
#define USERDATA_ADDRESS     0x6800

#define CUSTOM_DATA_SIZE     (6*1024)

// Global errors & status
// NOTE:Any changes to the following definitions must also be made in the firmware 'CP2114_Common.h' file.

//  Config errors
#define kInvalidConfigNumber           0x20  // Requested config number >= MAX_CONFIGS
#define kBootIndicesDepleted           0x21  // All Dev boot indexes have been used
#define kRequestedConfigNotPresent     0x22  // Pointer to requested Dev config is 0xFFFF
#define kRequestedConfigInvalid        0x23  // Config is invalid or not supported
#define kConfigPointersDepleted        0x24  // All Config pointer slots have been used
#define kConfigSpaceDepleted           0x25  // Not enough space to save the new config
#define kBootIndexUnchanged            0x26  // The user-specified boot index is already the current boot index
#define kConfigUnchanged               0x27  // The Config is already as the user requested
#define kConfigInvalidConfigIdentifier 0x28  // Identifier was not INBAND_IDENTIFIER_INIT/SUSPEND/ACTIVE
#define kConfigSettingsInvalid         0x29  // Configuration contains invalid setting(s)
#define kUnsupportedConfigFormat       0x2A  // The config format version is not supported by library/firmware

// 'Set Parameters for Next Get' errors
#define kInvalidNumberOfCachedParams   0x40  // Specified tSetParamsForNextGet.params > MAX_CACHED_PARAMS
#define kUnexpectedCacheData           0x41  // Something in tSetParamsForNextGet was not as expected

// I2C errors
#define kI2cBusy                       0x50
#define kI2cTimeout                    0x51
#define kI2cInvalidToken               0x52
#define kI2cInvalidWriteLength         0x53
#define kI2cInvalidConfigLength        0x54
#define kI2cSclStuckLow                0x55
#define kI2cSdaStuckLow                0x56

//-------------------------------------------------------
// CP2114 Capabilities
//-------------------------------------------------------
typedef struct 
{
    U8    availableBootIndices;
    U8    availableOtpConfigs;
    U8    currentBootConfig;
    U8    availableOtpConfigSpace_LSB;
    U8    availableOtpConfigSpace_MSB;
}tDeviceCaps;

#define SIZE_DEVICE_CAPS   (sizeof(tDeviceCaps))

// Returned by CP2114_GetVersions in config_version
#define CP2114_CONFIG_VERSION_B01  1
#define CP2114_CONFIG_VERSION_B02  2

// NOTE: The firmware and this library code assumes that RAMConfig fits in 
// one packet. Since byte[0] is the report ID, the maximum RAMConfig size 
// (not including the 2-byte length) is 61 bytes.
#define MAX_RAM_CONFIG_SIZE     (2 + 61)
#define RAM_CONFIG_SIZE_B01     30   // if config_version == CP2114_CONFIG_VERSION_B01
#define RAM_CONFIG_SIZE_B02     50   // if config_version == CP2114_CONFIG_VERSION_B02

struct _RAM_CONFIG_STRUCT
{
    U16 Length;
    U8  configData[MAX_RAM_CONFIG_SIZE];
};

// Configuration Report ID's

#define RESET_DEVICE          0x40    // Reset Device
#define GETSET_UART_ENABLE    0x41    // Get Set Receive Status
#define GET_UART_STATUS       0x42    // Get UART Status
#define PURGE_FIFOS           0x43    // Purge FIFOs
#define GET_GPIO_VALUES       0x44    // Get GPIO Values
#define SET_GPIO_VALUES       0x45    // Set GPIO Values
#define GET_VER_INFO          0x46    // Get Version Information
#define GETSET_LOCK_BYTE      0x47    // Get Set Lock Byte

#define GETSET_UART_CONFIG    0x50    // Get Set UART Config
#define TRANS_LINE_BREAK      0x51    // Transmit Line Break
#define STOP_LINE_BREAK       0x52    // Stop Line Break

#define GETSET_USB_CONFIG     0x60    // All customizable data that's not strings
#define GETSET_MANU1          0x61    // Get Set Manufacturing String 1
#define GETSET_MANU2          0x62    // Get Set Manufacturing String 2
#define GETSET_PROD1          0x63    // Get Set Product String 1
#define GETSET_PROD2          0x64    // Get Set Product String 2
#define GETSET_SERSTR         0x65    // Get Set Serial String
#define GETSET_PIN_CONFIG     0x66    // GPIO configuration

// 2114 Specific commands                   Parameter                            Description
#define GET_DEVICE_STATUS           0x70 //   none                       1 byte sticky status, cleared in firmware on a read
#define GET_DEVICE_CAPS             0x71 //   none                       Gets CP2114 capabilities
#define GET_RAM_CONFIG              0x72 //   none                       Get current CP2114 Config from RAM
#define SET_RAM_CONFIG              0x73 //   config till DAC pairs      Set CP2114 Configuration to RAM
#define SET_DAC_REGISTERS           0x74 //   register values            Set DAC Config
#define GET_DAC_REGISTERS           0x75 //   register addr/count        Get DAC registers
#define GET_OTP_CONFIG              0x76 //   index                      Return CP2114 OTP Config based on the current index
#define GET_DEVICE_VERSIONS         0x77 //   none                       Return API version and firmware version
#define CREATE_OTP_CONFIG           0x78 //   config block               Create New Configuration Block for CP2114
#define SET_BOOT_CONFIG             0x79 //   index                      Set CP2114 Boot Configuration
#define SET_PARAMS_FOR_NEXT_GET     0x7A //                              Parameters to be used for subsequent Get
#define GET_OTP_ALLCONFIG           0x7B //                              Get OTP all configuration
#define SET_OTP_ALLCONFIG           0x7C //                              Set OTP all configuration
#define I2C_WRITE_DATA              0x7D //   SLA,nWrite,data            I2C Write operation
#define I2C_READ_DATA               0x7E //   (Sent in Params block)     I2C Read operation

#define BUTTON_EVENT                0x80 //                              Report button status

enum 
{
    INBAND_IDENTIFIER_INIT     = 0xF9,
    INBAND_IDENTIFIER_SUSPEND  = 0xFA,
    INBAND_IDENTIFIER_ACTIVE   = 0xFB,
    INBAND_COMMAND_START       = 0xFC,
    INBAND_COMMAND_REENUMERATE = INBAND_COMMAND_START,
    INBAND_COMMAND_DELAY_US    = 0xFD,
    INBAND_COMMAND_SET_GPIO    = 0xFE,
    INBAND_COMMAND_DELAY_MS    = 0xFF,
};

#endif             // _CP2114_COMMON_H_

//-----------------------------------------------------------------------------
// End Of File
//-----------------------------------------------------------------------------

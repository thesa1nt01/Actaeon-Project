/*! \file uart2.c \brief Dual UART driver with buffer support. */
//*****************************************************************************
//
// File Name	: 'uart2.h' changed to 'uart4.h' (see footnote *)
// Title		: Dual UART driver with buffer support
// Author		: Pascal Stang - Copyright (C) 2000-2004
// Created		: 11/20/2000
// Revised		: 07/04/2004
// Version		: 1.0
// Target MCU	: ATMEL AVR Series
// Editor Tabs	: 4
//
// Description	: This is a UART driver for AVR-series processors with two
//		hardware UARTs such as the mega161 and mega128 
//
// This code is distributed under the GNU Public License
//		which can be found at http://www.gnu.org/licenses/gpl.txt
// 
// 
//   * Code modified by societyofrobots.com to handle four UARTs - using ATmega2560
//	  Dec 6th, 2007
//
//
//*****************************************************************************

#include <avr/io.h>
#include <avr/interrupt.h>

#include "buffer.h"
#include "uart4.h"

// UART global variables
// flag variables
volatile u08   uartReadyTx[4];
volatile u08   uartBufferedTx[4];
// receive and transmit buffers
cBuffer uartRxBuffer[4];
cBuffer uartTxBuffer[4];
unsigned short uartRxOverflow[4];
#ifndef UART_BUFFER_EXTERNAL_RAM
	// using internal ram,
	// automatically allocate space in ram for each buffer
	static char uart0RxData[UART0_RX_BUFFER_SIZE];
	static char uart0TxData[UART0_TX_BUFFER_SIZE];
#endif

typedef void (*voidFuncPtru08)(unsigned char);
volatile static voidFuncPtru08 UartRxFunc[4];

void uartInit(void)
{
	// initialize all uarts
	uart0Init();
}

void uart0Init(void)
{
	// initialize the buffers
	uart0InitBuffers();
	// initialize user receive handlers
	UartRxFunc[0] = 0;
	// enable RxD/TxD and interrupts
	outb(UCSR0B, BV(RXCIE)|BV(TXCIE)|BV(RXEN)|BV(TXEN));
	//outb(UCSR0B, BV(RXEN)|BV(TXEN));
	// set default baud rate
	uartSetBaudRate(0, UART0_DEFAULT_BAUD_RATE); 
	// initialize states
	uartReadyTx[0] = TRUE;
	uartBufferedTx[0] = FALSE;
	// clear overflow count
	uartRxOverflow[0] = 0;
	// enable interrupts
	sei();
}

void uart0InitBuffers(void)
{
	#ifndef UART_BUFFER_EXTERNAL_RAM
		// initialize the UART0 buffers
		bufferInit(&uartRxBuffer[0], (u08*) uart0RxData, UART0_RX_BUFFER_SIZE);
		bufferInit(&uartTxBuffer[0], (u08*) uart0TxData, UART0_TX_BUFFER_SIZE);
	#else
		// initialize the UART0 buffers
		bufferInit(&uartRxBuffer[0], (u08*) UART0_RX_BUFFER_ADDR, UART0_RX_BUFFER_SIZE);
		bufferInit(&uartTxBuffer[0], (u08*) UART0_TX_BUFFER_ADDR, UART0_TX_BUFFER_SIZE);
	#endif
}

void uartSetRxHandler(u08 nUart, void (*rx_func)(unsigned char c))
{
	// make sure the uart number is within bounds
	if(nUart < 4)
	{
		// set the receive interrupt to run the supplied user function
		UartRxFunc[nUart] = rx_func;
	}
}

void uartSetBaudRate(u08 nUart, u32 baudrate)
{
	// calculate division factor for requested baud rate, and set it
	u16 bauddiv = ((F_CPU+(baudrate*8L))/(baudrate*16L)-1);
	if(nUart==0)
	{
		outb(UBRR0L, bauddiv);
		#ifdef UBRR0H
		outb(UBRR0H, bauddiv>>8);
		#endif
	}
}

cBuffer* uartGetRxBuffer(u08 nUart)
{
	// return rx buffer pointer
	return &uartRxBuffer[nUart];
}

cBuffer* uartGetTxBuffer(u08 nUart)
{
	// return tx buffer pointer
	return &uartTxBuffer[nUart];
}

void uartSendByte(u08 nUart, u08 txData)
{
	// wait for the transmitter to be ready
//	while(!uartReadyTx[nUart]);
	// send byte
	if(nUart==0)
	{
		while(!(UCSR0A & (1<<UDRE0)));
		outb(UDR0, txData);
	}
	// set ready state to FALSE
	uartReadyTx[nUart] = FALSE;
}

void uart0SendByte(u08 data)
{
	// send byte on UART0
	uartSendByte(0, data);
}

int uart0GetByte(void)
{
	// get single byte from receive buffer (if available)
	u08 c;
	if(uartReceiveByte(0,&c))
		return c;
	else
		return -1;
}

u08 uartReceiveByte(u08 nUart, u08* rxData)
{
	// make sure we have a receive buffer
	if(uartRxBuffer[nUart].size)
	{
		// make sure we have data
		if(uartRxBuffer[nUart].datalength)
		{
			// get byte from beginning of buffer
			*rxData = bufferGetFromFront(&uartRxBuffer[nUart]);
			return TRUE;
		}
		else
			return FALSE;			// no data
	}
	else
		return FALSE;				// no buffer
}

void uartFlushReceiveBuffer(u08 nUart)
{
	// flush all data from receive buffer
	bufferFlush(&uartRxBuffer[nUart]);
}

u08 uartReceiveBufferIsEmpty(u08 nUart)
{
	return (uartRxBuffer[nUart].datalength == 0);
}

void uartAddToTxBuffer(u08 nUart, u08 data)
{
	// add data byte to the end of the tx buffer
	bufferAddToEnd(&uartTxBuffer[nUart], data);
}

void uart0AddToTxBuffer(u08 data)
{
	uartAddToTxBuffer(0,data);
}

void uartSendTxBuffer(u08 nUart)
{
	// turn on buffered transmit
	uartBufferedTx[nUart] = TRUE;
	// send the first byte to get things going by interrupts
	uartSendByte(nUart, bufferGetFromFront(&uartTxBuffer[nUart]));
}

u08 uartSendBuffer(u08 nUart, char *buffer, u16 nBytes)
{
	register u08 first;
	register u16 i;

	// check if there's space (and that we have any bytes to send at all)
	if((uartTxBuffer[nUart].datalength + nBytes < uartTxBuffer[nUart].size) && nBytes)
	{
		// grab first character
		first = *buffer++;
		// copy user buffer to uart transmit buffer
		for(i = 0; i < nBytes-1; i++)
		{
			// put data bytes at end of buffer
			bufferAddToEnd(&uartTxBuffer[nUart], *buffer++);
		}

		// send the first byte to get things going by interrupts
		uartBufferedTx[nUart] = TRUE;
		uartSendByte(nUart, first);
		// return success
		return TRUE;
	}
	else
	{
		// return failure
		return FALSE;
	}
}

// UART Transmit Complete Interrupt Function
void uartTransmitService(u08 nUart)
{
	// check if buffered tx is enabled
	if(uartBufferedTx[nUart])
	{
		// check if there's data left in the buffer
		if(uartTxBuffer[nUart].datalength)
		{
			// send byte from top of buffer
			if(nUart==3)
				outb(UDR0,  bufferGetFromFront(&uartTxBuffer[0]) );
		}
		else
		{
			// no data left
			uartBufferedTx[nUart] = FALSE;
			// return to ready state
			uartReadyTx[nUart] = TRUE;
		}
	}
	else
	{
		// we're using single-byte tx mode
		// indicate transmit complete, back to ready
		uartReadyTx[nUart] = TRUE;
	}
}

// UART Receive Complete Interrupt Function
void uartReceiveService(u08 nUart)
{
	u08 c;
	// get received char
	
	if(nUart==0){
		c = inb(UDR0);
	}

	// if there's a user function to handle this receive event
	if(UartRxFunc[nUart])
	{
		// call it and pass the received data
		UartRxFunc[nUart](c);
	}
	else
	{
		// otherwise do default processing
		// put received char in buffer
		// check if there's space
		if( !bufferAddToEnd(&uartRxBuffer[nUart], c) )
		{
			// no space in buffer
			// count overflow
			uartRxOverflow[nUart]++;
		}
	}
}

	// service UART transmit interrupt
//UART_INTERRUPT_HANDLER(SIG_USART0_TRANS)      
ISR(USART_TX_vect)  
{
	uartTransmitService(0);
}
	// service UART receive interrupt
//UART_INTERRUPT_HANDLER(_VECTOR(25))      
ISR(USART_RX_vect)      
{
	uartReceiveService(0);
}

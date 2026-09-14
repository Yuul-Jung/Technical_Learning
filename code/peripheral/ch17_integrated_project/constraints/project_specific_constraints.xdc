## ======================================================
## Chapter 17 Integrated Project - Project-specific constraints
## 기존 Basys-3-Master.xdc에 추가해서 사용한다.
## ======================================================

## ------------------------------------------------------
## PMOD JA : CdS + HC-SR04
## ------------------------------------------------------

## CdS Input : PMOD JA1
set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } [get_ports {cds_in}]

## Ultrasonic TRIG : PMOD JA2
set_property -dict { PACKAGE_PIN L2 IOSTANDARD LVCMOS33 } [get_ports {us_trig}]

## Ultrasonic ECHO : PMOD JA3
set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports {us_echo}]

## ------------------------------------------------------
## PMOD JB : L298 DC Motor Driver
## ------------------------------------------------------

## L298 ENA PWM : PMOD JB1
set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS33 } [get_ports {motor_ena_pwm}]

## L298 IN1 : PMOD JB2
set_property -dict { PACKAGE_PIN A16 IOSTANDARD LVCMOS33 } [get_ports {motor_in1}]

## L298 IN2 : PMOD JB3
set_property -dict { PACKAGE_PIN B15 IOSTANDARD LVCMOS33 } [get_ports {motor_in2}]

## ------------------------------------------------------
## JXADC : VAUX6 / AD6
## ------------------------------------------------------

## XA1_P
set_property PACKAGE_PIN J3 [get_ports vauxp6]
set_property IOSTANDARD LVCMOS33 [get_ports vauxp6]

## XA1_N
set_property PACKAGE_PIN K3 [get_ports vauxn6]
set_property IOSTANDARD LVCMOS33 [get_ports vauxn6]

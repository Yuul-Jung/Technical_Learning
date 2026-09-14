## ======================================================
## Project-specific PMOD JB mapping
## L298 DC Motor Driver
## ======================================================

## L298 ENA PWM : PMOD JB1
set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS33 } [get_ports {motor_ena_pwm}]

## L298 IN1 : PMOD JB2
set_property -dict { PACKAGE_PIN A16 IOSTANDARD LVCMOS33 } [get_ports {motor_in1}]

## L298 IN2 : PMOD JB3
set_property -dict { PACKAGE_PIN B15 IOSTANDARD LVCMOS33 } [get_ports {motor_in2}]

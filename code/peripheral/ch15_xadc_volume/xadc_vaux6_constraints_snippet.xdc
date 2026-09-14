## ======================================================
## XADC AD6 / VAUX6
## Basys3 JXADC XA1_P / XA1_N
## 기존 Basys-3-Master.xdc에 아래 항목을 추가한다.
## ======================================================

## XA1_P
set_property PACKAGE_PIN J3 [get_ports vauxp6]
set_property IOSTANDARD LVCMOS33 [get_ports vauxp6]

## XA1_N
set_property PACKAGE_PIN K3 [get_ports vauxn6]
set_property IOSTANDARD LVCMOS33 [get_ports vauxn6]

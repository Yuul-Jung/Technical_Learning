# Chapter 17 Integrated Project Source Manifest

이 폴더는 RTL 주변기기 회로설계 17 종합과제용 누적 소스 묶음입니다.

## Design Sources

- rtl/comm/uart/*
- rtl/controllers/uart_reg_write_controller.v
- rtl/controllers/simple_register_map.v
- rtl/controllers/led_pwm_controller.v
- rtl/controllers/cds_input_filter.v
- rtl/controllers/fnd_status_3digit_display.v
- rtl/controllers/distance_to_pwm_value_controller.v
- rtl/controllers/ultrasonic_distance_meter.v
- rtl/controllers/xadc_analog_reader.v
- rtl/controllers/xadc_volume_level_controller.v
- rtl/controllers/fnd_status_volume_selector.v
- rtl/controllers/l298_distance_motor_controller.v
- rtl/top/basys3_uart_led_pwm_cds_ultra_fnd_top.v

## Vivado IP

Vivado IP Catalog에서 XADC Wizard를 생성합니다.

- Component Name: xadc_wiz_0
- Interface: DRP
- Channel: VAUX6
- Mode: Continuous
- DCLK: 100 MHz

생성된 xadc_wiz_0.xci는 Design Sources에 포함합니다.

## Simulation Sources

- tb/controllers/tb_l298_distance_motor_controller.v
- tb/controllers/tb_xadc_volume_level_controller.v

현재 누적 패키지에는 xadc_wiz_0 Simulation Stub을 임의로 생성하지 않았습니다.
XADC Analog Reader를 별도로 시뮬레이션하려면 Vivado가 생성한 Simulation Model/Stub을 사용합니다.

## Constraints

constraints/project_specific_constraints.xdc의 JA/JB/XADC 항목을
기존 Basys-3-Master.xdc에 추가해서 사용합니다.

# Technical Learning

GitHub Pages 기반의 누적형 기술 학습 홈페이지입니다.

## 현재 공개 자료

### 환경구축 및 하드웨어/개념

#### 개념

- Verilog HDL 개요 · 역사 · 특징

#### 환경구축 및 하드웨어

1. Ubuntu에서 AMD Vivado 2024.2 설치
2. Basys3 회로도 읽기
3. Basys3 하드웨어 매뉴얼
4. XDC · Xilinx Design Constraints
5. Basys3 다운로드/장치 인식
6. Digilent Adept 구성과 역할

### FPGA / SoC 개념

01. FPGA 개요와 내부 구조
02. FPGA · ASIC · MCU · SoC 비교
03. RTL이 FPGA 회로가 되는 과정
04. SoC 개요와 구성
05. CPU · Memory · Peripheral 구조
06. Memory-Mapped I/O와 Register Map
07. AXI 개념 — AXI4 · AXI4-Lite · AXI4-Stream
08. IP · Module Reference · Custom IP
09. MicroBlaze 기반 FPGA SoC
10. FPGA Memory · BRAM · DSP 구조
11. Hardware Accelerator 구조
12. Basys3 NPU로 확장

> AMD/Xilinx · Digilent 공식 문서를 기준으로 구성하며, 원문 구조도는 핵심 개념을 유지한 교육용 재작성 그림으로 Repository 내부에 저장합니다.

### Digital / FPGA

01. SW0를 이용한 LED0 ON/OFF 실습
02. 74 시리즈 기반 Verilog RTL 설계 가이드
03. 부울대수 공리 FPGA 실습
04. Level 1 논리게이트 FPGA 실습
05. 구조화 Gate Module RTL 실습
06. Verilog 기본 문법과 로직게이트 실습
07. Boolean Algebra · Karnaugh Map RTL 실습
08. 조합회로 설계 실습 — Adder
09. CLA Adder 원리와 FPGA 실무형 작성법
10. Verilog Testbench 기본 개념
11. Selection · Conversion Logic RTL 실습
12. 조합회로 응용 Mini Project
13. Tri-State Buffer · Shared Bus RTL 실습
14. 순차회로와 Latch 기초
15. D Flip-Flop · Edge Triggered RTL 실습
16. 8bit Register · Enable · Load · Reset RTL 실습
17. Shift Register · Serial/Parallel 변환 RTL 실습
18. Counter Step 1 · Tick · BCD · FND RTL 실습
19. Counter Step 2 · Multi-Digit BCD · FND Multiplexing
20. Stopwatch Step 3 · 4자리 구조화 RTL 실습
21. Button Debounce · 2-FF Synchronizer · One-Pulse RTL
22. 24시간 디지털 시계 · HH:MM RTL 실습
23. FSM 회로 설계 · Moore · Mealy RTL 실습

### RTL 주변기기 회로설계

01. UART TX · FIFO · Sender · 8N1 FSM RTL 실습
02. UART RX Core · 1문자 수신 RTL 실습
03. UART RX 연속문자 · BRAM Line Buffer RTL 실습
04. UART RX + TX 통합 · uart_core RTL 실습
05. UART RX 1문자 즉시 표시 · RX Display Register 수정
06. UART Echo · RX → TX Loopback RTL 실습
07. UART Command Parser · Response Generator RTL 실습
08. UART Register Map · LED PWM Dimming RTL 실습
09. UART Register Map · CdS + LED PWM + FND RTL 실습
10. PWM_VALUE 기반 LED Bar Dimming RTL 실습
11. HC-SR04 초음파 거리계 · UART Register Map RTL 실습
12. FND 초음파 거리 상태 문자 · n / - / F RTL 실습
13. 초음파 거리 기반 LED Bar 재사용 RTL 실습
14. LED Breathing Mode · PWM_VALUE 0xFE RTL 실습
15. XADC 아날로그 입력 · 포텐셔미터 RTL 실습
16. L298 모터 + 초음파 + CdS 통합 RTL 실습
17. 종합과제 · 모터 + XADC + 초음파 + CdS + LED RTL 통합

> UART부터는 Digital / FPGA 기초 번호와 분리하여 `01`부터 별도 번호 체계로 관리합니다.

## 기본 구조

```text
Technical_Learning/
├── index.html
├── pages/
│   ├── environment/
│   │   ├── 00_verilog_hdl_overview_history_features.html
│   │   ├── 01_ubuntu_vivado_install.html
│   │   ├── 02_basys3_schematic.html
│   │   ├── 03_basys3_hardware_manual.html
│   │   ├── 04_xdc_constraints.html
│   │   ├── 05_basys3_device_recognition.html
│   │   └── 06_digilent_adept.html
│   ├── fpga_soc_concept/
│   │   ├── 01_fpga_architecture.html
│   │   ├── 02_fpga_asic_mcu_soc.html
│   │   ├── 03_fpga_design_flow.html
│   │   ├── 04_soc_overview.html
│   │   ├── 05_cpu_memory_peripheral.html
│   │   ├── 06_memory_mapped_io.html
│   │   ├── 07_axi_concept.html
│   │   ├── 08_ip_custom_ip.html
│   │   ├── 09_microblaze_soc.html
│   │   ├── 10_fpga_memory_dsp.html
│   │   ├── 11_hardware_accelerator.html
│   │   └── 12_npu_extension.html
│   ├── fpga/
│   │   ├── 01_sw0_led.html
│   │   ├── ...
│   │   └── 23_fsm_moore_mealy.html
│   └── peripheral/
│       ├── 01_uart_tx_fifo_fsm.html
│       ├── 02_uart_rx_core_single_byte.html
│       ├── 03_uart_rx_continuous_bram_line_buffer.html
│       ├── 04_uart_rx_tx_integration.html
│       ├── 05_uart_rx_immediate_display.html
│       ├── 06_uart_echo_loopback.html
│       ├── 07_uart_command_response.html
│       ├── 08_uart_register_map_led_pwm.html
│       ├── 09_uart_cds_led_pwm_fnd.html
│       ├── 10_pwm_value_led_bar_dimming.html
│       ├── 11_hcsr04_ultrasonic_register_map.html
│       ├── 12_fnd_distance_status.html
│       ├── 13_ultrasonic_distance_led_bar.html
│       ├── 14_led_breathing_mode.html
│       ├── 15_xadc_potentiometer.html
│       ├── 16_l298_motor_ultrasonic_cds.html
│       └── 17_integrated_motor_xadc_ultrasonic_cds_led.html
├── images/
├── code/
│   ├── fpga/
│   │   ├── ch05_gate_modules/
│   │   ├── ...
│   │   └── ch23_fsm_basics/
│   └── peripheral/
│       ├── ch01_uart_tx/
│       ├── ch02_uart_rx/
│       ├── ch03_uart_rx_continuous/
│       ├── ch04_uart_rx_tx/
│       ├── ch05_uart_rx_immediate_display/
│       ├── ch06_uart_echo/
│       ├── ch07_uart_command_response/
│       ├── ch08_uart_register_map_led_pwm/
│       ├── ch09_uart_cds_led_fnd/
│       ├── ch10_pwm_value_led_bar/
│       ├── ch11_hcsr04_ultrasonic/
│       ├── ch12_fnd_distance_status/
│       ├── ch13_ultrasonic_led_bar_reuse/
│       ├── ch14_led_breathing_mode/
│       ├── ch15_xadc_volume/
│       ├── ch16_l298_motor_control/
│       └── ch17_integrated_project/
├── css/
│   └── style.css
└── README.md
```

모든 웹 페이지는 GitHub Pages와 로컬 브라우저에서 모두 동작하도록 상대경로를 기본으로 사용합니다.

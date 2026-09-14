# Technical Learning

GitHub Pages 기반의 누적형 기술 학습 홈페이지입니다.

## 현재 공개 자료

### 환경구축

1. Ubuntu에서 AMD Vivado 2024.2 설치

### Digital / FPGA

2. SW0를 이용한 LED0 ON/OFF 실습
3. 74 시리즈 기반 Verilog RTL 설계 가이드
4. 부울대수 공리 FPGA 실습
5. Level 1 논리게이트 FPGA 실습
6. 구조화 Gate Module RTL 실습
7. Verilog 기본 문법과 로직게이트 실습
8. Boolean Algebra · Karnaugh Map RTL 실습
9. 조합회로 설계 실습 — Adder
10. CLA Adder 원리와 FPGA 실무형 작성법
11. Verilog Testbench 기본 개념
12. Selection · Conversion Logic RTL 실습
13. 조합회로 응용 Mini Project
14. Tri-State Buffer · Shared Bus RTL 실습
15. 순차회로와 Latch 기초
16. D Flip-Flop · Edge Triggered RTL 실습
17. 8bit Register · Enable · Load · Reset RTL 실습
18. Shift Register · Serial/Parallel 변환 RTL 실습
19. Counter Step 1 · Tick · BCD · FND RTL 실습
20. Counter Step 2 · Multi-Digit BCD · FND Multiplexing
21. Stopwatch Step 3 · 4자리 구조화 RTL 실습
22. Button Debounce · 2-FF Synchronizer · One-Pulse RTL
23. 24시간 디지털 시계 · HH:MM RTL 실습
24. FSM 회로 설계 · Moore · Mealy RTL 실습

### RTL 주변기기 회로설계

01. UART TX · FIFO · Sender · 8N1 FSM RTL 실습
02. UART RX Core · 1문자 수신 RTL 실습

> UART부터는 Digital / FPGA 기초 번호와 분리하여 `01`부터 별도 번호 체계로 관리합니다.

## 기본 구조

```text
Technical_Learning/
├── index.html
├── pages/
│   ├── environment/
│   │   └── 01_ubuntu_vivado_install.html
│   ├── fpga/
│   │   ├── 02_sw0_led.html
│   │   ├── ...
│   │   └── 24_fsm_moore_mealy.html
│   └── peripheral/
│       ├── 01_uart_tx_fifo_fsm.html
│       └── 02_uart_rx_core_single_byte.html
├── images/
├── code/
│   ├── fpga/
│   │   ├── ch06_gate_modules/
│   │   ├── ...
│   │   └── ch24_fsm_basics/
│   └── peripheral/
│       ├── ch01_uart_tx/
│       └── ch02_uart_rx/
├── css/
│   └── style.css
└── README.md
```

모든 웹 페이지는 GitHub Pages와 로컬 브라우저에서 모두 동작하도록 상대경로를 기본으로 사용합니다.

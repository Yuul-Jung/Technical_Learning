# FPGA / SoC 개념 Source Map

> 목적: GitHub Pages의 **FPGA / SoC 개념** 별도 루트를 만들기 전에, 각 챕터가 어떤 공식 문서와 원문 그림을 기준으로 작성되는지 먼저 고정한다.  
> 원칙: 개념 설명은 AMD/Xilinx·Digilent 공식 문서를 1차 기준으로 삼고, Basys3 실습과 연결되는 범위에서만 보완한다.

---

## 1. 전체 방향

`FPGA / SoC 개념` 루트는 실습 코드보다 **구조·원리·설계 흐름**을 설명하는 영역으로 사용한다.

```text
FPGA / SoC 개념
      ↓
FPGA 내부 구조
      ↓
RTL → 합성 → 구현
      ↓
CPU · Memory · Peripheral
      ↓
Memory-Mapped I/O · Register Map
      ↓
AXI
      ↓
IP · Custom IP
      ↓
MicroBlaze SoC
      ↓
Hardware Accelerator / NPU
```

기존 루트와 역할을 구분한다.

```text
환경구축 및 하드웨어
    → Vivado, Basys3, XDC, 드라이버, 보드 환경

FPGA / SoC 개념
    → 구조와 원리

Digital / FPGA
    → Verilog RTL 구현

RTL 주변기기 회로설계
    → UART, PWM, Sensor, Display 등 실제 RTL IP

SoC
    → MicroBlaze, AXI, Register Map, Custom IP 실제 통합

NPU / RISC-V
    → 가속기와 CPU 구조 확장
```

---

## 2. Repository 구조

```text
pages/
└── fpga_soc_concept/
    ├── 01_fpga_architecture.html
    ├── 02_fpga_asic_mcu_soc.html
    ├── 03_fpga_design_flow.html
    ├── 04_soc_overview.html
    ├── 05_cpu_memory_peripheral.html
    ├── 06_memory_mapped_io.html
    ├── 07_axi_concept.html
    ├── 08_ip_custom_ip.html
    ├── 09_microblaze_soc.html
    ├── 10_fpga_memory_dsp.html
    ├── 11_hardware_accelerator.html
    └── 12_npu_extension.html

images/
└── fpga_soc_concept/
    ├── 01_fpga_architecture/
    ├── 02_fpga_asic_mcu_soc/
    ├── 03_fpga_design_flow/
    ├── 04_soc_overview/
    ├── 05_cpu_memory_peripheral/
    ├── 06_memory_mapped_io/
    ├── 07_axi_concept/
    ├── 08_ip_custom_ip/
    ├── 09_microblaze_soc/
    ├── 10_fpga_memory_dsp/
    ├── 11_hardware_accelerator/
    └── 12_npu_extension/
```

---

## 3. 원문 그림 사용 원칙

- 원문에 중요한 구조도가 있으면 삭제하지 않는다.
- 한 챕터당 **핵심 원문 그림 2~5개 정도**를 우선 선정한다.
- 원문 그림은 장식이 아니라 구조를 설명하는 근거로 사용한다.
- 동일 내용을 설명하는 원문 그림이 여러 개라면 가장 단순하고 교육적으로 의미 있는 그림을 선택한다.
- 단순 Vivado GUI 캡처는 꼭 필요한 경우만 사용한다.
- 중요한 흐름은 `원문 그림 → 쉬운 해설 → Basys3에서의 의미` 순서로 연결한다.
- Notion 임시 S3 주소는 HTML에 직접 연결하지 않는다.
- 확보한 이미지는 Repository 내부에 저장하고 상대경로로 참조한다.
- 공개 GitHub Pages에서는 문서 전체 또는 대량 캡처를 복제하지 않고, 필요한 핵심 그림만 선택적으로 사용하며 문서명·문서번호·Figure 번호/제목·출처를 표시한다.
- 재배포 범위가 불명확한 그림은 구조를 분석해 교육용 그림으로 다시 작성하되, 기준 문서를 명시한다.

예:

```text
images/fpga_soc_concept/01_fpga_architecture/
├── ug474_clb_slice_arrangement.png
├── ug474_slicem_structure.png
├── ug473_bram_data_flow.png
└── ug479_dsp48e1_slice.png
```

---

## 4. 1차 공식 Source Set

| 문서 | 역할 |
|---|---|
| AMD UG474 — 7 Series FPGAs Configurable Logic Block User Guide | CLB, Slice, LUT, FF, Carry, Distributed RAM |
| AMD UG473 — 7 Series FPGAs Memory Resources User Guide | BRAM 구조와 메모리 자원 |
| AMD UG479 — 7 Series DSP48E1 Slice User Guide | DSP48E1, Multiply, MAC, Pipeline |
| AMD UG901 — Vivado Design Suite User Guide: Synthesis | RTL → Synthesis |
| AMD UG903 — Vivado Design Suite User Guide: Using Constraints | XDC, Clock, Timing Constraint |
| AMD UG904 — Vivado Design Suite User Guide: Implementation | Placement, Routing, Bitstream |
| AMD UG984 — MicroBlaze Processor Reference Guide | MicroBlaze CPU 내부 구조와 Bus Interface |
| AMD UG1579 — MicroBlaze Processor Embedded Design User Guide | MicroBlaze 기반 Embedded/SoC 설계 흐름 |
| AMD UG994 — Designing IP Subsystems Using IP Integrator | Block Design, IP 연결, Module Reference |
| AMD UG1118 — Creating and Packaging Custom IP | RTL → Custom IP |
| AMD UG1037 — Vivado AXI Reference Guide | AXI4, AXI4-Lite, AXI4-Stream |
| AMD PG144 — AXI GPIO | 실제 Register Map 예 |
| AMD PG079 — AXI Timer | Register Map, Timer, Interrupt 구조 |
| Digilent Basys3 Reference Manual | Basys3 실제 Artix-7 자원과 보드 I/O |
| Digilent Basys3 Schematic | 실제 FPGA 핀과 외부 회로 연결 |

---

# 5. 챕터별 Source Map

## 01. FPGA 개요와 내부 구조

### 핵심 질문
- FPGA는 무엇인가?
- Verilog 코드가 FPGA 내부에서 어떤 하드웨어 자원으로 바뀌는가?
- LUT, FF, Slice, CLB는 어떤 관계인가?
- Basys3의 Artix-7에는 어떤 주요 자원이 있는가?

### 1차 기준 문서
- AMD UG474: CLB Overview, CLB Slices, Slice Description, Look-Up Table, Carry Logic
- Digilent Basys3 Reference Manual: Overview, Artix-7 resource summary

### 원문 그림 후보
1. UG474 — CLB Overview, Figure 1: **Arrangement of Slices within the CLB**
2. UG474 — Slice Description, Figure 1: **Diagram of SLICEM**
3. UG474 — Slice Description, Figure 2: **Diagram of SLICEL**
4. UG474 — Carry Logic, Figure 1: **Fast Carry Logic Path and Associated Elements**
5. Basys3 Reference Manual — Board overview/photo

### 교육용 재작성 그림

```text
Verilog RTL
   ↓
LUT + FF
   ↓
Slice
   ↓
CLB
   ↓
Routing
   ↓
I/O / BRAM / DSP
```

### Basys3 연결
- XC7A35T-1CPG236C
- 33,280 Logic Cells
- 5,200 Slices
- 1,800 Kbit Block RAM
- 90 DSP Slices

### HTML
`pages/fpga_soc_concept/01_fpga_architecture.html`

---

## 02. FPGA · ASIC · MCU · SoC 비교

### 핵심 질문
- FPGA와 MCU는 무엇이 다른가?
- FPGA와 ASIC은 무엇이 다른가?
- FPGA 안에 CPU를 넣으면 왜 SoC처럼 사용할 수 있는가?
- Basys3 + MicroBlaze는 어떤 의미에서 FPGA SoC인가?

### 1차 기준 문서
- AMD UG984 — MicroBlaze Overview
- AMD UG1579 — Using a MicroBlaze Processor in an Embedded Design
- Digilent Basys3 Reference Manual

### 원문 그림 후보
1. UG984 — **MicroBlaze Core Block Diagram**
2. UG1579 — **Block Design of MicroBlaze Core**
3. Basys3 board overview

### 교육용 비교 그림

```text
MCU
CPU + Memory + Peripheral
        ↓
      고정 구조

FPGA
LUT + FF + BRAM + DSP + Routing
        ↓
   사용자가 회로 구성

FPGA SoC
MicroBlaze + BRAM + AXI + Peripheral + Custom RTL
```

### HTML
`02_fpga_asic_mcu_soc.html`

---

## 03. RTL이 FPGA 회로가 되는 과정

### 핵심 질문
- Verilog 소스가 어떻게 실제 FPGA 회로가 되는가?
- Elaboration, Synthesis, Implementation은 무엇이 다른가?
- Netlist, Placement, Routing, Bitstream은 무엇인가?

### 1차 기준 문서
- AMD UG901 — Synthesis
- AMD UG904 — Implementation
- AMD UG903 — Constraints

### 원문 그림 후보
1. UG904 — About the Vivado Implementation Process, Figure 1: **Vivado tools flow**
2. UG901 — Synthesis Settings/Flow 관련 그림
3. UG903 — Timing Constraints Window/Spreadsheet

### 교육용 흐름

```text
Verilog RTL
   ↓
Elaboration
   ↓
Synthesis
   ↓
Netlist
   ↓
Optimization
   ↓
Placement
   ↓
Routing
   ↓
Timing Analysis
   ↓
Bitstream
   ↓
Basys3 FPGA
```

### HTML
`03_fpga_design_flow.html`

---

## 04. SoC 개요와 구성

### 핵심 질문
- SoC(System-on-Chip)는 무엇인가?
- CPU만 있다고 SoC가 되는가?
- CPU, Memory, Bus, Peripheral은 어떻게 연결되는가?
- FPGA 내부 Soft Processor 시스템은 어떻게 이해해야 하는가?

### 1차 기준 문서
- AMD UG984
- AMD UG1579
- AMD UG994

### 원문 그림 후보
1. UG984 — MicroBlaze Core Block Diagram
2. UG1579 — MicroBlaze Embedded Design 구조
3. UG994 — IP Integrator Block Design 예

### HTML
`04_soc_overview.html`

---

## 05. CPU · Memory · Peripheral 구조

### 핵심 질문
- CPU는 명령어를 어디서 읽는가?
- Program Memory와 Data Memory는 어떻게 연결되는가?
- Peripheral은 CPU와 어떻게 데이터를 주고받는가?
- MicroBlaze의 LMB와 AXI는 역할이 어떻게 다른가?

### 1차 기준 문서
- AMD UG984 — MicroBlaze Architecture / I/O Overview
- AMD UG1579 — Memory IP / Block Automation

### 원문 그림 후보
1. UG984 — MicroBlaze Core Block Diagram
2. UG984 — **MicroBlaze I/O Overview**
3. UG1579 — MicroBlaze + Memory Block Design 예

### HTML
`05_cpu_memory_peripheral.html`

---

## 06. Memory-Mapped I/O와 Register Map

### 핵심 질문
- LED가 왜 주소를 가질 수 있는가?
- CPU의 write가 어떻게 FPGA 출력 신호로 연결되는가?
- Register Map은 왜 필요한가?
- Base Address와 Offset은 어떻게 결합되는가?

### 1차 기준 문서
- AMD PG144 — AXI GPIO
- AMD PG079 — AXI Timer
- AMD UG1579 — Creating a Memory Map

### 원문 그림/표 후보
1. PG144 — Register Space, Table 1: GPIO_DATA / GPIO_TRI 주소
2. PG144 — **AXI GPIO Data Register, Figure 1**
3. PG079 — Register Space, Table 1: TCSR/TLR/TCR
4. PG079 — **Block Diagram of AXI Timer**

### 교육용 핵심 그림

```text
CPU Write
Address = 0x4000_0000
Data    = 0x0000_0001
       ↓
AXI Decode
       ↓
GPIO_DATA Register
       ↓
LED[0] = 1
```

### HTML
`06_memory_mapped_io.html`

---

## 07. AXI 개념

### 핵심 질문
- AXI는 CPU인가? → 아니다.
- AXI는 단순한 배선인가? → 아니다.
- AXI4, AXI4-Lite, AXI4-Stream의 차이는 무엇인가?
- VALID/READY Handshake는 어떻게 동작하는가?

### 1차 기준 문서
- AMD UG1037 — Vivado AXI Reference Guide
- ARM AMBA AXI Protocol Specification
- AMD AXI4-Stream 관련 공식 Product Guide

### 원문 그림 후보
1. UG1037 — AXI Memory-Mapped 구조 관련 그림
2. UG1037 — AXI4-Stream Master/Slave 구조
3. AMD 공식 AXI4-Stream **VALID/READY Data Transfer** timing figure
4. AMD 공식 AXI4-Lite Write / Read Timing Diagram

### HTML
`07_axi_concept.html`

---

## 08. IP · Module Reference · Custom IP

### 핵심 질문
- RTL Module과 IP는 무엇이 다른가?
- Vendor IP란 무엇인가?
- 기존 Verilog RTL을 왜 IP로 Packaging하는가?
- Module Reference는 언제 쓰는가?

### 1차 기준 문서
- AMD UG994
- AMD UG1118
- AMD UG896

### 원문 그림 후보
1. UG994 — RTL Logo on RTL Module Symbol
2. UG994 — Module Reference Wrapper 구조
3. UG1118 — **Create and Package New IP Wizard**
4. UG1118 — Package IP 화면

### HTML
`08_ip_custom_ip.html`

---

## 09. MicroBlaze 기반 FPGA SoC

### 핵심 질문
- MicroBlaze는 FPGA 어디에 존재하는가?
- BRAM에는 무엇이 저장되는가?
- AXI GPIO/UART/Timer는 CPU와 어떻게 연결되는가?
- Bitstream과 Software ELF는 어떤 관계인가?

### 1차 기준 문서
- AMD UG984
- AMD UG1579
- AMD UG994
- PG144 AXI GPIO
- PG079 AXI Timer

### 원문 그림 후보
1. UG984 — MicroBlaze Core Block Diagram
2. UG1579 — Create Block Design / Add MicroBlaze
3. UG1579 — Block Automation 결과
4. UG1579 — MicroBlaze + Peripheral Block Design 예
5. UG994 — IP Integrator Block Design

### HTML
`09_microblaze_soc.html`

---

## 10. FPGA Memory · BRAM · DSP 구조

### 핵심 질문
- LUT와 BRAM의 메모리는 무엇이 다른가?
- NPU에서는 왜 BRAM이 중요한가?
- DSP48E1은 일반 LUT 연산과 무엇이 다른가?
- 곱셈·누산을 왜 전용 DSP에서 처리하는가?

### 1차 기준 문서
- AMD UG473 — Memory Resources
- AMD UG479 — DSP48E1
- AMD UG474 — Distributed RAM

### 원문 그림 후보
1. UG473 — RAMB36 Data Flow
2. UG473 — Simple Dual-Port RAM 구조
3. UG479 — Figure 2-1: **7 Series FPGA DSP48E1 Slice**
4. UG474 — Distributed RAM 구조

### HTML
`10_fpga_memory_dsp.html`

---

## 11. Hardware Accelerator 구조

### 핵심 질문
- CPU와 Accelerator는 역할이 왜 다른가?
- 어떤 처리를 RTL Accelerator로 옮기는가?
- Control Path와 Data Path를 왜 분리하는가?
- CPU가 Accelerator를 어떻게 시작시키고 완료를 확인하는가?

### 기준 문서
- UG994 — IP Integrator
- UG1037 — AXI
- UG479 — DSP48E1
- 기존 Custom RTL / Register Map 자료

### 원문 그림 후보
- AXI4-Lite Control 구조
- AXI4-Stream Data Flow
- DSP48E1 구조
- IP Integrator Custom IP 연결 예

### HTML
`11_hardware_accelerator.html`

---

## 12. Basys3 NPU로 확장

### 핵심 질문
- 학습된 Neural Network가 FPGA NPU로 어떻게 바뀌는가?
- FP32를 그대로 사용하는 것이 왜 어려운가?
- INT8 Quantization은 어떤 의미인가?
- Weight, Activation, MAC, BRAM, DSP는 어떻게 연결되는가?

### 기준 소스
- AMD UG479 — DSP48E1
- AMD UG473 — BRAM
- AMD UG1037 — AXI
- 기존 PyTorch / Quantization 학습자료
- 이후 실제 Basys3 NPU RTL

### 원문 그림 후보
1. UG479 DSP48E1 Slice
2. UG473 BRAM 구조
3. AXI4-Stream Handshake
4. 실제 Vivado NPU Synthesis / Utilization / Timing 결과 그림

### 자체 제작 핵심 구조도

```text
Trained PyTorch Model
        ↓
Quantization
FP32 → INT8
        ↓
Weight Export
        ↓
BRAM
        ↓
MAC Array
DSP48E1
        ↓
Accumulator
        ↓
Activation
        ↓
Output
```

### HTML
`12_npu_extension.html`

---

## 6. 추천 제작 순서

```text
Source Map 확정
      ↓
01 FPGA 개요와 내부 구조
      ↓
02 FPGA · ASIC · MCU · SoC
      ↓
03 FPGA 설계 흐름
      ↓
04 SoC 개요
      ↓
05 CPU · Memory · Peripheral
      ↓
06 Memory-Mapped I/O
      ↓
07 AXI
      ↓
08 IP · Custom IP
      ↓
09 MicroBlaze SoC
      ↓
10 BRAM · DSP
      ↓
11 Hardware Accelerator
      ↓
12 NPU
```

01~03은 FPGA 기반, 04~09는 SoC 기반, 10~12는 NPU 연결부로 구분한다.

---

## 7. 각 챕터 공통 페이지 형식

```text
Hero
↓
이 챕터에서 답할 핵심 질문
↓
원문 핵심 그림
↓
그림을 쉬운 말로 해설
↓
구조 설명
↓
Basys3에서 실제로 무엇을 의미하는가
↓
다음 단계 연결
↓
핵심 정리
↓
원문 출처
↓
← 이전 · 홈 · 다음 →
```

그림은 페이지 끝에 몰아넣지 않고 설명 직후 배치한다.

---

## 8. 이미지 검증 규칙

```text
원문에서 사용할 그림 후보 수
        ↓
실제 Repository 저장 이미지 수
        ↓
HTML <img> 참조 수
        ↓
상대경로 존재 여부
        ↓
alt / figcaption 존재 여부
        ↓
출처 표시 여부
```

완료 조건:

- 깨진 이미지 링크 0개
- Notion 임시 S3 URL 0개
- 로컬 PC 절대경로 0개
- 출처 없는 원문 그림 0개
- 의미 없는 장식 이미지 최소화
- 그림과 본문 설명 불일치 0개

---

## 9. 01 챕터 제작 시 우선 확보할 그림

1. Basys3 board overview
2. UG474 — Arrangement of Slices within the CLB
3. UG474 — Diagram of SLICEM
4. UG474 — Diagram of SLICEL
5. UG474 — Fast Carry Logic Path and Associated Elements
6. UG473 — Block RAM Data Flow
7. UG479 — 7 Series FPGA DSP48E1 Slice

실제 01 본문에는 핵심 4~5개를 우선 사용하고, BRAM·DSP 상세는 10장과 중복되지 않게 간략히만 보여준다.

---

## 10. 공식 출처 URL

### AMD
- UG474 — https://docs.amd.com/r/en-US/ug474_7Series_CLB
- UG984 — https://docs.amd.com/r/en-US/ug984-vivado-microblaze-ref
- UG901 — https://docs.amd.com/r/en-US/ug901-vivado-synthesis
- UG903 — https://docs.amd.com/r/en-US/ug903-vivado-using-constraints
- UG904 — https://docs.amd.com/r/en-US/ug904-vivado-implementation
- UG994 — https://docs.amd.com/r/en-US/ug994-vivado-ip-subsystems
- UG1118 — https://docs.amd.com/r/en-US/ug1118-vivado-creating-packaging-custom-ip
- UG1579 — https://docs.amd.com/r/en-US/ug1579-microblaze-embedded-design
- PG144 — https://docs.amd.com/r/en-US/pg144-axi-gpio
- PG079 — https://docs.amd.com/r/en-US/pg079-axi-timer

### Digilent
- Basys3 Reference Manual — https://digilent.com/reference/programmable-logic/basys-3/reference-manual
- Basys3 Product / Resource Center — https://digilent.com/shop/basys-3-amd-artix-7-fpga-trainer-board-recommended-for-introductory-users/

---

## 11. 최종 기준

이 루트는 단순한 FPGA 용어사전이 아니다.

```text
공식 원문
   ↓
원문 그림
   ↓
구조 이해
   ↓
Verilog RTL과 연결
   ↓
Basys3 실제 자원과 연결
   ↓
MicroBlaze / AXI / Custom IP
   ↓
NPU / RISC-V 확장
```

즉 **“FPGA 내부 자원 → RTL → SoC → Accelerator”가 한 줄로 연결되는 개념 교재**로 제작한다.

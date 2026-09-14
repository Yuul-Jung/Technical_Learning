RTL(Register Transfer Level, 알티엘, 레지스터 전송 수준) 회로설계 교육자료를 체계적으로 구축하려는 목적이라면 아래 저장소들이 특히 좋습니다. 
단순 예제 모음보다 목차 → 이론 → RTL → Testbench(테스트벤치, 검증 코드) → FPGA 구현이 연결되는 저장소를 우선 골랐습니다.

순위	GitHub	특징	활용 추천
1	lpacher/lae	디지털회로 → Verilog → Vivado → 조합/순차 → FSM → FIFO → RAM/ROM → Timing(타이밍)	⭐⭐⭐⭐⭐ 강의자료 기준
2	coulston/Digital-Design	디지털 설계를 교과서 형태로 체계화, Datapath(데이터패스) + Control(제어) 중심	⭐⭐⭐⭐⭐ 이론 체계
3	HDLBits Write-Up	기초부터 FSM까지 작은 문제를 단계적으로 RTL 구현	⭐⭐⭐⭐⭐ 실습문제
4	FPGADude/Digital-Design	Basys3 중심 실제 FPGA 프로젝트가 많음	⭐⭐⭐⭐⭐ Basys3 실습
5	adki/RTL-Design-For-FPGA	BRAM, Clock, Verilog, Accelerator(가속기), Convolution(합성곱)	⭐⭐⭐⭐ NPU 연결
6	BrunoLevy/learn-fpga	FPGA → CPU → RISC-V(리스크-파이브) → SoC	⭐⭐⭐⭐⭐ CPU 확장
7	lowRISC/ibex	산업 수준 RISC-V CPU RTL + 검증	⭐⭐⭐⭐⭐ 최종 참고

1. 가장 먼저 보실 곳 — lpacher/lae
lpacher/lae GitHub
제가 보기에는 현재 만들고 있는 RTL 회로설계 자료의 기준 저장소로 가장 적합합니다.
구성이 상당히 좋습니다.
Verilog HDL → 조합논리 → 순차논리 → Counter → Register → PWM → Shift Register → FSM → FIFO → RAM/ROM → XDC → Timing → FPGA 구현
순서로 되어 있습니다. 특히 AMD/Xilinx(에이엠디/자일링스) Vivado(비바도)를 사용하고 Artix-7(아틱스-세븐) FPGA까지 다루기 때문에 Basys3 교육과정과 상당히 잘 맞습니다.

2. coulston/Digital-Design
coulston/Digital-Design GitHub
이 저장소는 단순 코드 모음이 아니라 Digital Design(디지털 디자인, 디지털 회로설계) 교과서 자체가 공개된 형태입니다.
특히 좋은 점은 복잡한 디지털 시스템을
Datapath(데이터패스, 데이터 연산부) + Control(컨트롤, 제어부)
관점으로 단계적으로 설계하도록 되어 있다는 점입니다. 교재, 연습문제, Instructor Manual(인스트럭터 매뉴얼, 교수자 해설), FPGA Lab(에프피지에이 랩, FPGA 실습) 11개까지 포함되어 있습니다.
향후 우리가 FSM + Datapath → UART Controller → CPU → NPU로 가는 데 상당히 좋은 이론 뼈대입니다.

3. HDLBits 기반 RTL 문제집
Nideshkanna/hdlbits-verilog-writeup
이건 강의자료보다 RTL 문제집으로 아주 좋습니다.
구성이 대략
기본문법 → Wire/Vector → 조합논리 → Multiplexer → Sequential Logic → Counter → Shift Register → FSM → 큰 회로 구성
순으로 이어집니다.
특히 각 문제에 대해 합성 가능한 Verilog와 간단한 설명을 함께 제공하고, HDLBits 원래 구조를 그대로 따라갑니다.
현재 진행 중인 ChipVerify(칩베리파이) 자료와 HDLBits를 서로 교차 검증하면 상당히 좋은 RTL 교육과정이 됩니다.

4. Basys3라면 꼭 볼 만한 FPGADude/Digital-Design
FPGADude/Digital-Design GitHub
이 저장소는 사용자님에게 특히 유용합니다.
저자가 실제로 Basys3를 주요 FPGA 학습 보드로 사용하고 있으며 저장소도 다음처럼 구성되어 있습니다.
Digital Systems Information
        ↓
Modules with Simulations
        ↓
Verilog Module
        +
Testbench
        ↓
FPGA Projects
        ↓
HDL + Constraints
        ↓
실제 FPGA 구현

Basys3 외에도 Nexys, Zybo Z7 등의 프로젝트가 들어 있습니다.

따라서 우리가 만들 자료에서

개념
→ RTL
→ Testbench
→ Vivado Simulation
→ Synthesis
→ Implementation
→ XDC
→ Basys3 동작 확인

형식을 만들 때 좋은 참고자료입니다.

5. NPU까지 생각하면 adki/RTL-Design-For-FPGA

adki/RTL-Design-For-FPGA GitHub
이 저장소는 기초를 넘어서 FPGA Accelerator(에프피지에이 액셀러레이터, FPGA 가속기) 방향입니다.
세션 방식으로

Simple Memory
→ BRAM
→ Clock
→ Verilog
→ ...
→ Accelerator
→ Convolution

등으로 발전합니다. 실제로 session_13_convolution까지 존재합니다.

즉, 우리가 장기적으로 가려는

Basys3 RTL → MAC → Convolution → CNN → NPU

연결에 참고할 가치가 큽니다.

6. CPU/RISC-V 단계 — BrunoLevy/learn-fpga

BrunoLevy/learn-fpga GitHub

이 저장소는 아주 흥미롭습니다.

교육용 FPGA에서 시작해서 직접 RISC-V CPU와 SoC(System on Chip, 시스템온칩)까지 만듭니다.

특히 FemtoRV라는 작은 RISC-V CPU는 가장 단순한 RV32I 구현이 주석 포함 약 400줄 정도의 Verilog로 되어 있어서 CPU RTL 공부용으로 상당히 좋습니다. UART, LED Matrix, OLED, SPI RAM, SD Card 등의 주변장치도 연결합니다.

이 저장소는 향후 우리가 계획한

MicroBlaze → Register Map → Custom AXI IP → RISC-V CPU

단계에서 특히 가치가 있습니다.

7. 최종적으로 봐야 할 산업 수준 RTL — lowRISC/ibex

lowRISC/ibex GitHub

처음부터 공부하기에는 너무 어렵습니다.

하지만 최종적으로는 반드시 봐야 합니다.

Ibex(아이벡스)는 실제 32-bit RISC-V CPU Core(코어)이고 저장소가

rtl/
dv/
formal/
lint/
syn/
doc/
examples/

처럼 구성되어 있습니다. 즉 RTL 코드만 있는 것이 아니라 Verification(베리피케이션, 검증), Formal Verification(포멀 검증, 형식 검증), Lint(린트, 정적 코드 검사), Synthesis(신서시스, 합성)까지 포함한 실무 RTL 프로젝트 구조입니다.

제가 추천하는 조합

하나의 GitHub만 따라가는 것보다 4개를 역할별로 결합하는 것이 훨씬 좋습니다.

① ChipVerify
   ↓
디지털회로 개념 설명

② lpacher/lae
   ↓
체계적인 RTL / Vivado 강의 흐름

③ HDLBits
   ↓
단원별 RTL 문제풀이

④ FPGADude
   ↓
Basys3 실제 구현

────────────────────────

⑤ RTL-Design-For-FPGA
   ↓
Pipelining / Accelerator / Convolution

⑥ learn-fpga
   ↓
CPU / RISC-V / SoC

⑦ lowRISC Ibex
   ↓
산업 수준 RTL / Verification

현재 만들고 있는 디지털회로설계·RTL GitHub 자료라면 lpacher/lae를 먼저 깊게 분석하는 것을 가장 추천합니다. ChipVerify보다 Vivado·XDC·Timing·FPGA 구현까지 연결되는 구조가 훨씬 강합니다. 여기에 HDLBits의 문제 체계와 FPGADude의 Basys3 실습을 결합하면, 우리가 구축하려는 자료의 뼈대가 거의 완성됩니다.

원하시면 다음 단계에서는 제가 이 7개 GitHub의 목차를 전부 분석해서 디지털회로 → RTL → FPGA → SoC → NPU → RISC-V 하나의 통합 테크트리로 재구성해드리는 것이 좋겠습니다. 그 결과를 현재 작업 중인 GitHub 공개자료의 상위 목차로 바로 사용할 수 있습니다.

# 🥤FINAL PROJECT: FPGA Vending Machine

> **A hardware implementation of a vending machine built on an FPGA using Verilog, featuring keypad input, seven-segment displays, and finite state machine (FSM) control logic.**

This project was developed as the final project for **CS M152A: Digital Design Laboratory**. The goal was to design and implement a fully functional vending machine entirely in hardware using Verilog.

The vending machine accepts snack selections through a hexadecimal keypad, displays the selected product code on dual seven-segment displays, and shows the corresponding snack name on a four-digit seven-segment display. The project demonstrates practical digital system design concepts including finite state machines, combinational and sequential logic, display multiplexing, and hardware interfacing.

---

## ✨ Features

- ⌨️ Hexadecimal keypad for snack selection
- 🔢 Two-digit seven-segment display for product codes
- 🥨 Four-digit seven-segment display for snack names
- ⚙️ Finite State Machine (FSM) to manage vending machine behavior
- 🔄 Real-time hardware updates without software intervention
- 🧩 Modular Verilog implementation for maintainability

---

## 🏗️ System Overview

```text
           User Input
        (Hexadecimal Keypad)
                  │
                  ▼
        Keypad Decoder Logic
                  │
                  ▼
      Finite State Machine (FSM)
                  │
       ┌──────────┴──────────┐
       ▼                     ▼
 Product Code         Snack Selection
  Seven-Segment         Display Logic
    Display                  │
                              ▼
                   Four-Digit Seven-Segment
                         Snack Display
```

---

## 🛠️ Technologies

| Category | Technology |
|----------|------------|
| Hardware Description Language | Verilog |
| Development Board | FPGA *(update with board name if desired)* |
| Digital Components | Hex Keypad, Seven-Segment Displays |
| Design Concepts | FSMs, Sequential Logic, Combinational Logic, Multiplexing |

---

## 📖 How It Works

1. The user enters a snack code using the hexadecimal keypad.
2. The keypad input is decoded into a binary value.
3. The finite state machine validates the selection.
4. The selected snack code is displayed on the two-digit seven-segment display.
5. The corresponding snack name is shown on the four-digit seven-segment display.
6. The vending machine waits for the next customer selection.

The design was implemented entirely in hardware, emphasizing deterministic behavior and efficient digital logic rather than software execution.

---

## 🧠 Key Concepts Demonstrated

- Finite State Machine (FSM) design
- Verilog hardware description
- Sequential circuit implementation
- Combinational logic
- Seven-segment display driving
- Keypad scanning and decoding
- Modular hardware design
- FPGA synthesis and testing

---

## 📂 Project Structure

```text
csm152a/
├── lab1/
├── lab2/
├── ...
├── final_project/
│   ├── keypad.v
│   ├── display_controller.v
│   ├── vending_machine.v
│   ├── seven_segment.v
│   └── top_level.v
└── README.md
```

*(Module names may differ from the repository.)*

---

## 🚀 Running the Project

1. Open the project in your FPGA development environment.
2. Synthesize the Verilog design.
3. Generate the bitstream.
4. Program the FPGA development board.
5. Connect the hexadecimal keypad and seven-segment displays.
6. Enter a snack code using the keypad to interact with the vending machine.

---

## 🎯 Design Challenges

Some of the interesting engineering challenges in this project included:

- Interfacing a hexadecimal keypad with FPGA logic
- Managing multiple seven-segment displays simultaneously
- Mapping binary keypad inputs to human-readable snack names
- Designing a reliable finite state machine for user interaction
- Debugging hardware timing and display behavior

---

## 📚 What I Learned

This project strengthened my understanding of:

- Digital logic design
- FPGA development workflows
- Hardware debugging techniques
- Verilog module organization
- State machine architecture
- Display controller implementation
- Designing complete digital systems from specification to hardware

---

## 🔮 Future Improvements

- 💰 Simulate coin and bill acceptance
- 💳 Add NFC or contactless payment support
- 📦 Track inventory for each product
- 🖥️ LCD or OLED display for richer product information
- 🔊 Audio feedback for successful selections
- 📊 Maintenance mode with inventory statistics
- 🌐 IoT connectivity for remote inventory monitoring

---

## 📈 Project Highlights

This project demonstrates the implementation of a complete embedded digital system using hardware description languages rather than traditional software development. By integrating user input devices, display controllers, and finite state machine logic, the design replicates the core behavior of a real vending machine while reinforcing fundamental concepts in digital system design and FPGA development.

---

## 🎓 Course Information

**Course:** CS M152A – Digital Design Laboratory

**Project:** FPGA Vending Machine

# Digital Communications Project 📡

## 📝 Project Overview

In this project, the goal was to decode a received signal with **very little prior information** (blind decoding). It was akin to solving a puzzle with only a few clues. I had to design a complete digital communication receiver chain to retrieve a hidden image from a noisy signal.

The project involved analyzing the signal's characteristics, synchronizing it in time and frequency, and demodulating it to reconstruct the transmitted data.

## 🚀 Processing Pipeline

I implemented a full receiver chain following these steps:

1.  **Signal Reception**: Analysis of the raw received signal (Amplitude vs Samples).
2.  **Matched Filtering**: Application of a Root Raised Cosine filter to maximize Signal-to-Noise Ratio (SNR).
3.  **Time Synchronization**:
    * Used envelope detection.
    * Corrected sampling timing to find the optimal decision instant (downsampling).
4.  **Frequency Synchronization**:
    * Implemented a Phase-Locked Loop (PLL) to correct phase and frequency offsets.
5.  **Demodulation & Decision**:
    * Constellation analysis identified the modulation as **QPSK**.
    * Symbol-to-bit conversion using **Gray Mapping**.
6.  **Image Reconstruction**:
    * Reassembling bits into an 8-bit encoded image.

## 🔧 Technical Details & Parameters

Key algorithms and parameters determined during the project:

* **Modulation**: QPSK (Quadrature Phase Shift Keying)
* **Filter**: Root Raised Cosine
    * *Upsampling Factor (Fse)*: 10
    * *Roll-off factor*: 0.5
    * *Filter Span*: 5
* **Frequency Synchronization (PLL)**:
    * Type: Second-order discrete-time PLL
    * Parameters: $\alpha = 1$, $\beta = 0.1$, $M = 4$
* **Output Data**:
    * Image Resolution: 128x128 pixels
    * Encoding: 8 bits
  
## Final Output
The decoded binary stream reconstructed a clearer image of a **Tiger** (128x128).

# MATLAB-Based Multi-Target Radar Signal Processing and Detection

## Overview

This project implements a MATLAB-based multi-target radar signal processing and detection system. The simulation models multiple moving targets and processes radar echoes to estimate target range and velocity.

The project demonstrates fundamental Digital Signal Processing (DSP) and radar signal processing techniques including LFM chirp generation, FFT-based range processing, Doppler processing, Range-Doppler mapping, automatic target detection, relative RCS modeling, and SNR performance analysis.

## Objectives

- Generate an LFM chirp radar waveform
- Simulate echoes from multiple moving targets
- Estimate target range using FFT-based processing
- Estimate target velocity using Doppler processing
- Generate Range-Doppler maps
- Detect multiple targets automatically
- Model different target reflection strengths using relative RCS values
- Evaluate detection performance under different SNR conditions

## Tools and Technologies

- MATLAB
- Digital Signal Processing (DSP)
- Radar Signal Processing
- Fast Fourier Transform (FFT)
- LFM Chirp
- Range Processing
- Doppler Processing
- Range-Doppler Mapping
- Relative RCS Modeling
- SNR Analysis

## System Parameters

| Parameter | Value |
|---|---:|
| Carrier Frequency | 77 GHz |
| Bandwidth | 150 MHz |
| Chirp Duration | 20 µs |
| Sampling Frequency | 20 MHz |
| Number of Chirps | 128 |
| Number of Targets | 3 |

## Target Parameters

| Target | Range | Velocity | Relative RCS |
|---|---:|---:|---:|
| Target 1 | 100 m | +20 m/s | 1.0 |
| Target 2 | 200 m | -10 m/s | 0.5 |
| Target 3 | 300 m | +5 m/s | 0.2 |

## Processing Flow

1. Generate the LFM chirp waveform.
2. Simulate target delays and Doppler shifts.
3. Generate received radar echoes from multiple targets.
4. Add noise at different SNR levels.
5. Perform range FFT processing.
6. Perform Doppler FFT processing.
7. Generate the Range-Doppler map.
8. Detect target peaks automatically.
9. Model different target reflection strengths using relative RCS.
10. Evaluate detection performance under different SNR conditions.

## Results

The simulation successfully identifies the three modeled targets at their corresponding range and velocity locations.

### Range Profile

The range profile shows peaks corresponding to the simulated targets at approximately 100 m, 200 m, and 300 m.

### Range-Doppler Map

The Range-Doppler map provides simultaneous visualization of target range and velocity.

### Automatic Target Detection

The automatic detection stage identifies the simulated targets at their corresponding range and velocity coordinates.

### SNR Performance

Detection performance was evaluated under multiple SNR conditions to analyze the effect of noise on radar target detection.

### Relative RCS Comparison

Different relative target reflection strengths were modeled to represent differences in target echo strength.

## How to Run

1. Open MATLAB.
2. Download or clone this repository.
3. Open `radar_multiple_targets.m`.
4. Run the script.
5. Observe the generated radar range profile, Range-Doppler map, automatic target detection results, SNR analysis, and relative RCS comparison.

## Project Structure

```text
MATLAB-Multi-Target-Radar-Signal-Processing/
│
├── README.md
└── radar_multiple_targets.m

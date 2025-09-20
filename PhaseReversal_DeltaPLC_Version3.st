// --- Variable Declarations ---
// VAR
//   Analog_PhaseA : REAL;         // Analog input for phase A
//   Analog_PhaseB : REAL;         // Analog input for phase B
//   Analog_PhaseC : REAL;         // Analog input for phase C
//   Prev_PhaseA : REAL := 0.0;    // Previous sample for phase A
//   Prev_PhaseB : REAL := 0.0;    // Previous sample for phase B
//   Prev_PhaseC : REAL := 0.0;    // Previous sample for phase C
//   PhaseA_ZC : BOOL := FALSE;    // Zero crossing detected for A
//   PhaseB_ZC : BOOL := FALSE;    // Zero crossing detected for B
//   PhaseC_ZC : BOOL := FALSE;    // Zero crossing detected for C
//   PhaseOrder : INT := 0;        // Stores detected phase order (1:ABC, 2:ACB, etc.)
//   PhaseReversal : BOOL := FALSE;// Event flag for phase reversal
//   Digital_Output : BOOL := FALSE;// Output to indicate phase reversal
//   Sample_Counter : INT := 0;    // Used for timing/sequence window
// END_VAR

// --- Zero Crossing Detection (rising edge) ---
PhaseA_ZC := (Prev_PhaseA < 0.0) AND (Analog_PhaseA >= 0.0);
PhaseB_ZC := (Prev_PhaseB < 0.0) AND (Analog_PhaseB >= 0.0);
PhaseC_ZC := (Prev_PhaseC < 0.0) AND (Analog_PhaseC >= 0.0);

// --- Store current samples for next scan ---
Prev_PhaseA := Analog_PhaseA;
Prev_PhaseB := Analog_PhaseB;
Prev_PhaseC := Analog_PhaseC;

// --- Phase Sequence Detection Logic ---
// After detecting a zero crossing, determine which phase crosses first, second, and third.
// The code below uses a simple counter for a detection window.
IF PhaseA_ZC OR PhaseB_ZC OR PhaseC_ZC THEN
    Sample_Counter := 1; // Start detection window
END_IF

IF Sample_Counter > 0 THEN
    // Detect the order of zero crossings
    IF PhaseA_ZC THEN
        PhaseOrder := 1; // A first
    ELSIF PhaseB_ZC THEN
        PhaseOrder := 2; // B first
    ELSIF PhaseC_ZC THEN
        PhaseOrder := 3; // C first
    END_IF
    Sample_Counter := Sample_Counter + 1;
    // After a few scans, evaluate phase order
    IF Sample_Counter > 10 THEN // 10 scans window
        // Compare current phase order with expected (e.g., ABC)
        // If out of sequence (e.g., ACB, BAC, CBA), set reversal
        IF (PhaseOrder <> 1) THEN // Assuming ABC is normal, non-1 is reversal
            PhaseReversal := TRUE;
            Digital_Output := TRUE;
        ELSE
            PhaseReversal := FALSE;
            Digital_Output := FALSE;
        END_IF
        Sample_Counter := 0; // Reset for next detection
    END_IF
END_IF

// --- Output digital signal on phase reversal detection ---
// Digital_Output can be mapped to a physical output coil
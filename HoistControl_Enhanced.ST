// --- Variable Definitions (Rockwell Tags) ---
// BOOL Hoist_Run;          // Hoist run command
// INT  Speed_Setpoint;     // Desired speed from operator/HMI
// INT  Motor_Speed;        // Actual motor speed output to VFD
// BOOL Motor_On;           // Motor enable output
// BOOL Hoist_Up;           // Up direction command
// BOOL Hoist_Down;         // Down direction command
// BOOL Overload;           // Overload trip input
// BOOL Up_Limit;           // Upper limit switch (TRUE = at limit)
// BOOL Down_Limit;         // Lower limit switch (TRUE = at limit)
// INT  Ramp_Rate := 10;    // Speed ramp increment per scan
// BOOL VFD_Fault;          // Fault feedback from VFD
// BOOL VFD_Ready;          // VFD ready status

// --- Safety Interlocks ---
IF Overload OR VFD_Fault OR (Hoist_Up AND Up_Limit) OR (Hoist_Down AND Down_Limit) THEN
    Motor_On := FALSE;           // Disable motor
    Motor_Speed := 0;            // Stop motor
ELSE
    IF Hoist_Run AND VFD_Ready THEN
        Motor_On := TRUE;
        // --- Speed Ramping ---
        IF Motor_Speed < Speed_Setpoint THEN
            Motor_Speed := MIN(Speed_Setpoint, Motor_Speed + Ramp_Rate);
        ELSIF Motor_Speed > Speed_Setpoint THEN
            Motor_Speed := MAX(Speed_Setpoint, Motor_Speed - Ramp_Rate);
        END_IF;
        // --- Direction Control ---
        IF Hoist_Up AND NOT Up_Limit THEN
            // Set direction output for UP (e.g., Direction := TRUE)
        ELSIF Hoist_Down AND NOT Down_Limit THEN
            // Set direction output for DOWN (e.g., Direction := FALSE)
        END_IF;
    ELSE
        Motor_Speed := 0;
        Motor_On := FALSE;
    END_IF;
END_IF;

// --- Additional diagnostics (optional) ---
// Use status tags for HMI display: Hoist_Status, Fault_Code, etc.
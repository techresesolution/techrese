// --- Variable Declarations ---
// VAR
//   Hoist_Run : BOOL;           // Hoist run command
//   Speed_Setpoint : INT;       // Desired speed
//   Motor_Speed : INT;          // Actual motor speed output
//   Motor_On : BOOL;            // Motor enable output
//   Hoist_Up : BOOL;            // Up direction command
//   Hoist_Down : BOOL;          // Down direction command
//   Overload : BOOL;            // Overload trip input
//   Up_Limit : BOOL;            // Upper limit switch (TRUE = at limit)
//   Down_Limit : BOOL;          // Lower limit switch (TRUE = at limit)
//   Ramp_Rate : INT := 10;      // Ramp increment per scan
//   VFD_Fault : BOOL;           // VFD fault input
//   VFD_Ready : BOOL;           // VFD ready input
// END_VAR

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
// Implement status/fault code logic as needed for HMI/SCADA

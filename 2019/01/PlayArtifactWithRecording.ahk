#Persistent
#SingleInstance force

Hotkey, !F8, ReloadScript

exe_name := "dcg.exe"
is_recording := 0

; Launch Artifact
Run steam://rungameid/583950

; Wait for the game to load 
Sleep, 5000

SetTimer, check_artifact_state, 3000
return


check_artifact_state:
    ; If we already started recording and the exe is closed then we stop the recording
    if(is_recording = 1)
    {
        ; Stop Recording
        if !ProcessExist(exe_name)
        {
            Send !{F9}
            ExitApp
        }
    }
    else 
    {
        ; Start recording
        if ProcessExist(exe_name)
        {
            Send !{F9}
            is_recording := 1
        }
    }
return

ReloadScript:
    Reload
return

ProcessExist(Name){
	Process,Exist,%Name%
	return Errorlevel
}

; Remappings
Enter::Space
PgDn::End


gui, 1: New, , AutoZZZ Power State Timer
Gui, 1: Color, 884488
gui, 1:add, button, x25 y135 h20 w130 gSetToSleep, &Sleep
gui, 1:add, button, x25 y160 h20 w130 gSetToHibernate, &Hibernate
gui, 1:add, button, x25 y185 h20 w130 gSetToShutdown, Shut&down
gui, 1:add, button, x25 y210 h20 w130 gSetToMonitorOff, &Turn Off Monitor
gui, 1:add, button, x25 y250 h20 w130 gexit, Exit Script
Gui, 1:Add, Picture, x10 y5 w170 h170 +BackgroundTrans, bg.png
Gui, 1:Add, Text, x0 y115 w180 +center +BackgroundTrans, select an action to schedule

Gui, 2: New, ,Set Duration
Gui, 2: Color, 151515
Gui, 2:Add, Text, cFFFFFF +center w180 x0 y10,Enter Duration
Gui, 2:Add, Text, cFFFFFF +center w180 x0 y35,HH   MM   SS
Gui, 2:Add, Edit, x55 y50 w20 Limit2 Number +center vDurationInHours,
Gui, 2:Add, Edit, x80 y50 w20 Limit2 Number +center vDurationInMinutes,
Gui, 2:Add, Edit, x105 y50 w20 Limit2 Number +center vDurationInSeconds,

Gui, 2:Add, Button, Default +center x20 y90 w140 gShowCounter 0x80, SET && GO


Gui, 3: New, ,Countdown
Gui, 3: Color, 151515
Gui, 3:Add, Text, cFFFFFF x0 y15 w200 0x201 +center vcounterDesc, -----------------------------------
Gui, 3:Add, Text, cFFFFFF x0 y35 w200 0x201 +center vcounterFormatted, --
gui, 3:Add, Button, cFFFFFF x10 y65 w180  +center gexit, Cancel

Gui,1:Show, w185 h290

return 

setToSleep:
setToHibernate:
setToMonitorOff:
setToShutdown:
{
  global OperationFunc
  global OperationName
  OperationFunc := StrReplace(A_ThisLabel, "setTo", "do")
  OperationName := StrReplace(A_ThisLabel, "setTo", "")

  Gosub, askFTime
  return
}

askFTime:
{
  Gui, 1:Destroy,
  Gui, 2:Show, w180 h120
  GuiControl, 2:focus, DurationInMinutes
  return
}

showCounter:
Gui, 2:submit,nohide
{
  global OperationName
  GuiControlGet, DurationInMinutes
  GuiControlGet, DurationInSeconds
  GuiControlGet, DurationInHours

  if(!DurationInSeconds && !DurationInMinutes && !DurationInHours) {
    MsgBox,, Nope, Please enter duration.
    return
  }
  maximized := False
  Duration := (emptyToZero(DurationInHours) * 3600 + emptyToZero(DurationInMinutes) * 60 + emptyToZero(DurationInSeconds)) * 1000
  Now := A_TickCount
  EndAt := Now + Duration

  Gui, 2:Destroy
  Gui, 3:Show, w200 h95

  GuiControl, 3:Text, counterDesc,% "Time remained for " . OperationName . " " . remainerFormatted
  while (A_TickCount < EndAt) {
    remainer := EndAt - A_TickCount
    remainerFormatted := milli2hms(remainer)
    GuiControl, 3:Text, counterFormatted, %remainerFormatted%
    if(remainer < 10000 && !maximized) {
      Gui, 3:Restore
      maximized := True
    }
    Sleep, 200
  }

  ;Add a 10 sec filter to prevent double trigger in case PC sleeps by itself.
  ;Sleep, 13000 ;To test the filter
  remainer := EndAt - A_TickCount
  if(-10000 < remainer) {
    Gosub, finish
    return
  }

  MsgBox, Looks like your PC slept before script timer.
  Gosub, exit
  return
}

finish:
{
  Gosub, %OperationFunc%
  Gosub, exit
  return
}

doHibernate:
{
  DllCall("PowrProf\SetSuspendState", "int", 1, "int", 1, "int", 1)
  return
}


doShutdown:
{
  Shutdown, 5
  return
}


doMonitorOff:
{
  SendMessage 0x112, 0xF170, 2,,Program Manager
  return
}

doSleep:
{
  DllCall("PowrProf\SetSuspendState", "int", 0, "int", 1, "int", 1)
  return
}


guiclose:
guiescape:
2guiclose:
2guiescape:
3guiclose:
3guiescape:
exit:
{
  global OperationFunc
  OperationFunc = guiclose
  exitapp
}


milli2hms(milli, ByRef hours=0, ByRef mins=0, ByRef secs=0, secPercision=0)
{
  SetFormat, FLOAT, 0.%secPercision%
  milli /= 1000.0
  secs := mod(milli, 60)
  SetFormat, FLOAT, 0.0
  milli //= 60
  mins := mod(milli, 60)
  hours := milli //60
  if(secs < 10) {
    secs := "0" . secs
  }
  if(mins < 10) {
    mins := "0" . mins
  }
  if(hours < 10) {
    hours := "0" . hours
  }
  
  
  return hours . ":" . mins . ":" . secs
}

emptyToZero(str)
{
  if(str = "") {
    return 0
  }
  return str
}

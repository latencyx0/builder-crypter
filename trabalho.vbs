Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.CreateTextFile("output.bat", True)
objFile.WriteLine("@echo off")
objFile.WriteLine("echo hello oi")
objFile.WriteLine("pause")
objFile.Close

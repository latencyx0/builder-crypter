Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.CreateTextFile("output.txt", True)
objFile.WriteLine("Hello, World!")
objFile.Close

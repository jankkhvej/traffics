@echo off
cls
D:\CL87\BIN\tasm.exe /m support.asm
D:\cl87\BIN\clipper errorsys.prg -l
D:\cl87\BIN\clipper traffics.prg
if not ERRORLEVEL 1 D:\Cl87\BIN\tlink traffics+errorsys+support,traffics,nul,D:\cl87\LIB\clipper+D:\cl87\LIB\extend

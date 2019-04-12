del *.rpt
rem del *.sof
rem del *.pof
rem del *.ttf
rem del *.jbc
rem del *.hif
rem del *.mmf
rem del *.ndb
del *.hex
del *.fit
rem del *.snf
rem del *.idx
del *.pin
rem del *.jam
del *.db?
rem del *.scr
rem del *.sum
rem del *.xdb
rem del *.edf
rem del *.edo
del *.log
rem del *.his
rem del *.vmo
rem this is for quartus
rem del *.ini
rem del *.fsf
rem del *.eqn
rem del *.esf
rem del *.psf
rem del *.qws
rem del *.ssf
rem rem del *.fsf
rem del *.qws
del *.bak
del vhdl_files\applLogic\*.bak
del vhdl_files\libs\*.bak
del vhdl_files\logic\*.bak
del vhdl_files\logic\gui\*.bak
del vhdl_files\peripherals\*.bak
del vhdl_files\roms\*.bak
del vhdl_files\utils\*.bak
rem del *.xrf
del *.done
del *.smsg
del *.summary
del /Q /F /s db
rmdir /Q /S db
del /Q /F /s incremental_db
rmdir /Q /S incremental_db
rd db
rd incremental_db
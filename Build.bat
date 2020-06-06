@echo OFF
@cd /d "%~dp0"

rem set path=%path%;%windir%\Microsoft.NET\Framework\v4.0.30319
rem set path=%path%;"C:\Program Files (x86)\MSBuild\12.0\Bin"

set path=%path%;"C:\VS2017\MSBuild\15.0\Bin"
set LOGGING=^
/flp1:logfile=build_msbuild.log;verbosity=detailed ^
/flp2:logfile=build_warnings.log;warningsonly;verbosity=detailed ^
/flp3:logfile=build_errors.log;errorsonly;verbosity=detailed 

 msbuild.exe ..\ISP.Targets_.proj /t:MRApps_build /m:4 /p:Configuration=release,GENERATE_ASSEMBLYINFO=1 /p:CodeContractsRunCodeAnalysis=false,RunCodeAnalysis=Never,CodeContractsReferenceAssembly=DoNotBuild,SUPRESS_CA=1 %LOGGING% 
rem pause

rem msbuild.exe ..\ISP.Targets_.proj /t:UpdateBuildNumber /m:4 /p:Configuration=release,GENERATE_ASSEMBLYINFO=0 /p:CodeContractsRunCodeAnalysis=false,RunCodeAnalysis=Never,CodeContractsReferenceAssembly=DoNotBuild,SUPRESS_CA=1 %LOGGING% 
rem pause

rem msbuild.exe ..\ISP.Targets_.proj /t:Localization_Full /m:4 /p:Configuration=release %LOGGING% 
rem pause

rem msbuild.exe ..\ISP.Targets_.proj /t:ISP_Package_Full /m:4 %LOGGING% 
rem pause

rem msbuild.exe ..\ISP.Targets_.proj /t:ISP_ISO_Staging_Full /m:4 %LOGGING% 
rem pause

rem msbuild.exe ..\ISP.Targets_.proj /t:Portal_server_Pack /m:4 %LOGGING%
pause
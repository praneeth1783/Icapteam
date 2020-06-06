set LOGGING=^
/flp1:logfile=build_msbuild.log;verbosity=detailed ^
/flp2:logfile=build_warnings.log;warningsonly;verbosity=detailed ^
/flp3:logfile=build_errors.log;errorsonly;verbosity=detailed

"C:\VS2017\MSBuild\15.0\Bin\MSBuild.exe" "D:\HIT_ICAP_ISP\CT_SW_Tools\ICAP_Installer\ICAP_Installer.sln" /nologo /p:PortalISOVersion=13.1.2.01303 /p:ConcertoISOVersion=12.0.1.02303 /p:PortalBundleVersion=13.1.2.01303 /p:ConcertoBundleVersion=12.0.1.02303 /p:BundleVersion=12.0.37.4002 /t:Clean,Build /p:RunWixToolsOutOfProc=true /p:platform="x86" /p:configuration="Release" /p:_MSDeployUserAgent="TFS_0cb76a25-2556-4bd6-adaa-5e755ac07355_build_1713_0" %LOGGING% 
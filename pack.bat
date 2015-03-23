echo this is compile.bat v0.3

setlocal

set name=consist
set pkgrel=2

rd /s /q pkg
md pkg
md pkg\atx300\%name%
cp -av consistometer.exe pkg/atx300/%name%/
cp -av consistometer.ini pkg/atx300/%name%/
;rem md pkg\atx300\lingual\data\cs
;rem cp -av control.cs pkg/atx300/lingual/data/cs/
md pkg\atx300\loader\data
cp -av consist.loader pkg/atx300/loader/data/consist
cp atxpkg_backup pkg/.atxpkg_backup

hg parents --template "{latesttag}" >.version
set /p version=<.version
rm .version
set version=%version:~1%

;rem no, i can't do this inside of the if for some reason - FUCK WINDOWS!
awk "BEGIN {print strftime(\"%%Y%%m%%d%%H%%M%%S\")}" >.datetime
set /p datetime=<.datetime
rm .datetime

if "%1" == "" (
	echo devel version %datetime%

	set name=%name%.dev
	set version=%datetime%
	set upload=atxpkg@atxpkg-dev.asterix.cz:atxpkg/
) else if "%1" == "release" (
	echo release version %version%
	set upload=atxpkg@atxpkg.asterix.cz:atxpkg/
) else (
	echo unknown parameter!
	goto end
)

set pkg_fn=%name%-%version%-%pkgrel%.atxpkg.zip

rm %pkg_fn%

cd pkg
zip -r ../%pkg_fn% .
cd ..

rd /s /q pkg

pscp %pkg_fn% %upload%

:end
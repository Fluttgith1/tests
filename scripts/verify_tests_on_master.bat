@ECHO ON

REM Default values.
SET SHARDS=1
SET SHARD_INDEX=0

REM Parse the arguments for variables.
:parse
IF "%1"=="" GOTO endparse
IF "%1"=="--shards" (
    SET SHARDS=%2
)
IF "%1"=="--shard-index" (
    SET SHARD_INDEX=%2
)

SHIFT
GOTO parse
:endparse

REM Fetch Flutter.
git clone https://github.com/flutter/flutter.git || GOTO :END
CALL flutter\bin\flutter doctor -v || GOTO :END
@ECHO ON

SET PATH=%PATH%;%CD%\flutter/bin;%CD%\flutter\bin\cache\dart-sdk\bin

@ECHO.
@ECHO.

CD flutter\dev\customer_testing
CALL pub get || GOTO :END
@ECHO ON
CD ..\..\..

REM Now run the tests a bunch of times to try to find flakes (tests that sometimes pass
REM even though they should be failing).
@ECHO.
CALL dart flutter\dev\customer_testing\run_tests.dart --repeat=15 --skip-template --shards %SHARDS% --shard-index %SHARD_INDEX% --verbose registry/*.test || GOTO :END
@ECHO ON

@ECHO.
@ECHO.
@ECHO Testing complete.
GOTO :EOF

:END
@ECHO.
@ECHO.
@ECHO Testing failed.
EXIT /B 1

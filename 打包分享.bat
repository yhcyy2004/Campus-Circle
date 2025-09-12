@echo off
echo 正在准备项目分享包...

:: 创建临时目录
if exist "campus_project_share" rmdir /s /q "campus_project_share"
mkdir "campus_project_share"

:: 复制必需的文件夹
echo 复制核心代码...
xcopy "lib" "campus_project_share\lib" /E /I /H /Y
xcopy "android" "campus_project_share\android" /E /I /H /Y
xcopy "web" "campus_project_share\web" /E /I /H /Y
xcopy "windows" "campus_project_share\windows" /E /I /H /Y
xcopy "assets" "campus_project_share\assets" /E /I /H /Y
xcopy "test" "campus_project_share\test" /E /I /H /Y
xcopy "api" "campus_project_share\api" /E /I /H /Y

:: 复制必需的配置文件
echo 复制配置文件...
copy "pubspec.yaml" "campus_project_share\"
copy "pubspec.lock" "campus_project_share\"
copy "analysis_options.yaml" "campus_project_share\"
copy ".metadata" "campus_project_share\"
copy "build.yaml" "campus_project_share\"
copy "README.md" "campus_project_share\"

echo 项目打包完成！
echo 文件夹：campus_project_share
echo 请将此文件夹压缩后分享给团队成员
pause
myworkspace=xxx.xcworkspace # 替换workspace的名字
myscheme=xxx # 替换scheme的名字
xcodebuild -workspace $myworkspace -scheme $myscheme clean&&
xcodebuild -workspace $myworkspace -scheme $myscheme \
-configuration Debug \
| xcpretty -r json-compilation-database -o compile_commands.json&&
oclint-json-compilation-database -e Pods -- \
-report-type html -o oclint_result.html \
-rc LONG_LINE=300 \
-max-priority-1=100000 \
-max-priority-2=100000 \
-max-priority-3=100000; \
rm compile_commands.json;
if [ -f ./oclint_result.html ]; then echo '-----分析完毕-----'
else echo "-----分析失败-----"; fi
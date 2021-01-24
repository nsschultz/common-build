dotnet build
dotnet sonarscanner begin \
  /k:$MAIN_PROJ \
  /n:$SONAR_KEY \
  /d:"sonar.host.url=http://sonarqube.schultz.local/" \
  /d:"sonar.cs.opencover.reportsPaths=opencovercoverage.xml" \
  /d:"sonar.coverage.exclusions=Migrations/*.cs"
minicover instrument \
  --assemblies "$MAIN_PROJ.UnitTests/bin/**/*.dll" \
  --sources "$MAIN_PROJ/**/*.cs" \
  --tests "$MAIN_PROJ.UnitTests/**/*.cs"
minicover reset
dotnet test --no-build
minicover uninstrument
minicover opencoverreport
dotnet publish -c Release -o /app/out -v minimal
dotnet sonarscanner end
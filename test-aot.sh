#!/bin/sh

function cleanup() {
  local -r orig_code=$?

  if [ -f src/test.ts.bk ]; then
    mv src/test.ts.bk src/test.ts
  fi
  if [ -f tsconfig.aottest.json ]; then
    rm tsconfig.aottest.json
  fi
  node node_modules/rimraf/bin.js src/**/*.ngfactory.* src/**/*.ngsummary.* src/**/*.shim.ngstyle.ts
  node node_modules/rimraf/bin.js e2e/**/*.ngfactory.* e2e/**/*.ngsummary.* e2e/**/*.shim.ngstyle.ts
  find src/ -name "*.css" -exec rm {} \; && git checkout -- *.css

  exit $orig_code
}

trap cleanup EXIT

# 1. Create ngsummary.ts
cat << EOF > tsconfig.aottest.json
{
  "extends": "./tsconfig.json",
  "angularCompilerOptions": {
    "genDir": ".",
    "debug": false,
    "enableSummariesForJit": true
  }
}
EOF

./node_modules/.bin/gulp compile-sass
./node_modules/.bin/ngc -p tsconfig.aottest.json

# 2. Create an entry file for AOT testing
echo "import { AppModuleNgSummary } from './app/app.module.ngsummary';" > src/test_aot.ts
sed -E "s/platformBrowserDynamicTesting\(\)/platformBrowserDynamicTesting(), () => [AppModuleNgSummary],/g" src/test.ts >> src/test_aot.ts
mv src/test.ts src/test.ts.bk && mv src/test_aot.ts src/test.ts

# 3. Run karma
./node_modules/.bin/ng test --single-run

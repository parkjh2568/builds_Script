#!/bin/bash

echo '
{
    "include": [
      "src/**/*.ts",
    ],
    "compilerOptions": {
      "module": "CommonJS",
      "target": "es2020",
      "lib": ["es2020", "DOM"],
      "sourceMap": true,
      "esModuleInterop": true,
      // "noImplicitAny": true,   //any 비허용
      "noImplicitAny": false, //any허용
      "locale": "ko",
      "pretty": true,
      "allowJs": true,
      "rootDir": "src",
      "outDir": "dist",
    },
    "exclude": [
      "node_modules",
      "/dist/**/*"
    ],
  }
' >> tsconfig.json

echo '{
  "name": "write-back",
  "version": "0.1.0",
  "description": "",
  "main": "app.js",
  "scripts": {
    "start": "tsc-watch --onSuccess \"node dist/app.js\""
  },
  "dependencies": {
    "express": "^4.17.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.11",
    "@types/node": "^14.14.32",
    "ts-node": "^10.4.0",
    "tsc-watch": "^4.2.9",
    "typescript": "^4.2.3"
  }
}
' >> package.json

npm i

mkdir src

echo '
import express, {Request, Response} from "express"

const app = express()
const port = 3000

app.get("/", (req:Request, res:Response)=>{
    res.send("Hello World!")
})

app.listen(port, ()=>{
    console.log(`Server Run in ${port}`)
})
' >> ./src/app.ts

cd src

mkdir api
cd api
mkdir routes
mkdir controllers

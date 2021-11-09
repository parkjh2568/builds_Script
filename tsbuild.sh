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
    "dotenv": "^10.0.0",
    "express": "^4.17.1",
    "mariadb": "^2.5.5",
    "mysql2": "^2.3.3-rc.0",
    "sequelize": "^6.9.0",
    "sequelize-auto": "^0.8.5"
  },
  "devDependencies": {
    "@types/dotenv": "^8.2.0",
    "@types/express": "^4.17.11",
    "@types/node": "^14.14.32",
    "@types/sequelize": "^4.28.10",
    "ts-node": "^10.4.0",
    "tsc-watch": "^4.2.9",
    "typescript": "^4.2.3"
  }
}

' >> package.json

npm i

mkdir src

echo 'import express, {Request, Response} from "express"
import { apiRouter } from "./api/apiRouter"

const app = express()
const port = 3000

app.get("/", (req:Request, res:Response)=>{
    res.send("Hello World!")
})

app.use("/api", apiRouter)

app.listen(port, ()=>{
    console.log(`Server Run in ${port}`)
})
' >> ./src/app.ts

echo 'MYSQL_USER=sa
MYSQL_DATABASE=my_db
MYSQL_PASSWORD=helloworld
MYSQL_SERVER=127.0.0.1
MYSQL_PORT=3306
MYSQL_DIALECT=mariadb' >> .env

cd src

mkdir api
mkdir migrations

echo "import { Sequelize, Options } from 'sequelize';
import dotenv from 'dotenv';
dotenv.config();

class options implements Options{
   dialect!: 'mariadb';
   username!: string;
   password!: string;
   host!: string;
   port!: number;
}        

async function createDatabase(db_name:string) {
   const createDBOptions = new options();
   createDBOptions.username = process.env.MYSQL_TENANT_USER || 'root';
   createDBOptions.password = process.env.MYSQL_TENANT_PASSWORD || 'your password';
   createDBOptions.dialect = 'mariadb';
   createDBOptions.host = process.env.MYSQL_TENANT_SERVER || 'localhost';
   createDBOptions.port = Number(process.env.MYSQL_TENANT_PORT) || 3306

   const dbCreateSequelize = new Sequelize(createDBOptions);

   console.log('======Create DataBase ======');

   await dbCreateSequelize.getQueryInterface().createDatabase(db_name)
      .then(() => {
         console.log('✅db create success!');
      })
      .catch((e) => {
         console.log('❗️error in create db : ', e);
      })
}

export {createDatabase}
// createDatabase('ppc_test_4')
//./node_modules/.bin/ts-node ./src/migration/create-db.ts 로 디비생성실행" >> ./migrations/create_db.ts



echo '

//Sequelize-auto를 이용한 커멘드로 만든 init-models 활용
//yarn sequelize-auto -o "./src/db/TanantModels" -d 디비이름 -h 이비서버주소 -u 유저 -x 비밀번호 -p 포트 -e 사용디비(mysql, mariadb, mssql) -l 원하는코드타입(ts, js.... 생략시 js)

// import * as db_PacsPlusModels from "../db/PacsPlusModels/init-models"
// import * as db_TenantModels from "../db/TanantModels/init-models"
// import * as db_mysql_PPCModels from "../db_mysql/ppc_template/init-models"
// import * as db_mysql_TenantModels from "../db_mysql/TenantModels/init-models"
import {createTable} from "./create_table"
import {createDatabase} from "./create_db"
import readline from "readline"




//외부입력받는 단자 선언-------------------------------------------------------------------------------------
const r1 = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
});

let n, m, k;
  
// 입력 한번에 변수 하나씩 저장하는 함수
const generatorSequence = function* () {
  console.log("Type wanted database name:")
  n = yield;
  console.log("Type wanted model:(1. PacsPlusModel(db), 2. TenantModels(db), 3. ppc_template(db_mysql), 4. TenantModel(db_mysql))")
  m = yield;
  return true; //생략가능
};

async function create(db_name:string, model_code:Number) {
    await createDatabase(db_name)
    switch (model_code){
        // case 1:
        //     createTable(db_PacsPlusModels.initModels, db_name);
        //     break;
        // case 2:
        //     createTable(db_TenantModels.initModels, db_name);
        //     break;
        // case 3:
        //     createTable(db_mysql_PPCModels.initModels, db_name);
        //     break;
        // case 4:
        //     createTable(db_mysql_TenantModels.initModels, db_name);
        //     break;
        default:
            console.log("OH! Something happening")
    }
}

const generator = generatorSequence();
generator.next(); // n = yield를 실행하고 기다린다

// 이벤트 리스너 
r1.on("line", (line) => {
    if (n)
    {
        if (Number(line) > 0 && Number(line) <= 4)
        {
            let done = generator.next(line).done; // 더 이상 yield가 없으면 true 리턴
            if (done) r1.close();
        }
        else
            console.log("Error:: Plz input correct value")
    }
    else
        generator.next(line).done; // 더 이상 yield가 없으면 true 리턴
});

r1.on("close", () => {
    create(n, Number(m));
  console.log(`n,m: ${n}, ${m}`);
});


//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------




// const db_name = "0003test"

// async function create() {
//     await createDatabase(db_name)
//     createTable(local_db_ppc_template.initModels, db_name);
// }

// create();


' >> ./migrations/create_all_in_one.ts

echo '// //./node_modules/.bin/ts-node ./src/migration/create-table.ts //이작업시 세팅된 디비에 테이블 만들어짐

import { sequelize2 } from "./DBConnection"

function createTable(initModels:any, db_name:string) {
    const sequelize = sequelize2(db_name);
    initModels(sequelize);
    sequelize.sync()
        .then(() => {
            console.log("✅Success Create User Table");
        })
        .catch((err) => {
            console.log("❗️Error in Create User Table : ", err);
        })
}

export {createTable}
// createTable(db_PacsPlusModels.initModels)' >> ./migrations/create_table.ts

echo 'import {Sequelize, Options} from "sequelize";
import {config} from "dotenv"

// require("dotenv").config();
config();
const seq = new Sequelize(
  process.env.MYSQL_DATABASE ?? "",
  process.env.MYSQL_USER ?? "",
  process.env.MYSQL_PASSWORD ?? "",
  {
    host: process.env.MYSQL_SERVER ?? "",
    port: Number(process.env.MYSQL_PORT ?? ""),
    dialect: process.env.MYSQL_DIALECT ?? "" ,
    dialectOptions: {
      encrypt: false,
      options: {
        enableArithAbort: true,
        trustServerCertificate: true,
        requestTimeout: 300000
      }
    },

    define: {
      freezeTableName: true,
      timestamps: false
    },
    pool: {
      max: 20,
    },
    logging: false
  } as Options
)


function sequelize2(db: string): Sequelize {
  return new Sequelize(
    db ?? "",
    process.env.MYSQL_USER ?? "",
    process.env.MYSQL_PASSWORD ?? "",
    {
      host: process.env.MYSQL_SERVER ?? "",
      dialect: "mariadb",
      port: Number(process.env.MYSQL_PORT ?? ""),
    } as Options
  )
}

function sequelizeMy_db(db:string, user:string, ps:string, host:string, port:string, dialect:string) {
  return (new Sequelize(
      db ?? "",
      user ?? "",
      ps ?? "",
      {
          host: host ?? "",
          dialect: dialect,
          port: Number(port ?? ""),
          dialectOptions: {
            encrypt: false,
            options: {
              enableArithAbort: true,
              trustServerCertificate: true,
              requestTimeout: 300000
            }
          },
          define: {
            freezeTableName: true,
            timestamps: false
          },
          pool: {
            max: 20,
          },
          logging: false
      } as Options

  ))
}

async function connection_test_sequelize (sequelize_model:Sequelize) {
  await sequelize_model.authenticate()
    .then(async () => {
      console.log("connection success");
    })
    .catch((e) => {
      console.log("TT : ", e);
    })
}


export {seq as tenantDBConnection, sequelizeMy_db, sequelize2 }
' >> ./migrations/DBConnection.ts


cd api
mkdir routes
mkdir controllers

echo 'import express, {Request, Response} from "express"
import { wow1 } from "../controllers/userController"

const router = express.Router()

router.get("/", (req:Request, res:Response)=>{
    res.send("oh hi im userRouter")
})

router.get("/wow", wow1)

export {router as userRouter}
' >> ./routes/userRouter.ts

echo 'import {Request, Response} from "express"

function wow(req:Request, res:Response){
    console.log("Im user controller")
    res.send("im user Controller")

}

export {wow as wow1}' >> ./controllers/userController.ts

echo 'import express, {Request, Response} from "express"
import { userRouter } from "./routes/userRouter"

const router = express.Router()

router.get("/",(req:Request,res:Response)=>{
    console.log("Hello api!")
    res.send("Hello api!")
})

router.use("/user", userRouter)

export {router as apiRouter}
' >> ./apiRouter.ts

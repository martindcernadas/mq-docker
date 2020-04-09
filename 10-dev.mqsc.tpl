* © Copyright IBM Corporation 2017, 2019
*
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.

* Developer queues
DEFINE QLOCAL('DEV.QUEUE.1') REPLACE
DEFINE QLOCAL('DEV.QUEUE.2') REPLACE
DEFINE QLOCAL('DEV.QUEUE.3') REPLACE
DEFINE QLOCAL('DEV.DEAD.LETTER.QUEUE') REPLACE
* TN. profile
DEFINE QLOCAL('TN.CAUT.CODIGO.AUT.SOL') REPLACE
DEFINE QLOCAL('TN.CAUT.CODIGO.AUT.COMPRA.RES') REPLACE
DEFINE QLOCAL('TN.CAUT.CODIGO.AUT.ANULACION.RES') REPLACE
DEFINE QLOCAL('TN.CAUT.CODIGO.AUT.REV.COMPRA.RES') REPLACE
DEFINE QLOCAL('TN.CAUT.CODIGO.AUT.REV.ANULACION.RES') REPLACE

* Use a different dead letter queue, for undeliverable messages
ALTER QMGR DEADQ('DEV.DEAD.LETTER.QUEUE')

* Developer topics
DEFINE TOPIC('DEV.BASE.TOPIC') TOPICSTR('dev/') REPLACE

* Developer connection authentication
DEFINE AUTHINFO('DEV.AUTHINFO') AUTHTYPE(IDPWOS) CHCKCLNT(REQDADM) CHCKLOCL(OPTIONAL) ADOPTCTX(YES) REPLACE
ALTER QMGR CONNAUTH('DEV.AUTHINFO')
REFRESH SECURITY(*) TYPE(CONNAUTH)

* Developer channels (Application + Admin)
* Developer channels (Application + Admin)
DEFINE CHANNEL('DEV.ADMIN.SVRCONN') CHLTYPE(SVRCONN) REPLACE
DEFINE CHANNEL('DEV.APP.SVRCONN') CHLTYPE(SVRCONN) MCAUSER('app') REPLACE

* Developer channel authentication rules
SET CHLAUTH('*') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(NOACCESS) DESCR('Back-stop rule - Blocks everyone') ACTION(REPLACE)
* SET CHLAUTH('DEV.APP.SVRCONN') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) DESCR('Allows connection via APP channel') ACTION(REPLACE)
SET CHLAUTH('DEV.APP.SVRCONN') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) CHCKCLNT({{ .ChckClnt }}) DESCR('Allows connection via APP channel') ACTION(REPLACE)
SET CHLAUTH('DEV.ADMIN.SVRCONN') TYPE(BLOCKUSER) USERLIST('nobody') DESCR('Allows admins on ADMIN channel') ACTION(REPLACE)
SET CHLAUTH('DEV.ADMIN.SVRCONN') TYPE(USERMAP) CLNTUSER('admin') USERSRC(CHANNEL) DESCR('Allows admin user to connect via ADMIN channel') ACTION(REPLACE)

* Developer authority records
SET AUTHREC GROUP('mqclient') OBJTYPE(QMGR) AUTHADD(CONNECT,INQ)
SET AUTHREC PROFILE('DEV.**') GROUP('mqclient') OBJTYPE(QUEUE) AUTHADD(BROWSE,GET,INQ,PUT)
SET AUTHREC PROFILE('DEV.**') GROUP('mqclient') OBJTYPE(TOPIC) AUTHADD(PUB,SUB)
* TN. profile
SET AUTHREC PROFILE('TN.**') GROUP('mqclient') OBJTYPE(QUEUE) AUTHADD(BROWSE,GET,INQ,PUT)
SET AUTHREC PROFILE('TN.**') GROUP('mqclient') OBJTYPE(TOPIC) AUTHADD(PUB,SUB)


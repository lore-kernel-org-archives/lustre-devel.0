From: David Binderman <dcb314@hotmail.com>
Date: Mon, 17 Oct 2016 07:33:33 +0000
Subject: [lustre-devel]
 linux-4.9-rc1/drivers/staging/lustre/lustre/osc/osc_request.c:973: always
 false test ?
Message-ID: <VI1PR08MB1022232C214C9435587602379CD00@VI1PR08MB1022.eurprd08.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello there,



linux-4.9-rc1/drivers/staging/lustre/lustre/osc/osc_request.c:973]: (style) Checking if unsigned variable 'cli.cl_avail_grant' is less than zero.



Source code is



?? if (cli->cl_avail_grant < 0) {



Suggest code rework.


Regards


David Binderman

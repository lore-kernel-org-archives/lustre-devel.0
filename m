From: Patrick Farrell <paf@cray.com>
Date: Mon, 22 Jun 2015 10:46:15 -0500
Subject: [lustre-devel] Fwd: [HPDD-discuss] [PATCH 01/12] staging: lustre:
 fid: Use !x to check for kzalloc failure
In-Reply-To: <1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
Message-ID: <55882DC7.6060802@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Question for lustre-devel...  Isn't this the opposite of the style that 
we're currently trying to use in Gerrit submissions?  Is my memory faulty?


-------- Original Message --------
Subject: 	[HPDD-discuss] [PATCH 01/12] staging: lustre: fid: Use !x to 
check for kzalloc failure
Date: 	Sat, 20 Jun 2015 18:58:59 +0200
From: 	Julia Lawall <Julia.Lawall@lip6.fr>
To: 	Oleg Drokin <oleg.drokin@intel.com>
CC: 	<devel@driverdev.osuosl.org>, Greg Kroah-Hartman 
<gregkh@linuxfoundation.org>, <kernel-janitors@vger.kernel.org>, 
<linux-kernel@vger.kernel.org>, <HPDD-discuss@lists.01.org>



!x is more normal for kzalloc failure in the kernel.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression x;
statement S1, S2;
@@

x = kzalloc(...);
if (
- x == NULL
+ !x
  ) S1 else S2
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
  drivers/staging/lustre/lustre/fid/fid_request.c |    4 ++--
  1 file changed, 2 insertions(+), 2 deletions(-)

diff -u -p a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -498,11 +498,11 @@ int client_fid_init(struct obd_device *o
  	int rc;
  
  	cli->cl_seq = kzalloc(sizeof(*cli->cl_seq), GFP_NOFS);
-	if (cli->cl_seq == NULL)
+	if (!cli->cl_seq)
  		return -ENOMEM;
  
  	prefix = kzalloc(MAX_OBD_NAME + 5, GFP_NOFS);
-	if (prefix == NULL) {
+	if (!prefix) {
  		rc = -ENOMEM;
  		goto out_free_seq;
  	}

_______________________________________________
HPDD-discuss mailing list
HPDD-discuss at lists.01.org
https://lists.01.org/mailman/listinfo/hpdd-discuss



-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150622/efb39765/attachment.htm>

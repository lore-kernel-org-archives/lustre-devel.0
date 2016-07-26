From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 20:56:43 +0200
Subject: [lustre-devel] [PATCH 01/12] staging/lustre/ldlm: Delete
 unnecessary checks before the function call "kset_unregister"
In-Reply-To: <59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
Message-ID: <c65e8b79-6bc8-553c-ff59-6d64d25f03ef@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 11:33:43 +0200

The kset_unregister() function tests whether its argument is NULL
and then returns immediately. Thus the test around the calls is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 821939f..2c1c2fc 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -1067,10 +1067,8 @@ static int ldlm_cleanup(void)
 	if (ldlm_state->ldlm_cb_service)
 		ptlrpc_unregister_service(ldlm_state->ldlm_cb_service);
 
-	if (ldlm_ns_kset)
-		kset_unregister(ldlm_ns_kset);
-	if (ldlm_svc_kset)
-		kset_unregister(ldlm_svc_kset);
+	kset_unregister(ldlm_ns_kset);
+	kset_unregister(ldlm_svc_kset);
 	if (ldlm_kobj)
 		kobject_put(ldlm_kobj);
 
-- 
2.9.2

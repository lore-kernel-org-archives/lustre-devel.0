From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:12 -0500
Subject: [lustre-devel] [PATCH 444/622] lnet: Fix style issues for module.c
 conctl.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-445-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shaun Tancheff <stancheff@cray.com>

This patch fixes issues reported by checkpatch for the file
selftest/module.c and selftest/conctl.c.
Linux 5.3 enforces the use of 'fallthrough' which is also
suggested by checkpatch

Cray-bug-id: LUS-7690
WC-bug-id: https://jira.whamcloud.com/browse/LU-12635
Lustre-commit: ebff8aba3392 ("LU-12635 lnet: Fix style issues for module.c conctl.c")
Signed-off-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-on: https://review.whamcloud.com/35802
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/selftest/conctl.c | 4 ++--
 net/lnet/selftest/module.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/lnet/selftest/conctl.c b/net/lnet/selftest/conctl.c
index 906d82d..ed9eab9 100644
--- a/net/lnet/selftest/conctl.c
+++ b/net/lnet/selftest/conctl.c
@@ -121,7 +121,6 @@
 		return -EINVAL;
 
 	if (args->lstio_dbg_namep) {
-
 		if (copy_from_user(name, args->lstio_dbg_namep,
 				   args->lstio_dbg_nmlen))
 			return -EFAULT;
@@ -727,7 +726,8 @@ static int lst_test_add_ioctl(struct lstio_test_args *args)
 		goto out;
 	}
 
-	memset(&console_session.ses_trans_stat, 0, sizeof(struct lstcon_trans_stat));
+	memset(&console_session.ses_trans_stat,
+	       0, sizeof(struct lstcon_trans_stat));
 
 	switch (opc) {
 	case LSTIO_SESSION_NEW:
diff --git a/net/lnet/selftest/module.c b/net/lnet/selftest/module.c
index 9ba6532..2de2b59 100644
--- a/net/lnet/selftest/module.c
+++ b/net/lnet/selftest/module.c
@@ -105,7 +105,7 @@ enum {
 
 	nscheds = cfs_cpt_number(lnet_cpt_table());
 	lst_test_wq = kvmalloc_array(nscheds, sizeof(lst_test_wq[0]),
-					GFP_KERNEL | __GFP_ZERO);
+				     GFP_KERNEL | __GFP_ZERO);
 	if (!lst_test_wq) {
 		rc = -ENOMEM;
 		goto error;
-- 
1.8.3.1

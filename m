From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:25:59 -0400
Subject: [lustre-devel] [PATCH 07/31] lustre: lnet: change positional struct
 initializers to C99
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Steve Guminski <stephenx.guminski@intel.com>

This patch makes no functional changes. Struct initializers in the
lnet directory that use C89 or GCC-only syntax are updated to C99
syntax. Whitespace is corrected to match coding style guidelines.

C89 positional initializers require values to be placed in the
correct order. This will cause errors if the fields of the struct
definition are reordered or fields are added or removed. C99 named
initializers avoid this problem, and also automatically clear any
values that are not explicitly set.

The following struct initializers have been updated:

lnet/lnet/api-ni.c:
        lnet_process_id_t id
lnet/lnet/lo.c:
        lnd_t the_lolnd
lnet/selftest/framework.c:
        struct lst_sid LST_INVALID_SID

Signed-off-by: Steve Guminski <stephenx.guminski@intel.com>
WC-id: https://jira.whamcloud.com/browse/LU-6210
Reviewed-on: https://review.whamcloud.com/23493
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c        |  3 ++-
 drivers/staging/lustre/lnet/lnet/lo.c            | 20 +++++++++-----------
 drivers/staging/lustre/lnet/selftest/framework.c |  2 +-
 3 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index fea0373..e517893 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -884,7 +884,8 @@ struct lnet_ni  *
 		     struct lnet_handle_md *md_handle,
 		     int ni_count, bool set_eq)
 {
-	struct lnet_process_id id = {LNET_NID_ANY, LNET_PID_ANY};
+	struct lnet_process_id id = { .nid = LNET_NID_ANY,
+				      .pid = LNET_PID_ANY };
 	struct lnet_handle_me me_handle;
 	struct lnet_md md = { NULL };
 	int rc, rc2;
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index 7456b98..dd16cdf 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -91,15 +91,13 @@
 }
 
 struct lnet_lnd the_lolnd = {
-	/* .lnd_list       = */ {&the_lolnd.lnd_list, &the_lolnd.lnd_list},
-	/* .lnd_refcount   = */ 0,
-	/* .lnd_type       = */ LOLND,
-	/* .lnd_startup    = */ lolnd_startup,
-	/* .lnd_shutdown   = */ lolnd_shutdown,
-	/* .lnt_ctl        = */ NULL,
-	/* .lnd_send       = */ lolnd_send,
-	/* .lnd_recv       = */ lolnd_recv,
-	/* .lnd_eager_recv = */ NULL,
-	/* .lnd_notify     = */ NULL,
-	/* .lnd_accept     = */ NULL
+	.lnd_list	= {
+				.next	= &the_lolnd.lnd_list,
+				.prev	= &the_lolnd.lnd_list
+			},
+	.lnd_type	= LOLND,
+	.lnd_startup	= lolnd_startup,
+	.lnd_shutdown	= lolnd_shutdown,
+	.lnd_send	= lolnd_send,
+	.lnd_recv	= lolnd_recv,
 };
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 03a64e3..944a2a6 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -40,7 +40,7 @@
 
 #include "selftest.h"
 
-struct lst_sid LST_INVALID_SID = {LNET_NID_ANY, -1};
+struct lst_sid LST_INVALID_SID = { .ses_nid = LNET_NID_ANY, .ses_stamp = -1 };
 
 static int session_timeout = 100;
 module_param(session_timeout, int, 0444);
-- 
1.8.3.1

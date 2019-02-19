From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:06 +1100
Subject: [lustre-devel] [PATCH 24/37] lustre: lu_object: remove extra
 newline from debug printing.
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494611.24125.2469014113532688461.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In lu_cdebug_printer(), is "complete" is true, then
key->lck_area ends with a newline, so there is no need to
include on in the format too.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index d4f1eddd96ca..3e23babb329a 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -526,7 +526,7 @@ int lu_cdebug_printer(const struct lu_env *env,
 		  ARRAY_SIZE(key->lck_area) - used, format, args);
 	if (complete) {
 		if (cfs_cdebug_show(msgdata->msg_mask, msgdata->msg_subsys))
-			libcfs_debug_msg(msgdata, "%s\n", key->lck_area);
+			libcfs_debug_msg(msgdata, "%s", key->lck_area);
 		key->lck_area[0] = 0;
 	}
 	va_end(args);

From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:49 -0400
Subject: [lustre-devel] [PATCH 15/29] staging: lustre: obdecho: don't copy
	lu_site
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, Olaf Faaland <faaland1@llnl.gov>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

While creating an echo device, echo_device_alloc() copies the lu_site
from MD stack, such kind of copy result in uninitialized mutex and
other potential issues.

Instead of copying the lu_site, we'd use the lu_site by pointer directly.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Signed-off-by: Olaf Faaland <faaland1@llnl.gov>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6765
Reviewed-on: http://review.whamcloud.com/15657
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/obdecho/echo_client.c    |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index c69588c..30caf5f 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -55,7 +55,7 @@ struct echo_device {
 	struct echo_client_obd *ed_ec;
 
 	struct cl_site	  ed_site_myself;
-	struct cl_site	 *ed_site;
+	struct lu_site		*ed_site;
 	struct lu_device       *ed_next;
 };
 
@@ -527,17 +527,19 @@ static int echo_site_init(const struct lu_env *env, struct echo_device *ed)
 	}
 
 	rc = lu_site_init_finish(&site->cs_lu);
-	if (rc)
+	if (rc) {
+		cl_site_fini(site);
 		return rc;
+	}
 
-	ed->ed_site = site;
+	ed->ed_site = &site->cs_lu;
 	return 0;
 }
 
 static void echo_site_fini(const struct lu_env *env, struct echo_device *ed)
 {
 	if (ed->ed_site) {
-		cl_site_fini(ed->ed_site);
+		lu_site_fini(ed->ed_site);
 		ed->ed_site = NULL;
 	}
 }
@@ -674,7 +676,7 @@ static void echo_session_key_exit(const struct lu_context *ctx,
 			goto out_cleanup;
 		}
 
-		next->ld_site = &ed->ed_site->cs_lu;
+		next->ld_site = ed->ed_site;
 		rc = next->ld_type->ldt_ops->ldto_device_init(env, next,
 						next->ld_type->ldt_name,
 							      NULL);
@@ -741,7 +743,7 @@ static void echo_lock_release(const struct lu_env *env,
 	CDEBUG(D_INFO, "echo device:%p is going to be freed, next = %p\n",
 	       ed, next);
 
-	lu_site_purge(env, &ed->ed_site->cs_lu, -1);
+	lu_site_purge(env, ed->ed_site, -1);
 
 	/* check if there are objects still alive.
 	 * It shouldn't have any object because lu_site_purge would cleanup
@@ -754,7 +756,7 @@ static void echo_lock_release(const struct lu_env *env,
 	spin_unlock(&ec->ec_lock);
 
 	/* purge again */
-	lu_site_purge(env, &ed->ed_site->cs_lu, -1);
+	lu_site_purge(env, ed->ed_site, -1);
 
 	CDEBUG(D_INFO,
 	       "Waiting for the reference of echo object to be dropped\n");
@@ -766,7 +768,7 @@ static void echo_lock_release(const struct lu_env *env,
 		CERROR("echo_client still has objects at cleanup time, wait for 1 second\n");
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule_timeout(cfs_time_seconds(1));
-		lu_site_purge(env, &ed->ed_site->cs_lu, -1);
+		lu_site_purge(env, ed->ed_site, -1);
 		spin_lock(&ec->ec_lock);
 	}
 	spin_unlock(&ec->ec_lock);
@@ -780,7 +782,7 @@ static void echo_lock_release(const struct lu_env *env,
 	while (next)
 		next = next->ld_type->ldt_ops->ldto_device_free(env, next);
 
-	LASSERT(ed->ed_site == lu2cl_site(d->ld_site));
+	LASSERT(ed->ed_site == d->ld_site);
 	echo_site_fini(env, ed);
 	cl_device_fini(&ed->ed_cl);
 	kfree(ed);
-- 
1.7.1

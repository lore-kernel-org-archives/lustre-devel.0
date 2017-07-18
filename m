From: NeilBrown <neilb@suse.com>
Date: Wed, 19 Jul 2017 09:26:47 +1000
Subject: [lustre-devel] [PATCH 12/12] staging: lustre: ldlm: remove unused
 field 'fwd_generation'
In-Reply-To: <150041997277.20736.17112251996623587423.stgit@noble>
References: <150041997277.20736.17112251996623587423.stgit@noble>
Message-ID: <150042040769.20736.8915983949201116682.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

With this field gone, we don't need local variables 'imp' or 'obd'
any more.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |   21 +++------------------
 1 file changed, 3 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 4e8808103437..b72a195d9635 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -311,7 +311,6 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 
 struct ldlm_flock_wait_data {
 	struct ldlm_lock *fwd_lock;
-	int	       fwd_generation;
 };
 
 static void
@@ -342,11 +341,9 @@ int
 ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 {
 	struct file_lock		*getlk = lock->l_ast_data;
-	struct obd_device	      *obd;
-	struct obd_import	      *imp = NULL;
-	struct ldlm_flock_wait_data     fwd;
-	struct l_wait_info	      lwi;
-	int			     rc = 0;
+	struct ldlm_flock_wait_data	fwd;
+	struct l_wait_info		lwi;
+	int				rc = 0;
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT2, 4);
 	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT3)) {
@@ -374,18 +371,6 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 
 	LDLM_DEBUG(lock, "client-side enqueue returned a blocked lock, sleeping");
 	fwd.fwd_lock = lock;
-	obd = class_exp2obd(lock->l_conn_export);
-
-	/* if this is a local lock, there is no import */
-	if (obd)
-		imp = obd->u.cli.cl_import;
-
-	if (imp) {
-		spin_lock(&imp->imp_lock);
-		fwd.fwd_generation = imp->imp_generation;
-		spin_unlock(&imp->imp_lock);
-	}
-
 	lwi = LWI_TIMEOUT_INTR(0, NULL, ldlm_flock_interrupted_wait, &fwd);
 
 	/* Go to sleep until the lock is granted. */

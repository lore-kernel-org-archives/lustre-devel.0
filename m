From: NeilBrown <neilb@suse.com>
Date: Wed, 19 Jul 2017 09:26:47 +1000
Subject: [lustre-devel] [PATCH 01/12] staging: lustre: fix minor typos in
	comments
In-Reply-To: <150041997277.20736.17112251996623587423.stgit@noble>
References: <150041997277.20736.17112251996623587423.stgit@noble>
Message-ID: <150042040735.20736.6997246449635538567.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/namei.c   |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index a208a8b02c2c..293a3180ec70 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -490,7 +490,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 	*de = alias;
 
 	if (!it_disposition(it, DISP_LOOKUP_NEG)) {
-		/* we have lookup look - unhide dentry */
+		/* We have the "lookup" lock, so unhide dentry */
 		if (bits & MDS_INODELOCK_LOOKUP)
 			d_lustre_revalidate(*de);
 	} else if (!it_disposition(it, DISP_OPEN_CREATE)) {
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 3eb66cea65db..ae97c6f1aeb0 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -1030,7 +1030,7 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
  * If we're performing a creation, that means that unless the creation
  * failed with EEXIST, we should fake up a negative dentry.
  *
- * For everything else, we want to lookup to succeed.
+ * For everything else, we want the lookup to succeed.
  *
  * One additional note: if CREATE or OPEN succeeded, we add an extra
  * reference to the request because we need to keep it around until
@@ -1040,7 +1040,7 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
  * exactly what it_status refers to.
  *
  * If DISP_OPEN_OPEN is set, then it_status refers to the open() call,
- * otherwise if DISP_OPEN_CREATE is set, then it status is the
+ * otherwise if DISP_OPEN_CREATE is set, then it_status is the
  * creation failure mode.  In either case, one of DISP_LOOKUP_NEG or
  * DISP_LOOKUP_POS will be set, indicating whether the child lookup
  * was successful.

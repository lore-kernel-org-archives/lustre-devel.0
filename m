From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:50 -0500
Subject: [lustre-devel] [PATCH 22/60] staging: lustre: fid: fix race in fid
	allocation
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

There is race condition when allocating fid/seq in parallel
as following:

The thread1 will release the lcs_mutex via seq_fid_alloc_prep(),
then another fid allocation thread2 can obtain the lcs_mutex and
allocate FID in the new sequence that has just been allocated by
the thread1 via seq_client_alloc_seq(); and then after thread2
released the lcs_mutex, the thread1 will re-allocate the current
FID in the new sequence without checking whether some others have
already taken such FID in the new sequence during it re-obtaining
the lcs_mutex.

Such race will cause two objects to use the same FID, and trigger
OI conflict and LMA verification failures.

This patch makes the fid allocation and lu_client_seq modification
to be protected by the lcs_mutex.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8319
Reviewed-on: http://review.whamcloud.com/20939
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fid/fid_request.c | 55 ++++++++++++++++---------
 1 file changed, 35 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 999f250..62a9f7e 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -211,12 +211,35 @@ static int seq_fid_alloc_prep(struct lu_client_seq *seq,
 	return 0;
 }
 
-static void seq_fid_alloc_fini(struct lu_client_seq *seq)
+static void seq_fid_alloc_fini(struct lu_client_seq *seq, u64 seqnr,
+			       bool whole)
 {
 	LASSERT(seq->lcs_update == 1);
+
 	mutex_lock(&seq->lcs_mutex);
+	if (seqnr != 0) {
+		CDEBUG(D_INFO, "%s: New sequence [0x%16.16llx]\n",
+		       seq->lcs_name, seqnr);
+
+		seq->lcs_fid.f_seq = seqnr;
+		if (whole) {
+			/*
+			 * Since the caller require the whole seq,
+			 * so marked this seq to be used
+			 */
+			if (seq->lcs_type == LUSTRE_SEQ_METADATA)
+				seq->lcs_fid.f_oid =
+					LUSTRE_METADATA_SEQ_MAX_WIDTH;
+			else
+				seq->lcs_fid.f_oid = LUSTRE_DATA_SEQ_MAX_WIDTH;
+		} else {
+			seq->lcs_fid.f_oid = LUSTRE_FID_INIT_OID;
+		}
+		seq->lcs_fid.f_ver = 0;
+	}
+
 	--seq->lcs_update;
-	wake_up(&seq->lcs_waitq);
+	wake_up_all(&seq->lcs_waitq);
 }
 
 /* Allocate new fid on passed client @seq and save it to @fid. */
@@ -238,41 +261,33 @@ int seq_client_alloc_fid(const struct lu_env *env,
 	while (1) {
 		u64 seqnr;
 
-		if (!fid_is_zero(&seq->lcs_fid) &&
-		    fid_oid(&seq->lcs_fid) < seq->lcs_width) {
+		if (unlikely(!fid_is_zero(&seq->lcs_fid) &&
+			     fid_oid(&seq->lcs_fid) < seq->lcs_width)) {
 			/* Just bump last allocated fid and return to caller. */
-			seq->lcs_fid.f_oid += 1;
+			seq->lcs_fid.f_oid++;
 			rc = 0;
 			break;
 		}
 
+		/*
+		 * Release seq::lcs_mutex via seq_fid_alloc_prep() to avoid
+		 * deadlock during seq_client_alloc_seq().
+		 */
 		rc = seq_fid_alloc_prep(seq, &link);
 		if (rc)
 			continue;
 
 		rc = seq_client_alloc_seq(env, seq, &seqnr);
+		/* Re-take seq::lcs_mutex via seq_fid_alloc_fini(). */
+		seq_fid_alloc_fini(seq, rc ? 0 : seqnr, false);
 		if (rc) {
-			CERROR("%s: Can't allocate new sequence, rc %d\n",
+			CERROR("%s: Can't allocate new sequence, rc = %d\n",
 			       seq->lcs_name, rc);
-			seq_fid_alloc_fini(seq);
 			mutex_unlock(&seq->lcs_mutex);
 			return rc;
 		}
 
-		CDEBUG(D_INFO, "%s: Switch to sequence [0x%16.16Lx]\n",
-		       seq->lcs_name, seqnr);
-
-		seq->lcs_fid.f_oid = LUSTRE_FID_INIT_OID;
-		seq->lcs_fid.f_seq = seqnr;
-		seq->lcs_fid.f_ver = 0;
-
-		/*
-		 * Inform caller that sequence switch is performed to allow it
-		 * to setup FLD for it.
-		 */
 		rc = 1;
-
-		seq_fid_alloc_fini(seq);
 		break;
 	}
 
-- 
1.8.3.1

From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:44:07 -0400
Subject: [lustre-devel] [PATCH 24/29] staging/lustre/fid: Remove unused
	struct lu_server_seq
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-25-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/include/lustre_fid.h | 51 ----------------------
 1 file changed, 51 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index bbe3ff8..19d9175 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -369,57 +369,6 @@ struct lu_client_seq {
 	int		     lcs_update;
 };
 
-/* server sequence manager interface */
-struct lu_server_seq {
-	/* Available sequences space */
-	struct lu_seq_range	 lss_space;
-
-	/* keeps highwater in lsr_end for seq allocation algorithm */
-	struct lu_seq_range	 lss_lowater_set;
-	struct lu_seq_range	 lss_hiwater_set;
-
-	/*
-	 * Device for server side seq manager needs (saving sequences to backing
-	 * store).
-	 */
-	struct dt_device       *lss_dev;
-
-	/* LUSTRE_SEQ_SERVER or LUSTRE_SEQ_CONTROLLER */
-	enum lu_mgr_type       lss_type;
-
-	/* Client interface to request controller */
-	struct lu_client_seq   *lss_cli;
-
-	/* Mutex for protecting allocation */
-	struct mutex		lss_mutex;
-
-	/*
-	 * Service uuid, passed from MDT + seq name to form unique seq name to
-	 * use it with procfs.
-	 */
-	char		    lss_name[LUSTRE_MDT_MAXNAMELEN];
-
-	/*
-	 * Allocation chunks for super and meta sequences. Default values are
-	 * LUSTRE_SEQ_SUPER_WIDTH and LUSTRE_SEQ_META_WIDTH.
-	 */
-	__u64		   lss_width;
-
-	/*
-	 * minimum lss_alloc_set size that should be allocated from
-	 * lss_space
-	 */
-	__u64		   lss_set_width;
-
-	/* sync is needed for update operation */
-	__u32		   lss_need_sync;
-
-	/**
-	 * Pointer to site object, required to access site fld.
-	 */
-	struct seq_server_site  *lss_site;
-};
-
 /* Client methods */
 void seq_client_flush(struct lu_client_seq *seq);
 
-- 
2.1.0

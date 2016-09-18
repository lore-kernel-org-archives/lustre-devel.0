From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:06 -0400
Subject: [lustre-devel] [PATCH 007/124] staging: lustre: obd: add lnb_
	prefix to members of struct niobuf_local
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Add the prefix lnb_ to the members of struct niobuf_local that do not
already have it. Change the struct dentry *lnb_dentry member to void
*lnb_data as it is not used to hold a pointer to struct dentry.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5061
Reviewed-on: http://review.whamcloud.com/10451
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |   10 +++++-----
 .../staging/lustre/lustre/obdecho/echo_client.c    |    6 +++---
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index f3d141b..f55e679 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -437,11 +437,11 @@ struct lmv_obd {
 struct niobuf_local {
 	__u64		lnb_file_offset;
 	__u32		lnb_page_offset;
-	__u32		len;
-	__u32		flags;
-	struct page	*page;
-	struct dentry	*dentry;
-	int		rc;
+	__u32		lnb_len;
+	__u32		lnb_flags;
+	struct page	*lnb_page;
+	void		*lnb_data;
+	int		lnb_rc;
 };
 
 #define LUSTRE_FLD_NAME	 "fld"
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 7527112..e7c492e 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1452,14 +1452,14 @@ static int echo_client_prep_commit(const struct lu_env *env,
 		LASSERT(lpages == npages);
 
 		for (i = 0; i < lpages; i++) {
-			struct page *page = lnb[i].page;
+			struct page *page = lnb[i].lnb_page;
 
 			/* read past eof? */
-			if (!page  && lnb[i].rc == 0)
+			if (!page  && lnb[i].lnb_rc == 0)
 				continue;
 
 			if (async)
-				lnb[i].flags |= OBD_BRW_ASYNC;
+				lnb[i].lnb_flags |= OBD_BRW_ASYNC;
 
 			if (ostid_id(&oa->o_oi) == ECHO_PERSISTENT_OBJID ||
 			    (oa->o_valid & OBD_MD_FLFLAGS) == 0 ||
-- 
1.7.1

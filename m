From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:14 -0500
Subject: [lustre-devel] [PATCH 07/22] staging: lustre: obdclass:
	lu_site_purge() to handle purge-all
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alex Zhuravlev <alexey.zhuravlev@intel.com>, James Simmons <jsimmons@infradead.org>

From: Alex Zhuravlev <alexey.zhuravlev@intel.com>

if the callers wants to purge all objects, then scanning
should start from the first bucket.

Signed-off-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7038
Reviewed-on: http://review.whamcloud.com/18505
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 43868ed..a02aaa3 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -338,7 +338,7 @@ int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
 	struct cfs_hash_bd	    bd2;
 	struct list_head	       dispose;
 	int		      did_sth;
-	unsigned int start;
+	unsigned int start = 0;
 	int		      count;
 	int		      bnr;
 	unsigned int i;
@@ -351,7 +351,8 @@ int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
 	 * Under LRU list lock, scan LRU list and move unreferenced objects to
 	 * the dispose list, removing them from LRU and hash table.
 	 */
-	start = s->ls_purge_start;
+	if (nr != ~0)
+		start = s->ls_purge_start;
 	bnr = (nr == ~0) ? -1 : nr / (int)CFS_HASH_NBKT(s->ls_obj_hash) + 1;
  again:
 	/*
-- 
1.7.1

From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:04 -0400
Subject: [lustre-devel] [PATCH 065/124] staging: lustre: obdclass: change
	lu_site->ls_purge_start to unsigned
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-66-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Change the type accordant usage.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/12384
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |    2 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 7b37cae..260643e 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -602,7 +602,7 @@ struct lu_site {
 	/**
 	 * index of bucket on hash table while purging
 	 */
-	int		       ls_purge_start;
+	unsigned int		ls_purge_start;
 	/**
 	 * Top-level device for this stack.
 	 */
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index e284e5d..4395117 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -338,7 +338,7 @@ int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
 	struct cfs_hash_bd	    bd2;
 	struct list_head	       dispose;
 	int		      did_sth;
-	int		      start;
+	unsigned int start;
 	int		      count;
 	int		      bnr;
 	unsigned int i;
-- 
1.7.1

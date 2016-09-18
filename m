From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:21 -0400
Subject: [lustre-devel] [PATCH 022/124] staging: lustre: llog: add newly
	opened llog at tail of handle list
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Li Xi <lixi@ddn.com>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Li Xi <lixi@ddn.com>

Add newly opened llog handle at the tail of handle list to increase
lookup speed, especially for cancel operation, because the canceled
log will be removed from the list, and lookup is from the beginning.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: Li Xi <lixi@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5405
Reviewed-on: http://review.whamcloud.com/11575
Reviewed-by: Ian Costello <costello.ian@gmail.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/llog_cat.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index d28751a..b27f08f 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -107,7 +107,7 @@ static int llog_cat_id2handle(const struct lu_env *env,
 	}
 
 	down_write(&cathandle->lgh_lock);
-	list_add(&loghandle->u.phd.phd_entry, &cathandle->u.chd.chd_head);
+	list_add_tail(&loghandle->u.phd.phd_entry, &cathandle->u.chd.chd_head);
 	up_write(&cathandle->lgh_lock);
 
 	loghandle->u.phd.phd_cat_handle = cathandle;
-- 
1.7.1

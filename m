From: James Simmons <jsimmons@infradead.org>
Date: Thu,  5 May 2016 14:53:01 -0400
Subject: [lustre-devel] [PATCH 2/8] staging: lustre: o2iblnd: Use
	list_for_each_entry_safe in kiblnd_destroy_fmr_pool_list
In-Reply-To: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
References: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462474387-11406-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Doubly linked lists which are iterated using list_empty
and list_entry macros have been replaced with list_for_each_entry_safe
macro. This makes the iteration simpler and more readable.

This patch replaces the while loop containing list_empty and list_entry
with list_for_each_entry_safe.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5783
Reviewed-on: http://review.whamcloud.com/17606
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 60647bc..4a4b68c 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1313,10 +1313,9 @@ static void kiblnd_destroy_fmr_pool(kib_fmr_pool_t *fpo)
 
 static void kiblnd_destroy_fmr_pool_list(struct list_head *head)
 {
-	kib_fmr_pool_t *fpo;
+	kib_fmr_pool_t *fpo, *tmp;
 
-	while (!list_empty(head)) {
-		fpo = list_entry(head->next, kib_fmr_pool_t, fpo_list);
+	list_for_each_entry_safe(fpo, tmp, head, fpo_list) {
 		list_del(&fpo->fpo_list);
 		kiblnd_destroy_fmr_pool(fpo);
 	}
-- 
1.7.1

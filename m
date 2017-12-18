From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 11:46:30 +1100
Subject: [lustre-devel] [PATCH 14/15] staging: lustre: opencode
 LIBCFS_ALLOC_ATOMIC calls.
In-Reply-To: <151355781721.6200.2136335532722530242.stgit@noble>
References: <151355781721.6200.2136335532722530242.stgit@noble>
Message-ID: <151355799072.6200.1169111940083599054.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Just call kzalloc(GFP_ATOMIC) directly.
We don't need the warning on failure.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/lustre/obdclass/lprocfs_status.c        |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 85483a38c6c4..e1f4ef2bddd4 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1093,7 +1093,7 @@ int lprocfs_stats_alloc_one(struct lprocfs_stats *stats, unsigned int cpuid)
 	LASSERT((stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) == 0);
 
 	percpusize = lprocfs_stats_counter_size(stats);
-	LIBCFS_ALLOC_ATOMIC(stats->ls_percpu[cpuid], percpusize);
+	stats->ls_percpu[cpuid] = kzalloc(percpusize, GFP_ATOMIC);
 	if (stats->ls_percpu[cpuid]) {
 		rc = 0;
 		if (unlikely(stats->ls_biggest_alloc_num <= cpuid)) {
@@ -1156,7 +1156,7 @@ struct lprocfs_stats *lprocfs_alloc_stats(unsigned int num,
 	if ((flags & LPROCFS_STATS_FLAG_NOPERCPU) != 0) {
 		/* contains only one set counters */
 		percpusize = lprocfs_stats_counter_size(stats);
-		LIBCFS_ALLOC_ATOMIC(stats->ls_percpu[0], percpusize);
+		stats->ls_percpu[0] = kzalloc(percpusize, GFP_ATOMIC);
 		if (!stats->ls_percpu[0])
 			goto fail;
 		stats->ls_biggest_alloc_num = 1;
@@ -1193,8 +1193,7 @@ void lprocfs_free_stats(struct lprocfs_stats **statsh)
 
 	percpusize = lprocfs_stats_counter_size(stats);
 	for (i = 0; i < num_entry; i++)
-		if (stats->ls_percpu[i])
-			LIBCFS_FREE(stats->ls_percpu[i], percpusize);
+		kfree(stats->ls_percpu[i]);
 	kvfree(stats->ls_cnt_header);
 	kvfree(stats);
 }

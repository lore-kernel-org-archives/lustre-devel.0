From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue,  6 Dec 2016 22:53:48 -0500
Subject: [lustre-devel] [PATCH] staging/lustre/osc: Revert erroneous
	list_for_each_entry_safe use
Message-ID: <1481082828-1590398-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>, Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

I have been having a lot of unexplainable crashes in osc_lru_shrink
lately that I could not see a good explanation for and then I found
this patch that slip under the radar somehow that incorrectly
converted while loop for lru list iteration into
list_for_each_entry_safe totally ignoring that in the body of
the loop we drop spinlocks guarding this list and move list entries
around.
Not sure why it was not showing up right away, perhaps some of the
more recent LRU changes committed caused some extra pressure on this
code that finally highlighted the breakage.

Reverts: 8adddc36b1fc ("staging: lustre: osc: Use list_for_each_entry_safe")
CC: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
I also do not see this patch in any of the mailing lists I am subscribed to.
I wonder if there's a way to subscribe to those Greg's
"This is a note to let you know that I've just added the patch ...."
emails that concern Lustre to get them even if I am not on the CC list in
the patch itself?

 drivers/staging/lustre/lustre/osc/osc_page.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index c5129d1..e356e4a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -537,7 +537,6 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 	struct cl_object *clobj = NULL;
 	struct cl_page **pvec;
 	struct osc_page *opg;
-	struct osc_page *temp;
 	int maxscan = 0;
 	long count = 0;
 	int index = 0;
@@ -568,7 +567,7 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 	if (force)
 		cli->cl_lru_reclaim++;
 	maxscan = min(target << 1, atomic_long_read(&cli->cl_lru_in_list));
-	list_for_each_entry_safe(opg, temp, &cli->cl_lru_list, ops_lru) {
+	while (!list_empty(&cli->cl_lru_list)) {
 		struct cl_page *page;
 		bool will_free = false;
 
@@ -578,6 +577,8 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 		if (--maxscan < 0)
 			break;
 
+		opg = list_entry(cli->cl_lru_list.next, struct osc_page,
+				 ops_lru);
 		page = opg->ops_cl.cpl_page;
 		if (lru_page_busy(cli, page)) {
 			list_move_tail(&opg->ops_lru, &cli->cl_lru_list);
-- 
2.7.4

From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:35 -0500
Subject: [lustre-devel] [PATCH 287/622] lustre: statahead:
 sa_handle_callback get lli_sa_lock earlier
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-288-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ann Koehler <amk@cray.com>

sa_handle_callback() must acquire the lli_sa_lock before calling
sa_has_callback(), which checks whether the sai_interim_entries list is
empty. Acquiring the lock avoids a race between an rpc handler
executing ll_statahead_interpret and the separate ll_statahead_thread.

When a client receives a stat request response, ll_statahead_interpret
increments sai_replied and if needed adds the request to the
sai_interim_entries list for instantiating by the ll_statahead_thread.
ll_statahead_interpret() holds the lli_sa_lock while doing this work.
On process termination, ll_statahead_thread() waits for sai_sent to
equal sai_replied and then removes any entries in the
sai_interim_entries list. It does not get the lli_sa_lock until
it determines that there are sai_interim_entries to process.

A bug occurs on weak memory model processors that do not guarantee
that both ll_statahead_interpret updates done under the lock are
visible to other processors at the same time. For example, on ARM
nodes, an ll_statahead_thread can read the updated value of
sai_replied and a non-updated value of sai_interim_lists.
ll_statahead_thread then thinks all replies have been received (true)
and all sai_interim_entries have been processed false). Later, the
update to sai_interim_entries becomes visible leaving the
ll_statahead_info struct in an unexpected state.

The bad state eventually triggers the LBUG:
statahead.c:477:ll_sai_put()) ASSERTION( !sa_has_callback(sai) )

Cray-bug-id: LUS-6243
WC-bug-id: https://jira.whamcloud.com/browse/LU-12221
Lustre-commit: 31ef093c2197 ("LU-12221 statahead: sa_handle_callback get lli_sa_lock earlier")
Signed-off-by: Ann Koehler <amk@cray.com>
Reviewed-on: https://review.whamcloud.com/34760
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/statahead.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 7dfb045..497aba3 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -688,21 +688,19 @@ static void sa_handle_callback(struct ll_statahead_info *sai)
 
 	lli = ll_i2info(sai->sai_dentry->d_inode);
 
+	spin_lock(&lli->lli_sa_lock);
 	while (sa_has_callback(sai)) {
 		struct sa_entry *entry;
 
-		spin_lock(&lli->lli_sa_lock);
-		if (unlikely(!sa_has_callback(sai))) {
-			spin_unlock(&lli->lli_sa_lock);
-			break;
-		}
 		entry = list_first_entry(&sai->sai_interim_entries,
 					 struct sa_entry, se_list);
 		list_del_init(&entry->se_list);
 		spin_unlock(&lli->lli_sa_lock);
 
 		sa_instantiate(sai, entry);
+		spin_lock(&lli->lli_sa_lock);
 	}
+	spin_unlock(&lli->lli_sa_lock);
 }
 
 /*
-- 
1.8.3.1

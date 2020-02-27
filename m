From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:10 -0500
Subject: [lustre-devel] [PATCH 022/622] lustre: llite: yield cpu after call
 to ll_agl_trigger
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ann Koehler <amk@cray.com>

The statahead and agl threads loop over all entries in the
directory without yielding the CPU. If the number of entries in
the directory is large enough then these threads may trigger
soft lockups. The fix is to add calls to cond_resched() after
calling ll_agl_trigger(), which gets the glimpse lock for a
file.

Cray-bug-id: LUS-2584
WC-bug-id: https://jira.whamcloud.com/browse/LU-10649
Lustre-commit: 031001f0d438 ("LU-10649 llite: yield cpu after call to ll_agl_trigger")
Signed-off-by: Ann Koehler <amk@cray.com>
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/31240
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Sergey Cheremencev <c17829@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/statahead.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 99b3fee..4a61dac 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -907,6 +907,7 @@ static int ll_agl_thread(void *arg)
 			list_del_init(&clli->lli_agl_list);
 			spin_unlock(&plli->lli_agl_lock);
 			ll_agl_trigger(&clli->lli_vfs_inode, sai);
+			cond_resched();
 		} else {
 			spin_unlock(&plli->lli_agl_lock);
 		}
@@ -1071,7 +1072,7 @@ static int ll_statahead_thread(void *arg)
 
 					ll_agl_trigger(&clli->lli_vfs_inode,
 						       sai);
-
+					cond_resched();
 					spin_lock(&lli->lli_agl_lock);
 				}
 				spin_unlock(&lli->lli_agl_lock);
-- 
1.8.3.1

From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:03 -0500
Subject: [lustre-devel] [PATCH 435/622] lustre: llite: forget cached ACLs
 properly
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-436-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

Lustre with linux-4.* fails ACL tests (e.g. sanity/103 and sanityn/25)
because ll_lock_cancel_bits() does not reset i_acl and i_default_acl
into initial state.  use kernel's forget_all_cached_acls() to do so.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12657
Lustre-commit: 3df034f8f46b ("LU-12657 llite: forget cached ACLs properly")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35756
Reviewed-by: Neil Brown <neilb@suse.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/namei.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 71e757a..de01a73 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -361,6 +361,9 @@ static void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 	    !is_root_inode(inode))
 		ll_invalidate_aliases(inode);
 
+	if (bits & (MDS_INODELOCK_LOOKUP | MDS_INODELOCK_PERM))
+		forget_all_cached_acls(inode);
+
 	iput(inode);
 }
 
-- 
1.8.3.1

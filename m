From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:23:50 -0400
Subject: [lustre-devel] [PATCH 21/22] ext4: export ext4_orphan_add
In-Reply-To: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563758631-29550-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/ext4/namei.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 9b30cc6..6cb3f63 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -3615,6 +3615,7 @@ int ext4_orphan_add(handle_t *handle, struct inode *inode)
 	ext4_std_error(sb, err);
 	return err;
 }
+EXPORT_SYMBOL(ext4_orphan_add);
 
 /*
  * ext4_orphan_del() removes an unlinked or truncated inode from the list
-- 
1.8.3.1

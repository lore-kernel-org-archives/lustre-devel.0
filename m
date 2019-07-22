From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:23:40 -0400
Subject: [lustre-devel] [PATCH 11/22] ext4: over ride current_time
In-Reply-To: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563758631-29550-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

return i_ctime if IS_NOCMTIME is true for inode.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/ext4/ext4.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 51b6159..80601a9 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -661,6 +661,13 @@ enum {
 #define EXT4_GOING_FLAGS_LOGFLUSH		0x1	/* flush log but not data */
 #define EXT4_GOING_FLAGS_NOLOGFLUSH		0x2	/* don't flush log nor data */
 
+static inline struct timespec64 ext4_current_time(struct inode *inode)
+{
+	if (IS_NOCMTIME(inode))
+		return inode->i_ctime;
+	return current_time(inode);
+}
+#define current_time(a) ext4_current_time(a)
 
 #if defined(__KERNEL__) && defined(CONFIG_COMPAT)
 /*
-- 
1.8.3.1

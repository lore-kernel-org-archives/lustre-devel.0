From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 Nov 2015 13:39:59 -0500
Subject: [lustre-devel] [PATCH 03/10] staging: lustre: remove
	libcfs_debug_set_level prototype from libcfs_private.h
In-Reply-To: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
References: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446662406-4590-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: frank zago <fzago@cray.com>

The function libcfs_debug_set_level is used only internally so no reason
to expose it in libcfs_private.h. This is broken out from LU-5829 patch
http://review.whamcloud.com/13319.

Signed-off-by: frank zago <fzago@cray.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 6af733d..dc2fe1f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -185,8 +185,6 @@ int libcfs_debug_cleanup(void);
 int libcfs_debug_clear_buffer(void);
 int libcfs_debug_mark_buffer(const char *text);
 
-void libcfs_debug_set_level(unsigned int debug_level);
-
 /*
  * allocate per-cpu-partition data, returned value is an array of pointers,
  * variable can be indexed by CPU ID.
-- 
1.7.1

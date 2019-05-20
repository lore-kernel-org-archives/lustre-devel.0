From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:50:57 -0400
Subject: [lustre-devel] [PATCH v2 15/29] lustre: lprocfs: use log2.h macros
 instead of shift loop.
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

These shift loops seem to be trying to avoid doing a
multiplication.
The same effect can be achieved more transparently using
rounddown_pow_of_two().  Even though there is a multiplication
in the C code, the resulting machine code just does a single shift.

As rounddown_pow_of_two() is not defined for 0, and as we cannot be
positively use the blk_size is non-zero, use blk_size ?: 1.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/obdclass/lprocfs_status.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 29c6b5d..2af9dad 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -374,9 +374,7 @@ static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
 		u32 blk_size = osfs.os_bsize >> 10;
 		u64 result = osfs.os_blocks;
 
-		while (blk_size >>= 1)
-			result <<= 1;
-
+		result *= rounddown_pow_of_two(blk_size ?: 1);
 		return sprintf(buf, "%llu\n", result);
 	}
 
@@ -397,8 +395,7 @@ static ssize_t kbytesfree_show(struct kobject *kobj, struct attribute *attr,
 		u32 blk_size = osfs.os_bsize >> 10;
 		u64 result = osfs.os_bfree;
 
-		while (blk_size >>= 1)
-			result <<= 1;
+		result *= rounddown_pow_of_two(blk_size ?: 1);
 
 		return sprintf(buf, "%llu\n", result);
 	}
@@ -420,8 +417,7 @@ static ssize_t kbytesavail_show(struct kobject *kobj, struct attribute *attr,
 		u32 blk_size = osfs.os_bsize >> 10;
 		u64 result = osfs.os_bavail;
 
-		while (blk_size >>= 1)
-			result <<= 1;
+		result *= rounddown_pow_of_two(blk_size ?: 1);
 
 		return sprintf(buf, "%llu\n", result);
 	}
-- 
1.8.3.1

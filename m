From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:18 -0400
Subject: [lustre-devel] [PATCH 059/151] lustre: llite: sync bdi sysfs name
 with lustre sysfs tree
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-60-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When the linux kernel introduced super_setup_bdi_name()
the port for the lustre client was done which ends up
creating sysfs files of the format

/sys/devices/virtual/bdi/lustre-1

but their is not way to correlate this with the naming of
lustre sysfs objects. Update the bdi handle to use the naming
method applied to the llite sysfs tree.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9558
Lustre-commit: 1defa62a19e7 ("LU-9558 llite: port lustre to unified handling of bdi")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/28511
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 07d1568..b48b23e 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -945,7 +945,6 @@ int ll_fill_super(struct super_block *sb)
 	char *ptr;
 	int len;
 	int err;
-	static atomic_t ll_bdi_num = ATOMIC_INIT(0);
 
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p\n", sb);
 
@@ -970,8 +969,7 @@ int ll_fill_super(struct super_block *sb)
 	if (err)
 		goto out_free;
 
-	err = super_setup_bdi_name(sb, "lustre-%d",
-				   atomic_inc_return(&ll_bdi_num));
+	err = super_setup_bdi_name(sb, "lustre-%p", sb);
 	if (err)
 		goto out_free;
 
-- 
1.8.3.1

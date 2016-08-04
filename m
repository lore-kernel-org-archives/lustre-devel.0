From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:52:57 -0400
Subject: [lustre-devel] [PATCH 21/32] staging: lustre: obdclass: compile
	issues with variable not being initialized
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

One of the versions of gcc I have refuses to build obd_mount.c due to
index not be initialized in function lmd_make_exclusion before it is
used.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4629
Reviewed-on: http://review.whamcloud.com/10705
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 33d6c42..595ea1f 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -730,7 +730,7 @@ int lustre_check_exclusion(struct super_block *sb, char *svname)
 static int lmd_make_exclusion(struct lustre_mount_data *lmd, const char *ptr)
 {
 	const char *s1 = ptr, *s2;
-	__u32 index, *exclude_list;
+	__u32 index = 0, *exclude_list;
 	int rc = 0, devmax;
 
 	/* The shortest an ost name can be is 8 chars: -OST0000.
-- 
1.7.1

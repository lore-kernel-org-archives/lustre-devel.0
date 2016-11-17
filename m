From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:42 -0500
Subject: [lustre-devel] [PATCH 04/19] staging: lustre: libcfs: remove
	explicit test of NULL variable
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove != NULL which is not needed to test key existence.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
index 83543f9..1deea76 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
@@ -73,7 +73,7 @@ struct cfs_percpt_lock *
 
 	cfs_percpt_for_each(lock, i, pcl->pcl_locks) {
 		spin_lock_init(lock);
-		if (keys != NULL)
+		if (keys)
 			lockdep_set_class(lock, &keys[i]);
 	}
 
-- 
1.7.1

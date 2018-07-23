From: NeilBrown <neilb@suse.com>
Date: Mon, 23 Jul 2018 16:23:05 +1000
Subject: [lustre-devel] [PATCH 8/9] lustre: ensure libcfs is set up for
 ioctls.
In-Reply-To: <153232696720.26222.9658151633697867322.stgit@noble>
References: <153232696720.26222.9658151633697867322.stgit@noble>
Message-ID: <153232698502.26222.8106098993681745318.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

libcfs only allocated various buffers when libcfs_setup()
is called.
This should be called before any significant libcfs related
activity.  However it isn't called by libcfs_ioctl().
So if the first thing that happens is an ioctl, tracing can cause
NULL pointer dereferences.

Fixes: 64bf0b1a079d ("staging: lustre: refactor libcfs initialization.")
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/module.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index ad654b56814d..bfadfcfa3c44 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -206,6 +206,9 @@ static int libcfs_ioctl(unsigned long cmd, void __user *uparam)
 	struct libcfs_ioctl_hdr *hdr;
 	int err;
 
+	err = libcfs_setup();
+	if (err)
+		return err;
 	/* 'cmd' and permissions get checked in our arch-specific caller */
 	err = libcfs_ioctl_getdata(&hdr, uparam);
 	if (err) {

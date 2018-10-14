From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:57:55 -0400
Subject: [lustre-devel] [PATCH 05/28] lustre: uapi: add back
 LUSTRE_MAXFSNAME to lustre_user.h
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The work to turn lustre_param.h into a proper UAPI header
removed various user land functions used to validate poolnames
and file system names. The checks instead were enforced on the
kernel side to ensure any possible user land software directly
interfacing to the kernel wouldn't be able to break things badly.
For the case of formating the backend file system no kernel
interaction doesn't happen until it tries to mount the MDT/OST/MGT
which is very late in the process. So for this case lets add back
the file system name verification to userland. With bringing this
back LUSTRE_MAXFSNAME is needed again since it used by both user
land and kernel. For the kernel side use LUSTRE_MAXFSNAME instead
of the raw number in the function server_name2fsname() located in
obd_mount.c.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9767
Reviewed-on: https://review.whamcloud.com/28070
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h | 2 ++
 drivers/staging/lustre/lustre/obdclass/obd_mount.c             | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 4fa7796..b8525e5 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -515,6 +515,8 @@ static inline char *obd_uuid2str(const struct obd_uuid *uuid)
 	return (char *)(uuid->uuid);
 }
 
+#define LUSTRE_MAXFSNAME 8
+
 /* Extract fsname from uuid (or target name) of a target
  * e.g. (myfs-OST0007_UUID -> myfs)
  * see also deuuidify.
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 33a67fd..5ed1758 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -599,7 +599,7 @@ static int server_name2fsname(const char *svname, char *fsname,
 {
 	const char *dash;
 
-	dash = svname + strnlen(svname, 8); /* max fsname length is 8 */
+	dash = svname + strnlen(svname, LUSTRE_MAXFSNAME);
 	for (; dash > svname && *dash != '-' && *dash != ':'; dash--)
 		;
 	if (dash == svname)
-- 
1.8.3.1

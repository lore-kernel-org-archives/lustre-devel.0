From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:02 -0400
Subject: [lustre-devel] [PATCH 103/151] lustre: address issues raised by gcc7
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-104-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Starting with gcc version 7 several platforms have enabled new
flags to report potential problems when compling code. For lustre
much of the reported problems deal with potential buffer overruns.
Address these issues in struct lustre_sb_info and provide info
about the fields.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9934
Linux-commit: 61743b8867268 ("LU-9934 build: address issues raised by gcc7")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/30376
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_disk.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lustre_disk.h b/fs/lustre/include/lustre_disk.h
index 8b4a243..92618e8 100644
--- a/fs/lustre/include/lustre_disk.h
+++ b/fs/lustre/include/lustre_disk.h
@@ -125,8 +125,10 @@ struct lustre_sb_info {
 	atomic_t		  lsi_mounts; /* references to the srv_mnt */
 	struct kobject		 *lsi_kobj;
 	char			  lsi_svname[MTI_NAME_MAXLEN];
-	char			  lsi_osd_obdname[64];
-	char			  lsi_osd_uuid[64];
+	/* lsi_osd_obdname format = 'lsi->ls_svname'-osd */
+	char			  lsi_osd_obdname[MTI_NAME_MAXLEN + 4];
+	/* lsi_osd_uuid format = 'lsi->ls_osd_obdname'_UUID */
+	char			  lsi_osd_uuid[MTI_NAME_MAXLEN + 9];
 	struct obd_export	 *lsi_osd_exp;
 	char			  lsi_osd_type[16];
 	char			  lsi_fstype[16];
-- 
1.8.3.1

From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:50 -0400
Subject: [lustre-devel] [PATCH 07/29] staging/lustre: Remove unused
	statfs_pack()
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-8-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

It's only used on the server.

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_lib.h   |  1 -
 drivers/staging/lustre/lustre/obdclass/statfs_pack.c | 14 --------------
 2 files changed, 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index b380359..35175fd 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -100,7 +100,6 @@ struct obd_client_handle {
 #define OBD_CLIENT_HANDLE_MAGIC 0xd15ea5ed
 
 /* statfs_pack.c */
-void statfs_pack(struct obd_statfs *osfs, struct kstatfs *sfs);
 void statfs_unpack(struct kstatfs *sfs, struct obd_statfs *osfs);
 
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/statfs_pack.c b/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
index cc785ab..fb4e3ae 100644
--- a/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
+++ b/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
@@ -46,20 +46,6 @@
 #include "../include/obd_support.h"
 #include "../include/obd_class.h"
 
-void statfs_pack(struct obd_statfs *osfs, struct kstatfs *sfs)
-{
-	memset(osfs, 0, sizeof(*osfs));
-	osfs->os_type = sfs->f_type;
-	osfs->os_blocks = sfs->f_blocks;
-	osfs->os_bfree = sfs->f_bfree;
-	osfs->os_bavail = sfs->f_bavail;
-	osfs->os_files = sfs->f_files;
-	osfs->os_ffree = sfs->f_ffree;
-	osfs->os_bsize = sfs->f_bsize;
-	osfs->os_namelen = sfs->f_namelen;
-}
-EXPORT_SYMBOL(statfs_pack);
-
 void statfs_unpack(struct kstatfs *sfs, struct obd_statfs *osfs)
 {
 	memset(sfs, 0, sizeof(*sfs));
-- 
2.1.0

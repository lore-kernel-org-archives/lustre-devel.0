From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:57 -0400
Subject: [lustre-devel] [PATCH 14/29] staging/lustre: Remove unused function
	server_name2svname()
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-15-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

All users are only in the server code

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre_disk.h    |  2 --
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 27 ----------------------
 2 files changed, 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index ec33259..4178c85 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -385,8 +385,6 @@ struct lustre_mount_info {
 /* obd_mount.c */
 int server_name2fsname(const char *svname, char *fsname, const char **endptr);
 int server_name2index(const char *svname, __u32 *idx, const char **endptr);
-int server_name2svname(const char *label, char *svname, const char **endptr,
-		       size_t svsize);
 
 int lustre_put_lsi(struct super_block *sb);
 int lustre_start_simple(char *obdname, char *type, char *uuid,
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 16009a6..bc15e15 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -599,33 +599,6 @@ int server_name2fsname(const char *svname, char *fsname, const char **endptr)
 }
 EXPORT_SYMBOL(server_name2fsname);
 
-/**
- * Get service name (svname) from string
- * rc < 0 on error
- * if endptr isn't NULL it is set to end of fsname *
- */
-int server_name2svname(const char *label, char *svname, const char **endptr,
-		       size_t svsize)
-{
-	int rc;
-	const char *dash;
-
-	/* We use server_name2fsname() just for parsing */
-	rc = server_name2fsname(label, NULL, &dash);
-	if (rc != 0)
-		return rc;
-
-	if (endptr != NULL)
-		*endptr = dash;
-
-	if (strlcpy(svname, dash + 1, svsize) >= svsize)
-		return -E2BIG;
-
-	return 0;
-}
-EXPORT_SYMBOL(server_name2svname);
-
-
 /* Get the index from the obd name.
    rc = server type, or
    rc < 0  on error
-- 
2.1.0

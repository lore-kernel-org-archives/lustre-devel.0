From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 14:43:50 +1000
Subject: [lustre-devel] [PATCH 07/11] lustre: simplify some parsing in
 lmd_parse().
In-Reply-To: <153067941050.30111.13691201276059352926.stgit@noble>
References: <153067941050.30111.13691201276059352926.stgit@noble>
Message-ID: <153067943079.30111.1400570516954800906.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

1/ use kstrdup() or kstrndup() where appropriate.
2/ use kasprintf() where appropriate.
3/ use GFP_KERNEL because GFP_NOFS is not needed here.
4/ use strchrnul() instead of open-coding it.
5/ don't kfree() on error, that is done in lustre_free_lsi().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   24 +++++++-------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 708c5802ddc5..1a668874a165 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -1170,37 +1170,30 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 		/* Remove leading /s from fsname */
 		while (*++s1 == '/')
 			;
-		s2 = s1;
-		while (*s2 != '/' && *s2 != '\0')
-			s2++;
+		s2 = strchrnul(s1, '/');
 		/* Freed in lustre_free_lsi */
-		lmd->lmd_profile = kzalloc(s2 - s1 + 8, GFP_NOFS);
+		lmd->lmd_profile = kasprintf(GFP_KERNEL, "%.*s-client",
+					     (int)(s2 - s1), s1);
 		if (!lmd->lmd_profile)
 			return -ENOMEM;
 
-		strncat(lmd->lmd_profile, s1, s2 - s1);
-		strncat(lmd->lmd_profile, "-client", 7);
-
 		s1 = s2;
 		s2 = s1 + strlen(s1) - 1;
 		/* Remove padding /s from fileset */
 		while (*s2 == '/')
 			s2--;
 		if (s2 > s1) {
-			lmd->lmd_fileset = kzalloc(s2 - s1 + 2, GFP_NOFS);
-			if (!lmd->lmd_fileset) {
-				kfree(lmd->lmd_profile);
+			lmd->lmd_fileset = kstrndup(s1, s2 - s1 + 1,
+						    GFP_KERNEL);
+			if (!lmd->lmd_fileset)
 				return -ENOMEM;
-			}
-			strncat(lmd->lmd_fileset, s1, s2 - s1 + 1);
 		}
 	}
 
 	/* Freed in lustre_free_lsi */
-	lmd->lmd_dev = kzalloc(strlen(devname) + 1, GFP_NOFS);
+	lmd->lmd_dev = kstrdup(devname, GFP_KERNEL);
 	if (!lmd->lmd_dev)
 		return -ENOMEM;
-	strcpy(lmd->lmd_dev, devname);
 
 	/* Save mount options */
 	s1 = options + strlen(options) - 1;
@@ -1208,10 +1201,9 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 		*s1-- = 0;
 	if (*options != 0) {
 		/* Freed in lustre_free_lsi */
-		lmd->lmd_opts = kzalloc(strlen(options) + 1, GFP_NOFS);
+		lmd->lmd_opts = kstrdup(options, GFP_KERNEL);
 		if (!lmd->lmd_opts)
 			return -ENOMEM;
-		strcpy(lmd->lmd_opts, options);
 	}
 
 	lmd_print(lmd);

From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:00 -0400
Subject: [lustre-devel] [PATCH 23/45] lustre: obd: fix printing of client
 connection UUID
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The client connection UUID sent to the servers (ASCII format) was
being truncated to only 16 bytes in size, like '595f3c6a-20ae-4'
instead of a full UUID like '18ae0f9a-4b09-4599-8ced-0f2126eab425'.

This was caused by using UUID_SIZE to limit the size of the "%pU"
string printed to avoid overflowing the target buffer, but in fact
UUID_SIZE is the size of the binary uuid_t (16 bytes) instead of
the size of struct obd_uuid (40 bytes) where the ASCII version of
the UUID is stored.

Fix this to use sizeof(target) rather than an external constant,
which is exactly why sizeof(target) should always be used.  The
usage in osd_scrub.c is not actually broken, but it is still
better to use sizeof(target) to avoid future inconsistencies.

Fixes: e991811757a4f ("lustre: obd: replace class_uuid with linux kernel version")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13499
Lustre-commit: 9abdf96e56e23 ("LU-13499 obd: fix printing of client connection UUID")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38443
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c    | 2 +-
 fs/lustre/obdclass/obd_mount.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 83b95ce..da7604f 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1046,7 +1046,7 @@ int ll_fill_super(struct super_block *sb)
 
 	/* UUID handling */
 	generate_random_uuid(uuid.b);
-	snprintf(sbi->ll_sb_uuid.uuid, UUID_SIZE, "%pU", uuid.b);
+	snprintf(sbi->ll_sb_uuid.uuid, sizeof(sbi->ll_sb_uuid), "%pU", uuid.b);
 
 	CDEBUG(D_CONFIG, "llite sb uuid: %s\n", sbi->ll_sb_uuid.uuid);
 
diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index 84ce93b..13e6521 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -339,7 +339,7 @@ int lustre_start_mgc(struct super_block *sb)
 	}
 
 	generate_random_uuid(uuidc.b);
-	snprintf(uuid->uuid, UUID_SIZE, "%pU", uuidc.b);
+	snprintf(uuid->uuid, sizeof(*uuid), "%pU", uuidc.b);
 
 	/* Start the MGC */
 	rc = lustre_start_simple(mgcname, LUSTRE_MGC_NAME,
-- 
1.8.3.1

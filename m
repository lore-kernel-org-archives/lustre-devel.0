From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Apr 2016 16:14:13 -0400
Subject: [lustre-devel] [PATCH v2 13/16] staging: lustre: lov: return
	minimal FIEMAP for released files
In-Reply-To: <1460492056-31792-1-git-send-email-jsimmons@infradead.org>
References: <1460492056-31792-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460492056-31792-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bruno Faccini <bruno.faccini@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bruno Faccini <bruno.faccini@intel.com>

Since st_blocks = NULL is returned for released files, FIEMAP
should at least return a minimal mapping to make users aware
that file contains data but it is not immediately available.
This will make coreutils and tools such tar happy and have
them presume file is sparse.

Also, add a new test_228 in sanity-hsm to verify it works
for "[cp,tar] --sparse" commands.

Also fix a LBUG ("lov_fiemap()) ASSERTION( fm_local ) failed")
likely to occur when no-object/ENOMEM conditions and also now
when released.

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3864
Reviewed-on: http://review.whamcloud.com/7584
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Aurelien Degremont <aurelien.degremont@cea.fr>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_obd.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 1a9e3e8..9b72671 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1733,6 +1733,27 @@ static int lov_fiemap(struct lov_obd *lov, __u32 keylen, void *key,
 	unsigned int buffer_size = FIEMAP_BUFFER_SIZE;
 
 	if (!lsm_has_objects(lsm)) {
+		if (lsm && lsm_is_released(lsm) && (fm_key->fiemap.fm_start <
+		    fm_key->oa.o_size)) {
+			/*
+			 * released file, return a minimal FIEMAP if
+			 * request fits in file-size.
+			 */
+			fiemap->fm_mapped_extents = 1;
+			fiemap->fm_extents[0].fe_logical =
+					fm_key->fiemap.fm_start;
+			if (fm_key->fiemap.fm_start + fm_key->fiemap.fm_length <
+			    fm_key->oa.o_size) {
+				fiemap->fm_extents[0].fe_length =
+					fm_key->fiemap.fm_length;
+			} else {
+				fiemap->fm_extents[0].fe_length =
+					fm_key->oa.o_size - fm_key->fiemap.fm_start;
+				fiemap->fm_extents[0].fe_flags |=
+						(FIEMAP_EXTENT_UNKNOWN |
+						 FIEMAP_EXTENT_LAST);
+			}
+		}
 		rc = 0;
 		goto out;
 	}
-- 
1.7.1

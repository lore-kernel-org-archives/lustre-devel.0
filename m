From: NeilBrown <neilb@suse.com>
Date: Fri, 23 Nov 2018 18:15:27 +1100
Subject: [lustre-devel] [PATCH 1/9] lustre: obdclass: fix formating of
 connection flags
In-Reply-To: <154295730810.2850.961218355189474016.stgit@noble>
References: <154295730810.2850.961218355189474016.stgit@noble>
Message-ID: <154295732787.2850.4431010272997855706.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The current code puts the separator *only*
at the start rather than *never* at the start.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/lustre/obdclass/lprocfs_status.c        |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index feba2ef5a3bc..acfea7a44350 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -709,14 +709,14 @@ static void obd_connect_seq_flags2str(struct seq_file *m, u64 flags,
 	for (i = 0, mask = 1; i < 64; i++, mask <<= 1) {
 		if (flags & mask) {
 			seq_printf(m, "%s%s",
-				   first ? sep : "", obd_connect_names[i]);
+				   first ? "" : sep, obd_connect_names[i]);
 			first = false;
 		}
 	}
 
 	if (flags & ~(mask - 1)) {
 		seq_printf(m, "%sunknown flags %#llx",
-			   first ? sep : "", flags & ~(mask - 1));
+			   first ? "" : sep, flags & ~(mask - 1));
 		first = false;
 	}
 

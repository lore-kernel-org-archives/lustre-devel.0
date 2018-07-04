From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 14:43:50 +1000
Subject: [lustre-devel] [PATCH 09/11] lustre: remove dead code from
 obd_connect_flags2str()
In-Reply-To: <153067941050.30111.13691201276059352926.stgit@noble>
References: <153067941050.30111.13691201276059352926.stgit@noble>
Message-ID: <153067943086.30111.2323331820343229570.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In obd_connect_flags2str(), if obd_connect_names() has
fewer than 64 non-NULL entries, then the first for-loop
is dangerous.
If it has 64 or more, the first "unknown" error is pointless.

In fact, there are more than 64 entries, so provide a BUILD_BUG_ON
to that effect, and remove the pointless code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/lustre/obdclass/lprocfs_status.c        |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 9f76d8a0f5f1..377644737fb9 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -121,17 +121,14 @@ int obd_connect_flags2str(char *page, int count, u64 flags, u64 flags2,
 	__u64 mask;
 	int i, ret = 0;
 
+	BUILD_BUG_ON(ARRAY_SIZE(obd_connect_names) < 65);
+
 	for (i = 0, mask = 1; i < 64; i++, mask <<= 1) {
 		if (flags & mask)
 			ret += snprintf(page + ret, count - ret, "%s%s",
 					ret ? sep : "", obd_connect_names[i]);
 	}
 
-	if (flags & ~(mask - 1))
-		ret += snprintf(page + ret, count - ret,
-				"%sunknown flags %#llx",
-				ret ? sep : "", flags & ~(mask - 1));
-
 	if (!(flags & OBD_CONNECT_FLAGS2) || flags2 == 0)
 		return ret;
 

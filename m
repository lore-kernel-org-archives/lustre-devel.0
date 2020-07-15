From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:02 -0400
Subject: [lustre-devel] [PATCH 21/37] lnet: o2iblnd: Use ib_mtu_int_to_enum()
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Rather than bespoke code for converting an MTU into the enum,
use ib_mtu_int_to_enum().
This has slightly different behaviour for invalid values,
but those are caught when the parameter is set.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 1b622e2007483 ("LU-12678 o2iblnd: Use ib_mtu_int_to_enum()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39123
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c           | 29 +++--------------------------
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c |  4 +++-
 2 files changed, 6 insertions(+), 27 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index d8fca2a..e2e94b7 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -560,38 +560,15 @@ static struct kib_conn *kiblnd_get_conn_by_idx(struct lnet_ni *ni, int index)
 	return NULL;
 }
 
-int kiblnd_translate_mtu(int value)
-{
-	switch (value) {
-	default:
-		return -1;
-	case 0:
-		return 0;
-	case 256:
-		return IB_MTU_256;
-	case 512:
-		return IB_MTU_512;
-	case 1024:
-		return IB_MTU_1024;
-	case 2048:
-		return IB_MTU_2048;
-	case 4096:
-		return IB_MTU_4096;
-	}
-}
-
 static void kiblnd_setup_mtu_locked(struct rdma_cm_id *cmid)
 {
-	int mtu;
-
 	/* XXX There is no path record for iWARP, set by netdev->change_mtu? */
 	if (!cmid->route.path_rec)
 		return;
 
-	mtu = kiblnd_translate_mtu(*kiblnd_tunables.kib_ib_mtu);
-	LASSERT(mtu >= 0);
-	if (mtu)
-		cmid->route.path_rec->mtu = mtu;
+	if (*kiblnd_tunables.kib_ib_mtu)
+		cmid->route.path_rec->mtu =
+			ib_mtu_int_to_enum(*kiblnd_tunables.kib_ib_mtu);
 }
 
 static int kiblnd_get_completion_vector(struct kib_conn *conn, int cpt)
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index f341376..73ad22d 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -230,7 +230,9 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 	/* Current API version */
 	tunables->lnd_version = 0;
 
-	if (kiblnd_translate_mtu(*kiblnd_tunables.kib_ib_mtu) < 0) {
+	if (*kiblnd_tunables.kib_ib_mtu &&
+	    ib_mtu_enum_to_int(ib_mtu_int_to_enum(*kiblnd_tunables.kib_ib_mtu)) !=
+	    *kiblnd_tunables.kib_ib_mtu) {
 		CERROR("Invalid ib_mtu %d, expected 256/512/1024/2048/4096\n",
 		       *kiblnd_tunables.kib_ib_mtu);
 		return -EINVAL;
-- 
1.8.3.1

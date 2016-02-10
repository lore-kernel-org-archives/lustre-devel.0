From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 10 Feb 2016 13:00:19 -0500
Subject: [lustre-devel] [PATCH 2/5] staging/lustre/obdecho: Better handle
	invalid create requests
In-Reply-To: <1455127222-2557752-1-git-send-email-green@linuxhacker.ru>
References: <1455127222-2557752-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455127222-2557752-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

When gettng an invalid create request in echo code (wrong group,
or no group at all), just return an error instead of crashing.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdecho/echo_client.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index e1c9d11..4ca82af 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1210,8 +1210,10 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 	int		     rc;
 	int		     created = 0;
 
-	if ((oa->o_valid & OBD_MD_FLID) == 0) { /* no obj id */
-		CERROR("No valid oid\n");
+	if (!(oa->o_valid & OBD_MD_FLID) ||
+	    !(oa->o_valid & OBD_MD_FLGROUP) ||
+	    !fid_seq_is_echo(ostid_seq(&oa->o_oi))) {
+		CERROR("invalid oid " DOSTID "\n", POSTID(&oa->o_oi));
 		return -EINVAL;
 	}
 
@@ -1222,16 +1224,11 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 	}
 
 	/* setup object ID here */
-	LASSERT(oa->o_valid & OBD_MD_FLGROUP);
 	lsm->lsm_oi = oa->o_oi;
 
 	if (ostid_id(&lsm->lsm_oi) == 0)
 		ostid_set_id(&lsm->lsm_oi, ++last_object_id);
 
-	/* Only echo objects are allowed to be created */
-	LASSERT((oa->o_valid & OBD_MD_FLGROUP) &&
-		(ostid_seq(&oa->o_oi) == FID_SEQ_ECHO));
-
 	rc = obd_create(env, ec->ec_exp, oa, &lsm, oti);
 	if (rc != 0) {
 		CERROR("Cannot create objects: rc = %d\n", rc);
-- 
2.1.0

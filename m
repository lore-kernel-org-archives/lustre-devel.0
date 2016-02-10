From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 10 Feb 2016 13:00:18 -0500
Subject: [lustre-devel] [PATCH 1/5] staging/lustre/obdecho: Remove always
	true condition
In-Reply-To: <1455127222-2557752-1-git-send-email-green@linuxhacker.ru>
References: <1455127222-2557752-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455127222-2557752-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Dan Carpenter noticed that since we already checked for
(oa->o_valid & OBD_MD_FLID) == 0, that means
(oa->o_valid & OBD_MD_FLID) is always true after that so
no point in checking for it.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 drivers/staging/lustre/lustre/obdecho/echo_client.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index d3e398f..e1c9d11 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1222,10 +1222,8 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 	}
 
 	/* setup object ID here */
-	if (oa->o_valid & OBD_MD_FLID) {
-		LASSERT(oa->o_valid & OBD_MD_FLGROUP);
-		lsm->lsm_oi = oa->o_oi;
-	}
+	LASSERT(oa->o_valid & OBD_MD_FLGROUP);
+	lsm->lsm_oi = oa->o_oi;
 
 	if (ostid_id(&lsm->lsm_oi) == 0)
 		ostid_set_id(&lsm->lsm_oi, ++last_object_id);
-- 
2.1.0

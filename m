From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:54 -0500
Subject: [lustre-devel] [PATCH 24/35] staging: lustre: osc: osc_extent
	should hold refcount to osc_object
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

To avoid a race that osc_extent and osc_object destroy happens on the
same time, which causes kernel crash.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7164
Reviewed-on: http://review.whamcloud.com/16433
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index d17ec32..0ca01b1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -360,6 +360,7 @@ static void osc_extent_state_set(struct osc_extent *ext, int state)
 
 	RB_CLEAR_NODE(&ext->oe_node);
 	ext->oe_obj = obj;
+	cl_object_get(osc2cl(obj));
 	atomic_set(&ext->oe_refc, 1);
 	atomic_set(&ext->oe_users, 0);
 	INIT_LIST_HEAD(&ext->oe_link);
@@ -398,6 +399,7 @@ static void osc_extent_put(const struct lu_env *env, struct osc_extent *ext)
 			LDLM_LOCK_PUT(ext->oe_dlmlock);
 			ext->oe_dlmlock = NULL;
 		}
+		cl_object_put(env, osc2cl(ext->oe_obj));
 		osc_extent_free(ext);
 	}
 }
-- 
1.7.1

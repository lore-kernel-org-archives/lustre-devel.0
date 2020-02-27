From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:16 -0500
Subject: [lustre-devel] [PATCH 568/622] lnet: always check return of
 try_module_get()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-569-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

try_module_get() can fail, so the return value should be checked.
If we *know* that we already hold a reference, __module_get()
should be used instead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: a1282a0d8a53 ("LU-9679 lnet: always check return of try_module_get()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36854
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 4 +++-
 net/lnet/klnds/socklnd/socklnd.c | 3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 37d8235..f6db2c7 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2693,7 +2693,9 @@ static int kiblnd_base_startup(struct net *ns)
 
 	LASSERT(kiblnd_data.kib_init == IBLND_INIT_NOTHING);
 
-	try_module_get(THIS_MODULE);
+	if (!try_module_get(THIS_MODULE))
+		goto failed;
+
 	/* zero pointers, flags etc */
 	memset(&kiblnd_data, 0, sizeof(kiblnd_data));
 
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 593c205..9a19a3f 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2357,7 +2357,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 	/* flag lists/ptrs/locks initialised */
 	ksocknal_data.ksnd_init = SOCKNAL_INIT_DATA;
-	try_module_get(THIS_MODULE);
+	if (!try_module_get(THIS_MODULE))
+		goto failed;
 
 	/* Create a scheduler block per available CPT */
 	ksocknal_data.ksnd_schedulers = cfs_percpt_alloc(lnet_cpt_table(),
-- 
1.8.3.1

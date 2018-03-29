From: NeilBrown <neilb@suse.com>
Date: Thu, 29 Mar 2018 15:26:48 +1100
Subject: [lustre-devel] [PATCH 07/17] staging: lustre: ldlm: free resource
 when ldlm_lock_create() fails.
In-Reply-To: <152229732768.27689.4800156943561963977.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
Message-ID: <152229760844.27689.4330202028940942080.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

ldlm_lock_create() gets a resource, but don't put it on
all failure paths. It should.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index b8fd778d9832..614caa4a9b0e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1551,8 +1551,10 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 		return ERR_CAST(res);
 
 	lock = ldlm_lock_new(res);
-	if (!lock)
+	if (!lock) {
+		ldlm_resource_putref(res);
 		return ERR_PTR(-ENOMEM);
+	}
 
 	lock->l_req_mode = mode;
 	lock->l_ast_data = data;
@@ -1595,6 +1597,8 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 	return ERR_PTR(rc);
 }
 
+
+
 /**
  * Enqueue (request) a lock.
  * On the client this is called from ldlm_cli_enqueue_fini

From: NeilBrown <neilb@suse.com>
Date: Thu, 27 Sep 2018 11:14:35 +1000
Subject: [lustre-devel] [PATCH 05/25] lustre: lnet: fix race in lnet
 shutdown path
In-Reply-To: <87zhw3hkn5.fsf@notabene.neil.brown.name>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
 <1537930097-11624-6-git-send-email-jsimmons@infradead.org>
 <87zhw3hkn5.fsf@notabene.neil.brown.name>
Message-ID: <87tvmbhhc4.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Sep 27 2018, NeilBrown wrote:
>>  
>> +/* LNet states */
>> +#define LNET_STATE_SHUTDOWN		0	/* not started */
>> +#define LNET_STATE_RUNNING		1	/* started up OK */
>> +#define LNET_STATE_STOPPING		2	/* telling thread to stop */
>
> This would be nicer as an enum ...
>

I've added this:

From: NeilBrown <neilb@suse.com>
Date: Thu, 27 Sep 2018 11:13:58 +1000
Subject: [PATCH] lnet: use enum for states.

As these are arbitrary values, using a enum makes the
purpose more obvious.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h    | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 6abac191764d..14563bcafe61 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -722,14 +722,18 @@ struct lnet_msg_container {
 };
 
 /* Router Checker states */
-#define LNET_RC_STATE_SHUTDOWN		0	/* not started */
-#define LNET_RC_STATE_RUNNING		1	/* started up OK */
-#define LNET_RC_STATE_STOPPING		2	/* telling thread to stop */
+enum lnet_rc_state {
+	LNET_RC_STATE_SHUTDOWN,	/* not started */
+	LNET_RC_STATE_RUNNING,	/* started up OK */
+	LNET_RC_STATE_STOPPING,	/* telling thread to stop */
+};
 
 /* LNet states */
-#define LNET_STATE_SHUTDOWN		0	/* not started */
-#define LNET_STATE_RUNNING		1	/* started up OK */
-#define LNET_STATE_STOPPING		2	/* telling thread to stop */
+enum lnet_state {
+	LNET_STATE_SHUTDOWN,	/* not started */
+	LNET_STATE_RUNNING,	/* started up OK */
+	LNET_STATE_STOPPING,	/* telling thread to stop */
+};
 
 struct lnet {
 	/* CPU partition table of LNet */
@@ -793,7 +797,7 @@ struct lnet {
 	struct lnet_ping_info		 *ln_ping_info;
 
 	/* router checker startup/shutdown state */
-	int				  ln_rc_state;
+	enum lnet_rc_state		  ln_rc_state;
 	/* router checker's event queue */
 	struct lnet_handle_eq		  ln_rc_eqh;
 	/* rcd still pending on net */
@@ -811,7 +815,7 @@ struct lnet {
 	/* LNetNIInit/LNetNIFini counter */
 	int				  ln_refcount;
 	/* SHUTDOWN/RUNNING/STOPPING */
-	int				  ln_state;
+	enum lnet_state			  ln_state;
 
 	int				  ln_routing;	/* am I a router? */
 	lnet_pid_t			  ln_pid;	/* requested pid */
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180927/29ba60a1/attachment.sig>

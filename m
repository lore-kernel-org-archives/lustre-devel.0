From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Fri,  7 Apr 2017 17:57:02 -0700
Subject: [lustre-devel] [PATCH 04/12] fs: ceph: CURRENT_TIME with
	ktime_get_real_ts()
In-Reply-To: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <1491613030-11599-5-git-send-email-deepa.kernel@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: yuchao0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, clm-b10kYP2dOMg@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, dushistov-JGs/UdohzUI@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, dsterba-IBi9RG/b67k@public.gmane.org, jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbacik-b10kYP2dOMg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-f2fs-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-btrfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

CURRENT_TIME is not y2038 safe.
The macro will be deleted and all the references to it
will be replaced by ktime_get_* apis.

struct timespec is also not y2038 safe.
Retain timespec for timestamp representation here as ceph
uses it internally everywhere.
These references will be changed to use struct timespec64
in a separate patch.

The current_fs_time() api is being changed to use vfs
struct inode* as an argument instead of struct super_block*.

Set the new mds client request r_stamp field using
ktime_get_real_ts() instead of using current_fs_time().

Also, since r_stamp is used as mtime on the server, use
timespec_trunc() to truncate the timestamp, using the right
granularity from the superblock.

This api will be transitioned to be y2038 safe along
with vfs.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/block/rbd.c   | 2 +-
 fs/ceph/mds_client.c  | 4 +++-
 net/ceph/messenger.c  | 6 ++++--
 net/ceph/osd_client.c | 4 ++--
 4 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/block/rbd.c b/drivers/block/rbd.c
index 517838b..77204da 100644
--- a/drivers/block/rbd.c
+++ b/drivers/block/rbd.c
@@ -1922,7 +1922,7 @@ static void rbd_osd_req_format_write(struct rbd_obj_request *obj_request)
 {
 	struct ceph_osd_request *osd_req = obj_request->osd_req;
 
-	osd_req->r_mtime = CURRENT_TIME;
+	ktime_get_real_ts(&osd_req->r_mtime);
 	osd_req->r_data_offset = obj_request->offset;
 }
 
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index c681762..1d3fa90 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -1666,6 +1666,7 @@ struct ceph_mds_request *
 ceph_mdsc_create_request(struct ceph_mds_client *mdsc, int op, int mode)
 {
 	struct ceph_mds_request *req = kzalloc(sizeof(*req), GFP_NOFS);
+	struct timespec ts;
 
 	if (!req)
 		return ERR_PTR(-ENOMEM);
@@ -1684,7 +1685,8 @@ ceph_mdsc_create_request(struct ceph_mds_client *mdsc, int op, int mode)
 	init_completion(&req->r_safe_completion);
 	INIT_LIST_HEAD(&req->r_unsafe_item);
 
-	req->r_stamp = current_fs_time(mdsc->fsc->sb);
+	ktime_get_real_ts(&ts);
+	req->r_stamp = timespec_trunc(ts, mdsc->fsc->sb->s_time_gran);
 
 	req->r_op = op;
 	req->r_direct_mode = mode;
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index f76bb33..5766a6c 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -1386,8 +1386,9 @@ static void prepare_write_keepalive(struct ceph_connection *con)
 	dout("prepare_write_keepalive %p\n", con);
 	con_out_kvec_reset(con);
 	if (con->peer_features & CEPH_FEATURE_MSGR_KEEPALIVE2) {
-		struct timespec now = CURRENT_TIME;
+		struct timespec now;
 
+		ktime_get_real_ts(&now);
 		con_out_kvec_add(con, sizeof(tag_keepalive2), &tag_keepalive2);
 		ceph_encode_timespec(&con->out_temp_keepalive2, &now);
 		con_out_kvec_add(con, sizeof(con->out_temp_keepalive2),
@@ -3176,8 +3177,9 @@ bool ceph_con_keepalive_expired(struct ceph_connection *con,
 {
 	if (interval > 0 &&
 	    (con->peer_features & CEPH_FEATURE_MSGR_KEEPALIVE2)) {
-		struct timespec now = CURRENT_TIME;
+		struct timespec now;
 		struct timespec ts;
+		ktime_get_real_ts(&now);
 		jiffies_to_timespec(interval, &ts);
 		ts = timespec_add(con->last_keepalive_ack, ts);
 		return timespec_compare(&now, &ts) >= 0;
diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
index e15ea9e..242d7c0 100644
--- a/net/ceph/osd_client.c
+++ b/net/ceph/osd_client.c
@@ -3574,7 +3574,7 @@ ceph_osdc_watch(struct ceph_osd_client *osdc,
 	ceph_oid_copy(&lreq->t.base_oid, oid);
 	ceph_oloc_copy(&lreq->t.base_oloc, oloc);
 	lreq->t.flags = CEPH_OSD_FLAG_WRITE;
-	lreq->mtime = CURRENT_TIME;
+	ktime_get_real_ts(&lreq->mtime);
 
 	lreq->reg_req = alloc_linger_request(lreq);
 	if (!lreq->reg_req) {
@@ -3632,7 +3632,7 @@ int ceph_osdc_unwatch(struct ceph_osd_client *osdc,
 	ceph_oid_copy(&req->r_base_oid, &lreq->t.base_oid);
 	ceph_oloc_copy(&req->r_base_oloc, &lreq->t.base_oloc);
 	req->r_flags = CEPH_OSD_FLAG_WRITE;
-	req->r_mtime = CURRENT_TIME;
+	ktime_get_real_ts(&req->r_mtime);
 	osd_req_op_watch_init(req, 0, lreq->linger_id,
 			      CEPH_OSD_WATCH_OP_UNWATCH);
 
-- 
2.7.4

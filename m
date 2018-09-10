From: Doug Oucharek <doucharek@cray.com>
Date: Mon, 10 Sep 2018 23:32:41 +0000
Subject: [lustre-devel] [PATCH 10/34] lnet: add ni arg to
 lnet_cpt_of_nid()
In-Reply-To: <153628137163.8267.8668023630519839070.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137163.8267.8668023630519839070.stgit@noble>
Message-ID: <F7B7F3A3-A803-4E58-9402-105EE0B48B75@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso at me.com<mailto:dougso@me.com>>

Doug

On Sep 6, 2018, at 5:49 PM, NeilBrown <neilb at suse.com<mailto:neilb@suse.com>> wrote:

When choosing a cpt to use for a given network (identified by nid),
the choice might depend on a particular interface which has
already been identified - different interfaces can have different
sets of cpts.

So add an 'ni' arg to lnet_cpt_of_nid(). If given, choose a cpt
from the cpts of that interface. If not given, choose one from
the set of all cpts associated with any interface on the network.

This is part of
   8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
      LU-7734 lnet: Multi-Rail local NI split

Signed-off-by: NeilBrown <neilb at suse.com<mailto:neilb@suse.com>>
---
.../staging/lustre/include/linux/lnet/lib-lnet.h   |    4 +-
.../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    4 +-
.../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    2 -
.../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    4 +-
drivers/staging/lustre/lnet/lnet/api-ni.c          |   41 ++++++++++++--------
drivers/staging/lustre/lnet/lnet/lib-move.c        |   12 +++---
drivers/staging/lustre/lnet/lnet/lib-ptl.c         |    2 -
drivers/staging/lustre/lnet/lnet/peer.c            |    4 +-
drivers/staging/lustre/lnet/lnet/router.c          |    4 +-
drivers/staging/lustre/lnet/selftest/brw_test.c    |    2 -
drivers/staging/lustre/lnet/selftest/framework.c   |    3 +
drivers/staging/lustre/lnet/selftest/selftest.h    |    2 -
12 files changed, 48 insertions(+), 36 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 34509e52bac7..e32dbb854d80 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -395,8 +395,8 @@ lnet_net2rnethash(__u32 net)
extern struct lnet_lnd the_lolnd;
extern int avoid_asym_router_failure;

-int lnet_cpt_of_nid_locked(lnet_nid_t nid);
-int lnet_cpt_of_nid(lnet_nid_t nid);
+int lnet_cpt_of_nid_locked(lnet_nid_t nid, struct lnet_ni *ni);
+int lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni);
struct lnet_ni *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
struct lnet_ni *lnet_net2ni_locked(__u32 net, int cpt);
struct lnet_ni *lnet_net2ni(__u32 net);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index ade566d20c69..958ac9a99045 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -320,7 +320,7 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer **peerp,
{
struct kib_peer *peer;
struct kib_net *net = ni->ni_data;
- int cpt = lnet_cpt_of_nid(nid);
+ int cpt = lnet_cpt_of_nid(nid, ni);
unsigned long flags;

LASSERT(net);
@@ -643,7 +643,7 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cm

dev = net->ibn_dev;

- cpt = lnet_cpt_of_nid(peer->ibp_nid);
+ cpt = lnet_cpt_of_nid(peer->ibp_nid, peer->ibp_ni);
sched = kiblnd_data.kib_scheds[cpt];

LASSERT(sched->ibs_nthreads > 0);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index c266940cb2ae..e64c14914924 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -119,7 +119,7 @@ kiblnd_get_idle_tx(struct lnet_ni *ni, lnet_nid_t target)
struct kib_tx *tx;
struct kib_tx_poolset *tps;

- tps = net->ibn_tx_ps[lnet_cpt_of_nid(target)];
+ tps = net->ibn_tx_ps[lnet_cpt_of_nid(target, ni)];
node = kiblnd_pool_alloc_node(&tps->tps_poolset);
if (!node)
return NULL;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 2036a0ae5917..ba68bcee90bc 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -101,7 +101,7 @@ static int
ksocknal_create_peer(struct ksock_peer **peerp, struct lnet_ni *ni,
    struct lnet_process_id id)
{
- int cpt = lnet_cpt_of_nid(id.nid);
+ int cpt = lnet_cpt_of_nid(id.nid, ni);
struct ksock_net *net = ni->ni_data;
struct ksock_peer *peer;

@@ -1099,7 +1099,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
LASSERT(conn->ksnc_proto);
LASSERT(peerid.nid != LNET_NID_ANY);

- cpt = lnet_cpt_of_nid(peerid.nid);
+ cpt = lnet_cpt_of_nid(peerid.nid, ni);

if (active) {
ksocknal_peer_addref(peer);
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index c21aef32cdde..6e0b8310574d 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -713,31 +713,41 @@ lnet_nid_cpt_hash(lnet_nid_t nid, unsigned int number)
}

int
-lnet_cpt_of_nid_locked(lnet_nid_t nid)
+lnet_cpt_of_nid_locked(lnet_nid_t nid, struct lnet_ni *ni)
{
- struct lnet_ni *ni;
+ struct lnet_net *net;

/* must called with hold of lnet_net_lock */
if (LNET_CPT_NUMBER == 1)
return 0; /* the only one */

- /* take lnet_net_lock(any) would be OK */
- if (!list_empty(&the_lnet.ln_nis_cpt)) {
- list_for_each_entry(ni, &the_lnet.ln_nis_cpt, ni_cptlist) {
- if (LNET_NIDNET(ni->ni_nid) != LNET_NIDNET(nid))
- continue;
+ /*
+ * If NI is provided then use the CPT identified in the NI cpt
+ * list if one exists. If one doesn't exist, then that NI is
+ * associated with all CPTs and it follows that the net it belongs
+ * to is implicitly associated with all CPTs, so just hash the nid
+ * and return that.
+ */
+ if (ni != NULL) {
+ if (ni->ni_cpts != NULL)
+ return ni->ni_cpts[lnet_nid_cpt_hash(nid,
+     ni->ni_ncpts)];
+ else
+ return lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
+ }

- LASSERT(ni->ni_cpts);
- return ni->ni_cpts[lnet_nid_cpt_hash
-   (nid, ni->ni_ncpts)];
- }
+ /* no NI provided so look at the net */
+ net = lnet_get_net_locked(LNET_NIDNET(nid));
+
+ if (net != NULL && net->net_cpts) {
+ return net->net_cpts[lnet_nid_cpt_hash(nid, net->net_ncpts)];
}

return lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
}

int
-lnet_cpt_of_nid(lnet_nid_t nid)
+lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni)
{
int cpt;
int cpt2;
@@ -745,11 +755,10 @@ lnet_cpt_of_nid(lnet_nid_t nid)
if (LNET_CPT_NUMBER == 1)
return 0; /* the only one */

- if (list_empty(&the_lnet.ln_nis_cpt))
- return lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
-
cpt = lnet_net_lock_current();
- cpt2 = lnet_cpt_of_nid_locked(nid);
+
+ cpt2 = lnet_cpt_of_nid_locked(nid, ni);
+
lnet_net_unlock(cpt);

return cpt2;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index b6e81a693fc3..02cd1a5a466f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1095,7 +1095,9 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
msg->msg_sending = 1;

LASSERT(!msg->msg_tx_committed);
- cpt = lnet_cpt_of_nid(rtr_nid == LNET_NID_ANY ? dst_nid : rtr_nid);
+ local_ni = lnet_net2ni(LNET_NIDNET(dst_nid));
+ cpt = lnet_cpt_of_nid(rtr_nid == LNET_NID_ANY ? dst_nid : rtr_nid,
+      local_ni);
 again:
lnet_net_lock(cpt);

@@ -1188,7 +1190,7 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
* was changed when we release the lock
*/
if (rtr_nid != lp->lp_nid) {
- cpt2 = lnet_cpt_of_nid_locked(lp->lp_nid);
+ cpt2 = lp->lp_cpt;
if (cpt2 != cpt) {
if (src_ni)
lnet_ni_decref_locked(src_ni, cpt);
@@ -1677,7 +1679,7 @@ lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
payload_length = le32_to_cpu(hdr->payload_length);

for_me = (ni->ni_nid == dest_nid);
- cpt = lnet_cpt_of_nid(from_nid);
+ cpt = lnet_cpt_of_nid(from_nid, ni);

switch (type) {
case LNET_MSG_ACK:
@@ -2149,7 +2151,7 @@ lnet_create_reply_msg(struct lnet_ni *ni, struct lnet_msg *getmsg)
lnet_msg_attach_md(msg, getmd, getmd->md_offset, getmd->md_length);
lnet_res_unlock(cpt);

- cpt = lnet_cpt_of_nid(peer_id.nid);
+ cpt = lnet_cpt_of_nid(peer_id.nid, ni);

lnet_net_lock(cpt);
lnet_msg_commit(msg, cpt);
@@ -2160,7 +2162,7 @@ lnet_create_reply_msg(struct lnet_ni *ni, struct lnet_msg *getmsg)
return msg;

 drop:
- cpt = lnet_cpt_of_nid(peer_id.nid);
+ cpt = lnet_cpt_of_nid(peer_id.nid, ni);

lnet_net_lock(cpt);
the_lnet.ln_counters[cpt]->drop_count++;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 90ce51801726..c8d8162cc706 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -220,7 +220,7 @@ lnet_match2mt(struct lnet_portal *ptl, struct lnet_process_id id, __u64 mbits)

/* if it's a unique portal, return match-table hashed by NID */
return lnet_ptl_is_unique(ptl) ?
-       ptl->ptl_mtables[lnet_cpt_of_nid(id.nid)] : NULL;
+       ptl->ptl_mtables[lnet_cpt_of_nid(id.nid, NULL)] : NULL;
}

struct lnet_match_table *
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index ed29124ebded..808ce25f1f00 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -270,7 +270,7 @@ lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt)
return -ESHUTDOWN;

/* cpt can be LNET_LOCK_EX if it's called from router functions */
- cpt2 = cpt != LNET_LOCK_EX ? cpt : lnet_cpt_of_nid_locked(nid);
+ cpt2 = cpt != LNET_LOCK_EX ? cpt : lnet_cpt_of_nid_locked(nid, NULL);

ptable = the_lnet.ln_peer_tables[cpt2];
lp = lnet_find_peer_locked(ptable, nid);
@@ -362,7 +362,7 @@ lnet_debug_peer(lnet_nid_t nid)
int rc;
int cpt;

- cpt = lnet_cpt_of_nid(nid);
+ cpt = lnet_cpt_of_nid(nid, NULL);
lnet_net_lock(cpt);

rc = lnet_nid2peer_locked(&lp, nid, cpt);
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 72b8ca2b0fc6..5493d13de6d9 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1207,7 +1207,7 @@ lnet_router_checker(void *arg)
version = the_lnet.ln_routers_version;

list_for_each_entry(rtr, &the_lnet.ln_routers, lp_rtr_list) {
- cpt2 = lnet_cpt_of_nid_locked(rtr->lp_nid);
+ cpt2 = rtr->lp_cpt;
if (cpt != cpt2) {
lnet_net_unlock(cpt);
cpt = cpt2;
@@ -1693,7 +1693,7 @@ lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, time64_t when)
{
struct lnet_peer *lp = NULL;
time64_t now = ktime_get_seconds();
- int cpt = lnet_cpt_of_nid(nid);
+ int cpt = lnet_cpt_of_nid(nid, ni);

LASSERT(!in_interrupt());

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index f1ee219bc8f3..e372ff3044c8 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -124,7 +124,7 @@ brw_client_init(struct sfw_test_instance *tsi)
return -EINVAL;

list_for_each_entry(tsu, &tsi->tsi_units, tsu_list) {
- bulk = srpc_alloc_bulk(lnet_cpt_of_nid(tsu->tsu_dest.nid),
+ bulk = srpc_alloc_bulk(lnet_cpt_of_nid(tsu->tsu_dest.nid, NULL),
      off, npg, len, opc == LST_BRW_READ);
if (!bulk) {
brw_client_fini(tsi);
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 944a2a6598fa..a82efc394659 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -1013,7 +1013,8 @@ sfw_run_batch(struct sfw_batch *tsb)
tsu->tsu_loop = tsi->tsi_loop;
wi = &tsu->tsu_worker;
swi_init_workitem(wi, sfw_run_test,
-  lst_test_wq[lnet_cpt_of_nid(tsu->tsu_dest.nid)]);
+  lst_test_wq[lnet_cpt_of_nid(tsu->tsu_dest.nid,
+  NULL)]);
swi_schedule_workitem(wi);
}
}
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 9dbb0a51d430..edf783af90e8 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -527,7 +527,7 @@ srpc_init_client_rpc(struct srpc_client_rpc *rpc, struct lnet_process_id peer,

INIT_LIST_HEAD(&rpc->crpc_list);
swi_init_workitem(&rpc->crpc_wi, srpc_send_rpc,
-  lst_test_wq[lnet_cpt_of_nid(peer.nid)]);
+  lst_test_wq[lnet_cpt_of_nid(peer.nid, NULL)]);
spin_lock_init(&rpc->crpc_lock);
atomic_set(&rpc->crpc_refcount, 1); /* 1 ref for caller */




-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180910/89c3c6e7/attachment-0001.html>

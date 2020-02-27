From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:06 -0500
Subject: [lustre-devel] [PATCH 018/622] lustre: ptlrpc: Add QoS for uid and
 gid in NRS-TBF
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Teddy Chan <teddy@ddn.com>

This patch add a new QoS feature in TBF policy which could
limits the rate based on uid or gid. The policy is able to
limit the rate both on MDT and OSS site.

The command for this feature is like:
Start the tbf uid QoS on OST:
    lctl set_param ost.OSS.*.nrs_policies="tbf uid"
Limit the rate of ptlrpc requests of the uid 500
    lctl set_param ost.OSS.*.nrs_tbf_rule=
 "start tbf_name uid={500} rate=100"

Start the tbf gid QoS on OST:
    lctl set_param ost.OSS.*.nrs_policies="tbf gid"
Limit the rate of ptlrpc requests of the gid 500
    lctl set_param ost.OSS.*.nrs_tbf_rule=
 "start tbf_name gid={500} rate=100"

or use generic tbf rule to mix them on OST:
    lctl set_param ost.OSS.*.nrs_policies="tbf"
Limit the rate of ptlrpc requests of the uid 500 gid 500
    lctl set_param ost.OSS.*.nrs_tbf_rule=
 "start tbf_name uid={500}&gid={500} rate=100"

Also, you can use the following rule to control all reqs
to mds:
Start the tbf uid QoS on MDS:
    lctl set_param mds.MDS.*.nrs_policies="tbf uid"
Limit the rate of ptlrpc requests of the uid 500
    lctl set_param mds.MDS.*.nrs_tbf_rule=
 "start tbf_name uid={500} rate=100"

For the linux client we need to send the uid and gid
information to the NRS-TBF handling on the servers.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9658
Lustre-commit: e0cdde123c14 ("LU-9658 ptlrpc: Add QoS for uid and gid in NRS-TBF")
Signed-off-by: Teddy Chan <teddy@ddn.com>
Signed-off-by: Li Xi <lixi@ddn.com>
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/27608
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_object.c |  5 ++---
 fs/lustre/obdclass/obdo.c    |  5 +++++
 fs/lustre/osc/osc_request.c  | 10 ++++++++++
 3 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index 24cde0d..eeb8823 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -196,7 +196,7 @@ static int vvp_object_glimpse(const struct lu_env *env,
 static void vvp_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 			     struct cl_req_attr *attr)
 {
-	u64 valid_flags = OBD_MD_FLTYPE;
+	u64 valid_flags = OBD_MD_FLTYPE | OBD_MD_FLUID | OBD_MD_FLGID;
 	struct inode *inode;
 	struct obdo *oa;
 
@@ -204,8 +204,7 @@ static void vvp_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 	inode = vvp_object_inode(obj);
 
 	if (attr->cra_type == CRT_WRITE) {
-		valid_flags |= OBD_MD_FLMTIME | OBD_MD_FLCTIME |
-			       OBD_MD_FLUID | OBD_MD_FLGID;
+		valid_flags |= OBD_MD_FLMTIME | OBD_MD_FLCTIME;
 		obdo_set_o_projid(oa, ll_i2info(inode)->lli_projid);
 	}
 	obdo_from_inode(oa, inode, valid_flags & attr->cra_flags);
diff --git a/fs/lustre/obdclass/obdo.c b/fs/lustre/obdclass/obdo.c
index 1926896..e5475f1 100644
--- a/fs/lustre/obdclass/obdo.c
+++ b/fs/lustre/obdclass/obdo.c
@@ -144,6 +144,11 @@ void lustre_set_wire_obdo(const struct obd_connect_data *ocd,
 	if (!ocd)
 		return;
 
+	if (!(wobdo->o_valid & OBD_MD_FLUID))
+		wobdo->o_uid = from_kuid(&init_user_ns, current_uid());
+	if (!(wobdo->o_valid & OBD_MD_FLGID))
+		wobdo->o_gid = from_kgid(&init_user_ns, current_gid());
+
 	if (unlikely(!(ocd->ocd_connect_flags & OBD_CONNECT_FID)) &&
 	    fid_seq_is_echo(ostid_seq(&lobdo->o_oi))) {
 		/*
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 300dee5..99c9620 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1184,6 +1184,16 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 
 	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa, oa);
 
+	/* For READ and WRITE, we can't fill o_uid and o_gid using from_kuid()
+	 * and from_kgid(), because they are asynchronous. Fortunately, variable
+	 * oa contains valid o_uid and o_gid in these two operations.
+	 * Besides, filling o_uid and o_gid is enough for nrs-tbf, see LU-9658.
+	 * OBD_MD_FLUID and OBD_MD_FLUID is not set in order to avoid breaking
+	 * other process logic
+	 */
+	body->oa.o_uid = oa->o_uid;
+	body->oa.o_gid = oa->o_gid;
+
 	obdo_to_ioobj(oa, ioobj);
 	ioobj->ioo_bufcnt = niocount;
 	/* The high bits of ioo_max_brw tells server _maximum_ number of bulks
-- 
1.8.3.1

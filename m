From: Thomas Stibor <t.stibor@gsi.de>
Date: Wed, 17 Apr 2013 08:46:15 +0200
Subject: [Lustre-devel] UID/GID access control in Lustre
Message-ID: <516E4537.4000806@gsi.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello list members,

I started to develop a kernel module which hooks into Lustre 2.3 for
controlling data access based on nid and uid/gid. The background
is the following: Here at GSI we have currently a reserved uid/gid space
which partner institutes are using to access our exported Lustre mounts.
However, we currently have no mechanism to control (guaranty) that the
reserved uid/gid space are used. We can control the access on IP based
firewall level but not on a UID/GID level.

The kernel module reads input via /proc/lugac (Lustre User Group Access
Control), e.g.

echo "10.10.[1-10].[1-128]@tcp5 [100-200] [100-200]" > /proc/lugac

and stores this information within a c-struct which is stored as a node
in a linked-list.
The kernel module exports the function:

int allow_access_nugid(const char *const nid, const uid_t uid, const
gid_t gid)

which tells whether access for a certain nid, uid and gid is granted.
I did some "integration experiments" after studying the Lustre 2.3 code
and tracing the function calls with lctl debug_daemon and
sysctl -w lnet.debug=+trace
sysctl -w lnet.debug=+info
sysctl -w lnet.debug=+inode
sysctl -w lnet.debug=+super
sysctl -w lnet.debug=+ext2
....

and integrated the function allow_access_nugid(...) in
lustre/mdt/mdt_lib.c inside

static int old_init_ucred(struct mdt_thread_info *info,
                          struct mdt_body *body)
{
        struct md_ucred *uc = mdt_ucred(info);
        struct mdt_device  *mdt = info->mti_mdt;
        struct md_identity *identity = NULL;

        ENTRY;

        uc->mu_valid = UCRED_INVALID;
        uc->mu_o_uid = uc->mu_uid = body->uid;
        uc->mu_o_gid = uc->mu_gid = body->gid;
        uc->mu_o_fsuid = uc->mu_fsuid = body->fsuid;
        uc->mu_o_fsgid = uc->mu_fsgid = body->fsgid;
        uc->mu_suppgids[0] = body->suppgid;
        uc->mu_suppgids[1] = -1;
        uc->mu_ginfo = NULL;
        if (!is_identity_get_disabled(mdt->mdt_identity_cache)) {
                identity = mdt_identity_get(mdt->mdt_identity_cache,
                                            uc->mu_fsuid);
                if (IS_ERR(identity)) {
                        if (unlikely(PTR_ERR(identity) == -EREMCHG)) {
                                identity = NULL;
                        } else {
                                CDEBUG(D_SEC, "Deny access without
identity: "
                                       "uid %u\n", uc->mu_fsuid);
                                RETURN(-EACCES);
                        }
                }
        }
        /* MODIFICATION: UID/GID access control verification. */
        if
(allow_access_nugid(libcfs_nid2str(mdt_info_req(info)->rq_peer.nid),
                            body->uid, body->gid)) {
                     CDEBUG(D_INFO, "Deny access for %s, uid: %d, gid:
%d due to missing entry in access control list\n",

libcfs_nid2str(mdt_info_req(info)->rq_peer.nid), body->uid, body->gid);
            RETURN(-EACCES);
        }
        ...
}

At a first view it seems to work. A user where nid/uid/gid is not a
member of the linked list gets e.g.

user1 at 10.10.1.1:uid:5:gid:5>ls /lustre
ls: cannot access /lustre: Permission denied

Another user which has the proper entry in the linked list gets

user2 at 10.10.1.1:uid:105:gid:105>ls /lustre
data.raw

However, repeating the same steps with user1 again, he/she can also see
the file data.raw.

Can anybody tell me in which Lustre function such a allow_access_nugid()
could be properly placed?
I also started to study lustre/mdd/mdd_permission.c, however, also with
no "integration success".

The long term goal is to setup a Kerberized Lustre and to use the
/etc/idmap.conf functionality , however, currently the Kerberos support
for Lustre > 2.3 is
broken and I have started to work on some patches for fixing this problem.

Best wishes,
 Thomas

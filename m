From: Kilian CAVALOTTI <kilian.cavalotti.work@gmail.com>
Date: Thu, 25 Aug 2011 11:56:02 +0200
Subject: [Lustre-devel] Changelogs and xattrs
Message-ID: <CAJz=VjFQPXFuQ=BBK3wF5UJXe_2RLv9CR=Bpi5h_8tYAH4i5xg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all,

Using version 2.0, I noticed that changelogs emitted on extended
attributes modification depend on the namespace the xattr belongs to.

For instance, when setting an attribute in user.*, an XATTR changelog
is recorded:

root:~ # setfattr -n user.foo -v bar /mnt/lustre/file
root:~ # getfattr -d -m user.* /mnt/lustre/file
getfattr: Removing leading '/' from absolute path names
# file: mnt/lustre/file
user.foo="bar"
root:~ # lfs changelog lustre-MDT0000
19810 00MARK ?09:17:11.709504920 2011.08.25 0x0 t=[0x40001:0x0:0x0]
p=[0:0x0:0x0] mdd_obd-lustre-MDT0000-0
19811 15XATTR 09:17:17.932504772 2011.08.25 0x0 t=[0x200000401:0x1634:0x0]

But when I try to set an attribute in trusted.*, system.* or
security.* the recorded changelog is of the CTIME type:

root:~ # lfs changelog_clear lustre-MDT0000 cl1 0
root:~ # lfs changelog lustre-MDT0000
19825 00MARK ?09:30:00.495488159 2011.08.25 0x0 t=[0x40001:0x0:0x0]
p=[0:0x0:0x0] mdd_obd-lustre-MDT0000-0
root:~ # setfattr -n trusted.foo -v bar /mnt/lustre/testfile
root:~ # lfs changelog lustre-MDT0000
19825 00MARK ?09:30:00.495488159 2011.08.25 0x0 t=[0x40001:0x0:0x0]
p=[0:0x0:0x0] mdd_obd-lustre-MDT0000-0
19826 18CTIME 09:30:27.887487611 2011.08.25 0x4 t=[0x200000401:0x1634:0x0]

Note: the CTIME changelog is only recorded after the changelogs have
been cleared after setting an attributed in user.*. When it's not, no
changelog is recorded at all for subsequent changes in
{trusted,security,system}.*

When the first attribute is set in user.*, an XATTR event is recorded
in the changelog. After that, any attribute modification in
{trusted,security,system}.* does not generate any changelog. But a
modification in user.* still does.

root:~ # lfs changelog_clear lustre-MDT0000 cl1 0
root:~ # setfattr -n user.foo -v bar /mnt/lustre/testfile
root:~ # lfs changelog lustre-MDT0000
19827 00MARK ?09:34:31.733482876 2011.08.25 0x0 t=[0x40001:0x0:0x0]
p=[0:0x0:0x0] mdd_obd-lustre-MDT0000-0
19828 15XATTR 09:34:37.653482765 2011.08.25 0x0 t=[0x200000401:0x1634:0x0]
root:~ # setfattr -n trusted.foo -v bar /mnt/lustre/testfile
root:~ # lfs changelog lustre-MDT0000
19827 00MARK ?09:34:31.733482876 2011.08.25 0x0 t=[0x40001:0x0:0x0]
p=[0:0x0:0x0] mdd_obd-lustre-MDT0000-0
19828 15XATTR 09:34:37.653482765 2011.08.25 0x0 t=[0x200000401:0x1634:0x0]
root:~ # setfattr -n security.foo -v bar /mnt/lustre/testfile
root:~ # lfs changelog lustre-MDT0000
19827 00MARK ?09:34:31.733482876 2011.08.25 0x0 t=[0x40001:0x0:0x0]
p=[0:0x0:0x0] mdd_obd-lustre-MDT0000-0
19828 15XATTR 09:34:37.653482765 2011.08.25 0x0 t=[0x200000401:0x1634:0x0]
root:~ # setfattr -n user.foo -v bar /mnt/lustre/testfile
root:~ # lfs changelog lustre-MDT0000
19827 00MARK ?09:34:31.733482876 2011.08.25 0x0 t=[0x40001:0x0:0x0]
p=[0:0x0:0x0] mdd_obd-lustre-MDT0000-0
19828 15XATTR 09:34:37.653482765 2011.08.25 0x0 t=[0x200000401:0x1634:0x0]
19829 15XATTR 09:35:16.723482030 2011.08.25 0x0 t=[0x200000401:0x1634:0x0]


Quickly looking at the code, it seems indeed that only user xattr
changes are recorded. In lustre/mdd/mdd_object.c:

static int mdd_xattr_set(const struct lu_env *env, struct md_object *obj,
                         const struct lu_buf *buf, const char *name,
                         int fl)
{
...
        /* Only record user xattr changes */
        if ((rc == 0) && (strncmp("user.", name, 5) == 0))
                rc = mdd_changelog_data_store(env, mdd, CL_XATTR, 0, mdd_obj,
...
}


So my questions are:
1. why are xattr changes ignored in namespaces other than user.*?
2. why xattr changes in {trusted,security,system}.* generate a CTIME
event after the changelogs have been cleared? And not otherwise?


Thanks a lot for any insight.
Cheers,
--
Kilian

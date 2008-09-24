From: Nathan Roberts <nroberts@yahoo-inc.com>
Date: Wed, 24 Sep 2008 10:43:32 -0500
Subject: [Lustre-devel] Question on iopen_lookup()
Message-ID: <48DA6024.5080507@yahoo-inc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

(Sorry if this is duplicated, mailing wasn't cooperating)
Hello,

I've got a quick question on the open_by_inode support that ldiskfs
is using.

Since there is only a single magic ".inode" directory inode, AND
real_lookup() locks the directory mutex when performing the lookup
of the actual file inode, I'm seeing major contention for this lock.
The contention makes it impossible for the io scheduler to do anything
intelligent when there are lots of opens occurring at the same time,
thus killing small file performance.

Since this directory isn't real I don't think there is a reason
we need to hold the lock during this type of lookup. I added
a couple of lines to drop and re-aquire this lock around the
expensive iget() just to see if it removes the bottleneck. My
read request rate went up from 96 ops/second to 565 so it does
seem to help.

Can you see any danger in this type of approach? If it is a completely
broken approach, any suggestions on how to go about removing this
contention?

Thanks for any insight.
Nathan Roberts


----


static struct dentry *iopen_lookup(struct inode * dir, struct dentry *dentry,
                                    struct nameidata *nd)
{
         struct inode *inode;
         unsigned long ino;
         struct list_head *lp;
         struct dentry *alternate;
         char buf[IOPEN_NAME_LEN];

         if (dentry->d_name.len >= IOPEN_NAME_LEN)
                 return ERR_PTR(-ENAMETOOLONG);

         memcpy(buf, dentry->d_name.name, dentry->d_name.len);
         buf[dentry->d_name.len] = 0;

         if (strcmp(buf, ".") == 0)
                 ino = dir->i_ino;
         else if (strcmp(buf, "..") == 0)
                 ino = EXT3_ROOT_INO;
         else
                 ino = simple_strtoul(buf, 0, 0);

         if ((ino != EXT3_ROOT_INO &&
              ino < EXT3_FIRST_INO(dir->i_sb)) ||
             ino > le32_to_cpu(EXT3_SB(dir->i_sb)->s_es->s_inodes_count))
                 return ERR_PTR(-ENOENT);

+       mutex_unlock(&dir->i_mutex);
	inode = iget(dir->i_sb, ino);
+	mutex_lock(&dir->i_mutex);
         if (!inode)
                 return ERR_PTR(-EACCES);
         if (is_bad_inode(inode)) {
                 iput(inode);
                 return ERR_PTR(-ENOENT);
         }

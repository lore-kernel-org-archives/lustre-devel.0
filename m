From: James Simmons <jsimmons@infradead.org>
Date: Wed, 11 May 2016 16:54:01 +0100 (BST)
Subject: [lustre-devel] [PATCH] xattr handlers: fixup generic_listxattr
In-Reply-To: <551ED650-CBF8-40D6-85A0-BDB3C281C247@dilger.ca>
References: <1462229118-13123-1-git-send-email-agruenba@redhat.com>
	<551ED650-CBF8-40D6-85A0-BDB3C281C247@dilger.ca>
Message-ID: <alpine.LFD.2.20.1605111649310.27778@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andreas Gruenbacher <agruenba@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Tyler Hicks <tyhicks@canonical.com>, ecryptfs@vger.kernel.org, Miklos Szeredi <miklos@szeredi.hu>, linux-unionfs@vger.kernel.org, fuse-devel@lists.sourceforge.net, Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-ima-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, David Howells <dhowells@redhat.com>, Serge Hallyn <serge.hallyn@canonical.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, Casey Schaufler <casey@schaufler-ca.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Lustre Developement <lustre-devel@lists.lustre.org>


While looking at porting lustre to use xattr handlers I
noticed issues in generic_listxattr() when handle->list()
is used. The function generic_listxattr() generates it
results from the handle->name field. If the current handle
name field is NULL then generic_listxattr() will call
handle->list() if it exist. Calling handle->list() has no
affect on the output since their is no way to set the
name field of the handler. This patch allows the passing
in of the handler to *list() so the handle->name field
can be set. Now with the ability to create the name field
after its contents are transfer to the passed in buffer
the name field has to be freed to prevent memory leaks.
Also freeing the memory of the name field ensures that
the *list() function will be called at a latter time
which ensures the xattr list is not stale. This patch
is against Viro's work.xattrs branch.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/ext2/xattr.c       |    2 +-
 fs/ext4/xattr.c       |    2 +-
 fs/f2fs/xattr.c       |    2 +-
 fs/reiserfs/xattr.c   |    2 +-
 fs/squashfs/xattr.c   |    2 +-
 fs/xattr.c            |    8 ++++++--
 include/linux/xattr.h |    2 +-
 7 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/fs/ext2/xattr.c b/fs/ext2/xattr.c
index 1a5e3bf..0aab6a5 100644
--- a/fs/ext2/xattr.c
+++ b/fs/ext2/xattr.c
@@ -290,7 +290,7 @@ bad_block:	ext2_error(inode->i_sb, "ext2_xattr_list",
 		const struct xattr_handler *handler =
 			ext2_xattr_handler(entry->e_name_index);
 
-		if (handler && (!handler->list || handler->list(dentry))) {
+		if (handler && (!handler->list || handler->list(handler, dentry))) {
 			const char *prefix = handler->prefix ?: handler->name;
 			size_t prefix_len = strlen(prefix);
 			size_t size = prefix_len + entry->e_name_len + 1;
diff --git a/fs/ext4/xattr.c b/fs/ext4/xattr.c
index 0441e05..0941198 100644
--- a/fs/ext4/xattr.c
+++ b/fs/ext4/xattr.c
@@ -402,7 +402,7 @@ ext4_xattr_list_entries(struct dentry *dentry, struct ext4_xattr_entry *entry,
 		const struct xattr_handler *handler =
 			ext4_xattr_handler(entry->e_name_index);
 
-		if (handler && (!handler->list || handler->list(dentry))) {
+		if (handler && (!handler->list || handler->list(handler, dentry))) {
 			const char *prefix = handler->prefix ?: handler->name;
 			size_t prefix_len = strlen(prefix);
 			size_t size = prefix_len + entry->e_name_len + 1;
diff --git a/fs/f2fs/xattr.c b/fs/f2fs/xattr.c
index 17fd2b1..0cb0fc1 100644
--- a/fs/f2fs/xattr.c
+++ b/fs/f2fs/xattr.c
@@ -412,7 +412,7 @@ ssize_t f2fs_listxattr(struct dentry *dentry, char *buffer, size_t buffer_size)
 		size_t prefix_len;
 		size_t size;
 
-		if (!handler || (handler->list && !handler->list(dentry)))
+		if (!handler || (handler->list && !handler->list(handler, dentry)))
 			continue;
 
 		prefix = handler->prefix ?: handler->name;
diff --git a/fs/reiserfs/xattr.c b/fs/reiserfs/xattr.c
index 02137bb..509d2a0 100644
--- a/fs/reiserfs/xattr.c
+++ b/fs/reiserfs/xattr.c
@@ -787,7 +787,7 @@ static int listxattr_filler(struct dir_context *ctx, const char *name,
 		handler = find_xattr_handler_prefix(b->dentry->d_sb->s_xattr,
 						    name);
 		if (!handler /* Unsupported xattr name */ ||
-		    (handler->list && !handler->list(b->dentry)))
+		    (handler->list && !handler->list(handler, b->dentry)))
 			return 0;
 		size = namelen + 1;
 		if (b->buf) {
diff --git a/fs/squashfs/xattr.c b/fs/squashfs/xattr.c
index 1548b37..64e8573 100644
--- a/fs/squashfs/xattr.c
+++ b/fs/squashfs/xattr.c
@@ -67,7 +67,7 @@ ssize_t squashfs_listxattr(struct dentry *d, char *buffer,
 
 		name_size = le16_to_cpu(entry.size);
 		handler = squashfs_xattr_handler(le16_to_cpu(entry.type));
-		if (handler && (!handler->list || handler->list(d))) {
+		if (handler && (!handler->list || handler->list(handler, d))) {
 			const char *prefix = handler->prefix ?: handler->name;
 			size_t prefix_size = strlen(prefix);
 
diff --git a/fs/xattr.c b/fs/xattr.c
index b11945e..1ec51a7 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -716,9 +716,11 @@ generic_listxattr(struct dentry *dentry, char *buffer, size_t buffer_size)
 	if (!buffer) {
 		for_each_xattr_handler(handlers, handler) {
 			if (!handler->name ||
-			    (handler->list && !handler->list(dentry)))
+			    (handler->list && !handler->list(handler, dentry)))
 				continue;
 			size += strlen(handler->name) + 1;
+			if (handler->list)
+				kfree(handler->name);
 		}
 	} else {
 		char *buf = buffer;
@@ -726,7 +728,7 @@ generic_listxattr(struct dentry *dentry, char *buffer, size_t buffer_size)
 
 		for_each_xattr_handler(handlers, handler) {
 			if (!handler->name ||
-			    (handler->list && !handler->list(dentry)))
+			    (handler->list && !handler->list(handler, dentry)))
 				continue;
 			len = strlen(handler->name);
 			if (len + 1 > buffer_size)
@@ -734,6 +736,8 @@ generic_listxattr(struct dentry *dentry, char *buffer, size_t buffer_size)
 			memcpy(buf, handler->name, len + 1);
 			buf += len + 1;
 			buffer_size -= len + 1;
+			if (handler->list)
+				kfree(handler->name);
 		}
 		size = buf - buffer;
 	}
diff --git a/include/linux/xattr.h b/include/linux/xattr.h
index 1cc4c57..e4fb463 100644
--- a/include/linux/xattr.h
+++ b/include/linux/xattr.h
@@ -28,7 +28,7 @@ struct xattr_handler {
 	const char *name;
 	const char *prefix;
 	int flags;      /* fs private flags */
-	bool (*list)(struct dentry *dentry);
+	bool (*list)(const struct xattr_handler *, struct dentry *dentry);
 	int (*get)(const struct xattr_handler *, struct dentry *dentry,
 		   struct inode *inode, const char *name, void *buffer,
 		   size_t size);
-- 
1.7.1

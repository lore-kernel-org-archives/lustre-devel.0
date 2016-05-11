From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Wed, 11 May 2016 19:01:37 +0200
Subject: [lustre-devel] [PATCH] xattr handlers: fixup generic_listxattr
In-Reply-To: <alpine.LFD.2.20.1605111649310.27778@casper.infradead.org>
References: <1462229118-13123-1-git-send-email-agruenba@redhat.com>
	<551ED650-CBF8-40D6-85A0-BDB3C281C247@dilger.ca>
	<alpine.LFD.2.20.1605111649310.27778@casper.infradead.org>
Message-ID: <CAHc6FU4LPMkMqYcY17ksDBBhLfUhGyz6K6HvLogCZKvahDzdwQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Tyler Hicks <tyhicks@canonical.com>, ecryptfs@vger.kernel.org, Miklos Szeredi <miklos@szeredi.hu>, linux-unionfs@vger.kernel.org, fuse-devel@lists.sourceforge.net, Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-ima-devel@lists.sourceforge.net, LSM <linux-security-module@vger.kernel.org>, David Howells <dhowells@redhat.com>, Serge Hallyn <serge.hallyn@canonical.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, Casey Schaufler <casey@schaufler-ca.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Lustre Developement <lustre-devel@lists.lustre.org>

On Wed, May 11, 2016 at 5:54 PM, James Simmons <jsimmons@infradead.org> wrote:
> While looking at porting lustre to use xattr handlers I
> noticed issues in generic_listxattr() when handle->list()
> is used. The function generic_listxattr() generates it
> results from the handle->name field. If the current handle
> name field is NULL then generic_listxattr() will call
> handle->list() if it exist.

generic_listxattr() is different from generic_getxattr() /
generic_setxattr() / generic_removexattr. It makes sense only for
filesystems that support a fixed set of xattrs, which means that all
handlers will have handler->name set.

If any of the handlers has handler->prefix set instead, that handler
matches a whole set of attributes. Generic_listxattr() would have to
fill in all of those names matching that handler, but it doesn't know
which those are.

It is common for filesystems to have their own listxattr inode
operation and still use generic_{get,set,remove}xattr.

> Calling handle->list() has no
> affect on the output since their is no way to set the
> name field of the handler. This patch allows the passing
> in of the handler to *list() so the handle->name field
> can be set.

No, that's broken. The handlers pointed at by sb->s_xattr must not be
modified. Doing so would mess up all other concurrent getxattr /
setxattr / listxattr / removexattr operations on that superblock.

Andreas

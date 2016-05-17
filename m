From: James Simmons <jsimmons@infradead.org>
Date: Tue, 17 May 2016 02:12:15 +0100 (BST)
Subject: [lustre-devel] [PATCH] xattr handlers: fixup generic_listxattr
In-Reply-To: <CAHc6FU4LPMkMqYcY17ksDBBhLfUhGyz6K6HvLogCZKvahDzdwQ@mail.gmail.com>
References: <1462229118-13123-1-git-send-email-agruenba@redhat.com>
	<551ED650-CBF8-40D6-85A0-BDB3C281C247@dilger.ca>
	<alpine.LFD.2.20.1605111649310.27778@casper.infradead.org>
	<CAHc6FU4LPMkMqYcY17ksDBBhLfUhGyz6K6HvLogCZKvahDzdwQ@mail.gmail.com>
Message-ID: <alpine.LFD.2.20.1605170137480.13979@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Tyler Hicks <tyhicks@canonical.com>, ecryptfs@vger.kernel.org, Miklos Szeredi <miklos@szeredi.hu>, linux-unionfs@vger.kernel.org, fuse-devel@lists.sourceforge.net, Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-ima-devel@lists.sourceforge.net, LSM <linux-security-module@vger.kernel.org>, David Howells <dhowells@redhat.com>, Serge Hallyn <serge.hallyn@canonical.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, Casey Schaufler <casey@schaufler-ca.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Lustre Developement <lustre-devel@lists.lustre.org>


> generic_listxattr() is different from generic_getxattr() /
> generic_setxattr() / generic_removexattr. It makes sense only for
> filesystems that support a fixed set of xattrs, which means that all
> handlers will have handler->name set.
> 
> If any of the handlers has handler->prefix set instead, that handler
> matches a whole set of attributes. Generic_listxattr() would have to
> fill in all of those names matching that handler, but it doesn't know
> which those are.
> 
> It is common for filesystems to have their own listxattr inode
> operation and still use generic_{get,set,remove}xattr.

That clears things up a bit. So that leaves a few questions. First 
question is looking at several of the file system's implementations
I noticed it contains loops such as:

list_for_each_xattr(entry, base_addr) {
	const struct xattr_handler *handler =                
		blah_xattr_handler(entry->e_name_index);
        const char *prefix;
        size_t prefix_len;
        size_t size;

        if (!handler || (handler->list && !handler->list(dentry)))
        	continue;

	...
}

Is the handler->list() test needed for a private listxattr implementation? 
Also I don't see anyone using handler->list() which which brings up the
next question. What is the purpose of list() function? 
 

From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Thu, 12 Aug 2010 15:28:04 -0600
Subject: [Lustre-devel] Caching the root directory
In-Reply-To: <201008121912.o7CJCauK006951@hedwig.cmf.nrl.navy.mil>
References: <201008121912.o7CJCauK006951@hedwig.cmf.nrl.navy.mil>
Message-ID: <2E548D41-3270-4898-8482-06D813088AED@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-08-12, at 13:12, Ken Hornstein wrote:
> So, with a not inconsiderable amount of pain, I've got attribute caching
> working on the Mac client.  Hooray!

Yay.

> But there is one wrinkle that bugs me: I can't figure out how to cache any
> information off of the root directory of a filesystem.
> 
> In MacOS X (and from what I can tell, most vnode-derived systems), you
> never get a "lookup" call for the root node in your filesystem; it's
> managed by the operating system, and when you traverse a mountpoint the
> operating system then just substitutes "your" root node for the root
> directory (there's a special function just to fetch the root node information).

I believe the Linux VFS will call revalidate on the root inode as part of the path traversal, so that it can present correct information for that inode.  See, for example, ll_inode_revalidate_it().

> The whole setup works out that you never end up with a lookup for the
> root node (the filesystem path is cached so when you would look up "."
> in the root directory, it ends up just back at the root node again
> without a lookup call).  And now that I think about it, I'm not sure
> how you could even do that, since one of the arguments to the lookup
> RPC is the parent directory and what do you put in for that for the
> root node?

Just leave it blank.

> Obviously I can still fetch the directory attributes when the OS asks for
> it, but in a perfect world I'd cache that information.  I've looked at the
> Linux client, but it's not clear what happens in the root node case.
> Can someone shed some light on this?  Does Linux cache the root node
> attribute information?  If so, how does it do that?

Caching the entries in the root directory is important, since they are traversed all the time, and also change very rarely.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.

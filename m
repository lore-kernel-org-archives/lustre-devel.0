From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Thu, 12 Aug 2010 20:37:20 -0400
Subject: [Lustre-devel] Caching the root directory
In-Reply-To: <2E548D41-3270-4898-8482-06D813088AED@oracle.com>
Message-ID: <201008130037.o7D0bLYh010763@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>> The whole setup works out that you never end up with a lookup for the
>> root node (the filesystem path is cached so when you would look up "."
>> in the root directory, it ends up just back at the root node again
>> without a lookup call).  And now that I think about it, I'm not sure
>> how you could even do that, since one of the arguments to the lookup
>> RPC is the parent directory and what do you put in for that for the
>> root node?
>
>Just leave it blank.

Hrm.  I'm not sure that will work.

Obviously I can call md_getattr() with just the fid of the root directory;
that's what is done now if no cached data exists.  But even if CONNECT_ATTRFID
was supported (which it currently is NOT, as we've discussed previously),
you need the parent FID in there, because if you DON'T provide it, the
server will throw an LBUG (which, okay, we all know is a bug, but it's
still clear that the parent fid needs to be there).

In the case of md_intent_lock() .... hmmm.  I see in ll_revalidate_it()
that mountpoints are explicitly skipped (and the attributes are fixed up
in ll_inode_revalidate_it(), which from what I see unless there is a lock
already, you don't get a new one).  Does d_mountpoint(de) apply to the
root node?

From what I can read ... ll_prep_md_op_data() pretty much requires that
the first argument (the parent inode) needs to be filled in.  The server
gets a little complicated to follow, but I do see that the server does:

	rc = mdt_object_exists(parent);

inside of mdt_getattr_name_lock().  Which sure would imply to me that things
are going to be unhappy if you don't supply a parent node.

>Caching the entries in the root directory is important, since they are
>traversed all the time, and also change very rarely.

Right, I haven't yet gotten to caching the directory pages yet, and everything
_from_ the root directory down is fine .. it's just the root itself I can't
quite figure out how to cache the attributes :-/

--Ken

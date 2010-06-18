From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Fri, 18 Jun 2010 15:35:35 -0600
Subject: [Lustre-devel] Attribute caching and OBD_CONNECT_ATTRFID
In-Reply-To: <201006091642.o59GgTll020727@hedwig.cmf.nrl.navy.mil>
References: <201006091642.o59GgTll020727@hedwig.cmf.nrl.navy.mil>
Message-ID: <A7BFC57F-AB97-41F2-95A8-B867E89C4875@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-06-09, at 10:42, Ken Hornstein wrote:
> So I've been working on attribute caching for Lustre for the MacOS X port,
> and I've run into a bit of a snag.

Ken,
sorry for the delay in replying, this mail disappeared off the top of my inbox.

> A bit of a brief explanation: unlike Linux, where (as I understand it)
> filesystems have to store attributes in the vnode as they change, on
> BSD-derived vnode filesystems you have a getattr function that gets
> called to find out the attributes of a file.

Linux VFS is kind of half-way between that.  There is a "common" inode structure that has information needed for any kind of inode (owner, size, blocks, etc), and then a "private" inode structure with filesystem-specific data, pointers, etc.

>  You get passed a pointer
> to the vnode (a sort-of virtual inode) and in that contains a pointer
> to a structure which the filesystem manages; in Lustre's case, that
> contains among other things a copy of the FID.  So just to recap, when
> MacOS X wants the attributes of a file, it's done via FID, not by
> filename. I am aware that you can get attributes at lookup time, and I
> plan on implementing that, but I figure I'd start with this first.

Right, this getattr-by-FID is done when revalidating an inode, but as you write it is normally done at lookup time.

> It is my understanding that to properly implement attribute caching, I
> need to call md_intent_lock with the right op_data and an intent
> structure with it_op set to IT_GETATTR.  When those attributes change,
> I'll get notified in my ast callback.  If that's wrong, then please
> correct me.

The "intent" part of the locking is that the client is trying to write-lock the directory with the intent looking up the file to open+create it.  In all cases today the MDS does not grant the write lock on the directory, and replies to the client essentially "you can't have the directory lock, but I opened/created the file for you, and here are the attributes".

> First off, I see that one of the options at connect time is
> OBD_CONNECT_ATTRFID, and looking at the comments and the llite code for
> this option it seems pretty self explanatory - you can fetch file
> attributes by FID.  Perfect!  Well, like the llite code I test to make
> sure OBD_CONNECT_ATTRFID is set in the connect flags, and I discover
> that it is _not_.
> 
> The reason for this is that it's commented out of the
> MDT_CONNECT_SUPPORTED macro in lustre_idl.h (and that's used to mask
> out the reply you get indicating what is supported).  Now, it's not
> clear to me why that was done: this happened back in 2007 as part of
> commit d2d56f38, and the commit entry just says, "make HEAD from
> b_post_cmd3", and it's been that way ever since.

I was going to point out where this wasn't correct, but it seems this IS commented out, and it would seem to be a legitimate problem.  I wasn't involved in CMD3 so offhand I can't say either why it was changed.  I'm doing some spelunking in CVS to see if there is an explanation for it.  From what I can gather, the commit comment is:

revision 1.1.14.82.2.12
date: 2007/06/14 06:54:00;  author: tappro
- disable ATTRFID feature due to cmd restriction
  bz12718
r:huanghua,fanyong


And in bugzilla bug 12718 (among the dozens of other patches landed from that bug) there is a comment:

>> Created an attachment (id=11067)  ATTRFID disable
>> 
>> ATTRFID should be disabled in CMD. The reason for that is locking - getting attr by fid require LOOKUP|UPDATE lock (LOOKUP is for access rights attributes) but in CMD LOOKUP lock can be already taken on another MDS - on name.
>> This is old CMD issue and the solution will be provided later, it seems we need new lock (e.g. PERMISSION) to protect such attributes. For now we just disable ATTRFID support.       
> 
> But disabling ATTRFID will cause sanity 29 to fail.
> Please investigate, or find solution for sanity 29.

But this question was never answered, and the patch was landed.  To my reading, the lack of ATTRFID support would prevent attribute caching on clients connected to 2.x servers once they lose their lock - they will repeatedly to MDS_GETATTR RPCs and never be able to cache them.

Seeing as 2.0 does not support CMD, and even in 2.x when we support CMD not all systems will be configured with CMD it should be possible to enable ATTRFID if no CMD is enabled.  

> The code still seems to exist on the server, so I figure I'll give it
> a try anyway,  First issue: you need to include the parent when using
> CONNECT_ATTRFID; I have to confess that I don't understand why, because
> you would think that it wouldn't be necessary just to get the attributes
> for a file, but this in enforced on the server (unfortunately, by
> kicking an LBUG).

It is a serious defect to LBUG() on the server due to bad client data/request.  Could you please file a bug on that?

>  This is a problem for the root directory since it's
> the first one looked up _and_ it doesn't have a parent, but I can special
> case that; for all other vnodes, the parent is easy to find (the filesystem
> layer keeps track of it).

I think that is fixing the symptom and not the cause.  I'm not sure why we need the parent FID to get a lock on the child by itself, but even the client can't be 100% sure that it will have the parent.  For example, if the Lustre client is re-exporting the filesystem via NFS, then it has crashed and lost the in-memory directory hierarchy, and then gets a revalidation/getattr request from its NFS client without the parent it won't have the parent directory.  IIRC, this is the original reason we added ATTRFID support, was for NFS to be able to cache attributes for such inodes.

> When I try doing _that_, I get an error from the lmv routines that I haven't
> tracked down yet.  But the whole thing makes me wonder if perhaps I'm
> doing the wrong thing.
> 
> From what I see, attributes are also cached at open/lookup time and as
> part of the statahead code; I can do that relatively easy.  But if
> attributes _change_, then I have to wonder what is supposed to happen
> next.

If there is a lock on the attributes, the lock will be revoked and the client's attributes will no longer be valid.  Presumably, either the client will do another lookup by name and re-get the lock on that inode, or the internal revalidation will just keep on doing MDS_GETATTR RPCs and the attributes will not be cached.

> Since current Lustre servers don't return OBD_CONNECT_ATTRFID as
> being set anymore, the code in the client doesn't seem like it will
> cache the attribute (for files, anyway) anymore.  It's entirely possible 
> that I'm missing something; that happens a lot.
> 
> So, I guess the question I have is ... if you get your lock broken when
> you have it on a file's attributes, exactly what is supposed to happen next?
> What's the mechanism for getting it again?

Well, it should do a getattr-by-FID and re-fetch the lock, which is exactly what happens with 1.6/1.8 servers.  I wonder if we even have a test workload that would expose this difference, since many tests like "ls -l" will always do a stat(filename), and I suspect very few tests will keep a filehandle open and do fstat(fd) for a long enough time for the client to lose its lock on the inode.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.

From: Andreas Dilger <adilger@sun.com>
Date: Mon, 27 Oct 2008 17:12:04 -0600
Subject: [Lustre-devel] HSM comments
In-Reply-To: <4905F121.6000501@cea.fr>
References: <4905F121.6000501@cea.fr>
Message-ID: <20081027231204.GP3184@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Oct 27, 2008  17:49 +0100, Aurelien Degremont wrote:
> Some points we did not discuss at last conf call:
>
> * File unlinks:
>
> - HSM object removal should be async.
> - We should not link hsm object, even in v1. Could we manage hsm object
> deletion like ost object deletion and manage orphan in the same way?

I wouldn't object to this - there could be an "HSM unlink" llog, similar
to the OST unlink llog that the HSM coordinator (either in the kernel,
or in userspace) processes at startup.  The difficulty is to know when
the llog record can be cancelled.

> - Presently, we could also leak hsm objects if the file is dirtied when
> being copied out. In this case, the file will be tagged dirtied, with no
> copyout_begin/complete flag. So the MDT will not request for HSM removal
> but their is something to delete there. Maybe the copyout mechanisms
> should be adapted.

I would recommend that we can keep a reference to a "dirty" HSM object
even if the copyout did not complete successfully, and HSM policy engine
should decide if the dirty object is kept or deleted.  In some cases
it may never be possible to do a complete copyout of the file, and having
some copy of the file would be better than having none at all.

> * HSM dirty bit.
>
> - should be updated with laziness.
> - Is it possible to implement it like the lazy file size? That means,
> manage the dirty bit, per OST object, and lazily update it on the MDT?

> - Also, if, instead of setting hsm_dirty bit to 1 when the file is
> modified, can we do counter += 1 ? That way 'counter' could be use as
> 'light' file revision. You compare two versions of this variable, is
> their differ, the file has been modified  (this is not intended to check
> 'counter_c1 < counter_c2' but just 'counter_c1 != counter_c2', that way,
> you can have circular counters.)

The MDS in 1.8 (and soon 2.0) will already keep a version counter for all
changes to the MDS inode.  The OSTs will also keep version numbers for
all of the objects there.

> - Could this flag be exposed to userspace via liblustreapi? Maybe this
> flag should be set on file creation also? Doing this, Policy Engines
> could use this flag to know easily if the file is udate to date in hsm
> or not.
>
> * Policy Engine
>
> - It needs to:
> . read changelogs (mdt)
> . df (mdt/client)
> . lfs df (per ost) (mdt/client)
> . scan namespace (client)
> . lfs getstripe by fid (client)
> . stat file by fid (client)
>
> The only thing the engine will lack on a client is the changelogs. May
> be it could be a good idea to export the changelogs on some 'trusted
> clients' ?

Yes, that is already considered.

> If not, we will be force to have MDT, client mount and policy engine on
> the same node or split the policy engine into two components (very bad
> idea to impose that on the engine). Potential overhead?

If the policy engine is running via an external database (e.g. MySQL),
it wouldn't be impossible to just have the Changelog reader do the
database insertions remotely, after looking up the pathname.

> - Could a policy test could be based on file path (not just filename and
> properties) ? This is a rule we presently used in our hsm tools. I do
> not see how have the filepath from the changelogs data (lfs fid2path?) ?

I believe the Changelog will report a full pathname (relative to the root
of the filesystem).  This will be exported via llapi to userspace.  Nathan?



Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.

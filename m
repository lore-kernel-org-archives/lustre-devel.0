From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 20 May 2008 16:10:07 -0600
Subject: [Lustre-devel] Replication for NRL/NGA
In-Reply-To: <483211F2.5090305@sun.com>
Message-ID: <C458A85F.469E%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>
> ps: Nathan, to build the changelog ZFS exploits a tree structure for
> objects, directories and blocks ? the tree structure allows the file
> system to be searched fast for changes (log based). A missing element
> is a fast object to path lookup. To get an approximation of the
> metadata changelog, ZFS would use the difference on changed
> directories at the beginning and ending snapshot (the tree structure
> will help you to find pages that have seen insertions and removals ?
> this function would be called zapdiff).

Hi Nathan -

> At first glance I am interpreting this very similar to the "zfs send"
> output stream, but the format of the stream would be
> 1. a fixed user API

Hmm, don't understand this part.

> 2. include full path names (or enough info to generate full path names)
> The stream would then be passed to a userland replicator (our current
> replication plan, and not "zfs recv")

Yes, including policy processing, like only syncing certain subtrees.

> 
> Is that about right? So we're just moving the MDT changelog generating
> part into ZFS

Yup, but careful, this is a changeset (not an ordered log) but with
snapshots and you can change it into some kind of log that performs the same
changes.

, and assuming data changes are reflected in mtime updates
> on the MDT's znodes (i.e. we still are only paying attention to the
> MDTs, and not the OSTs).

We use the same mechanism to make an OST change set.

> 
> And for the efficient pathname generation, the plan would still be a
> (fid,name,parent list) database on the MDT, or something new / ZFS
> specific? I haven't really dug into ZFS much, but I assume we could go
> back to the "store parent znode in file EAs, store dirname in dir EAs" idea.
> The snapshots give us a way to avoid the dynamic "current path" issue,
> so this would be a little easier.

Jeff Bonwick has extremely clear ideas about how he wants to do this (email
him and cc me, he'll explain, should he miss this line here).


> 
> But a big question is are we delivering zfs-based Lustre this fall? Not
> that I know anything about it, but aren't there licence problems with
> zfs and Linux?

My proposal is that we demo ZFS replication first and then put it in Lustre
(and pNFS etc).

BTW, we discussed other exciting things, namely that ZFS can just do the
rollback for CMD and that it can do metadata only snapshots to avoid
consuming lots of free space with the snapshotting of data, and Jeff even
came up with an idea to not snapshot at all but retain a few transactions to
roll back to.


- Peter -

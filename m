From: John Groves <John@systemfabricworks.com>
Date: Mon, 5 Jan 2009 12:32:23 -0600
Subject: [Lustre-devel] Lustre client disk cache (fscache)
In-Reply-To: <20081115000043.GE16005@webber.adilger.int>
References: <b062d32b0811111123i36b84bd6lc7a197fbba81ae79@mail.gmail.com>
	<20081115000043.GE16005@webber.adilger.int>
Message-ID: <b062d32b0901051032l7c24ce28g85e155fe61944390@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas, thanks for the thoughtful reply, and sorry for being so slow to
acknowledge and respond to it.   Responses are below.

On Fri, Nov 14, 2008 at 6:00 PM, Andreas Dilger <adilger@sun.com> wrote:

> On Nov 11, 2008  13:23 -0600, John Groves wrote:
> > This work is primarily motivated by the need to improve the performance
> > of lustre clients as SMB servers to windows nodes.  As I understand it,
> > this need is primarily for file readers.
> >
> > Requirements
> >
> > 1. Enabling fscache should be a mount option, and there should be ioctl
> >    support for enabling, disabling and querying a file's fscache usage.
>
> For Lustre there should also be the ability to do this via /proc/fs/lustre
> tunables/stats.


Makes sense, thanks.


>
>
> > 2. Data read into the page cache will be asynchronously copied to the
> >    disk-based fscache upon arrival.
> > 3. If requested data is not present in the page cache, it will be
> retrieved
> >    preferentially from the fscache.  If not present in the fscache, data
> >    will be read via RPC.
> > 4. When pages are reclaimed due to memory pressure, they should remain in
> >    the fscache.
> > 5. When a user writes a page (if we support fscache for non-read-only
> > opens),
> >    the corresponding fscache page must either be invalidated or
> >    (more likely) rewritten.
> > 6. When a DLM lock is revoked, the entire extent of the lock must be
> >    dropped from the fscache (in addition to dropping any page cache
> >    resident pages) - regardless of whether any pages are currently
> resident
> >    in the page cache.
> > 7. As sort-of a corollary to #6, DLM locks must not be canceled by the
> owner
> >    as long as pages are resident in the fscache, even if memory pressure
> >    reclamation has emptied the page cache for a given file.
> > 8. Utilities and test programs will be needed, of course.
> > 9. The fscache must be cleared upon mount or dismount.
>
> > High Level Design Points
> >
> > The following is written based primarily on review of the 1.6.5.1 code.
> > I'm aware that this is not the place for new development, but it was
> > deemed a stable place for initial experimentation.
>
> Note that the client IO code was substantially re-written for the 2.0
> release.  The client IO code from 1.6.5 is still present through the
> 1.8.x releases.


Understood.


> > Req.    Notes
> >
> >  1.    In current Redhat distributions, fscache is included and
> >     NFS includes fscache support, enabled by a mount option.
> >     We don't see any problems with doing something similar.
> >     A per-file ioctl to enable/disable fscache usage is also seen
> >     as straightforward.
> >
> >  2.     When an RPC read (into the page cache) completes, in the
> >     ll_ap_completion() function, an asynchronous read to the
> >     same offset in the file's fscache object will be initiated.
> >     This should not materially impact access time (think dirty page
> >     to fscache filesystem).
>
>
> Do you mean an "asynchronous write to the ... fscache object"?


Yes - write it is.


> >  3.     When the readpage method is invoked because a page is not
> >     already resident in the page cache, the page will be read
> >     first from the fscache.  This is non-blocking and (presumably)
> >     fast for the non-resident case.  If available, the fscache
> >     read will proceed asynchronously, after which the page will be
> >     valid in the page cache.  If not available in the fscache,
> >     the RPC read will proceed normally.
> >
> >  4.     Page removal due to memory pressure is triggered by a call to
> >     the llap_shrink_cache function.  This function should not require
> >     any material change, since pages can be removed from the page
> >     cache without removal from the fscache in this case.  In fact,
> >     if this doesn't happen, the fscache will never be read.
> >     (note: test coverage will be important here)
> >
> >  5.    It may be reasonable in early code to enable fscache only
> >     for read-only opens.  However, we don't see any inherent problems
> >     with running an asynchronous write to the fscache concurrently
> >     with a Lustre RPC write.  Note that this approach would *never*
> >     have dirty pages exist only in the fscache; if it's dirty it
> >     stays in the page cache until it's written via RPC (or RPC
> >     AND fscache if we're writing to both places)..
>
>
> This is dangerous from the point of view that the write to the fscache
> may succeed, but the RPC may fail for a number of reasons (e.g. client
> eviction) so it would seem that the write to the fscache cannot start
> until the RPC completes successfully.


Good catch, thanks.


> >  6 & 7    This is where it gets a little more tedious.  Let me revert to
> >     paragraph form to address these cases below.
> >
> >  8    Testing will require the following:
> >     * ability to query and punch holes in the page cache (already done).
> >     * ability to query and punch holes in the fscache (nearly done).
> >
> >  9  I presume that all locks are canceled when a client dismounts
> >     a filesystem, in which case it would never be safe to use data
> >     in the fscache from a prior mount.
>
>
> A potential future improvement in the second generation of this feature
> might be the ability to revalidate the files in the local disk cache by
> the MDT and OST object versions, if those are also stored in fscache.


Cool idea.


> > Lock Revocation
> >
> > Please apply that "it looks to me like this is how things work" filter
> here;
> > I am still pretty new to Lustre (thanks).  My questions are summarized
> > after the the text of this section.
> >
> > As of 1.6.5.1, DLM locks keep a list of page-cached pages
> > (lock->l_extents_list contains osc_async_page structs for all currently
> > cached pages - and I think the word extent is used both for each page
> cached
> > under a lock, and to describe a locked region...is this right?).  If a
> lock
> > is revoked, that list is torn down and the pages are freed.  Pages are
> also
> > removed from that list when they are freed due to memory pressure, making
> > that list sparse with regard to the actual region of the lock.
> >
> > Adding fscache, there will be zero or more page-cache pages in the extent
> > list, as well as zero or more pages in the file object in the fscache.
> > The primary question, then, is whether a lock will remain valid (i.e. not
> be
> > voluntarily released) if all of the page-cache pages are freed for
> > non-lock-related reasons (see question 3 below).
>
>
> Yes, the lock can remain valid on the client even when no pages are
> protected by the lock.  However, locks with few pages are more likely
> to be cancelled by the DLM LRU because the cost of re-fetching those
> locks is much smaller compared to locks covering lots of data.  The
> lock "weight" function would need to be enhanced to include pages that
> are in fscache instead of just those in memory.


Got it, thanks.  That would have eluded me...


> > The way I foresee cleaning up the fscache is by looking at the overall
> > extent of the lock (at release or revocation time), and punching a
> > lock-extent-sized hole in the fscache object prior to looping through
> > the page list (possibly in cache_remove_lock() prior to calling
> > cache_remove_extents_from_lock()).
>

FYI it turns out that fscache doesn't have the ability to punch a hole.  The
whole file has to be dropped at present.


>
> >
> > However, that would require finding the inode, which (AFAICS) is not
> > available in that context (ironically, unless the l_extents_list is non-
> > empty, in which case the inode can be found via any of the page structs
> in
> > the list).  I have put in a hack to solve this, but see question 6 below.
>
>
> Actually, each lock has a back-pointer to the inode that is referencing
> it, in l_ast_data, so that lock_cancel->mapping->page_removal can work.
> Use ll_inode_from_lock() for this.


That's much nicer than my hack...thanks.


> > Summarized questions:
> > Q1: Where can I read up on the unit testing infrastructure for Lustre?
>
>
> There is an internal wiki page with some information on this, it should
> probably be moved to the public wiki.


If there's a way to let me know when that happens, I'd appreciate it.  I'm
not a full time lustre-devel reader (at least currently).



> > Q2: Is stale cache already covered by existing unit tests?
>
>
> I'm not sure what you mean.  There is no such thing as stale cache in
> Lustre.


What I was driving at is a test to verify that any page cache data was
discarded when a lock was revoked.  The same test would catch failure to
discard fscache data, that being a potentially stale place to reload the
page cache from.  Perhaps that's implicitly covered somehow.


> > Q3: Will a DLM lock remain valid (i.e. not be canceled) even if its page
> >     list is empty (i.e. all pages have been freed due to memory
> pressure)?
>
>
> Yes, though the reverse is impossible.
>
> > Q4: Will there *always* be a call to cache_remove_lock() when a lock is
> >     canceled or revoked?  (i.e. is this the place to punch a hole in the
> >     fscache object?)
> > Q5: for the purpose of punching a hole in a cache object upon lock
> >     revocation, can I rely on the lock->l_req_extent structure as the
> >     actual extent of the lock?
>
> No, there are two different extent ranges on each lock.  The requested
> extent, and the granted extent.  The requested extent is the minimum
> extent size that the server could possibly grant to the client to finish
> the operation (e.g. large enough to handle a single read or write syscall).
> The server may decide to grant a larger lock if the resource (object) is
> not contended.
>
> In the current implementation, the DLM will always grant a full-file lock
> to the first client that requests it, because the most common application
> case is that only a single client is accessing the file.  This avoids any
> future lock requests for this file in the majority of cases.


Thanks.  Given that fscache invalidation turns out to be full-file anyway,
this becomes moot for the time being.


> > Q6: a) is there a way to find the inode that I've missed?, and
> >     b) if not what is the preferred way of giving that function a way to
> >     find the inode?
>
>
> See above.
>
> > FYI we have done some experimenting and we have the read path in a
> > demonstrable state, including crude code to effect lock revocation on the
> > fscache contents.  The NFS code modularized the fscache hooks pretty
> nicely,
> > and we have followed that example.
>
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>
>
>

Thanks again!
John
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090105/1c5947d6/attachment.htm>

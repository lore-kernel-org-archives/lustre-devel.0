From: John Groves <jgl@johngroves.net>
Date: Tue, 11 Nov 2008 13:23:04 -0600
Subject: [Lustre-devel] Lustre client disk cache (fscache)
Message-ID: <b062d32b0811111123i36b84bd6lc7a197fbba81ae79@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Greetings,

We (System Fabric Works) have been retained by Sun to prove concept on
integrating the lustre client filesystem with a local disk cache
(specifically fscache from Red Hat).

Eric Barton and I discussed this several days ago, but I would appreciate
others' feedback on the requirements and approach documented  below.  I'm
relatively new to Lustre, so there is a very real possibility  that I "don't

know what I don't know".

Motivation

This work is primarily motivated by the need to improve the performance
of lustre clients as SMB servers to windows nodes.  As I understand it,
this need is primarily for file readers.

Requirements

1. Enabling fscache should be a mount option, and there should be ioctl
   support for enabling, disabling and querying a file's fscache usage.
2. Data read into the page cache will be asynchronously copied to the
   disk-based fscache upon arrival.
3. If requested data is not present in the page cache, it will be retrieved
   preferentially from the fscache.  If not present in the fscache, data
   will be read via RPC.
4. When pages are reclaimed due to memory pressure, they should remain in
   the fscache.
5. When a user writes a page (if we support fscache for non-read-only
opens),
   the corresponding fscache page must either be invalidated or
   (more likely) rewritten.
6. When a DLM lock is revoked, the entire extent of the lock must be
   dropped from the fscache (in addition to dropping any page cache
   resident pages) - regardless of whether any pages are currently resident
   in the page cache.
7. As sort-of a corollary to #6, DLM locks must not be canceled by the owner
   as long as pages are resident in the fscache, even if memory pressure
   reclamation has emptied the page cache for a given file.
8. Utilities and test programs will be needed, of course.
9. The fscache must be cleared upon mount or dismount.

High Level Design Points

The following is written based primarily on review of the 1.6.5.1 code.
I'm aware that this is not the place for new development, but it was
deemed a stable place for initial experimentation.

Req.    Notes

 1.    In current Redhat distributions, fscache is included and
    NFS includes fscache support, enabled by a mount option.
    We don't see any problems with doing something similar.
    A per-file ioctl to enable/disable fscache usage is also seen
    as straightforward.

 2.     When an RPC read (into the page cache) completes, in the
    ll_ap_completion() function, an asynchronous read to the
    same offset in the file's fscache object will be initiated.
    This should not materially impact access time (think dirty page
    to fscache filesystem).

 3.     When the readpage method is invoked because a page is not
    already resident in the page cache, the page will be read
    first from the fscache.  This is non-blocking and (presumably)
    fast for the non-resident case.  If available, the fscache
    read will proceed asynchronously, after which the page will be
    valid in the page cache.  If not available in the fscache,
    the RPC read will proceed normally.

 4.     Page removal due to memory pressure is triggered by a call to
    the llap_shrink_cache function.  This function should not require
    any material change, since pages can be removed from the page
    cache without removal from the fscache in this case.  In fact,
    if this doesn't happen, the fscache will never be read.
    (note: test coverage will be important here)

 5.    It may be reasonable in early code to enable fscache only
    for read-only opens.  However, we don't see any inherent problems
    with running an asynchronous write to the fscache concurrently
    with a Lustre RPC write.  Note that this approach would *never*
    have dirty pages exist only in the fscache; if it's dirty it
    stays in the page cache until it's written via RPC (or RPC
    AND fscache if we're writing to both places)..

 6 & 7    This is where it gets a little more tedious.  Let me revert to
    paragraph form to address these cases below.

 8    Testing will require the following:
    * ability to query and punch holes in the page cache (already done).
    * ability to query and punch holes in the fscache (nearly done).

 9  I presume that all locks are canceled when a client dismounts
    a filesystem, in which case it would never be safe to use data
    in the fscache from a prior mount.


Lock Revocation

Please apply that "it looks to me like this is how things work" filter here;
I am still pretty new to Lustre (thanks).  My questions are summarized
after the the text of this section.

As of 1.6.5.1, DLM locks keep a list of page-cached pages
(lock->l_extents_list contains osc_async_page structs for all currently
cached pages - and I think the word extent is used both for each page cached
under a lock, and to describe a locked region...is this right?).  If a lock
is revoked, that list is torn down and the pages are freed.  Pages are also
removed from that list when they are freed due to memory pressure, making
that list sparse with regard to the actual region of the lock.

Adding fscache, there will be zero or more page-cache pages in the extent
list, as well as zero or more pages in the file object in the fscache.
The primary question, then, is whether a lock will remain valid (i.e. not be
voluntarily released) if all of the page-cache pages are freed for
non-lock-related reasons (see question 3 below).

The way I foresee cleaning up the fscache is by looking at the overall
extent of the lock (at release or revocation time), and punching a
lock-extent-sized hole in the fscache object prior to looping through
the page list (possibly in cache_remove_lock() prior to calling
cache_remove_extents_from_lock()).

However, that would require finding the inode, which (AFAICS) is not
available in that context (ironically, unless the l_extents_list is non-
empty, in which case the inode can be found via any of the page structs in
the list).  I have put in a hack to solve this, but see question 6 below.

Summarized questions:
Q1: Where can I read up on the unit testing infrastructure for Lustre?
Q2: Is stale cache already covered by existing unit tests?
Q3: Will a DLM lock remain valid (i.e. not be canceled) even if its page
    list is empty (i.e. all pages have been freed due to memory pressure)?
Q4: Will there *always* be a call to cache_remove_lock() when a lock is
    canceled or revoked?  (i.e. is this the place to punch a hole in the
    fscache object?)
Q5: for the purpose of punching a hole in a cache object upon lock
    revocation, can I rely on the lock->l_req_extent structure as the
    actual extent of the lock?
Q6: a) is there a way to find the inode that I've missed?, and
    b) if not what is the preferred way of giving that function a way to
    find the inode?

...

FYI we have done some experimenting and we have the read path in a
demonstrable state, including crude code to effect lock revocation on the
fscache contents.  The NFS code modularized the fscache hooks pretty nicely,
and we have followed that example.

Thanks,
John Groves
John at SystemFabricWorks.com
+1-512-302-4005
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20081111/31e52478/attachment.htm>

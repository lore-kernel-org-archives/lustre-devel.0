From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Jun 2018 12:03:43 +1000
Subject: [lustre-devel] [PATCH 08/24] lustre: use truncate_inode_page in
 place of truncate_complete_page
In-Reply-To: <61C2F92E-8F88-49C6-83FB-F3013289265C@linuxhacker.ru>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669032.10587.11474850109829193046.stgit@noble>
 <alpine.LFD.2.21.1806160115430.15679@casper.infradead.org>
 <87y3ffft80.fsf@notabene.neil.brown.name>
 <61C2F92E-8F88-49C6-83FB-F3013289265C@linuxhacker.ru>
Message-ID: <877emwg8ao.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Jun 15 2018, Oleg Drokin wrote:

>> On Jun 15, 2018, at 8:52 PM, NeilBrown <neilb@suse.com> wrote:
>> 
>> On Sat, Jun 16 2018, James Simmons wrote:
>> 
>>>> Carrying a local truncate_complete_page() is not good
>>>> for maintainability.  Linux now used truncate_inode_page,
>>>> so use that instead.
>>>> For correct use, we need to pass the mapping to mdc_release_page()
>>>> rather than trusting page->mapping.
>>> 
>>> Nak: truncate_inode_page is not exported so it fails to build when lustre
>>> is configured as a module.
>> 
>> Bother, nor it is.
>> We could probably use truncate_inode_pages_range() but it isn't a
>> perfect fit, which seems to suggest that lustre is trying to do
>> something that no other filesystem finds the need to do.
>> I'll dig deeper and work out what is really going on.
>
> Lustre evicts pages from mapping when the lock that covers the pages
> is canceled.
> Normally this only applies to data pages, and I see this is in mdc which is for metadata.

The invalidation of data pages is presumably where vvp_page_discard()
calls  ll_invalidate_page() [which is not the same as ll_invalidatepage() :-( ]

ll_invalidate_page does almost exactly the same as
truncate_inode_page(), which isn't exported.
We cannot just call
   truncate_inode_pages_range(page->mapping,
		page->index<<PAGE_SHIFT, page->index<<PAGE_SHIFT + 1);
as that will try to lock the page, which is already locked.

We could use generic_error_remove_page() instead (that is exported).
This condition isn't exactly an error, but it is a situation where
memory soon will not contain correct data.
afs uses this in afs_kill_pages() though the purpose is different.

cepfs uses it in writepages_finish in a context described as:

        /*
         * We lost the cache cap, need to truncate the page before
         * it is unlocked, otherwise we'd truncate it later in the
         * page truncation thread, possibly losing some data that
         * raced its way in
         */
which sounds similar to what lustre is doing.

NFS can only lose a lock (delegation) on the whole file, not for
individual pages, so it just invalidates a range.

I think I'd like to change lustre to use generic_error_remove_page
instead of ll_invalidate_page() - for S_ISREG mappings.

>
> For metadata the only pages we hold are readdir pages and the lock currently
> covers entire dir so lock cancelation should not need this.
>
> So looking at the code the other two users are readdir where we failed to populate page
> somehow and now need to throw it out and then a collision event for hashes, it appears.
> Both of these should apply to other filesystems I am sure.

In the directory case there is no invalidatepage operation, so the
current truncate_complete_page() function just does:

       cancel_dirty_page(page);
       ClearPageMappedToDisk(page);
       ll_delete_from_page_cache(page);

I'd guess that lustre directory pages don't get PageMappedToDisk set,
and in this situation there aren't dirty.
So this just boils down to
   delete_from_page_cache(page)

Do you know if my guesses are correct?  If they are, lets just use
delete_from_page_cache() for unwanted directory pages.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180618/b06cae4e/attachment.sig>

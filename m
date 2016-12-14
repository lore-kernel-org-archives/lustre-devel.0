From: quentin.bouget at cea.fr <quentin.bouget@cea.fr>
Date: Wed, 14 Dec 2016 17:21:39 +0100
Subject: [lustre-devel] caching in Lustre
In-Reply-To: <CY4PR11MB1751D8EF7926721056AC3FFFCB9B0@CY4PR11MB1751.namprd11.prod.outlook.com>
References: <6cac83b6-3d70-a814-3b12-54ea51386296@cea.fr>
	<CY4PR11MB1751D8EF7926721056AC3FFFCB9B0@CY4PR11MB1751.namprd11.prod.outlook.com>
Message-ID: <586fb656-ab88-08d9-6102-400432e7dc5f@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Le 13/12/2016 ? 14:33, Patrick Farrell a ?crit :
>
>
> Quentin,
>
> I suspect that the pages are only maintained during the duration of an 
> IO, then discarded.  I haven't dug in to the exact mechanics of it, 
> but when caches are disabled, the key thing is no CACHING occurs, 
> i.e., nothing can be read from the cache.  So, I assume, these pages 
> you see are transiently present for purposes of performing the IO.  
> (The data from the disk has to go somewhere.)
>
> - Patrick
> ------------------------------------------------------------------------
> *From:* lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf 
> of quentin.bouget at cea.fr <quentin.bouget@cea.fr>
> *Sent:* Tuesday, December 13, 2016 4:02:06 AM
> *To:* lustre-devel at lists.lustre.org
> *Subject:* [lustre-devel] caching in Lustre
>
> Hi all,
>
> I am currently trying to work out how Lustre behaves when both 
> "read_cache" and "writethrough_cache" are disabled. What I 
> particularly want to know is how does writing to the related proc 
> files influence the cache policy?
>
> To me (and perf_event reports it too on a 2.7 setup), the code always 
> gets cache pages (using find_or_create_page() in 
> "lustre/osd-ldiskfs/osd_io.c") even with both cache parameters set to 0.
> After that, if caching is disabled, a call to 
> generic_error_remove_page() is issued on the pages that were 
> allocated. This functions is described in the kernel sources like this:
>
> *//* * Used to get rid of pages on hardware memory corruption. */ int 
> generic_error_remove_page(struct adress_space *mapping, struct page 
> *page) /*
>
> This does not seem to be the "natural" call to use, but anyway, I can 
> live with that.
> What really bothers me is that the behaviour of Lustre from this point 
> looks exactly the same as if cache was enabled. I can't find a single 
> branching point that handles things differently: pages are kmapped, 
> written to/read from, kunmmaped... I am probably missing something, 
> but I can't figure out what. Could someone please point me in the 
> right direction?
>
> The functions I find the most relevant to study are:
> "lustre/ofd/ofd_io.c":
>     ofd_preprw() -> ofd_preprw_read() / ofd_preprw_write()
>
> their counterparts:
> "lustre/ofd/ofd_io.c":
>     ofd_commitrw() -> ofd_commitrw_read() / ofd_commitrw_write()
>
> the handlers of the proc files 
> "/proc/fs/lustre/obdfilter/*/{read,writethrough}_cache_enable":
> "lustre/osd-ldiskfs/osd_lproc.c":
>     ldiskfs_osd_cache_seq_write(), ldiskfs_osd_wcache_seq_write()
>
> and the only places that use the variables set by the proc files 
> (where generic_error_remove_page() is used):
> "lustre/osd-ldiskfs/osd_io.c":
>     osd_read_prep(), osd_write_prep()
>
> (I suspect I am missing something really important about what 
> generic_error_remove_page() does)
>
>
> Regards
>
> Quentin Bouget
>
Alright, so data has to go somewhere. That makes sense. And those pages 
are probably discarded as soon as the last reference is dropped (surely 
on IO completion). So Lustre allocates cache pages, that it sort of 
converts into "regular" buffers and uses as such. So indeed it mimics a 
"no_cache" policy... Then, I need to elaborate...

I am running obdfilter on Lustre with SSD disks as OST(s). The 
performance of Lustre seems directly related to the number of threads I 
configure obdfilter to spawn (the more threads there are, the better).
But there is a catch: the more threads I spawn, the more they contends 
on locks inside the pagecache allocations functions. I reach 100% CPU 
usage before the theoric throughput of the disks.

So I want to see if disabling cache in Lustre provides a better ratio of 
CPU usage over IO throughput. From there I get confused when I notice 
that there are still as many calls to find_or_create_page() as with 
cache enabled, and that my CPU consumption is still maxed out. (I now 
understand why find_or_create_page() still gets called)

Looking at the code of find_or_create_page() it seems to do mainly 2 
things: allocate a page, then add it to the LRU list. Yet, removing the 
page from the LRU list is quite a costly operation. I would have thought 
that generic_error_remove_page() would take care of it, efficiently, 
right after initialization, but perf_event shows me that it actually 
happens when the IO completes -- when the page is released -- and that 
half the time of one execution of obdfilter-survey is spent spinning there.

Would it be imaginable that Lustre used another page allocation function 
when cache is disabled? Maybe it is even possible to use buffers 
directly from the ptlrpc requests? Does someone see another way out of 
this?

I tried to be as clear as possible, but I can try again if need be. =)


Regards,

Quentin Bouget

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161214/5eeddd15/attachment.htm>

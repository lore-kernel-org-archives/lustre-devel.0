From: quentin.bouget at cea.fr <quentin.bouget@cea.fr>
Date: Tue, 13 Dec 2016 11:02:06 +0100
Subject: [lustre-devel]  caching in Lustre
Message-ID: <6cac83b6-3d70-a814-3b12-54ea51386296@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all,

I am currently trying to work out how Lustre behaves when both 
"read_cache" and "writethrough_cache" are disabled. What I particularly 
want to know is how does writing to the related proc files influence the 
cache policy?

To me (and perf_event reports it too on a 2.7 setup), the code always 
gets cache pages (using find_or_create_page() in 
"lustre/osd-ldiskfs/osd_io.c") even with both cache parameters set to 0.
After that, if caching is disabled, a call to 
generic_error_remove_page() is issued on the pages that were allocated. 
This functions is described in the kernel sources like this:

*//* * Used to get rid of pages on hardware memory corruption. */ int 
generic_error_remove_page(struct adress_space *mapping, struct page 
*page) /*

This does not seem to be the "natural" call to use, but anyway, I can 
live with that.
What really bothers me is that the behaviour of Lustre from this point 
looks exactly the same as if cache was enabled. I can't find a single 
branching point that handles things differently: pages are kmapped, 
written to/read from, kunmmaped... I am probably missing something, but 
I can't figure out what. Could someone please point me in the right 
direction?

The functions I find the most relevant to study are:
"lustre/ofd/ofd_io.c":
     ofd_preprw() -> ofd_preprw_read() / ofd_preprw_write()

their counterparts:
"lustre/ofd/ofd_io.c":
     ofd_commitrw() -> ofd_commitrw_read() / ofd_commitrw_write()

the handlers of the proc files 
"/proc/fs/lustre/obdfilter/*/{read,writethrough}_cache_enable":
"lustre/osd-ldiskfs/osd_lproc.c":
     ldiskfs_osd_cache_seq_write(), ldiskfs_osd_wcache_seq_write()

and the only places that use the variables set by the proc files (where 
generic_error_remove_page() is used):
"lustre/osd-ldiskfs/osd_io.c":
     osd_read_prep(), osd_write_prep()

(I suspect I am missing something really important about what 
generic_error_remove_page() does)


Regards

Quentin Bouget

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161213/418a8d6e/attachment.htm>

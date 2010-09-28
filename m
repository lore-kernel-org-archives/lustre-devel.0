From: Jeremy Filizetti <jeremy.filizetti@gmail.com>
Date: Tue, 28 Sep 2010 09:14:45 -0400
Subject: [Lustre-devel] Large readdir RPCs project
Message-ID: <AANLkTin42fMZpZ-eRt6gF__Ftw6Oo5BBf58Mb-376erW@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Since I work mostly with Lustre over a WAN I'd definitely like to see the
larger readdir RPCs in Lustre to save on RTTs between clients and the MDS.
I'm just looking for some input to make sure I'm looking at the right
changes.  I know Andreas had mentioned an issue with larger pages to me at
LUG this year.

From the description I'm guessing the approach would be to request
additioinal pages in the ll_dir_readpage similar to how read ahead is
handled in ll_readpage.  mdc_readpage also needs to be changed to handle
multiple pages and prep each page for bulk.  I think this makes the most
sense because at least by default I see getdents64 only be called with a 4k
buffer.  Otherwise it might make sense to change the ll_readdir functions to
handle more pages and ll_get_dir_page to request additional pages and call
read_cache_pages instead.

Jeremy
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100928/40575d40/attachment.htm>

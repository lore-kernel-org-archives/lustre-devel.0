From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Thu, 13 Jun 2019 13:54:47 +0200
Subject: [lustre-devel] Request arc buffer, zerocopy
Message-ID: <1560426887.3392.0@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dear all,

in osd-zfs/osd_io.c:osd_bufs_get_write you can find a comment regarding 
zerocopy:

	/*
	 * currently only full blocks are subject to zerocopy approach:
	 * so that we're sure nobody is trying to update the same block
	 */

Whenever a block to be written is full, an arc buffer is requested, 
otherwise alloc_page.

I do not really understand the conclusion. Why and how do full blocks 
prevent updates?
And put it differently - why not to try zerocopy for not full blocks?
What could happen if I tried to request an arc buffer for e.g. a block 
with missing last page?

I would be greateful for details.
Best regards
Anna






-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190613/b506a814/attachment.html>

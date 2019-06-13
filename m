From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 13 Jun 2019 17:26:58 +0000
Subject: [lustre-devel] Request arc buffer, zerocopy
In-Reply-To: <1560426887.3392.0@informatik.uni-hamburg.de>
References: <1560426887.3392.0@informatik.uni-hamburg.de>
Message-ID: <4A887B54-96F2-439C-9207-1BBA01350869@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Add relevant developers to CC list. 

Cheers, Andreas

> On Jun 13, 2019, at 05:54, Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de> wrote:
> 
> Dear all,
> 
> in osd-zfs/osd_io.c:osd_bufs_get_write you can find a comment regarding zerocopy:
> 
> 	/*
> 	 * currently only full blocks are subject to zerocopy approach:
> 	 * so that we're sure nobody is trying to update the same block
> 	 */
> 
> Whenever a block to be written is full, an arc buffer is requested, otherwise alloc_page.
> 
> I do not really understand the conclusion. Why and how do full blocks prevent updates?
> And put it differently - why not to try zerocopy for not full blocks?
> What could happen if I tried to request an arc buffer for e.g. a block with missin g last page?
> 
> I would be greateful for details.
> Best regards
> Anna
> 
> 
> 
> 
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

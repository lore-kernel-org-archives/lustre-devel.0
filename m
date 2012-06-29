From: Nathan Rutman <nathan_rutman@xyratex.com>
Date: Fri, 29 Jun 2012 14:11:28 -0700
Subject: [Lustre-devel] mmp unplug patch
In-Reply-To: <20120629204339.GE19971@granier.hd.free.fr>
References: <5E974A8D-E444-46AE-9212-645CBC40CC4C@xyratex.com>
	<20120629204339.GE19971@granier.hd.free.fr>
Message-ID: <F58A3E05-E9BB-42CF-B543-4F02CA83FB11@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks Johann.  I think we're going to experiment with removing it...


On Jun 29, 2012, at 1:43 PM, Johann Lombardi wrote:

> On Fri, Jun 29, 2012 at 11:58:53AM -0700, Nathan Rutman wrote:
>> Can anyone explain the purpose of unplug call in this patch?
> 
> I guess the intent is to make sure that the MMP block updates aren't delayed by the underlying I/O scheduler and make it to the storage system in a timely manner.
> 
>> The first part of the patch I get, but why do we need to drop the existing queued items?
> 
> The issue is that some I/O schedulers might not support BIO_RW_SYNC and the ones that do might still delay the request a bit, hoping to merge it with a forthcoming request. Therefore, the only way to make sure that the I/O is issued straight away is to unplug the queue.
> 
> All in all, it depends on whether the I/O scheduler delay is negligible compared to the MMP update interval.
> 
>> Doesn't this simply result in more fragmented IO?
> 
> Yes, it might.
> 
> HTH
> 
> Cheers,
> Johann
> -- 
> Johann Lombardi
> Whamcloud, Inc.
> www.whamcloud.com

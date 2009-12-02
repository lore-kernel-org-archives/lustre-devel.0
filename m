From: Andreas Dilger <adilger@sun.com>
Date: Wed, 02 Dec 2009 12:43:04 -0700
Subject: [Lustre-devel] Fwd: Disk rebuild
In-Reply-To: <8acda98c0912020613l4cee1a43s3be7ec4f52383304@mail.gmail.com>
References: <8acda98c0912010700r684bfcf6h94ec347cd6190990@mail.gmail.com>
	<20091201235754.GC4508@clouds>
	<8acda98c0912020613l4cee1a43s3be7ec4f52383304@mail.gmail.com>
Message-ID: <E9666E71-8BE9-400D-9EA4-445011BB8961@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Nikita!

On 2009-12-02, at 07:13, Nikita Danilov wrote:
>> On Tue, Dec 01, 2009 at 06:00:39PM +0300, Nikita Danilov wrote:
>>> what is the status of this? Is ext3 guided resync code (RHEL 5  
>>> version was posted on lkml in October) used by Lustre?
>>
>> This is covered by bug 19932.
>
> The last (43rd) comment there is rather intriguing. Can you elaborate
> on why guided resync cannot work with the Lustre IO stack?


The problem lies in the way that obdfilter submits IO.  Since it is  
not using the normal buffer cache to track "data=ordered" (or in the  
case of this patch "data=declared") mode the bio_submit() will likely  
start modifying the MD device before the corresponding declare blocks  
are committed to the journal.

This breaks the whole validity of declared mode in case of a crash,  
since we can no longer be certain that the declare blocks contain all  
of the locations in the MD RAID that may need to have parity rebuilt.

It would be possible to fix this by having the OST use the normal VFS  
methods to order the IO to disk, but I'm sure you're well aware of the  
performance impact of this.  It wouldn't be so bad with older versions  
of Lustre, where we had to wait for the journal commit before  
returning to the client anyway, but in 1.8.2 there is a (disabled by  
default) async journal commit option that allows the client to get RPC  
replies before the bulk IO is committed.

In order to accommodate declared mode it mean that we need to  
implement full write-cached IO on the OST, which wouldn't be  
impossible given that 1.8 already uses the page cache for reading, but  
given the amount of change and risk this would introduce it wasn't  
thought worthwhile to implement for the short lifespan it would have.   
It wouldn't be practical to introduce such a major change any sooner  
than the DMU OSD in the 2.1 release, at which point it is largely  
obsolete.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.

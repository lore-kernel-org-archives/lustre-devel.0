From: Andreas Dilger <adilger@sun.com>
Date: Wed, 02 Dec 2009 15:48:45 -0700
Subject: [Lustre-devel] Fwd: Disk rebuild
In-Reply-To: <8acda98c0912021258j140748b1wb2cdb0d2036a864a@mail.gmail.com>
References: <8acda98c0912010700r684bfcf6h94ec347cd6190990@mail.gmail.com>
	<20091201235754.GC4508@clouds>
	<8acda98c0912020613l4cee1a43s3be7ec4f52383304@mail.gmail.com>
	<E9666E71-8BE9-400D-9EA4-445011BB8961@sun.com>
	<8acda98c0912021258j140748b1wb2cdb0d2036a864a@mail.gmail.com>
Message-ID: <23BF8704-265B-476D-AAF7-47F79A131553@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2009-12-02, at 13:58, Nikita Danilov wrote:
>> The problem lies in the way that obdfilter submits IO.  Since it is  
>> not
>> using the normal buffer cache to track "data=ordered" (or in the  
>> case of
>> this patch "data=declared") mode the bio_submit() will likely start
>> modifying the MD device before the corresponding declare blocks are
>> committed to the journal.
>
> Thank you for the detailed explanation, data-path completely escaped
> my mind. Still, on the mdt side, osd goes through the normal VFS paths
> and data=declared should work, right?

Yes, though in general the MDT is a lot smaller than the OSTs, fails  
less often, has RAID-1 instead of RAID-6 so the rebuild goes  
considerably faster, has metadata journaling for everything (so  
doesn't get inconsistent in the first place).

There would likely be some improvement, but we haven't benchmarked it  
- the main concern was for the OSTs.


Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.

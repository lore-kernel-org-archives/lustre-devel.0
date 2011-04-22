From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 22 Apr 2011 11:06:22 -0600
Subject: [Lustre-devel] 64-bit ext4 inodes
In-Reply-To: <28DD036A-3277-4D65-87A5-ADB9ECF7B51C@xyratex.com>
References: <2368DAF2-4CA9-41E4-8A56-E48AEA9D4549@xyratex.com>
	<73AED5C780AE05478241DB067651A92102378476@XYUS-EX22.xyus.xyratex.com>
	<50A7CDE4-73B3-4BEB-9BF4-BE0D077A3A00@whamcloud.com>
	<5E5695A6-CE4E-4253-B97C-85FAD3C96FFF@llnl.gov>
	<28DD036A-3277-4D65-87A5-ADB9ECF7B51C@xyratex.com>
Message-ID: <711A9E1C-4C86-4871-97DA-7DC2362BB652@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-04-22, at 9:33 AM, Alexey Lyashkov <alexey_lyashkov@xyratex.com> wrote:
> Andreas, is possible to check different inodes groups  on different cores in parallel?
> It's should be dramatically increase time of checking on systems with 8-16 CPU cores.

Yes, all of pass1 in e2fsck is trivially run in parallel. It would probably be best to make it event driven, by reading chunks from disk (maybe whole groups) and then having a task queue to process each chunk on a different core. The main effort would be adding locking to the data structures from many threads.

Some of the other passes could also be parallelized, like tree walking, but getting good balance of disk and CPU usage is less trivial. 

Cheers, Andreas 

> On Apr 22, 2011, at 19:13, D. Marc Stearman wrote:
> 
>> Andreas, LLNL often has file systems with more than 500M inodes in use.  We create them with 1B inodes just for that reason.  And yes, e2fsck times are horrible.  Very painful.
>> 
>> -Marc
>> 
>> ----
>> D. Marc Stearman
>> Lustre Operations Lead
>> marc at llnl.gov
>> 925.423.9670
>> Pager: 1.888.203.0641
>> 
>> 
>> 
>> 
>> On Apr 21, 2011, at 3:56 PM, Andreas Dilger wrote:
>> 
>>> On Apr 20, 2011, at 11:07 AM, Nathan Rutman wrote:
>>>> We're about to start looking into 64-bit inodes on ext4 -- anybody else working on this at the moment?
>>> 
>>> I don't know of anyone other than Fujitsu that are looking at this.  I haven't had any kind of technical discussion with them about it, nor looked at their code, but just implied that this is what they did based on their slides.
>>> 
>>> One important consideration to note with 64-bit inode numbers is that they cannot be used safely on 1.8 MDS filesystems.  That is because the IGIF FID namespace only has room for 2^32 inode numbers (mapped into the 2.x FID SEQ field, see ), so upgrading a 1.8 MDS with 64-bit inode numbers to 2.x would cause a huge world of hurt.  If this is limited to 2.x filesystems that only identify MDS inodes via FIDs to the clients then this is not a concern.
>>> 
>>> If you are concerned with being able to upgrade 32-bit inode filesystems into 64-bit inode filesystems, you should look at the data-in-dirent patch that is currently in the 2.x ldiskfs patchset.  It was developed to allow storing the 128-bit Lustre FID in the directory entry in a compatible manner, but was also designed to allow storing the high 32 bits of a 64-bit inode number into the directory entry.  That allows compatibility for upgrades by avoiding the need to atomically upgrade a whole directory full of dirents to have 64-bit inode number fields.  It also avoids the need to store 64-bit inode numbers when most of them are 32-bit values.
>>> 
>>> 
>>> I'm not against the idea of exploring this approach, but I am concerned that e2fsck time will continue to grow with the number of inodes in a single filesystem, and scalability of a single MDT will increasingly be an issue.  
>>> 
>>> AFAIK, e2fsck times are currently on the order of 1h/100M inodes, and no Lustre filesystems that I know of are above 500M inodes today just due to the average file size being so large and the long e2fsck times.  With improvements in ext4 to reduce e2fsck time like flex_bg, and SSDs, it may be possible to reduce the e2fsck time/inode ratio noticeably, but I think it would take more effort on the e2fsck side than the ext4 side to make many billions of inodes in a single MDT a practical approach.
>>> 
>>> Things like metadata prefetching that Dave Dillow was doing for e2scan with event-driven completion handlers that process the blocks whenever they arrive from the disk, and multi-threading some of the passes of e2fsck with an understanding of the underlying disk layout (using the s_raid_stride and s_raid_stripe_width).
>>> 
>>> Cheers, Andreas
>>> --
>>> Andreas Dilger 
>>> Principal Engineer
>>> Whamcloud, Inc.
>>> 
>>> 
>>> 
>>> _______________________________________________
>>> Lustre-devel mailing list
>>> Lustre-devel at lists.lustre.org
>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>> 
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> --------------------------------------------
> Alexey Lyashkov
> alexey_lyashkov at xyratex.com
> 
> 
> 
> 
> ______________________________________________________________________
> This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
> 
> Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
> 
> Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
> 
> The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
> ______________________________________________________________________
> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

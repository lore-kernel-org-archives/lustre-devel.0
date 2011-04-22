From: D. Marc Stearman <marc@llnl.gov>
Date: Fri, 22 Apr 2011 08:13:37 -0700
Subject: [Lustre-devel] 64-bit ext4 inodes
In-Reply-To: <50A7CDE4-73B3-4BEB-9BF4-BE0D077A3A00@whamcloud.com>
References: <2368DAF2-4CA9-41E4-8A56-E48AEA9D4549@xyratex.com>
	<73AED5C780AE05478241DB067651A92102378476@XYUS-EX22.xyus.xyratex.com>
	<50A7CDE4-73B3-4BEB-9BF4-BE0D077A3A00@whamcloud.com>
Message-ID: <5E5695A6-CE4E-4253-B97C-85FAD3C96FFF@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas, LLNL often has file systems with more than 500M inodes in use.  We create them with 1B inodes just for that reason.  And yes, e2fsck times are horrible.  Very painful.

-Marc

----
D. Marc Stearman
Lustre Operations Lead
marc at llnl.gov
925.423.9670
Pager: 1.888.203.0641




On Apr 21, 2011, at 3:56 PM, Andreas Dilger wrote:

> On Apr 20, 2011, at 11:07 AM, Nathan Rutman wrote:
>> We're about to start looking into 64-bit inodes on ext4 -- anybody else working on this at the moment?
> 
> I don't know of anyone other than Fujitsu that are looking at this.  I haven't had any kind of technical discussion with them about it, nor looked at their code, but just implied that this is what they did based on their slides.
> 
> One important consideration to note with 64-bit inode numbers is that they cannot be used safely on 1.8 MDS filesystems.  That is because the IGIF FID namespace only has room for 2^32 inode numbers (mapped into the 2.x FID SEQ field, see ), so upgrading a 1.8 MDS with 64-bit inode numbers to 2.x would cause a huge world of hurt.  If this is limited to 2.x filesystems that only identify MDS inodes via FIDs to the clients then this is not a concern.
> 
> If you are concerned with being able to upgrade 32-bit inode filesystems into 64-bit inode filesystems, you should look at the data-in-dirent patch that is currently in the 2.x ldiskfs patchset.  It was developed to allow storing the 128-bit Lustre FID in the directory entry in a compatible manner, but was also designed to allow storing the high 32 bits of a 64-bit inode number into the directory entry.  That allows compatibility for upgrades by avoiding the need to atomically upgrade a whole directory full of dirents to have 64-bit inode number fields.  It also avoids the need to store 64-bit inode numbers when most of them are 32-bit values.
> 
> 
> I'm not against the idea of exploring this approach, but I am concerned that e2fsck time will continue to grow with the number of inodes in a single filesystem, and scalability of a single MDT will increasingly be an issue.  
> 
> AFAIK, e2fsck times are currently on the order of 1h/100M inodes, and no Lustre filesystems that I know of are above 500M inodes today just due to the average file size being so large and the long e2fsck times.  With improvements in ext4 to reduce e2fsck time like flex_bg, and SSDs, it may be possible to reduce the e2fsck time/inode ratio noticeably, but I think it would take more effort on the e2fsck side than the ext4 side to make many billions of inodes in a single MDT a practical approach.
> 
> Things like metadata prefetching that Dave Dillow was doing for e2scan with event-driven completion handlers that process the blocks whenever they arrive from the disk, and multi-threading some of the passes of e2fsck with an understanding of the underlying disk layout (using the s_raid_stride and s_raid_stripe_width).
> 
> Cheers, Andreas
> --
> Andreas Dilger 
> Principal Engineer
> Whamcloud, Inc.
> 
> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

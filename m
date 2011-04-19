From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 19 Apr 2011 12:00:23 -0600
Subject: [Lustre-devel] Quota enforcement
In-Reply-To: <011901cbfe97$46ef3630$d4cda290$@com>
References: <011901cbfe97$46ef3630$d4cda290$@com>
Message-ID: <7A5E948E-231A-4D8C-9984-97A4D213D02F@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-04-19, at 7:39 AM, "Eric Barton" <eeb@whamcloud.com> wrote:
> I'd like to take a fresh look at quota enforcement.  I think the
> current approach of trying to implement quota purely through POSIX
> APIs is flawed, and I'd like to open up a debate on alternatives.
> 
> If we go back to first premises, quota enforcement is about resource
> management - tracking and enforcing limits on consumption to ensure
> some measure of insulation between different users.  In general, when
> we have 'n' resources which are all consumed independently we should
> also track and enforce limits on each of these independently.

Agreed. In ldiskfs this means tracking inodes and blocks separately, because they have very different constraints. It also means that the quota for MDT and OST space needs to be tracked separately. 

> In conventional filesystems the relevant resources are inodes and
> blocks - which POSIX quota matches nicely.  Although it may seem to
> simplify quota management to equate the POSIX quota inode count with
> the MDS's inode count, and the POSIX quota block count with the sum of
> all blocks on the OSTs, it ignores the following issues...
> 
> 1. Block storage on the MDS must be sized to ensure it is not
>   exhausted before inodes on the MDS run out.  This requires
>   assumptions about the average size of Lustre directories and
>   utilisation of extended attributes.

Agreed. This is definitely the case with current MDTs - the amount of free space is currently always far in excess of what is needed for the number of inodes. For HDDs this is fine because MDT space is "free" when adding spindles for the IOPS.

In any case, the current quota does account for space usage on the MDT. This is important for future data-on-MDT cases. The inode consumption is also a useful metric because it allows the admin to track the fixed ldiskfs inode resource, and also to compute average file size on a per user basis. 

> 2. Sufficient inodes must be reserved on the OSTs to ensure they are
>   not exhausted before block storage.  This requires assumptions
>   about the average Lustre file size and number of stripes.

That is true, but inevitable with the structure of ldiskfs. In the past we have FAR over-provisioned the inodes on ldiskfs OSTs by default because we cannot know in advance what the user is going to be doing with their filesystem.  There is guidance in the manual for tuning this at setup time, but not everyone reads the manual...

I consider the use of inodes/objects on OSTs to be a side-effect of the Lustre implementation, so as long as we have enough I don't think they should be accounted separately, and definitely not in the same bucket as MDT inodes. This is because the performance characteristics of a single file vary with the number of objects == OSTs, and the user may not even be controlling this mapping in the future with dynamic layouts. 

With newer filesystems that have dynamic inode allocation, the concept of inodes being a constrained resource on the OSTs is gone, and essentially this is just a small overhead of space on the OST, like an indirect block is.

> 3. Imbalanced OST utilization causes allocation failures while
>   resources are still available on other OSTs.

That is true whether the allocation failure is due to the OST filling up with a dynamic quota, or if the quota is running out on an OST with a static quota. Both problems would ideally be avoided by perfectly even usage, but that is not realistic. 

> (3) is the most glaringly obvious issue.  It gives you ENOSPACE when
> you extend a file if one of the OSTs it's striped over is full.  Very
> irritating if 'df' reports that plenty of space is still available and
> it's not something the quota system itself can help you avoid.  
> 
> In fact quota enforcement currently takes pains to allow quota
> utilisation to become imbalanced across OSTs by dynamically
> distributing the user's quota to where it's being used.  This comes at
> a performance cost as quota nears exhaustion.  Provided the user
> operates well within her quota, quota is distributed in large units
> with low overhead.  However as she nears her limit, protocol overhead
> increases as quota is distributed in successively smaller units to
> ensure it is not all consumed prematurely on one OST.
> 
> An alternative approach to (3) is to move the usage to where the
> resources are - i.e. implement complex/dynamic file layouts that
> effectively allow files to grow dynamically into available free space.
> This works not just for quota enforcement but for all free space.
> However it also comes at the cost of increasing overhead as
> space/quota is exhausted.  It's also much harder to implement -
> especially for overwriting "holes" rather than simply extending files.

This doesn't seem like a huge win to me, and comes at a cost in implementation complexity. I agree that dynamic layouts is something that we've discussed for a long time already, and we are moving in that direction with the layout lock from HSM, but we are still some distance away from this today, IMHO.

We also have to consider that dynamic layout for large files may not always be a magic bullet. If there are many processes writing what the MDT considers "large" files, then always increasing the stripe count would only serve to increase contention on the OSTs, and not improve apace balance at all. 

> I'd dearly like some surveys of real-world systems to discover exactly
> how imbalanced utilisation can really become, both for individual
> users and also in aggregate to provide guidance on how to proceed.

The common case of severe imbalance that I'm aware of is a user creating a huge tar file of their output, but not specifying a wide striping, so thousands of files currently spread over many OSTs are copied onto one or two OSTs where the tar file is located.

The only other real-world case I'm aware of is applications/users specifying striping with an index == 0 instead of -1 that causes the first OST(s) to fill unevenly.  I'm some sense, this is an artifact of the first problem, that users need to specify striping in the first place.

With balanced round-robin allocation, the majority of "general" imbalance will be avoided, and dynamic layouts would help those extreme cases of large imbalanced files. 

> I'm leaning towards static quota distribution since that matches the
> physical constraints, but it requires much better tools (e.g.  for
> rebalancing files and reporting not just utilization totals but also
> median/min etc).

Cheers, Andreas

From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 24 Aug 2011 15:59:32 -0600
Subject: [Lustre-devel] MRP-203 obdfilter not able to serve more then 32
	requests in parallel
In-Reply-To: <73AED5C780AE05478241DB067651A92102378760@XYUS-EX22.xyus.xyratex.com>
References: <73AED5C780AE05478241DB067651A9210237875E@XYUS-EX22.xyus.xyratex.com>
	<73AED5C780AE05478241DB067651A92102378760@XYUS-EX22.xyus.xyratex.com>
Message-ID: <7A4E2471-331E-4DE4-8208-A4D5B9F945BA@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-08-24, at 1:12 PM, Nathan Rutman wrote:
> On Aug 24, 2011, at 11:22 AM, Oleg Drokin wrote:
>> Increasing number of dirs is fine by me, but it has implications for upgrading and downgrading.
>> For example I think number of dirs is really hardcoded everywhere instead of using value in server data.
>> Also if you want to change the value on existing OST, we need a rehash functionality,
>> and then using older releases on such filesystems would lead to corruptions which also needs to be avoided somehow.

Yes, compatibility definitely has to be taken into account.  Note that in 1.x
the code has always used fo_subdir_count for this value, so it should be
relatively straight forward to change this code in a compatible way.

The fo_subdir_count is initialized to FILTER_SUBDIR_COUNT when last_rcvd is
first created, but if last_rcvd needs to be recreated after the filesystem is
in use then it needs to scan O/0/d* to see what the actual subdirectory count
is (easily done just by calling readdir() on O/0 and finding the largest value).
Also lustre/utils/ll_recover_lost_found_objs.c would need to be fixed similarly.

If in-place upgrading is needed, then either rehash would be possible but
initially slow, and possibly broken if it is interrupted in the middle.  It
would be possible to do this on the fly by creating d[0..FILTER_SUBDIR_COUNT-1]
and searching d{objid % fo_subdir_count} first, but for missing objects it
should also check d{objid % FILTER_SUBDIR_COUNT_OLD} (if fo_subdir_count isn't
FILTER_SUBDIR_COUNT_OLD) and move the object over if found.

That way the OST puts progressively more objects in the new directory structure,
and only unused objects are left in d[0-31].  This kind of scheme would also
allow the hash size to be changed while the OST is in use (with also new subdir
array allocations and such), if there is ever a need to do so.

On a related note, while this is a very easy fix and I encourage you to finish
it, there are some other efforts that may make this less critical:
- parallel directory operations (originally for MDT) would also avoid lock
  contention on the OST parent directories, but not until 2.2
- server DLM locks should hold an inode reference (discussed in the past,
  but nobody working on it) which would avoid parent directory lookups
  entirely, since client already sends lock handle for O(1) lock lookups,
  and that would give inode reference for free and also avoid pushing the
  in-use inodes out of memory on the server due to memory pressure


> On Aug 24, 2011, at 11:06 AM, Nathan Rutman wrote:
> 
>> currently we have to use 32 directories for object in OST. but for large scale OST it isn't enough. 
>> so we need to able to extend that number to ~1024 or more.
>> 
>> This was brought up at LUG (presentation attached below) and my recollection is that Oleg had some strong opinions on this -- maybe not increasing the number of dirs but certainly on any locking changes.  Oleg -- did you have any objection to increasing the number of object directories?
>> 
>> 130-200_Ben_Evans_LUG ... - OLCF.ORNL.GOV
>> 
>> 
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
> 
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel


Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.

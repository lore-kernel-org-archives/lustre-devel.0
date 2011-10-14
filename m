From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 13 Oct 2011 20:14:08 -0600
Subject: [Lustre-devel] Moving ldiskfs external to the Lustre tree
In-Reply-To: <73AED5C780AE05478241DB067651A921023788A5@XYUS-EX22.xyus.xyratex.com>
References: <4E960A40.9040509@llnl.gov>
	<2B361165-F4ED-4339-BA05-D216AE62A4AC@whamcloud.com>
	<73AED5C780AE05478241DB067651A921023788A5@XYUS-EX22.xyus.xyratex.com>
Message-ID: <88AF06C1-9A91-4652-B43F-6C4ABCAC039C@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-10-13, at 4:30 PM, "Nathan Rutman" <Nathan_Rutman@xyratex.com> wrote:
> On Oct 12, 2011, at 7:05 PM, Andreas Dilger wrote:
>> I'm not against this in principle, but I think it may be more difficult to actually implement before the OSD changes from Orion are landed to master.  
> 
> You mean, it will make it more difficult to land Orion changes, right?  
> Chris already has implemented the external build.

No, I mean it will make it harder to maintain Lustre and ldiskfs separately before we get to the OSD API that has a better abstraction than the current fsfilt/lvfs interface that is used in the current Lustre code. 

Granted that we don't have to change this code very often recently, it does change on occasion, and maintaining compatibility between arbitrary versions of ldiskfs and Lustre is a headache that we don't really need right now.

The fact that Chris has a point-in-time version of ldiskfs and Lustre that are working together is great, but given that the OSD code migration is already underway it doesn't make sense to add a lot of code churn before that happens. 

I'm not against making this change if there is no expectation that there is lomg-term compatibility between different ldiskfs and Lustre builds. If it works, great, but if there is an interface change needed then both packages will need to be upgraded. 

Hopefully once we have the OSD API in use for the OSS, MGS, and the ZFS is working there will be fewer API changes needed and the number of dependent package updates can be reduced.

Cheers, Andreas

>> In the past we also thought about making ldiskfs as a separate package, before ext4 started in the kernel. 
>> 
>> I've seen Prakash working on those patches but will not have time to look at them until at least next week. 
>> 
>> Are those patches against the master branch or against Orion?  Also, what kernels are supported?
>> 
>> Cheers, Andreas
>> 
>> On 2011-10-12, at 3:44 PM, "Christopher J. Morrone" <morrone2@llnl.gov> wrote:
>> 
>>> We would like to see the ldiskfs tree removed from the lustre tree and 
>>> made an independent package.  I have been floating this idea 
>>> unofficially for a while, but I would like to now officially propose 
>>> this for Lustre 2.2.
>>> 
>>> With the OBD changes that are taking place on the Orion branch, we want 
>>> to make lustre be able to use any of a number of backend filesystems. 
>>> The current tree and configure tools make it very hard to build without 
>>> ldiskfs (instead using zfs, btrfs, or something we haven't thought of 
>>> yet).  As part of cleaning that up, moving ldiskfs external to lustre 
>>> will help ensure that we don't have unnecessary dependencies crop up in 
>>> the future.
>>> 
>>> We have created an external package of the ldiskfs tree and put it up on 
>>> github:
>>> 
>>> https://github.com/chaos/ldiskfs
>>> 
>>> To use the new external ldiskfs package with lustre, you will also need 
>>> a few patches to lustre itself.  There are links to the patches in this 
>>> jira ticket:
>>> 
>>> http://jira.whamcloud.com/browse/LU-723
>>> 
>>> On a RHEL system, ldiskfs has a build dependency on the kernel-debuginfo 
>>> packages by default.  That is where we find the ext4 source code.
>>> 
>>> Building should be fairly straight forward.  Build and install ldiskfs 
>>> (in particular the lustre-ldiskfs-devel package), and then build lustre. 
>>> The main new change to lustre is the addition of the configure option 
>>> "--with-ldiskfs-devel".  On a RHEL system if you have the 
>>> lustre-ldiskfs-devel package installed, you won't need to give a path.
>>> 
>>> Note that we have not yet removed the in-tree ldiskfs.  Our first step 
>>> was to get this working.  Once this is accepted, we will be happy to 
>>> submit the patches to remove lustre's copy of ldiskfs and generally 
>>> clean up lustre's autoconf checks involving ldiskfs.
>>> 
>>> We attempted to keep the changes minimal, so we didn't change the name 
>>> of the ldiskfs rpm packages.  But we think is would be nice to change 
>>> the name from "lustre-ldiskfs" to simply "ldiskfs".  If we want to make 
>>> that change, now is the time to do it.
>>> 
>>> Chris
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
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20111013/6bc1b75a/attachment.htm>

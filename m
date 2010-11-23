From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Tue, 23 Nov 2010 14:19:03 -0700
Subject: [Lustre-devel] Stripe offset default
In-Reply-To: <4CEC1AB8.2040507@llnl.gov>
References: <016b01cb8b32$cc3a9c90$64afd5b0$@com> <4CEC1AB8.2040507@llnl.gov>
Message-ID: <AA2C4DA2-1607-4509-9BF2-7F05A352B269@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-11-23, at 12:49, Christopher J. Morrone wrote:
> On 11/23/2010 09:20 AM, Eric Barton wrote:
>> I believe, now that lfs setstripe uses options rather than positional
>> parameters, that the risk of unintentional errors is much less.  But
>> that still leaves the filesystem vulnerable to na?ve or malicious
>> users.  So I propose that we should continue to check permissions
>> normally when setting the default stripe _count_, but restrict the
>> ability to set a specific default stripe _offset_ to the superuser.
> 
> At the very least bug 18547 MUST be completed before doing this. 
> Lustre's default layout mechanism is too uneven, and leads to too much 
> of a performance problem right now to take away users' only ability to 
> lay files out evenly on their own.

I guess the subtle distinction in Eric's question is for "default striping parameters specified on a directory" and not "striping parameters set on a per-file basis".  In IRC I discussed with Eric that it is like that specifying the starting OST on a directory default layout is _probably_ not what a user wants to do.

I think the majority of the confusion was due to the (archaic and long obsolete) usage of positional "lfs setstripe {size} {offset} {count}" parameters, when in fact most users just want to specify {count} and neither of the others.  The {size} and {offset} values would get various strange "default" values, depending on whether the user remembers their meanings.  This accidentally caused many users to specify OST 0 as the starting offset for their files, instead of using "-1" which means "let the MDS decide which OSTs to use".

Instead, the named options "--size/-s", "--offset/-o" (identical to "--index/-i"), and "--count/-c" to "lfs setstripe" have been available since 1.6.1, but it was only in 1.8.0 that using the old positional parameters would generate a warning, and in 2.1.0 this usage will generate an error.

> How much of a problem, really, are naive/malicious users?

IMHO, limiting the ioctl() to root users is at best obfuscating the issue, and not really solving the problem.  In either case, it doesn't help if the users are running ancient versions of Lustre where the problem has not been fixed.

> Malicious users can easily fill the OST of their choice with a tiny 
> script that creates thousands of empty files, and then fills only the 
> files that happened to land on the target OST.
> 
> Naive users can fill one or a few OSTs by simply writing really large 
> files.  We've had that happen when a user, for instance, decides to 
> create a really large tar file without first creating a widely striped 
> file to hole the tar date.
> 
> But taking away our ability specify file offset where we want them 
> definitely hurts testing and debugging efforts.  Testing reproducibility 
> is enhanced when we can reproducibly lay out files.  Debugging problems 
> on a live system is sometimes made easier by specifying the file offset, 
> e.g. when we are trying to target certain network switches or OSS nodes.
> 
> And when a problem DOES occur, sysadmins now have lustre quotas to help 
> them quickly identify the culprit.
> 
> Since the problem user can quickly be identified, and since the users 
> can still pretty easily cause the same trouble using other mechanisms, I 
> don't think that the benefits necessarily outweigh the disadvantages.
> 
> If someone decides that they really, really want this, then I think it 
> should be tunable to allow the sysadmin to select whether or not setting 
> file offset is restricted to superuser.
> 
> Chris
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel


Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.

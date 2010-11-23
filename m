From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Tue, 23 Nov 2010 11:49:12 -0800
Subject: [Lustre-devel] Stripe offset default
In-Reply-To: <016b01cb8b32$cc3a9c90$64afd5b0$@com>
References: <016b01cb8b32$cc3a9c90$64afd5b0$@com>
Message-ID: <4CEC1AB8.2040507@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 11/23/2010 09:20 AM, Eric Barton wrote:
>

> I believe, now that lfs setstripe uses options rather than positional
> parameters, that the risk of unintentional errors is much less.  But
> that still leaves the filesystem vulnerable to na?ve or malicious
> users.  So I propose that we should continue to check permissions
> normally when setting the default stripe _count_, but restrict the
> ability to set a specific default stripe _offset_ to the superuser.
>
> Thoughts?

At the very least bug 18547 MUST be completed before doing this. 
Lustre's default layout mechanism is too uneven, and leads to too much 
of a performance problem right now to take away users' only ability to 
lay files out evenly on their own.

How much of a problem, really, are naive/malicious users?

Malicious users can easily fill the OST of their choice with a tiny 
script that creates thousands of empty files, and then fills only the 
files that happened to land on the target OST.

Naive users can fill one or a few OSTs by simply writing really large 
files.  We've had that happen when a user, for instance, decides to 
create a really large tar file without first creating a widely striped 
file to hole the tar date.

But taking away our ability specify file offset where we want them 
definitely hurts testing and debugging efforts.  Testing reproducibility 
is enhanced when we can reproducibly lay out files.  Debugging problems 
on a live system is sometimes made easier by specifying the file offset, 
e.g. when we are trying to target certain network switches or OSS nodes.

And when a problem DOES occur, sysadmins now have lustre quotas to help 
them quickly identify the culprit.

Since the problem user can quickly be identified, and since the users 
can still pretty easily cause the same trouble using other mechanisms, I 
don't think that the benefits necessarily outweigh the disadvantages.

If someone decides that they really, really want this, then I think it 
should be tunable to allow the sysadmin to select whether or not setting 
file offset is restricted to superuser.

Chris

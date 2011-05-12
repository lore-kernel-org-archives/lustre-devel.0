From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Thu, 12 May 2011 10:28:42 -0700
Subject: [Lustre-devel] Technical debt in the lustre build system
In-Reply-To: <27CC7301-CA70-4AB6-8AB0-4302637B0367@ddn.com>
References: <4DC46DDB.4000906@llnl.gov>
	<27CC7301-CA70-4AB6-8AB0-4302637B0367@ddn.com>
Message-ID: <4DCC18CA.6070205@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 05/12/2011 01:58 AM, Ashley Pittman wrote:

> 10)
>
> One of the things that bugs me is that currently we build and distribute a new kernel for each and every update when in theory we could re-use the kernel and only update the modules 90% of the time.  As a background to this we maintain our list of patches to Lustre with quilt and for any given commit there is no way that I know of to tell if the change impacts the kernel patches or just the module/userspace.  As a result the only safe thing to do is to build a whole new kernel each and every time.  Actually the cost of this is pretty low as Lustre runs on dedicated machines so rebooting during updates is not an issue.

I feel for you.  We used to maintain our patches to lustre in quilt, but 
we've moved to just keeping a branch in git.  I for one am MUCH happier 
now that we've eliminated that quilt part.

> One thing I changed at Quadrics where we had a similar problem was to separate the kernel patches from the kernel modules into different "packages" and maintain, distribute, and update them as separate bits of software.  This had the added benefit of making it obvious when people were patching the kernel further which reduced the incidence of this and meant we put more thought into changes.  I suspect this wouldn't work for Lustre as it's more intrusive into the kernel source but I'd welcome ideas for solving the do-I-update-the-kernel-or-not problem.

Yes, I agree, that is an issue.  We maintain our own kernel release, and 
currently we need to keep the same watch on the kernel_patches 
directories that you do so that we can regularly pull the patches into 
our kernel repo.

I think we can greatly improve that situation.  I see two things that 
would make a big difference:

1) Make lustre "patchless".  If you ignore the ldiskfs patches, the 
kernel patch set for lustre is getting quite small.  There is even the 
belief that with some effort lustre can go completely patchless 
(ignoring ldiskfs) for the server as well as the client.  This effort is 
under way, and there are bugs open to track it.  But it is one of those 
items that tends to have slow progress because the developers are busy 
with other tasks.

2) Package ldiskfs separately.  Make direct commits to ldiskfs's git 
repo rather than maintaining a quilt patch stack.

Chris

From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 19 Dec 2012 08:39:08 +0000
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
 primitives usage.
In-Reply-To: <20121219001255.GB5622@llnl.gov>
Message-ID: <CCF6C722.BA0B%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 12/18/12 5:12 PM, "Prakash Surya" <surya1@llnl.gov> wrote:
>On Tue, Dec 18, 2012 at 05:12:27PM -0500, Brian J. Murrell wrote:
>> On Mon, 2012-12-17 at 23:12 -0500, Ken Hornstein wrote:
>> > There's a HUGE
>> > difference in practice between "feature X appears in Linux kernel
>> > version Y" and "My RedHat release Z has a particular feature".  That's
>> > where life gets complicated.  Many times we're stuck on a particular
>> > kernel for various complicated reasons, yet we need to upgrade Lustre
>> > ... or vice versa.  It's kind of like Infiniband in the Linux kernel
>>...
>> > at best, it doesn't hurt us, but it's always the "wrong" version (or
>>so
>> > my Infiniband guys tell me).  We never end up using the Infiniband in
>> > the kernel, and sometimes (depending on the vagarities of the distro)
>> > that screws us up hard; part of that is because for a long time one
>> > particular distro never would distribute the development symbols for
>> > the Infiniband in the kernel that matched what the kernel was running.
>> > That won't be an issue with Lustre, but you get the idea.
> > 
>> 
>> So let me just confirm I understand your issue here.  For example, the
>> Linux kernel is at 3.12.1 (version numbers are purely hypothetical and
>> far into the future) which has Lustre 2.6.3 in it.  But RHEL 9's kernel
>> is only 3.8.1"ish" and has Lustre 2.4.2 (because that's what was in the
>> upstream Linux 3.8.1 kernel) in it.
>> 
>> The complaint is that the Lustre (2.4.2) that's in the RHEL 9 kernel
>> that you are using is too old for some reason?
>> 
>> So what's the remedy?  You can either (a) download the stand-alone
>> Lustre module source for the version of Lustre you need and build it
>> against the RHEL 9 kernel you want to use (assuming they are near enough
>> to be compatible -- which is the same situation that exists today) or
>
>That is a big assumption, and is most likely false. Currently autoconf
>maintains the compatibility of Lustre with the different kernel versions.
>If the client is in tree, are we really going to maintain the same level
>of autoconf "foo" to be compatible with older kernels? And if not, we
>would have to maintain a second package, outside of the kernel, which did
>have this autoconf compatibility layer.
>
>I don't think option (a) is the same as what we have now.

We _already_ have to maintain this autoconf layer for the out-of-kernel
tree, and we've had to do it basically forever.  At least if Lustre is in
the kernel, it is _possible_ that the version that is in the vendor
release is "good enough" for a large number of users (probably more than
exist today).  

If we align the Lustre "maintenance" branch with the kernel version that
goes into the distro long-term-maintenance kernels (e.g. Lustre 3.0 and
Linux 3.24 for RHEL8) that wouldn't be very different from what we are
doing today, but it would be a lot less hassle for most users.  If someone
wants to run a new kernel and new Lustre development release, then they
will get both at the same time.

The corner case is a development version of Lustre with an older vendor
kernel, which would require making the new version of Lustre to build
against the vendor kernel.  The in-kernel version of Lustre would no
longer have the autoconf and kernel-portability wrappers, but at least for
a few years there would be an out-of-kernel version of Lustre until it is
available in the vendor kernels (only updated every few years).

Having Lustre in the kernel would also tend to provide a more "stable"
point for the Lustre client and network protocol (as commented elsewhere),
assuming we can line up the Lustre maintenance releases with the kernel
chosen by the vendors.  We already need to provide interop and upgrade
support for Lustre, regardless of whether it is in the kernel or not.

It may mean that the "maintenance" version of Lustre is chosen by Red Hat
when they decide on which kernel to use for, say, RHEL8.  We would push
Lustre fixes into the "stable" kernel branch used by RHEL8 and/or directly
to RH.

The most difficult part will be the transition, when there is a version of
Lustre in the kernel, but there is still a need to maintain Lustre out of
the tree for the older kernels that do not have it yet.  That would
probably take 3-6 years before we could reasonably deprecate the oldest
vendor kernel that does not have any Lustre support in it.

>> (b) you download the entire upstream kernel that has the version of
>> Lustre that you want to use and build that.
>> 
>> It seems to me that (a) is what everyone already has to do all of the
>> time today anyway (assuming the binary RPM that we ship for the given
>> vendor kernel is not new enough) and (b) just isn't even possible so
>> that's gravy.
>> 
>> There might be something obvious that I'm missing, but I'm failing to
>> see how having Lustre (client) in the kernel is any worse than the
>> status quo (basically scenario (a) above) and indeed should provide
>> Lustre compatibility to the current stable Linux sooner than we can
>> typically turn it around.
>> 
>> Cheers,
>> b.


Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division

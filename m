From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 19 Dec 2012 22:59:21 +0000
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
 primitives usage.
In-Reply-To: <D01411ED-E27A-4245-8614-86A69F168F95@xyratex.com>
Message-ID: <CCF78FC7.BD6F%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 12/19/12 5:32 AM, "Alexey Lyahkov" <alexey_lyashkov@xyratex.com> wrote:

>That is second question,
>how we plan maintain a stable version to build with older kernels from
>RHEL, SuSe and may be Debian.
>how WC have plan to sync changes between stable tree and development in
>kernel?

This will need some extra effort, but needs to happen.  That is why we are
now
working to clean up the current Lustre code to be acceptable to the
upstream
kernel.  If the out-of-kernel Lustre code is wildly different from the
in-kernel
Lustre code, then it will be far too much effort to keep the two in sync.

By changing the compatibility macros to match the upstream kernel, cfs_*
wrappers,
split the client/server code, etc, we can make the out-of-tree code match
the
in-kernel code very closely, then porting patches back and forth will be
much
less work.

>what they will planed in case huge API changes? as example that change -
>splice API was added in 2.6.20 kernel and sendfile API was killed - so we
>should lost all kernels with sendfile support (RHEL5, SLES9/10).
>Same for page fault API - they have 3 versions between 2.6.21 and 2.6.26
>- so old kernels will be also killed from support.
>or we will have never tested code in 'stable' tree.

This is no different than the situation today.  There are large API
changes in
the upstream kernel (e.g. VFS changes in 2.6.37), and we are always playing
catch-up with them.  Through the work of EMC we are close to being in sync
with
the upstream kernel (3.6 at least), and being part of the upstream kernel
will
definitely help avoid this problem.  Then, patches to change the API in the
kernel will also be applied to the Lustre code immediately.

Once Lustre is in the upstream kernel, it will eventually get into the
vendor
kernels.  It may also be possible to get a backport (i.e. the current
version)
included into a vendor kernel since they are less reluctant to do so for
code
that is already in the upstream kernel.

>reason to use autoconf macroses - we can't trust a RHEL/SuSe kernel
>version/

Sure, we will need this for the out-of-tree Lustre code, as we do today,
but not
inside the kernel.  The benefit is that the in-tree code will be the
"right"
code for that particular kernel version, and no macros will be needed.

Cheers, Andreas

>On Dec 19, 2012, at 04:12, Prakash Surya wrote:
>>>> ]unning.
>>>> That won't be an issue with Lustre, but you get the idea.
>>> 
>>> So let me just confirm I understand your issue here.  For example, the
>>> Linux kernel is at 3.12.1 (version numbers are purely hypothetical and
>>> far into the future) which has Lustre 2.6.3 in it.  But RHEL 9's kernel
>>> is only 3.8.1"ish" and has Lustre 2.4.2 (because that's what was in the
>>> upstream Linux 3.8.1 kernel) in it.
>>> 
>>> The complaint is that the Lustre (2.4.2) that's in the RHEL 9 kernel
>>> that you are using is too old for some reason?
>>> 
>>> So what's the remedy?  You can either (a) download the stand-alone
>>> Lustre module source for the version of Lustre you need and build it
>>> against the RHEL 9 kernel you want to use (assuming they are near
>>>enough
>>> to be compatible -- which is the same situation that exists today) or
>> 
>> That is a big assumption, and is most likely false. Currently autoconf
>> maintains the compatibility of Lustre with the different kernel
>>versions.
>> If the client is in tree, are we really going to maintain the same level
>> of autoconf "foo" to be compatible with older kernels? And if not, we
>> would have to maintain a second package, outside of the kernel, which
>>did
>> have this autoconf compatibility layer.
>> 
>> I don't think option (a) is the same as what we have now.
>> 
>> -- 
>> Cheers, Prakash
>> 
>>> (b) you download the entire upstream kernel that has the version of
>>> Lustre that you want to use and build that.
>>> 
>>> It seems to me that (a) is what everyone already has to do all of the
>>> time today anyway (assuming the binary RPM that we ship for the given
>>> vendor kernel is not new enough) and (b) just isn't even possible so
>>> that's gravy.
>>> 
>>> There might be something obvious that I'm missing, but I'm failing to
>>> see how having Lustre (client) in the kernel is any worse than the
>>> status quo (basically scenario (a) above) and indeed should provide
>>> Lustre compatibility to the current stable Linux sooner than we can
>>> typically turn it around.
>>> 
>>> Cheers,
>>> b.
>>> 
>
>----------------------------------------------
>Alexey Lyahkov
>alexey_lyashkov at xyratex.com
>
>
>_______________________________________________
>Lustre-devel mailing list
>Lustre-devel at lists.lustre.org
>http://lists.lustre.org/mailman/listinfo/lustre-devel
>


Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division

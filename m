From: NeilBrown <neilb@suse.com>
Date: Fri, 08 Jun 2018 06:50:29 +1000
Subject: [lustre-devel] [PATCH 10/11] staging: lustre: move ldlm into
 ptlrpc
In-Reply-To: <D73EEFA7.FCA6%jevans@cray.com>
References: <152826510267.16761.14361003167157833896.stgit@noble>
 <152826511923.16761.9237280635711887801.stgit@noble>
 <alpine.LFD.2.21.1806070546210.23188@casper.infradead.org>
 <87sh5zlyf4.fsf@notabene.neil.brown.name> <D73EEFA7.FCA6%jevans@cray.com>
Message-ID: <87k1ramicq.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ben Evans <bevans@cray.com>, James Simmons <jsimmons@infradead.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Jun 07 2018, Ben Evans wrote:

> On 6/7/18, 5:48 AM, "lustre-devel on behalf of NeilBrown"
> <lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:
>
>>On Thu, Jun 07 2018, James Simmons wrote:
>>
>>>> The ldlm code is built into the ptlrpc module, yet it lived in a
>>>> separate directory.  This requires filename editing in the Makefile
>>>> and make it difficult to e.g. build the .s file for code in ldlm.
>>>> 
>>>> All the ldlm files have distinctive names so confusion from having
>>>> ptlrpc and ldlm in the same directory is unlikely.  So move them all
>>>> into ptlrpc.
>>>
>>> Nak. The reason is it would be nice to keep the directory structure.
>>> What really needs to be done and Oleg has looked into it is to reduced
>>> the number of modules created down to two, one for LNet and the other
>>> lustre.ko. This also is a step in the right direction to remove the
>>> create struct obd_ops and struct md_ops pointer madness. Well their
>>> is the issue with obd echo client but we can deal with this at a later
>>> date. Also the number of EXPORT_SYMBOLS and things will greatly reduce.
>>
>>Yeah, you are probably right.
>>I had a bit of a look at how to build everything into a
>>single module.  You can do with by having a single make
>>file that lists parts from other directories - the same way
>>that ptlrpc includes files from ldlm - but that is rather ugly.
>>
>>I've very nearly got it working using the lib-y infrastructure.
>>I can build lnet as a single module, but the dependency calc isn't
>>quite right so things happen in the wrong order.  The build
>>fails the first time because some files don't exist, then
>>succeeds on the second run.
>>Hopefully I'll figure out how to make it work tomorrow.
>>
>>Thanks for the review,
>>NeilBrown
>
> Would this be client-only, or could the server code be added as well with
> an ldiskfs/zfs module?

The important step is creating the infrastructure so that choice can
be easily made, and changed, with just a single line in a Makefile.
Fine-tuning decisions can follow.

I doubt it would make sense for ldiskfs and/or zfs to be in the same
module as lustre.  I also doubt that either will ever land upstream so
it hardly matters (to me).
When the server lands upstream (I think it will), it will use (at least)
the upstream ext4.  This might require changes to upstream ext4
(I understand a lot of work has already happened in that direction).  It
might require sacrificing some functionality (hopefully only
temporarily).  It might require having an incompatible on-disk format
(which is unfortunate but quite manageable).

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180608/3cd44b19/attachment.sig>

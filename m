From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 09:40:49 +1000
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <DM3PR1101MB121322E85FDE1E5310F6F4B7CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <alpine.LFD.2.21.1806210239190.3886@casper.infradead.org>
 <DM3PR1101MB1213DDB7FC857EE6B1444153CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <alpine.LFD.2.21.1806210354260.3886@casper.infradead.org>
 <3FD4D051-9C95-449D-8A23-D42B271E55B8@dilger.ca>
 <DM3PR1101MB121322E85FDE1E5310F6F4B7CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
Message-ID: <87tvprah32.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 21 2018, Patrick Farrell wrote:

> Ah, thanks Andreas.  Perhaps not coincidentally, Lustre 2.4 is the first release I worked on.
>
> Neil, I am really unenamored of the idea of the shared ptlrpc ldlm module being named ptlrpc...

Can you say why?  Is it the choice of name that bothers you, or the
combining of two things into the one kernel module, or something else?
Currently in  git://git.hpdd.intel.com/fs/lustre-release.git
(or the git tree that was until recently at the above address),
the module named "ptlrpc" contains ptlrpc code, ldlm code, and target
code.  I wonder what "target" means in this context.

>
> Also, Lustre currently has a bunch of module parameters which are used for configuration.  Thoughts on that?

Yes, the module parameters are an interesting part of the story.
libcfs has a bunch of module parameters that are symlinked from debugfs.
It seems that user-space largely uses the debugfs links to access them,
so they can become part of the "lnet" module with minimal pain.
Other modules have parameters that I haven't yet looked in to.

There probably will need to be user-space changes to support reduction
in the number of modules.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/0350635b/attachment.sig>

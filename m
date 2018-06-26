From: Patrick Farrell <paf@cray.com>
Date: Tue, 26 Jun 2018 13:51:13 +0000
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <alpine.LFD.2.21.1806260206360.31196@casper.infradead.org>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <alpine.LFD.2.21.1806210239190.3886@casper.infradead.org>
 <DM3PR1101MB1213DDB7FC857EE6B1444153CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <alpine.LFD.2.21.1806210354260.3886@casper.infradead.org>
 <3FD4D051-9C95-449D-8A23-D42B271E55B8@dilger.ca>
 <DM3PR1101MB121322E85FDE1E5310F6F4B7CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <87tvprah32.fsf@notabene.neil.brown.name>,
 <alpine.LFD.2.21.1806260206360.31196@casper.infradead.org>
Message-ID: <DM3PR1101MB121358672276198B843DE5A7CB490@DM3PR1101MB1213.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ah, sorry, lost your mail in the shuffle, Neil.

The name, mostly.  ptlrpc is one subdirectory and one subsystem, so I don?t want to use it for a module that explicitly includes all of several.  I?m not sure of a better name immediately - is this module intended to be shared between client and server?


________________________________
From: James Simmons <jsimmons@infradead.org>
Sent: Monday, June 25, 2018 8:13:22 PM
To: NeilBrown
Cc: Patrick Farrell; Andreas Dilger; Oleg Drokin; Lustre Development List
Subject: Re: [lustre-devel] [PATCH 00/24] lustre - more cleanups including module reduction.


> > Ah, thanks Andreas.  Perhaps not coincidentally, Lustre 2.4 is the first release I worked on.
> >
> > Neil, I am really unenamored of the idea of the shared ptlrpc ldlm module being named ptlrpc...
>
> Can you say why?  Is it the choice of name that bothers you, or the
> combining of two things into the one kernel module, or something else?
> Currently in  git://git.hpdd.intel.com/fs/lustre-release.git
> (or the git tree that was until recently at the above address),
> the module named "ptlrpc" contains ptlrpc code, ldlm code, and target
> code.  I wonder what "target" means in this context.

target is the server code built into ptlrpc which is for the "Unified
Target". Its the shared code that is used by both the MDS and OSS code.
Andreas or Oleg can add more details than this. BTW also the nodemap
code also get built into ptlrpc module as well for the server side.

> > Also, Lustre currently has a bunch of module parameters which are used for configuration.  Thoughts on that?
>
> Yes, the module parameters are an interesting part of the story.
> libcfs has a bunch of module parameters that are symlinked from debugfs.
> It seems that user-space largely uses the debugfs links to access them,
> so they can become part of the "lnet" module with minimal pain.
> Other modules have parameters that I haven't yet looked in to.
>
> There probably will need to be user-space changes to support reduction
> in the number of modules.

The test suite will need some changes since it loads the modules. We
need to handle the case if its built into the kernel as well.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180626/bc8c6124/attachment.html>

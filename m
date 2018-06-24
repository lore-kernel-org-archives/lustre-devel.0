From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 21:46:22 +0100 (BST)
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <87r2l0df25.fsf@notabene.neil.brown.name>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <alpine.LFD.2.21.1806210239190.3886@casper.infradead.org>
 <87r2l0df25.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1806242140210.28698@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> >> Here are a bunch more cleanups that will appear in my lustre-testing
> >> tree shortly.
> >> 
> >> The interesting stuff is some enhancements to kbuild to let us
> >> build modules from multiple directories.
> >> I've used that to clean up the build of ptlrpc+ldlm and to
> >> merge libcfs and lnet into the one module - I've left the lnds
> >> separate.
> >
> > That looks pretty good. It doesn't apply to the stable lustre tree but I
> > did try it out on lustre-testing. The module building does seem to 
> > function well. Only thing not clear is if do a
> >
> > make SUBDIRS=drivers/staging/lustre/lustre/lmv modules
> 
> Why would you do that?  SUBDIRS= is for building external modules.
> What are you trying to achieve?
> 
> >
> > do lmv.a and the other *.a files get relinked int lustre.ko ?
> 
> It isn't "lmv.a", it is ".../lustre/lmv/mod.a".

Sorry I forgot the mod.a naming. I was asking to get a feel of how the
work flow would change. It is common for lustre developers to build
in tree and test without installing anything. The many module approach
might of been a way for people to rebuild a module, unload module and
then reload module quickly to test a change. I don't work this way so
I can't say. I was looking to see if that work flow could still be
done.

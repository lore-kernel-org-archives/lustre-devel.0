From: Liang Zhen <Zhen.Liang@Sun.COM>
Date: Wed, 16 Dec 2009 10:55:11 +0800
Subject: [Lustre-devel] client side reply handling
In-Reply-To: <2b20c7140912151801m78871060pd20e5136c105b507@mail.gmail.com>
References: <2b20c7140912090705s47667951w26fe6c95e81f2c8f@mail.gmail.com>
	<3ed212d00912150828u2fc58cf2v541c95989d220a85@mail.gmail.com>
	<2b20c7140912151801m78871060pd20e5136c105b507@mail.gmail.com>
Message-ID: <4B284C0F.3080303@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter,

It depends on how buffers are attached to portal, ptlrpc has three cases 
of this:
1. If buffer is for incoming request (not for RDMA, so it's not unique 
match)
    the MD is constructed with lnet_md_t::threshold = LNET_MD_THRESH_INF,
    so it will be unlinked only for two cases:
    a) user call LNetMDUnlink explicitly
    b) the buffer is exhausted (lnet_md_exhausted() return 1 in LNet)
    Once LNet get a request for that buffer, it will change offset of 
the buffer so
it wouldn't be overwritten by the next match, it's possible that upper 
layer is handing
the request, and the buffer is still on match list

2. If buffer is for bulk (it's unique)
    the MD is constructed with lnet_md_t::threshold = 1, and
    LNetMDAttach(...LNET_UNLINK...)
    so LNet will auto-unlink the buffer from match list once it got a 
match, I think
this is the case you want

3. If the buffer is for reply (it's unique as well)
    the MD is constructed with lnet_md_t::threshold = LNET_MD_THRESH_INF,
so it's same as 1), the buffer wouldn't be unlinked unless user call  
LNetMDUnlink
or LNetMEUnlink, so safety of reply buffer can be guaranteed only if user is
sure the buffer is unlinked.

Regards
Liang


Peter Braam wrote:
> No - buffers can and probably should (because, for example, 
> re-delivery may leaver buffer state undefined) be unlinked from the 
> match list before passing the buffer up to any other layer. 
>  Portals/LNET certainly can do this.  
>
> The question is why isn't this done, Eric, Isaac, Andreas?
>
> Peter
>
> On Tue, Dec 15, 2009 at 9:28 AM, Yuriy Umanets 
> <yuriy.umanets at clusterstor.com <mailto:yuriy.umanets@clusterstor.com>> 
> wrote:
>
>
>
>     2009/12/9 Peter Braam <peter.braam@clusterstor.com
>     <mailto:peter.braam@clusterstor.com>>
>
>         Hi, 
>
>     hi Peter,
>      
>
>         I wonder if LNET doesn't have an atomic operation that unlinks
>         the packet from the delivery process upon receiving a packet.
>           Iirc it does.  Why wouldn't one use that?
>
>     That is probably because it still may be in use by upper layers
>     (ptlrpc, etc), i.e. it is up to upper layer to decide should its
>     buffers be still linked for access or not.
>
>     Thanks.
>
>
>         Peter
>
>         _______________________________________________
>         Lustre-devel mailing list
>         Lustre-devel at lists.lustre.org
>         <mailto:Lustre-devel@lists.lustre.org>
>         http://lists.lustre.org/mailman/listinfo/lustre-devel
>
>
>
>
>     -- 
>     umka
>
>
> ------------------------------------------------------------------------
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   

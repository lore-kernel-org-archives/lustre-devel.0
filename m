From: Cory Spitz <spitzcor@cray.com>
Date: Wed, 27 Jun 2018 04:00:28 +0000
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <87d0wd6i4m.fsf@notabene.neil.brown.name>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <alpine.LFD.2.21.1806210239190.3886@casper.infradead.org>
 <DM3PR1101MB1213DDB7FC857EE6B1444153CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <alpine.LFD.2.21.1806210354260.3886@casper.infradead.org>
 <3FD4D051-9C95-449D-8A23-D42B271E55B8@dilger.ca>
 <DM3PR1101MB121322E85FDE1E5310F6F4B7CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <87tvprah32.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806260206360.31196@casper.infradead.org>
 <DM3PR1101MB121358672276198B843DE5A7CB490@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <87d0wd6i4m.fsf@notabene.neil.brown.name>
Message-ID: <913847E3-EB34-4B9D-9314-0BCF59837AFC@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello, Neil.

Cray does indeed have another user of LNet.  While it is now GPL, I can't say if it will ever be in mainline.  However, even without it there is a case for LNet to live on its own as Andreas pointed out recently with http://lists.lustre.org/pipermail/lustre-devel-lustre.org/2018-June/007098.html.

But, if you want to group everything together now, we can hopefully tease it apart again in the future.  If so, I think that it would be misleading to call a module lnet if it contained distributed locking functionality (ldlm).  How about lustre-common, lustre-core, or some such?

Thanks,
-Cory

-- 

?On 6/26/18, 10:09 PM, "lustre-devel on behalf of NeilBrown" <lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:

    On Tue, Jun 26 2018, Patrick Farrell wrote:
    
    > Ah, sorry, lost your mail in the shuffle, Neil.
    >
    > The name, mostly.  ptlrpc is one subdirectory and one subsystem, so I don?t want to use it for a module that explicitly includes all of several.  I?m not sure of a better name immediately - is this module intended to be shared between client and server?
    >
    
    Thanks for clarifying.
    Note that I'm still feeling my way around here so "intended" can at most
    be a soft intention, open to change.  But yes, I expect this module
    would ultimately be shared with the server.
    
    I think things should only be in different modules if it might sometimes
    make sense to use one without the other.
    
    So everything that is always used for a lustre client mount, and is only
    used for a lustre client mount, should be in a module called "lustre".
    And everything always and only used for a lustre server should be in a
    module called (something like) "lustre-server".
    
    It appears to me that ptlrpc, ldlm, and obdclass are always and only
    used together, but can be used for client or server.  So I think they
    should be together in a module.
    I'm tempted to add lnet to that list.  There has been mention that cray
    has some other functionality that uses lnet - if that doesn't use
    ptlrpc, then maybe that is a case for keeping lnet separate.  However I
    would rather see it as a potential case to separate lnet from the others
    at a later date if that functionality from cray ever goes into mainline.
    
    The klnds modules can presumably be used independently(?) so they can
    sensibly remain as separate modules, though I'm beginning to wonder if
    lnet can actually function without socklnd, so I wonder if that should
    be permanently part of the lnet module (with NFS, the xprt_sock code is
    a permanent part of "sunrpc", while the xprt_rdma (aka rpcrdma) code
    can be a separate module).
    
    In the interests of a concrete strawman, what objections would I get if
    I suggested that ptlrpc, ldlm, obdclass, lnet, and socklnd were all included in
    the one module named "lnet" ??
    
    Thanks,
    NeilBrown
    

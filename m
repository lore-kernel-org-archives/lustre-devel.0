From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 21:39:49 +0100 (BST)
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <87o9g4des9.fsf@notabene.neil.brown.name>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <alpine.LFD.2.21.1806210239190.3886@casper.infradead.org>
 <DM3PR1101MB1213DDB7FC857EE6B1444153CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <87o9g4des9.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1806242138170.28698@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> So llite fid fld lmv lov mdc mgc osc and obdclass
> can all be in a "lustre" module.
>
> ldlm and ptlrpc should be in a separate "ptlrpc" module.
> And lnet and the klnds are also separate.
> 
> On the server side we would have
>   lod mdd mdt mgs ofd osp ost
> 
> does that seem approximately right?

The best way to see what modules contain both server and client code is to
search for HAVE_SERVER_SUPPROT in the OpenSFS source tree.

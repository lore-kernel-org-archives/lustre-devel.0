From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 27 Jun 2018 11:01:27 +0000
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
Message-ID: <44633E99-07CB-4C40-967C-0B4FE206F29A@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 27, 2018, at 05:08, NeilBrown <neilb@suse.com> wrote:
> 
> On Tue, Jun 26 2018, Patrick Farrell wrote:
> 
>> Ah, sorry, lost your mail in the shuffle, Neil.
>> 
>> The name, mostly.  ptlrpc is one subdirectory and one subsystem, so I don?t want to use it for a module that explicitly includes all of several.  I?m not sure of a better name immediately - is this module intended to be shared between client and server?
>> 
> 
> Thanks for clarifying.
> Note that I'm still feeling my way around here so "intended" can at most
> be a soft intention, open to change.  But yes, I expect this module
> would ultimately be shared with the server.
> 
> I think things should only be in different modules if it might sometimes
> make sense to use one without the other.
> 
> So everything that is always used for a lustre client mount, and is only
> used for a lustre client mount, should be in a module called "lustre".
> And everything always and only used for a lustre server should be in a
> module called (something like) "lustre-server".
> 
> It appears to me that ptlrpc, ldlm, and obdclass are always and only
> used together, but can be used for client or server.  So I think they
> should be together in a module.
> 
> I'm tempted to add lnet to that list.  There has been mention that Cray
> has some other functionality that uses lnet - if that doesn't use
> ptlrpc, then maybe that is a case for keeping lnet separate.  However I
> would rather see it as a potential case to separate lnet from the others
> at a later date if that functionality from cray ever goes into mainline.
> 
> The klnds modules can presumably be used independently(?) so they can
> sensibly remain as separate modules, though I'm beginning to wonder if
> lnet can actually function without socklnd, so I wonder if that should
> be permanently part of the lnet module (with NFS, the xprt_sock code is
> a permanent part of "sunrpc", while the xprt_rdma (aka rpcrdma) code
> can be a separate module).

Definitely LNet can run without ksocklnd, and it does so on clients that
only have IB connections.  Lots of HPC systems have client nodes that do
not have Ethernet interfaces, since it is a cabling/networking nightmare
to add a few thousand additional Ethernet cables/ports in addition to the
IB cables/ports, and it is always possible to run IPoIB for TCP traffic.

> In the interests of a concrete strawman, what objections would I get if
> I suggested that ptlrpc, ldlm, obdclass, lnet, and socklnd were all included in
> the one module named "lnet" ??

This would break all of the module parameters for ptlrpc.  There are only
a few obdclass module parameters that are rarely used, so I'm less worried
about those ones.

Given that lnet is a separate thing, I'd prefer to keep "ptlrpc" and "lnet"
as separate modules, then "lustre" for the remainder of the client code.

The "ptlrpc" module should also include the "fld", "fid", "quota", "mgc"
modules, since these are shared with the server as well.

Server modules:
[adilger at mookie ~]$ lsmod | grep ^obdclass
obdclass             1731964  83 mdd,lod,mdt,osp,ofd,lfsck,ost,mgs,mgc,osd_ldiskfs,fid,fld,lquota,ptlrpc

Client modules:
[adilger at twoshoes ~]$ lsmod | grep ^obdclass
obdclass             1568040  86 osc,mgc,lustre,lov,mdc,fid,lmv,fld,ptlrpc


James, if we are going to move in the direction of having a separate
"lustre-server" module, it would make sense to land a patch to master
now that adds both a module alias, as well as a filesystem type alias
for lustre-server, so that we can start moving systems over to using
"lustre-server" as the filesystem type in /etc/fstab or HA mounting
scripts, and it will auto-load the module at the same time.  This might
also allow the Lustre mount code to be simplified, since I think it has
some messy code to have the same code, but distinguish between client
and server mounts.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud






-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 235 bytes
Desc: Message signed with OpenPGP
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180627/91d93896/attachment-0001.sig>

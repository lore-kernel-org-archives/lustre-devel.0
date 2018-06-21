From: Patrick Farrell <paf@cray.com>
Date: Thu, 21 Jun 2018 12:28:11 +0000
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <3FD4D051-9C95-449D-8A23-D42B271E55B8@dilger.ca>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <alpine.LFD.2.21.1806210239190.3886@casper.infradead.org>
 <DM3PR1101MB1213DDB7FC857EE6B1444153CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <alpine.LFD.2.21.1806210354260.3886@casper.infradead.org>,
 <3FD4D051-9C95-449D-8A23-D42B271E55B8@dilger.ca>
Message-ID: <DM3PR1101MB121322E85FDE1E5310F6F4B7CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ah, thanks Andreas.  Perhaps not coincidentally, Lustre 2.4 is the first release I worked on.

Neil, I am really unenamored of the idea of the shared ptlrpc ldlm module being named ptlrpc...

Also, Lustre currently has a bunch of module parameters which are used for configuration.  Thoughts on that?


________________________________
From: Andreas Dilger <adilger@dilger.ca>
Sent: Thursday, June 21, 2018 2:22:45 AM
To: James Simmons
Cc: Patrick Farrell; Lustre Development List
Subject: Re: [lustre-devel] [PATCH 00/24] lustre - more cleanups including module reduction.

On Jun 20, 2018, at 8:57 PM, James Simmons <jsimmons@infradead.org> wrote:
>
>>
>> Huh?  Very little of the client is used on the server.  The vast majority of the client is llite, vvp, then lov, osc, and mdc.  These are
>> not used on the servers at all, the modules won't even be loaded.
>>
>>
>> Servers are definitely *not* clients of one another in the sense of "Lustre clients".  They interact with each other, but in a manner very
>> different from client to server.
>>
>> The ldlm and ptlrpc layers are *partly* shared, and of course, the networking from lnet down is.  But that's not "the client".
>>
>> The statement that the server layer is a middle layer on top of the client code doesn't make any sense to me.  It's like this:
>>
>>
>> vfs
>> client code
>> ptlrpc
>> networking
>> ------ PHYSICAL BOUNDARY --------
>> networking
>> ptlrpc
>> server code
>> ldiskfs
>>
>>
>>
>> with LDLM also being explicitly shared, though client & server code is not all shared.  Very little to nothing outside of the networking &
>> ldlm layers is shared.
>
> When I first started this (pre 2.3 days) that is how it was explained to
> me. I just took it at face value but when it comes to the separation as I
> don't have a clue. Patrick since you have a better grasp of the
> architecture can you provide details to Neil. Perhaps to documentation on
> this separation if it exist.

James,
you are (or were) correct, but the code has evolved over the years.  The lov/osc and
modules were formerly used on the MDS in order to connect to the OSS, and lmv/mdc were
used with the old CMD code to connect to other MDS nodes.  However, that ended up with
a lot of code that was in those modules that was only used on the client or server.  In
the CMD code it also meant that a lot of complexity existed with making "fake" RPCs to
other MDS nodes that tried to keep the same RPC opcode but were interpreted differently
at the MDS when they were being sent from another MDS.

In the 2.4 release (which included both DNE and the OSD rewrite for ZFS) the lov/osc
server code was copied/split into lod/osp, and this is used for remote connections to
both the OSSs and other MDS nodes.  The MDS is still a client of the OSS for precreate
and recovery operations (and soon also statfs), but the code is no longer shared with
the regular clients.

Cheers, Andreas





-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180621/79f84741/attachment-0001.html>

From: Doug Oucharek <doucharek@cray.com>
Date: Fri, 6 Jul 2018 00:01:46 +0000
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <alpine.LFD.2.21.1807060043430.12665@casper.infradead.org>
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
 <44633E99-07CB-4C40-967C-0B4FE206F29A@whamcloud.com>
 <DM3PR1101MB12132AC3E33E7D7C8FBE4536CB480@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <87tvpn6592.fsf@notabene.neil.brown.name>
 <DM3PR1101MB12139B5B51BCE76A79DEC383CB4F0@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <D6CA5D91-2344-446F-9621-935A52E47A24@whamcloud.com>
 <alpine.LFD.2.21.1807060043430.12665@casper.infradead.org>
Message-ID: <D654AFAE-B860-4BE8-B988-57C481597AD5@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Unfortunately, NIDs get stored outside of LNet in the Lustre configuration.  That?s why changing the nature of NIDs requires a lot of changes in many places in and out of LNet.  

In my opinion, the best gameplay is to get Lustre to stop even knowing what a NID is.  Have Lustre identify nodes via a name which LNet converts to a NID (sort of like how DNS works).  At that point, LNet can make the NID be anything you want: IPv6, IB address, etc.  This also means you don?t have to run writeconf (or something like that) when the network changes.  Only LNet needs to be updated.

Doug

> On Jul 5, 2018, at 4:47 PM, James Simmons <jsimmons@infradead.org> wrote:
> 
> 
>>> I would say about the acceptor and sock lnd: I believe Lustre assumes some IP transport is available for configuration, but does NOT necessarily use it for primary communication.  Fabrics - Like infiniband or Cray Aries - are more or less always configured to provide IP transport, to enable the panoply of tools and apps that rely on it.  But they perform better if their native protocols are used, which is of course what the other LNDs do.
>> 
>> It is worthwhile to clarify this a bit - LNet uses IP for *addressing* of the nodes at connection time, but I don't think it even uses the TCP interface for any communication itself (though I could be mistaken, as LNet isn't my specialty).  After the initial connection, the only other thing the IP addresses are used for is printing in error messages.
>> 
>> At one time or another we've discussed how we might get rid of the need for IPoIB on client nodes, since some sites don't want any IP connectivity to the client nodes for security and performance reasons.  That said, I don't think we've come up with a good solution yet.  LNet itself allows alternate addressing schemes to be used.  The former qswlnd (for Quadrics Elan networks) just used an integer node number, like 1 at elan for the NID, but I don't think there is any such alternative for IB node addresses except using a MAC hardware address or similar.
> 
> The challenge to moving away from IP address for addressing is the NID 
> address itself. Currently it is 64 bits which is composed for two parts.
> 
> static inline lnet_nid_t LNET_MKNID(__u32 net, __u32 addr)
> {
>        return (((__u64)net) << 32) | addr;
> }
> 
> To use IB harware addressing would require a full 64 bit space so
> lnet_nid_t is to small. This is reason IPv6 is not supported. Ideas
> have floated around on how to get around this but nothing yet.
> It would be a massive API change currently.
> 
>>> Neil Brown <neilb@suse.com> wrote:
>>>> 
>>>> On Wed, Jun 27 2018, Patrick Farrell wrote:
>>>> 
>>>>> Neil,
>>>>> 
>>>>> We do indeed have such functionality (it?s called DVS and it?s
>>>>> basically a high speed file system projection framework, ala NFS but
>>>>> faster), so the ability to build lnet separately is valuable to us.
>>>>> While it is being open sourced under the GPL, I don?t think there?s
>>>>> any intention to try to upstream it.  The current code isn?t even
>>>>> usable off of Cray systems as it depends on info from user space (that
>>>>> is provided, in the end, from Cray proprietary hardware) to keep its
>>>>> connection/routing tables up to date.  That?s supposedly in the
>>>>> pipeline to get fixed, but it?s still pretty far from generally
>>>>> usable.
>>>>> 
>>>>> But we?d still really appreciate it if lnet stayed separate.  Don?t
>>>>> know if that?s enough for you - I know sometimes *small* stuff is done
>>>>> for out of tree users.  Hopefully this meets that standard.
>>>>> 
>>>> 
>>>> Ahh - DVS.  That answers a question I just asked in another email.
>>>> My google-skills don't seem to be up to locating the source code though
>>>> :-(
>>>> 
>>>> While I wouldn't knowingly break an interface used by some out-of-tree
>>>> code without good reason, it is hard to avoid if you don't know what the
>>>> out-of-tree code does.  It can be very tempting to remove something that
>>>> isn't being used, but that can certainly hurt out-of-tree code
>>>> sometimes.
>>>> 
>>>> A particular example I'm exploring at present is the dual data paths in
>>>> LNet.  Or maybe it is dual types of Memory Descriptors.
>>>> There is 'kiov' which uses kernel-virtual addresses and 'iovec' which
>>>> uses page+offset.
>>>> The kiov option isn't used in the client code and it seems likely that
>>>> the server-side code could be converted to use iovec without problems.
>>>> 
>>>> I'd like to remove the kiov as I wouldn't be able to justify its
>>>> existence when submitting the client-only code upstream.  But I don't
>>>> want to remove the option of having an alternate MD type if it really is
>>>> significantly more efficient in some context.
>>>> If I know whether DVS used kiov or iovec - and in what way - that would
>>>> help me to know if I might break something, and to be able to assess the
>>>> cost.
>>>> 
>>>> In my mind, the "standard" that you mention is always about
>>>> practicality.   Code needs to be maintainable - easy to understand and
>>>> hard to break.  If the LNet interface is clean and well documented in
>>>> the kernel, then I don't see why we would not at least attempt to
>>>> preserve it.
>>>> 
>>>> Thanks,
>>>> NeilBrown
>> 
>> Cheers, Andreas
>> ---
>> Andreas Dilger
>> Principal Lustre Architect
>> Whamcloud
>> 
>> 
>> 
>> 
>> 
>> 
>> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

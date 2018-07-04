From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 15:22:29 +1000
Subject: [lustre-devel] [PATCH v3 07/26] staging: lustre: libcfs: NUMA
 support
In-Reply-To: <AT5PR8401MB0900C67FADDF0EF7ED1CDBC4854E0@AT5PR8401MB0900.NAMPRD84.PROD.OUTLOOK.COM>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-8-git-send-email-jsimmons@infradead.org>
 <877emnaed8.fsf@notabene.neil.brown.name>
 <A764DED1-A9A8-4FA5-A0F1-922C3E2D822A@cray.com>
 <87lgb16j8q.fsf@notabene.neil.brown.name>
 <DM3PR1101MB1213FD1001256E565FF011FFCB480@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <8736x77lrk.fsf@notabene.neil.brown.name>
 <9DE389AB-C7E1-4336-B7E8-604581EFD53E@cray.com>
 <CAAqp6i0uwmpdFYUJ7mCBz+MH+gVBa6S=P2t5Yn7wcFOtrTD-Fg@mail.gmail.com>
 <AT5PR8401MB0900C67FADDF0EF7ED1CDBC4854E0@AT5PR8401MB0900.NAMPRD84.PROD.OUTLOOK.COM>
Message-ID: <87va9vziay.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Thanks everyone for your patience in explaining things to me.
I'm beginning to understand what to look for and where to find it.

So the answers to Greg's questions:

  Where are you reading the host memory NUMA information from?

  And why would a filesystem care about this type of thing?  Are you
  going to now mirror what the scheduler does with regards to NUMA
  topology issues?  How are you going to handle things when the topology
  changes?  What systems did you test this on?  What performance
  improvements were seen?  What downsides are there with all of this?


Are:
  - NUMA info comes from ACPI or device-tree just like for every one
      else.  Lustre just uses node_distance().

  - The filesystem cares about this because...  It has service
    thread that does part of the work of some filesystem operations
    (handling replies for example) and these are best handled "near"
    the CPU the initiated the request.  Lustre partitions
    all CPUs into "partitions" (cpt) each with a few cores.
    If the request thread and the reply thread are on different
    CPUs but in the same partition, then we get best throughput
    (is that close?)

  - Not really mirroring the scheduler, maybe mirroring parts of the
    network layer(?)

  - We don't handle topology changes yet except in very minimal ways
    (cpts *can* become empty, and that can cause problems).

  - This has been tested on .... great big things.
  - When multi-rails configurations are used (like ethernet-bonding,
    but for RDMA), we get ??? closer to theoretical bandwidth.
    Without these changes it scales poorly (??)

  - The down-sides primarily are that we don't auto-configure
    perfectly.  This particularly affects hot-plug, but without
    hotplug the grouping of cpus and interfaces are focussed
    on .... avoiding worst case rather than achieving best case.
    

I've made up a lot of stuff there.  I'm happy not to pursue this further
at the moment, but if anyone would like to enhance my understanding by
correcting the worst errors in the above, I wouldn't object :-)

Thanks,
NeilBrown




On Fri, Jun 29 2018, Weber, Olaf (HPC Data Management & Storage) wrote:

> To add to Amir's point,  Lustre's CPTs are a way to partition a machine. The distance mechanism I added is one way to map the ACPI-reported distances on the Lustre CPT mapping. It tends to assume the worst case applies to the wholes. It is there because the rest of the Lustre code (at least in the tree I had to work on) "thinks" in CPTs.
>
> Other CPT-related stuff that came in with the multi-rail code has the same rationale. If I'd been working against the kernel interfaces themselves it would have looked differently, but that was not an option at the time.
>
> We've found it to be useful, so replacing it would be better than just ripping it out.
>
> That's all there is to it.
>
> Olaf
>
> ---
> From: Amir Shehata [mailto:amir.shehata.whamcloud at gmail.com] 
> Sent: Friday, June 29, 2018 19:28
> To: Doug Oucharek <doucharek@cray.com>
> Cc: NeilBrown <neilb@suse.com>; Weber, Olaf (HPC Data Management & Storage) <olaf.weber@hpe.com>; Amir Shehata <amir.shehata@intel.com>; Lustre Development List <lustre-devel@lists.lustre.org>
> Subject: Re: [lustre-devel] [PATCH v3 07/26] staging: lustre: libcfs: NUMA support
>
> Olaf can add more details, but I believe we are using the linux distance infrastructure. Take a look at cfs_cpt_distance_calculate(). What we're doing is extracting the NUMA distances provided in the kernel and building an internal representation of distances between CPU partitions (CPTs) since that's what's used in the code.
>
> On 29 June 2018 at 10:19, Doug Oucharek <doucharek@cray.com> wrote:
> I?ll leave Olaf of HPE answer questions about the distance code.? I was only an inspector as it relates to the Multi-Rail feature in the community tree.? 
>
> Doug
>
>> On Jun 27, 2018, at 6:17 PM, NeilBrown <neilb@suse.com> wrote:
>> 
>> 
>> I went digging and found that Linux already has a well defined concept
>> of distance between NUMA nodes.
>> On x86 (and amd64?), this is loaded from ACPI.? Other platforms can
>> describe it in devicetree.
>> You can view distance information in
>>? /sys/devices/system/node/node*/distance
>> 
>> or using "numactl --hardware".
>> 
>> Why doesn't lustre simple extract and use this information?? Why does
>> lustre need to allow it to be configured?
>> 
>> Thanks,
>> NeilBrown
>> 
>> On Wed, Jun 27 2018, Patrick Farrell wrote:
>> 
>>> Neil,
>>> 
>>> I am not the person at Cray for this, but if SUSE does take an interest in this, Cray would probably be interested in weighing in and contributing info if not actually code.? In fact, other HPC vendors like HPE(by which I mostly mean the old SGI) or IBM might as well.? NUMA optimization is a persistent fascination in our area of the industry...
>>> 
>>> - Patrick
>>> 
>>> ________________________________
>>> From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
>>> Sent: Tuesday, June 26, 2018 9:44:37 PM
>>> To: Doug Oucharek
>>> Cc: Amir Shehata; Lustre Development List
>>> Subject: Re: [lustre-devel] [PATCH v3 07/26] staging: lustre: libcfs: NUMA support
>>> 
>>> On Mon, Jun 25 2018, Doug Oucharek wrote:
>>> 
>>>> Some background on this NUMA change:
>>>> 
>>>> First off, this is just a first step to a bigger set of changes which include changes to the Lustre utilities.? This was done as part of the Multi-Rail feature.? One of the systems that feature is meant to support is the SGI UV system (now HPE) which has a massive number of NUMA nodes connected by a NUMA Link.? There are multiple fabric cards spread throughout the system and Multi-Rail needs to know which fabric cards are nearest to the NUMA node we are running on.? To do that, the ?distance? between NUMA nodes needs to be configured.
>>>> 
>>>> This patch is preparing the infrastructure for the Multi-Rail feature to support configuring NUMA node distances.? Technically, this patch should be landing with the Multi-Rail feature (still to be pushed) for it to make proper sense.
>>>> 
>>> 
>>> Thanks a lot for the background.
>>> 
>>> If these NUMA nodes have a 'distance' between them, and if lustre can
>>> benefit from knowing the distance, then is seems likely that other code
>>> might also benefit.? In that case it would be best if the distance were
>>> encoded in some global state information so that lustre and any other
>>> subsystem can extract it.
>>> 
>>> Do you know if there is any work underway by anyone to make this
>>> information generally available?? If there is, we should make sure that
>>> lustre works in a compatible way so that once that work lands, lustre
>>> can use it directly and not need extra configuration.
>>> If no such work is underway, then it would be really good if something
>>> were done in that direction.? If no-one here is able to work on this, I
>>> can ask around in SUSE and see if anyone here knows anything relevant.
>>> 
>>> Thanks,
>>> NeilBrown
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180704/c2020123/attachment.sig>

From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 01 Jul 2008 08:56:28 -0600
Subject: [Lustre-devel] Wide area use of Lustre and client caches
In-Reply-To: <2027440260.979211214910221062.JavaMail.root@dahlback.prod.local>
Message-ID: <C48FA1BC.46DB%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yes, it should help a lot - and it should apply in the same way.  The open
cache is automatically used by the NFS server (which runs in kernel space).

Any volunteers to write the cachefs interfaces for us?

Peter


On 7/1/08 5:03 AM, "Daire Byrne" <Daire.Byrne@framestore.com> wrote:

> Peter,
> 
> I assume the same rational holds for NFS exporting too? I'm toying with the
> idea of putting lots of RAM in a server and exporting our LustreFS over NFS.
> We have some workloads which do a lot of seeking through a reasonably small
> set (~32Gigs worth) of files which may perform better if an NFS server caches
> the dataset and consequently doesn't have to do any disk seeks. Obviously this
> is not particularly scalable (cheaply) but in small scale tests it seems to
> perform better than seeking directly from Lustre.
> 
> The "open lock" stuff you mention is the work going on in #14975 right? Using
> Lustre 1.6.5 server/client it seems like I can already get line speed (GigE)
> reads over NFS for a single file once the Lustre client on the NFS server has
> cached it. But I have not tested this at scale with many clients and files
> simultaneously.
> 
> While we wait for Lustre caching (I assume the work done in #12182 is dead in
> the water?) this may be the best way for us to deal with heavy seek+read
> workloads. Our use of SATA based hardware RAID arrays doesn't help our seek
> performance either.
> 
> Daire
> 
> 
> ----- "Peter Braam" <Peter.Braam@Sun.COM> wrote:
> 
>> Wide area use of Lustre and client caches During the LUG I was
>> approached by a customer who wants to use a Lustre file system at the
>> far end of a WAN link. Since the situation may be of general interest,
>> I thought I would post a short report of the discussion here.
>> 
>> His use pattern was interesting ? a number of Windows clients must be
>> browsing files stored in Lustre in this remote location. It was
>> expected that the files would be fairly large, would be viewed by
>> multiple clients, and that few or no modifications would be made.
>> 
>> After some discussion we proposed a solution that involved a
>> deployment as follows:
>> 
>> 
>> 
>>     1. A single Lustre client with lots of RAM. The settings on the
>> client would be (1) that the memory available for caching by lustre is
>> large (2) that the number of locks that can be held by this client is
>> fairly large (3) that this client uses the ?open cache?.
>>     2. A samba server on this Lustre client.
>> 
>> With the settings above, we can expect that many of the files can be
>> cached in the Lustre client, hence after the initial read, I/O would
>> be local in the remote site. With the open file cache enabled, even
>> the open and close traffic will not go to the servers, but can be
>> handled by the client. We think that this will lead to a very good
>> solution, that can work today.
>> 
>> A refinement is possible, that requires some development. There is a
>> feature in the Linux kernel to use a disk partition as a cache for a
>> file system ? it is called cachefs. This requires a few hooks in
>> Lustre to store chunks of files that are transferred to the client
>> into this cache, and cache invalidation calls to remove them. It
>> allows us to achieve the same performance as with the solution above,
>> except that the disk will be a bit slower than memory, but it can also
>> be much larger.
>> 
>> We are eagerly awaiting the results of testing this configuration!
>> 
>> - peter - 
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel

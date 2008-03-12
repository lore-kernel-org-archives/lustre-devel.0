From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 12 Mar 2008 13:56:08 -0600
Subject: [Lustre-devel] Feature request: expand SNMP scope
In-Reply-To: <200803121251.02482.kilian@stanford.edu>
Message-ID: <C3FD9178.2C56%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 3/12/08 1:51 PM, "Kilian CAVALOTTI" <kilian@stanford.edu> wrote:

> Bonjour Patrice,
> 
> On Wednesday 12 March 2008 07:00:05 am patrice.lucas at cea.fr wrote:
>> This method is not
>> integrated to the inner Lustre code. If people change /proc entries,
>> the snmp agent code must clearly be rewrite. I agree with you when
>> you emphasize the need to link the snmp code to the rest of the
>> Lustre development.
> 
> Yes, that's what Brian first pointed out, and I think that's really the
> cornerstone here. Manually editing the SNMP code and the corresponding
> MIB files each time a new metric is added, removed or renamed, will
> rapidly get to be a nightmare.
> 
>>  From a more integrated point of view, do you think it could be a
>> good idea to benefit from Lustre itself to deliver monitoring data ?
>> Lustre is a parallel filesystem. Data delivered by Lustre can be
>> accessed by remote client. Instead of using "/proc", can Lustre
>> benefits from its capability of distributed filesystem to deliver
>> monitoring data ? By doing that, we could lose the advantage of snmp
>> to interface with many available common snmp network monitoring
>> tools.

There are already some /proc files for Lustre that actually make an RPC when
read.  We have talked often about greatly enlarging this and in addition
letting servers also report on the client state.

So a monitoring node would poll servers and servers would export their own
data including data for each client that is connected to the server.

Generating SNMP info from this is then easy, and it would hook very nicely
into the various management tools too, and work on non-IP networked
computers (if there are any left).

- Peter -


> 
> Well, yes, actually, that sounds like a very reasonnable approach too.
> The main advantages for SNMP, from my standpoint are the following:
> 
> 1. It's a network protocol, so the monitored system doesn't have to be
>    the same as the monitoring one. This allows remote collection of
>    metrics, aggregation, and central administration.
> 
> 2. It's an industry standard (even if vendors sometimes tend to have a
>    proprietary interpretation of what is a 'standard'), so it can be
>    used across a large variety of monitoring systems. Interoperability
>    is always a good thing
> 
> But only point 1. is really required to allow easier Lustre monitoring.
> If all the lnet/client/oss/mds data could be accessed from clients,
> that would be enough. One specific client (potentially patchless) could
> be dedicated for monitoring with almost the same advantage as a SNMP
> host.
> 
> That looks like the OFED approach: SNMP is not a priority for
> OpenFabrics, since the IB counters from all over the fabric can be
> gathered with a single perfquery, from a simple IB node.
> 
> And this may also be easier to implement than mapping SNMP exports to
> the Lustre stats files.
> 
> Cheers,

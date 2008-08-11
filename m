From: Vitaly Fertman <vitaly@sun.com>
Date: Mon, 11 Aug 2008 16:56:14 +0400
Subject: [Lustre-devel] Security issues
In-Reply-To: <C4C1DAA6.5570%peter.braam@sun.com>
References: <C4C1DAA6.5570%peter.braam@sun.com>
Message-ID: <6EA5F184-C02A-4BFC-8C65-DF4027083513@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Aug 8, 2008, at 9:12 PM, Peter Braam wrote:
>> 2. Securing Capabilities.
>>
>> If we want to be sure that a Capability given to client A cannot be
>> snooped and used by client B we either (a) have to make the  
>> Capability
>> secret (i.e. never passed in cleartext) or (b) have to make the  
>> Capability
>> identify which client it is valid for.
>>
>> It seems to me that (b) is preferrable since it ensures that a  
>> malicious
>> client cannot leak Capabilities to a 3rd party.  The downside is  
>> that this
>> multiplies the number of unique Capabilities by the number of  
>> clients,
>> potentially increasing CPU load when 1000s of clients all open the  
>> same
>> shared file and each require unique Capabilities to access the  
>> stripe objects.
>> Do we have a feel for how bad this could be?
>>
> Yes, very bad, and it is absolutely necessary to have an option that  
> avoids this (also 1000s is out of date ? it could be 100x worse).   
> That option could be to simply not have security on the compute  
> cluster if customers agree with this.


this kind of problem also exists for OST capabilities even without  
making
them unique per client.

As objects do not know the mds fid initially, we can check the  
operation is
intended for this particular object by objid/gr only. The proposed  
solution was
to generate on mds an objid-based capa for each object instead of 1  
common
fid-based capa (i.e. a pair objid/group is signed instead of mds fid),  
and
therefore we give out default-stripe-count OST capas instead of 1  
every time.

it could be optimized later, by switching to fid-based capas with time  
when
mds gets known all the objects know the mds fid. however, the mechanism
is not clear yet.

--
Vitaly

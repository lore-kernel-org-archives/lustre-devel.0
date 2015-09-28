From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Mon, 28 Sep 2015 01:02:07 +0000
Subject: [lustre-devel] [PATCH 04/73] staging/lustre: tracefile:
 document seconds overflow
In-Reply-To: <D22E51DB.10D6D3%andreas.dilger@intel.com>
References: <1443386773-305443-1-git-send-email-green@linuxhacker.ru>
	<1443386773-305443-5-git-send-email-green@linuxhacker.ru>
	<D22E51DB.10D6D3%andreas.dilger@intel.com>
Message-ID: <76975028-45A4-4527-B214-33D2389E034F@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Sep 27, 2015, at 8:38 PM, Dilger, Andreas wrote:

> On 2015/09/27, 10:45 PM, "green at linuxhacker.ru" <green@linuxhacker.ru>
> wrote:
> 
>> From: Arnd Bergmann <arnd@arndb.de>
>> 
>> The lustre tracefile has a timestamp defined as
>> 
>>      __u32 ph_sec;
>>      __u64 ph_usec;
>> 
>> which seems completely backwards, as the microsecond portion of
>> a time stamp will always fit into a __u32 value, while the second
>> portion will overflow in 2038 or 2106 (in case of unsigned seconds).
> 
> This is indeed confusing, but the original reason for such a thing is
> lost in the mists of antiquity.
> 
>> Changing this would unfortunately change the format in an incompatible
>> way, breaking all existing user space tools that access the data.
> 
> It seems that it would be possible to fix this declaration to be
> compatible with current usage, since these fields are always written
> in host-endian order:
> 
> 
> #ifdef(__LITTLE_ENDIAN)
> 	__u32 ph_sec;
> 	__u32 ph_usec;
>        __u32 ph_sec_hi;
> #else
> 	__u32 ph_sec;
>        __u32 ph_sec_hi;
>        __u32 ph_usec;
> #endif
> 
> ph_sec_hi will always be zero today because microseconds don't grow
> so large, and we have 22 years to ensure existing user tools are
> updated to handle this in a similar manner.
> 
> Another option would be to mark in ph_flags whether the ph_sec field
> is a __u32 or __u64 and that would allow us to migrate over to a
> "normal" field ordering gradually (these debug logs are only useful
> for a short time anyway).
> 
> It would probably also make sense to change to use ph_nsec at this point
> as well, since that avoids the division (which might be noticeable in
> itself) and gives us better time resolution.

I suggest we start with tools first.
Once we do have the tools that understand this greatly deployed, then we
can change the kernel code, as otherwise it's going to be quite a mess.
And we still do have quite a bit of time until year 2104, so I don't feel
there's a big rush here.

Bye,
    Oleg

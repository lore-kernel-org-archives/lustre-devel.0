From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 28 Sep 2015 10:02:52 +0200
Subject: [lustre-devel] [PATCH 04/73] staging/lustre: tracefile:
	document seconds overflow
In-Reply-To: <D22E51DB.10D6D3%andreas.dilger@intel.com>
References: <1443386773-305443-1-git-send-email-green@linuxhacker.ru>
	<1443386773-305443-5-git-send-email-green@linuxhacker.ru>
	<D22E51DB.10D6D3%andreas.dilger@intel.com>
Message-ID: <10314017.Ku9U9j04Cs@wuerfel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Monday 28 September 2015 00:38:37 Dilger, Andreas wrote:
> >Changing this would unfortunately change the format in an incompatible
> >way, breaking all existing user space tools that access the data.
> 
> It seems that it would be possible to fix this declaration to be
> compatible with current usage, since these fields are always written
> in host-endian order:
> 
> 
> #ifdef(__LITTLE_ENDIAN)
> 	__u32 ph_sec;
> 	__u32 ph_usec;
>         __u32 ph_sec_hi;
> #else
> 	__u32 ph_sec;
>         __u32 ph_sec_hi;
>         __u32 ph_usec;
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

See the discussion for the previous version I sent. Unfortunately, there
is no generic __LITTLE_ENDIAN macro that we can use in both kernel
and user space, so we'd either have to introduce that for all architectures
first, or use the approach I described earlier:

	ph_usec = (now.tv_nsec / NSEC_PER_SEC) | (now.tv_sec & 0xffffffff00000000ull);

which Oleg said was a bit too ugly.

	Arnd

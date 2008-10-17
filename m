From: Eric Barton <eeb@sun.com>
Date: Fri, 17 Oct 2008 11:10:07 +0100
Subject: [Lustre-devel] "Simple" HSM straw man
In-Reply-To: <48F85F43.2050007@cea.fr>
References: <48EE87A1.7000003@sun.com> <48F379B4.6040209@cea.fr>
	<48F4F5DA.7090000@sun.com> <CE2BF0610E4C4692A3DDDD842249AAE2@ebpc>
	<48F85F43.2050007@cea.fr>
Message-ID: <FE8C312998514690AA1ED80B9125D11E@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Aurelien,

>  >> I don't think we want to block the write just because the HSM
>  >> copy isn't done yet.  If the data is changing, then the policy
>  >> engine shouldn't have started a copyout process in the first
>  >> place.
>  >
>  > Indeed.
> 
> You were speaking of a FS with only one big file and so we need to
> have a way to be sure it will be copied at least once, even if
> people are writting on it.  In this case, with a classical policy
> engine, this file will never be copied out because data is
> constantly changing.

I'm not so sure that's a realistic case.  If this file is so active
that it's impossible to take a consistent copy of it without some
sort of a snapshot facility, does that really mean it's a candidate
for archiving?

    Cheers,
              Eric

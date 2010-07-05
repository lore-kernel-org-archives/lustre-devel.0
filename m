From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Mon, 5 Jul 2010 12:58:30 -0500
Subject: [Lustre-devel] Integrity and corruption - can file systems be
 scalable?
In-Reply-To: <4C315739.6040304@oracle.com>
References: <AANLkTilbGHD1tSW3vHcRmKGbvfeP6_M3cLspoCgEwBww@mail.gmail.com>
	<4C2E518D.30802@oracle.com>
	<AANLkTim773u3UsE0zo0T-a6nzTkqKiv0qxByxx918vgY@mail.gmail.com>
	<4C2E57B0.6010408@oracle.com>
	<AANLkTin1hOwVV2EzBvnPSGoHQr7kPYo_ulncZP77KL5H@mail.gmail.com>
	<20100702222151.GG15407@oracle.com> <4C2EB090.5030003@oracle.com>
	<20100704235600.GI15407@oracle.com> <4C315739.6040304@oracle.com>
Message-ID: <20100705175829.GK15407@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 04, 2010 at 11:53:29PM -0400, Dmitry Zogin wrote:
> What I really mean is the defragmentation issue and not the
> fragmentation itself. All file systems becomes fragmented, as it is
> unavoidable. But the defragmentation of the file system using hash
> trees really becomes a problem.

That is emphatically not true.

To defragment a ZFS-like filesystem all you need to do is traverse the
metadata looking for live blocks from old transaction groups, then
relocate those by writing them out again almost as if an application had
written to them (except with no mtime updates).

In ZFS we call this block pointer rewrite, or bp rewrite.

> >Everything we do involves trade-offs.
> >
> Yes, but if the performance drop becomes unacceptable, any gain in
> the integrity is miserable.

I believe ZFS has shown that unacceptable performance losses are not
required in order to get the additional integrity protection.

Nico
-- 

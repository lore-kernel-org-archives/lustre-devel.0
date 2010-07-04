From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Sun, 4 Jul 2010 18:56:01 -0500
Subject: [Lustre-devel] Integrity and corruption - can file systems be
 scalable?
In-Reply-To: <4C2EB090.5030003@oracle.com>
References: <AANLkTilbGHD1tSW3vHcRmKGbvfeP6_M3cLspoCgEwBww@mail.gmail.com>
	<4C2E518D.30802@oracle.com>
	<AANLkTim773u3UsE0zo0T-a6nzTkqKiv0qxByxx918vgY@mail.gmail.com>
	<4C2E57B0.6010408@oracle.com>
	<AANLkTin1hOwVV2EzBvnPSGoHQr7kPYo_ulncZP77KL5H@mail.gmail.com>
	<20100702222151.GG15407@oracle.com> <4C2EB090.5030003@oracle.com>
Message-ID: <20100704235600.GI15407@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Jul 02, 2010 at 11:37:52PM -0400, Dmitry Zogin wrote:
> Well, the hash trees certainly help to achieve data integrity, but
> at the performance cost.

Merkle hash trees cost more CPU cycles, not more I/O.  Indeed, they
result in _less_ I/O in the case of RAID-Zn because there's no need to
read the parity unless the checksum doesn't match.  Also, how much CPU
depends on the hash function.  And HW could help if this became enough
of a problem for us.

> Eventually, the file system becomes fragmented, and moving the data
> around implies more random seeks with Merkle hash trees.

Yes, fragmentation is a problem for COW, but that has nothing to do with
Merkle trees.  But practically every modern filesystem coalesces writes
into contiguous writes on disk to reach streaming write perfmormance,
and that, like COW, results in filesystem fragmentation.

(Of course, you needn't get fragmentation if you never delete or over
write files.  You'll get some fragmentation of meta-data, but that's
much easier to garbage collect since meta-data will amount to much less
on disk than data.)

Everything we do involves trade-offs.

Nico
-- 

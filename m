From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Fri, 2 Jul 2010 17:35:08 -0500
Subject: [Lustre-devel] Integrity and corruption - can file systems be
 scalable?
In-Reply-To: <20100702222151.GG15407@oracle.com>
References: <AANLkTilbGHD1tSW3vHcRmKGbvfeP6_M3cLspoCgEwBww@mail.gmail.com>
	<4C2E518D.30802@oracle.com>
	<AANLkTim773u3UsE0zo0T-a6nzTkqKiv0qxByxx918vgY@mail.gmail.com>
	<4C2E57B0.6010408@oracle.com>
	<AANLkTin1hOwVV2EzBvnPSGoHQr7kPYo_ulncZP77KL5H@mail.gmail.com>
	<20100702222151.GG15407@oracle.com>
Message-ID: <20100702223508.GH15407@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I explained why well-delineated transactions help, but didn't really
explain why COW and Merkle hash trees help.  COW helps ensure that
correct transactions cannot result in incorrect filesystems -- fsck need
only ensure that a transaction hasn't overwritten live blocks to
guarantee that one can at least rollback to that transaction.  Merkle
hash trees help detect (and recover from) bit rot and hardware errors,
which in turn helps ensure that those incremental fscks are dealing with
correct meta-data (correct fsck code + bad meta-data == bad fsck).

It's much harder to ensure that there are no errors in parts of the
system that are exposed due to lack of special protection features (such
as ECC memory), in system buses and CPUs, that might be difficult or
impossible to protect against in software.  One option is to run the
fscks on different hosts than the ones doing the writing (this means
multi-pathing though, which complicates the overall system, but at least
we currently depend on multipathing anyways).  But even that won't
protect against such unprotectable errors in _data_ (originating in
faraway clients, say).

Nico
-- 

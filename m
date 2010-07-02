From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Fri, 2 Jul 2010 16:09:47 -0500
Subject: [Lustre-devel] Integrity and corruption - can file systems be
 scalable?
In-Reply-To: <AANLkTim773u3UsE0zo0T-a6nzTkqKiv0qxByxx918vgY@mail.gmail.com>
References: <AANLkTilbGHD1tSW3vHcRmKGbvfeP6_M3cLspoCgEwBww@mail.gmail.com>
	<4C2E518D.30802@oracle.com>
	<AANLkTim773u3UsE0zo0T-a6nzTkqKiv0qxByxx918vgY@mail.gmail.com>
Message-ID: <20100702210947.GF15407@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Jul 02, 2010 at 02:59:00PM -0600, Peter Braam wrote:
> The point of the note is the opposite of what you write, namely that backend
> systems in fact do not solve this, unless they are guaranteed to be bug
> free.

Fsck tools can also be buggy.  Consider them redundant code run
asynchronously.  Is it possible to fsck petabytes in reasonable time?
Not if storage capacity grows faster than storage bandwidth.

The obvious alternatives are: test, test, test, and/or run redundant
fsck-like code synchronously.  The latter could be done by reading
just-written transactions to check that the filesystem is consistent.

Nico
-- 

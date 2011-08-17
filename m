From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Tue, 16 Aug 2011 22:01:19 -0400
Subject: [Lustre-devel] client i/o and PG_writeback
In-Reply-To: <20110810142341.GA15190@granier.hd.free.fr>
Message-ID: <201108170201.p7H21JXn003518@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>For historical reasons (lustre was initially developed for 2.4
>kernels), the 1.8 client holds the page lock over bulk write RPCs.
>Some basic support for PG_writeback was added back in 2007 (see
>bugzilla ticket 11710), but the page lock is still held until
>RPC completion.

Alright, let me ask some potentially dumb questions, no doubt due to my
lack of understanding of the Linux VM system:

- I'm missing the connection between using PG_writeback and selecting pages
  to minimize RPC fragmentation (I mean, I understand why you want to
  minimize RPC fragmentation, I just don't quite understand how PG_writeback
  helps that).  I looked at bugzilla ticket 11710, but that seems to be
  about how using PG_writeback is important for fsync() support.

- As I understand it, you drop PG_locked and set PG_writeback during the
  actual write operation.  Correct?

- How are you planning on implementing this?  Via a new state in the
  cl_page state machine, and setting PG_writeback in the new state?
  A new page lock at the cl_page level?

As far as technical concerns ... as long as code that directly uses
PG_writeback and/or PageWriteback() stays in the llite directory,
then I don't _think_ it will affect portability that much.  I believe
I can simply fake it under MacOS X.

--Ken

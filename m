From: Mark Hills <Mark.Hills@framestore.com>
Date: Wed, 27 Jul 2011 18:33:10 +0100 (BST)
Subject: [Lustre-devel] Hangs with cgroup memory controller
In-Reply-To: <BE324D9D-3D7B-4D9E-8F3D-316F259871FC@whamcloud.com>
References: <alpine.LFD.2.01.1107271556070.7176@sys880.ldn.framestore.com>
	<BE324D9D-3D7B-4D9E-8F3D-316F259871FC@whamcloud.com>
Message-ID: <alpine.LFD.2.01.1107271820040.6411@sys880.ldn.framestore.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 27 Jul 2011, Andreas Dilger wrote:

> Two ideas come to mind. On is that the reason you are having difficulty 
> to reproduce the problem is that it only happens after some fault 
> condition. Possibly you need the client to do recovery to an OST and 
> resend a bulk RPC, or resend due to a checksum error?

Is there an easy way to trigger some error cases like this?

> It might also be due to application IO types (e.g. mmap, direct IO, 
> pwrite, splice, etc).

Yes, of course. Although I didn't gather any statistics, there wasn't a 
clear standout application which was more affected than others.

> Possibly you can correlate reproducer cases with Lustre errors on the 
> console?

Back when I tried this last year on the production system, I wasn't able 
to see corresponding errors. But I don't have any of this data around any 
more.

I'd need to do some tests on the production system to capture one case.

> Lustre also has memory debugging that can be enabled, but without a 
> reasonably concise reproducer it would be difficult to log/analyze so 
> much data for hours of runtime.

If I am able to capture a case, is there a way to, for example, dump a 
list of Lustre pages still held by the client? And correlate these with 
the files in question?

What I am thinking is that I could stop the running processes and attempt 
to drain all the pages, and this could hopefully leave a small number of 
'bad' ones -- with the files in question I could at least help to identify 
the I/O type.

Thanks for your reply

-- 
Mark

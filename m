From: Johann Lombardi <johann@whamcloud.com>
Date: Thu, 10 Mar 2011 18:13:24 +0100
Subject: [Lustre-devel] Bug?
In-Reply-To: <AANLkTimAPHef88==0MTGAoz5m_MkKmtuwfL2mydcjGBf@mail.gmail.com>
References: <AANLkTimAPHef88==0MTGAoz5m_MkKmtuwfL2mydcjGBf@mail.gmail.com>
Message-ID: <20110310171323.GA2368@granier.hd.free.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Mar 10, 2011 at 10:02:03AM -0600, Daniel Mayfield wrote:
> Pid: 12935, comm: ptlrpcd-brw Not tainted 2.6.32.28-2.rgm #1 PowerEdge R610
                    ^^^^^^^^^^^             ^^^^^^^^^^^^^^^
Please note that 2.0 does not support 2.6.32 kernels. 2.1 will.

> RIP: 0010:[<ffffffff811ebf93>]  [<ffffffff811ebf93>] sg_next+0x3/0x30
> Call Trace:
>  [<ffffffffa094dc3e>] ? kiblnd_map_tx+0x1be/0x430 [ko2iblnd]
>  [<ffffffffa094e8a1>] ? kiblnd_queue_tx_locked+0x91/0x2b0 [ko2iblnd]

This is a bug introduced by one of the patch from bug 21951 (attachment 29114). This patch was then reverted from both b1_8 (see 23123) and master (see 23332), but it is unfortunately included in 2.0.0.

Cheers,
Johann

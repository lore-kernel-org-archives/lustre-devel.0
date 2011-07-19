From: Richard Henwood <rhenwood@whamcloud.com>
Date: Tue, 19 Jul 2011 12:03:28 -0500
Subject: [Lustre-devel] [PATCH] Fix task IO accounting on reads
In-Reply-To: <alpine.LFD.2.01.1107191701270.9249@sys880.ldn.framestore.com>
References: <alpine.LFD.2.01.1104261356450.21670@sys880.ldn.framestore.com>
	<CAA6TbrM8LSL41forun6bFgaV5gvRju0rJaJJd3piFPQTwTkSJA@mail.gmail.com>
	<alpine.LFD.2.01.1107191701270.9249@sys880.ldn.framestore.com>
Message-ID: <CAA6TbrMDSSKE1MwyjBhjP1Tfm2j=ZEhriestOFKM=kr0NQUBmw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jul 19, 2011 at 11:08 AM, Mark Hills <Mark.Hills@framestore.com> wrote:
<snip>
>
> I was aware of these stats (and this patch), but I concluded that they did
> not track memory mapped access.
>
> So I think our patches address two separate parts of the process. But I'm
> happy to be corrected -- it was some time ago that I did this.
>

It was indeed a while ago, and I'm sorry I missed this conversation
when it was current!

It seems that both patches have the same motivation for reliable read
stats, but the patches are different with complementary approaches.

richard,
-- 
Richard.Henwood at whamcloud.com
Whamcloud Inc.
tel: +1 512 410 9612

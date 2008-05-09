From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Fri, 09 May 2008 13:08:22 -0400
Subject: [Lustre-devel] Wide area use of Lustre and client caches
In-Reply-To: <C449C4F5.418F%peter.braam@sun.com>
References: <C449C4F5.418F%peter.braam@sun.com>
Message-ID: <1210352902.23307.242.camel@pc.ilinx>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, 2008-05-09 at 09:08 -0600, Peter Braam wrote:
> Nono - striping should only be used to get more bandwidth from servers.  The
> correct solution to the problem you point out is a lock conversion,

Indeed, I have heard that term being used and figured that that is what
it was all about, however...

> planned
> long ago, still far away maybe (Nikita?).

Given that it's not yet available and won't be for some time, isn't
breaking a file up into many objects via striping a sufficient
alternative to the problem?

Are there other problems caused by striping a file (that technically
doesn't need more bandwidth) that outweigh the benefits of not having to
toss so much cache away when a file is written to (i.e. assuming the
cost of reading the file is high such as it would be on a WAN link)?

b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 189 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080509/2051fccf/attachment.pgp>

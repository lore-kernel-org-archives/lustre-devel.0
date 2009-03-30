From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Mon, 30 Mar 2009 10:42:21 -0400
Subject: [Lustre-devel] Async close RPC
In-Reply-To: <29A3C6ED-8132-4896-92CB-3518036D84BB@Sun.COM>
References: <29A3C6ED-8132-4896-92CB-3518036D84BB@Sun.COM>
Message-ID: <1238424141.24213.195.camel@pc.interlinx.bc.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, 2009-03-28 at 15:08 -0400, Oleg Drokin wrote:
> Hello!
> 
>     It recently struck me as how unfair many file creation tests are  
> to Lustre. The problem is only with tests because they portray Lustre
>     creation rates lower than actual speed to be seen by application.  
> (same goes for opens, btw).

The only thing I would add/say Oleg, is have you looked at the Hendrix
CMD specific metadata tests?  I only mention this because from what I
recall, we took advantage of every opportunity we could (within the
requirements of the project) to show performance in the best light we
could.  I'd imagine that those tests (and the corresponding Lustre code_
would have considered some of the same things you are considering.

It may be however that some of the solutions were CMD specific and not
really applicable to you, but perhaps in the least, looking at some of
those tests (i.e. mdsrate was one key test) might prevent you from
re-inventing tests.

Cheers,
b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 197 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090330/3045bfe1/attachment.pgp>

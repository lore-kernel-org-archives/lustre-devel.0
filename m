From: Eric Barton <eeb@sun.com>
Date: Fri, 04 Dec 2009 11:07:42 +0000
Subject: [Lustre-devel] client-side reply handling
In-Reply-To: <5B2F74A3-0AA9-488B-BE30-312C68B70E60@sun.com>
References: <027901ca7429$60703d10$2150b730$@com>
	<5B2F74A3-0AA9-488B-BE30-312C68B70E60@sun.com>
Message-ID: <038601ca74d2$006e1910$014a4b30$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> On 2009-12-03, at 08:00, Eric Barton wrote:
> > Edited from IRC...
> >>
> >> <Liang> eeb_: do you mean, we can be 100% sure it's safe to unpack
> >>        in-place only when the buffer is unlinked? so it is better
> >>        to unregister reply buffer before calling into
> >>        after_reply()->unpack_reply()?
> >
> > Yes, I think so.  While the reply buffer remains attached, it's
> > possible to overwrite it at any time.  This could happen if...
> >
> > a) The server is buggy or malign
> 
> Let's hope we never have to worry about malicious server nodes...

We do.

> > b) The request is re-sent and the same reply matchbits are used,
> >   which is what I think happens currently for non-bulk reqs.
> 
> In theory, the reply to the re-sent request should be identical due
> to reply reconstruction, so it shouldn't matter if it happens to
> overwrite the same buffer.

We're at the mercy of the sender here.  The only robust option is never
to interpret volatile buffers.

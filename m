From: Eric Barton <eeb@sun.com>
Date: Thu, 03 Dec 2009 15:00:39 +0000
Subject: [Lustre-devel] client-side reply handling
Message-ID: <027901ca7429$60703d10$2150b730$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Edited from IRC...

> <maxim> eeb_: Liang: btw, shadow complained recently that it's not
>       great that both 'real' and early replies are being stored in
>       the same place. having in mind possible reordering of packets
>       -just a side note - not sure if it's applicable to your
>       discussion
> 
> <eeb_> the idea was to minimize the # of attach operations since
>        that was considered expensive
> 
> <eeb_> also, we'd need another portal or additional matchbits for
>        early replies if we register them separately
> 
> <eeb_> also, the current way of doing it allows the server to send
>        multiple early replies if it wants to
> 
> <eeb_> I'm not so worried about early replies sharing the same ME/MD
>        with the real reply provided....
> 
> <eeb_> 1. The client detects a protocol error if the "early" reply
>           overlaps the "real" reply part of the reply buffer or if
>           the "real" reply overlaps the "early" part of the reply
>           buffer
> 
> <eeb_> 2. Interpretation of replies (both early and real) is safe
>           against the network overwriting them - e.g. early replies
>           are copied out of the buffer before being interpreted and
>           the whole reply buffer is unlinked before the real reply
>           is interpreted in-place
> 
> <Liang> eeb_: do you mean, we can be 100% sure it's safe to unpack
>         in-place only when the buffer is unlinked? so it is better
>         to unregister reply buffer before calling into
>         after_reply()->unpack_reply()?

Yes, I think so.  While the reply buffer remains attached, it's
possible to overwrite it at any time.  This could happen if...

a) The server is buggy or malign

b) The request is re-sent and the same reply matchbits are used,
   which is what I think happens currently for non-bulk reqs.

...so unlikely, but possible.

    Cheers,
              Eric

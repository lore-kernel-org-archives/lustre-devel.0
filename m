From: Peter Braam <Peter.Braam@Sun.COM>
Date: Fri, 08 Aug 2008 11:12:38 -0600
Subject: [Lustre-devel] Security issues
In-Reply-To: <E9CB31E9D0194A4C88BEA32B04BC2996@ebpc>
Message-ID: <C4C1DAA6.5570%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 8/8/08 11:03 AM, "Eric Barton" <eeb@sun.com> wrote:

> 1. Securing bulk data.
>  
> It seems to me that it is appropriate to use the GSSAPI to secure the
> transfer of bulk data between client and server since it's effectively just
> another message.  I can see (at least naively) that it would be good to
> avoid double encryption in the case where file contents are actually stored
> encrypted on disk.

You are not telling me that we are going through a lot of re-design, that we
are encrypting data and that then we are not storing it encrypted on disk?
Come on, adding an EA with a key to decrypt is not so hard and one gets lots
of value from it.
> 
> But even in this case, don't we still have to sign the
> (encrypted) bulk so that the receiver can be sure it arrived intact?
> 
Well, yes, but as I indicated you can sign the hash that is stored on (ZFS)
disk for this.  That avoids generating the hash twice.  So I am really not
convinced yet.
> 
The issue is not the message mechanism, but is what identity to use for GSS
to authenticate and how to manage and revoke that etc.
>  
> 2. Securing Capabilities.
>  
> If we want to be sure that a Capability given to client A cannot be
> snooped and used by client B we either (a) have to make the Capability
> secret (i.e. never passed in cleartext) or (b) have to make the Capability
> identify which client it is valid for.
>  
> It seems to me that (b) is preferrable since it ensures that a malicious
> client cannot leak Capabilities to a 3rd party.  The downside is that this
> multiplies the number of unique Capabilities by the number of clients,
> potentially increasing CPU load when 1000s of clients all open the same
> shared file and each require unique Capabilities to access the stripe objects.
> Do we have a feel for how bad this could be?
> 
Yes, very bad, and it is absolutely necessary to have an option that avoids
this (also 1000s is out of date ? it could be 100x worse).  That option
could be to simply not have security on the compute cluster if customers
agree with this.

We also need to discuss your proposals with a review committee from LLNL and
Sandia, as we did during the PF discussions.

Peter
> 
>  
>     Cheers, 
>                    Eric
> 
>  
> 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080808/45c1a7ad/attachment.htm>

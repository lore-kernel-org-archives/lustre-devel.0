From: Eric Barton <eeb@sun.com>
Date: Fri, 08 Aug 2008 18:03:08 +0100
Subject: [Lustre-devel] Security issues
In-Reply-To: <C4C1B833.5560%peter.braam@sun.com>
References: <1218205536.814.55.camel@JimsOSlap>
	<C4C1B833.5560%peter.braam@sun.com>
Message-ID: <E9CB31E9D0194A4C88BEA32B04BC2996@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

1. Securing bulk data.
 
It seems to me that it is appropriate to use the GSSAPI to secure the
transfer of bulk data between client and server since it's effectively just
another message.  I can see (at least naively) that it would be good to
avoid double encryption in the case where file contents are actually stored
encrypted on disk.  But even in this case, don't we still have to sign the
(encrypted) bulk so that the receiver can be sure it arrived intact?
 
2. Securing Capabilities.
 
If we want to be sure that a Capability given to client A cannot be
snooped and used by client B we either (a) have to make the Capability 
secret (i.e. never passed in cleartext) or (b) have to make the Capability
identify which client it is valid for.
 
It seems to me that (b) is preferrable since it ensures that a malicious
client cannot leak Capabilities to a 3rd party.  The downside is that this
multiplies the number of unique Capabilities by the number of clients,
potentially increasing CPU load when 1000s of clients all open the same
shared file and each require unique Capabilities to access the stripe objects.
Do we have a feel for how bad this could be?
 
    Cheers, 
                   Eric 

 
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080808/7c229165/attachment.htm>

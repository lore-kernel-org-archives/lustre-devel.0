From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Wed, 25 Mar 2009 16:00:40 -0400
Subject: [Lustre-devel] Start the MGS first?
In-Reply-To: <49CA8A73.9080103@sun.com>
References: <49CA8A73.9080103@sun.com>
Message-ID: <1238011240.6090.16.camel@pc.interlinx.bc.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 2009-03-25 at 12:48 -0700, Nathaniel Rutman wrote:
> As of Lustre 1.6, servers can be started in any order (after the initial registration at first startup).  Internally, this required significant bending of our connection rules, and with a move toward ZFS becomes even more burdensome.  
> So my question to the Lustre community is this: would anyone strenuously object to a startup ordering requirement that the MGS must be started before any other servers?  
> This would probably be in the Lustre 3.0 timeframe.  It is also likely that we will have to divorce the MGS and MDT onto separate devices -- no more "combo" MDT/MGSes. 

I'll ask before anyone else does... would this require the MGS be
available at any time a server (or client?) needs to start rather than
the optional behaviour (for anything but first time server starts) that
we currently enjoy?  IOW, does this make the MGS a much more critical
component of the filesystem than it is currently?

b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 197 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090325/67ee0ef3/attachment.pgp>

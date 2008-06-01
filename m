From: Peter Braam <Peter.Braam@Sun.COM>
Date: Mon, 02 Jun 2008 08:03:20 +0900
Subject: [Lustre-devel] COS
Message-ID: <C46959C8.5663%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Mike, Zam -

I had one more thought about COS.

Please avoid all special algorithms for Lustre 1.6, e.g.  no need for
workarounds to handle the absence of partial directory locks; we simply
should wait until Lustre 2.0 or whatever version will have that to improve
that.

Peter
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080602/57b58ba3/attachment.htm>

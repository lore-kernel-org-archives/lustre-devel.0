From: Jeff Darcy <jeffd@sicortex.com>
Date: Wed, 22 Oct 2008 13:12:07 -0400
Subject: [Lustre-devel] [Lustre-discuss] Misaligned buffers being handed to
	LND?
Message-ID: <48FF5EE7.4090205@sicortex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Have any other LND authors (either at Sun or elsewhere) noticed recent 
Lustre versions passing iovs with non-page-aligned middle elements down 
to the LND layer?  We've always seen plenty of misaligned start/end 
elements, but prior to 1.6.3 we never saw it with middle elements.  We 
were advised that this would never be the case, and some code was 
written based on that assumption.  Now we do see this behavior from lnet 
- always associated with large/complex "ld" invocations while building 
programs, oddly enough.  This is a little non-trivial to deal with in 
our LND for the SiCortex fabric interconnect, and is likely to remain a 
performance issue even with code in place to handle it.  Have any of the 
folks working on other LNDs hit this?
_______________________________________________
Lustre-discuss mailing list
Lustre-discuss at lists.lustre.org
http://lists.lustre.org/mailman/listinfo/lustre-discuss

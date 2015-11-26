From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 26 Nov 2015 23:01:30 +0300
Subject: [lustre-devel] [PATCH 3/3] staging: lustre: Less function calls
 in class_register_type() after error detection
In-Reply-To: <5657573D.4080905@users.sourceforge.net>
References: <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
	<530DD06F.4090703@users.sourceforge.net>
	<alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<563B473C.5090508@users.sourceforge.net>
	<563B4991.90005@users.sourceforge.net>
	<20151125163901.GA7368@kroah.com>
	<5656AFEC.8030709@users.sourceforge.net>
	<20151126165331.GA7882@kroah.com>
	<5657573D.4080905@users.sourceforge.net>
Message-ID: <20151126200130.GI7289@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

These patches are often correct in the same way a stopped clock is
correct twice a day, but I reject the motivation/approach/patch
description.  Just because there is a sanity check does not mean we
should use it (ie, do an insane thing).  It hurts readability to hide
the NULL check.

On the other hand, half the time the NULL checks are superflous because
the pointer is never NULL.  The other half of the time the NULL checks
are there because the code uses one err style error handling.  Also the
error handling code should mirror the allocation code so I feel like it
should be:

	if (some_feature)
		foo = allocate();
	ret = frob();
	if (ret)
		goto free_foo;

free_foo:
	if (some_feature)  // <--- as opposed to if (foo) {
		free(foo);

So anyway I often don't like the original code, but the new code is
even worse and I have never heard a good motivation for these patches
besides that they were generated using a cool tool.  It's not a good
reason.  Other maintainers are accepting these patches so you are free
to send them there.

regards,
dan carpenter

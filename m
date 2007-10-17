From: shadow at clusterfs.com <shadow@clusterfs.com>
Date: Wed, 17 Oct 2007 08:50:41 -0600
Subject: [Lustre-devel] [Bug 13913] New:
	ASSERTION(atomic_read(&ctxt_->loc_refcount) > 0) failed
Message-ID: <200710171450.l9HEofZK001376@shell.clusterfs.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Please don't reply to lustre-devel. Instead, comment in Bugzilla by using the following link:
https://bugzilla.lustre.org/show_bug.cgi?id=13913



while run sanity on loop devices i got assetion.
ASSERTION(atomic_read(&ctxt_->loc_refcount) > 0) failed
this after loop device error and got ENOMEM.

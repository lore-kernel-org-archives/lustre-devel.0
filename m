From: Alex Zhuravlev <bzzz@sun.com>
Date: Tue, 07 Apr 2009 10:30:11 +0400
Subject: [Lustre-devel] WBC HLD outline
In-Reply-To: <20090407061843.GA3204@webber.adilger.int>
References: <200903240058.30343.alexander.zarochentsev@sun.com>
	<00a001c9b2a2$45665430$d032fc90$@com>
	<200904061423.51437.alexander.zarochentsev@sun.com>
	<20090407061843.GA3204@webber.adilger.int>
Message-ID: <m3k55x3rik.fsf@bzzz.home.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>>>> Andreas Dilger (AD) writes:

 AD> On Apr 06, 2009  13:23 +0300, Alexander Zarochentsev wrote:
 >> On 1 April 2009 12:17:17 Eric Barton wrote:
 >> I think we can't avoid tagging OST object creation w/ epoch counter.
 >> Would Lustre users complain if file writes are out-of-epochs?
 >> 
 >> There is a security problem with out-of-epochs writes and setting 
 >> file attributes (especially permissions):
 >> chmod 400 foo; cat /etc/secret-file >> foo. Chmod/chown can be a special 
 >> case which triggers wbc flush.

 AD> While this example has been given many times as a security issue that
 AD> forces many strange actions on the part of Lustre, the example is
 AD> fundamentally broken because POSIX allows "foo" to be opened before the
 AD> chmod, and kept open until after the write and then read the "secret-file"
 AD> content.  The "foo" file needs to be created securely in the first place
 AD> to be safe.

yup, and there is no way in posix to even check whether file is opened.

my take on this and similar security related issues is that we probably
should provide two modes:
1) strict, when no optimizations in order of flush is done
2) relaxed, when order is not garanteed and user should use some form of sync
   but lustre can improve performance


-- 
thanks, Alex

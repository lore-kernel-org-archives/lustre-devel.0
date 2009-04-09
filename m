From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 08 Apr 2009 23:04:47 -0400
Subject: [Lustre-devel] WBC HLD outline
In-Reply-To: <m3k55x3rik.fsf@bzzz.home.net>
References: <200903240058.30343.alexander.zarochentsev@sun.com>
	<00a001c9b2a2$45665430$d032fc90$@com>
	<200904061423.51437.alexander.zarochentsev@sun.com>
	<20090407061843.GA3204@webber.adilger.int>
	<m3k55x3rik.fsf@bzzz.home.net>
Message-ID: <2508C191-5730-4B4D-990C-9465C57DC18D@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Apr 7, 2009, at 2:30 AM, Alex Zhuravlev wrote:
> AD> While this example has been given many times as a security issue  
> that
> AD> forces many strange actions on the part of Lustre, the example is
> AD> fundamentally broken because POSIX allows "foo" to be opened  
> before the
> AD> chmod, and kept open until after the write and then read the  
> "secret-file"
> AD> content.  The "foo" file needs to be created securely in the  
> first place
> AD> to be safe.
> yup, and there is no way in posix to even check whether file is  
> opened.

I do not know if file leases are POSIX or not (and cannot check right  
now),
but they do in fact allow you not only to ensure the file is not  
opened in certain
mode, but would also allow you to get notified when somebody attempts  
to open
a file on which you have obtained such a lease.

Bye,
    Oleg

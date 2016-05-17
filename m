From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 17 May 2016 09:53:31 +0300
Subject: [lustre-devel] [PATCH v2] staging/lustre/ptlrpc: Removes
 potential null dereference
In-Reply-To: <8AEE9006-6CF8-4BB7-A236-808ACE3AB302@intel.com>
References: <1463408271-18079-1-git-send-email-lidza.louina@oracle.com>
	<573A0A23.2010705@cray.com>
	<alpine.LFD.2.20.1605161912310.9721@casper.infradead.org>
	<8AEE9006-6CF8-4BB7-A236-808ACE3AB302@intel.com>
Message-ID: <20160517065330.GA10957@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When I read the code, I just assumed desc was a pointer and it should
have been:

	if (!desc)
		return NULL;

For me, "if (rc) " is way more readable than "if (rc != 0) ".  So
readability could go either way depending on what you're used to, I
suppose.

It should definitely == 0 and != 0 if you are talking about the actual
number zero instead of success/fail like we are here.  Also it helps to
use == 0 with strcmp() and friends (although half of the kernel does not
know that trick yet).

The other thing which I have noticed recently is that a lot of
subsystems use a mix of "if (rc) " and "if (rc < 0) ".  It's annoying
for Smatch because say a function only returns zero but the some of the
callers check for < 0 and some check for != 0.  We can't know for sure
that they are equivalent.

regards,
dan carpenter

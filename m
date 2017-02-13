From: Patrick Farrell <paf@cray.com>
Date: Mon, 13 Feb 2017 12:34:08 +0000
Subject: [lustre-devel] Failing tests
In-Reply-To: <1486985871.4090.13.camel@informatik.uni-hamburg.de>
References: <1486985871.4090.13.camel@informatik.uni-hamburg.de>
Message-ID: <CY4PR11MB1751064AAAE7D5A5202B1753CB590@CY4PR11MB1751.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Michael,


You can either request someone from Intel re-start the tests (this message to the list may do the trick...), or you can re-submit your patch yourself (Re-make the commit with the same Change ID, etc, and just push again), to restart the test process.  (I also concur your patch is unlikely to have caused that test failure.)


- Patrick

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Michael Kuhn <michael.kuhn@informatik.uni-hamburg.de>
Sent: Monday, February 13, 2017 5:37:51 AM
To: lustre-devel at lists.lustre.org
Subject: [lustre-devel] Failing tests

Dear all,

I could not find any information about how to handle failing tests. One
of my changes [0] on Gerrit has a failing test [1] that I think is not
actually caused by the change itself. Due to this, the change is now
marked as "Verified-1". How should I proceed?

[0]: https://review.whamcloud.com/#/c/25307/
[1]: https://testing.hpdd.intel.com/test_sessions/93509fd6-ee24-11e6-bbfe-5254006e85c2


Best regards,
Michael
_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170213/e9629cc1/attachment.htm>

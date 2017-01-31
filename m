From: Patrick Farrell <paf@cray.com>
Date: Tue, 31 Jan 2017 13:25:20 +0000
Subject: [lustre-devel] [PATCH 21/60] staging: lustre: ptlrpc: correct
 use of list_add_tail()
In-Reply-To: <20170131085429.GH6881@mwanda>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
	<1485648328-2141-22-git-send-email-jsimmons@infradead.org>,
	<20170131085429.GH6881@mwanda>
Message-ID: <CY4PR11MB1751E25F983A72AA507E5125CB4A0@CY4PR11MB1751.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dan,


This is a A) a still fairly rarely used crypto feature [A full and usable implementation of it is relatively recent, and this is supporting code that I believe is older.], and B) per that link, the crash only happens when you change your shared key during operation.  So, I'd guess it's a pretty rare thing to do.


- Patrick

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Dan Carpenter <dan.carpenter@oracle.com>
Sent: Tuesday, January 31, 2017 2:54:29 AM
To: James Simmons
Cc: devel at driverdev.osuosl.org; Greg Kroah-Hartman; Linux Kernel Mailing List; Oleg Drokin; Lustre Development List
Subject: Re: [lustre-devel] [PATCH 21/60] staging: lustre: ptlrpc: correct use of list_add_tail()

On Sat, Jan 28, 2017 at 07:04:49PM -0500, James Simmons wrote:
> From: "John L. Hammond" <john.hammond@intel.com>
>
> In sptlrpc_gc_add_sec() swap the arguments to list_add_tail() so that
> it does what we meant it to do.
>

Huh...  This is from before lustre was merged into staging.  What are
the user visible effects of this bug?  I would have expected it to get
caught earlier.


> Signed-off-by: John L. Hammond <john.hammond@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8270

I bet the answer to my question is on this link but I'm reviewing
offline right now.  Plus that's not where the bug description belongs.

regards,
dan carpenter

_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170131/da8b11d3/attachment-0001.htm>

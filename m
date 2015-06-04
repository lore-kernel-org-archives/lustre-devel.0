From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 4 Jun 2015 11:21:09 +0000
Subject: [lustre-devel] Lustre and libreadline
In-Reply-To: <20150603224901.GB10033@llnl.gov>
References: <556F4825.1050408@cray.com> <20150603185716.GA10033@llnl.gov>
	<556F6341.3070507@cray.com>
	<116ba3cddacd422ca0f9b597c691f5df@EXCHCS32.ornl.gov>
	<20150603224901.GB10033@llnl.gov>
Message-ID: <D1959036.F52DC%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/06/03, 4:49 PM, "Ned Bass" <bass6@llnl.gov> wrote:

>On Wed, Jun 03, 2015 at 09:07:11PM +0000, Simmons, James A. wrote:
>> >You say you just install the library and not the utils, but do you
>> >specifically build without the utils?  Is there some existing config
>> >option for that?  (Hoping to save myself some grepping...) Otherwise,
>> >I'll have to add in that option.
>> >
>> >It also seems that readline-devel isn't available for the Intel Xeon
>>Phi 
>> >chips (or at least Cray doesn't have it in our build setup).
>> 
>> This is just papering over the real problem. The utilites should be
>>using
>> getopt() instead. The only thing Parse does that is non standard is
>> an interactive command line. The only place I have ever used that is
>> for lnet selftest. Does lfs really need an interactive command line?
>> I think not.
>
>I concur. There a few lctl commands that can only be run today in the
>interactive mode because they rely on earlier commands. For example,
>"conn_list" requires that you first run "network". Such commands should
>be updated to use sub-arguments rather than relying on previous
>commands.

This is handled by having a "command" named "--net" that runs the next
command (e.g. "conn_list") so that it can be run from the command-line.
That can definitely be replaced by getopt.  I don't think interactive mode
is used very much anymore, so would probably be ok to remove from lctl.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division

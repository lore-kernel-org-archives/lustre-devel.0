From: Simmons, James A. <simmonsja@ornl.gov>
Date: Wed, 3 Jun 2015 21:07:11 +0000
Subject: [lustre-devel] Lustre and libreadline
In-Reply-To: <556F6341.3070507@cray.com>
References: <556F4825.1050408@cray.com> <20150603185716.GA10033@llnl.gov>
	<556F6341.3070507@cray.com>
Message-ID: <116ba3cddacd422ca0f9b597c691f5df@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>You say you just install the library and not the utils, but do you 
>specifically build without the utils?  Is there some existing config 
>option for that?  (Hoping to save myself some grepping...) Otherwise, 
>I'll have to add in that option.
>
>It also seems that readline-devel isn't available for the Intel Xeon Phi 
>chips (or at least Cray doesn't have it in our build setup).

This is just papering over the real problem. The utilites should be using
getopt() instead. The only thing Parse does that is non standard is
an interactive command line. The only place I have ever used that is
for lnet selftest. Does lfs really need an interactive command line?
I think not.

- Patrick

On 06/03/2015 01:57 PM, Ned Bass wrote:
> Hi Patrick,
>
> LLNL builds a stand-alone liblustreapi library for our BG/Q compute
> nodes, and readline isn't available there. Now, since we just install
> the library and not the utils we don't actually need readline. Perhaps
> rather than making the readline configurue check stricly mandatory, we
> could add a --disable-utils option which, if specified, would make
> readline optional.
>
> Thanks,
> Ned
>
> On Wed, Jun 03, 2015 at 01:32:05PM -0500, Patrick Farrell wrote:
>> Good afternoon,
>>
>> Cray has recently discovered that 'lfs getstripe' crashes with a
>> null pointer if it is not built with libreadline (Found in
>> 'readline-devel').
>>
>> When built without libreadline, Lustre uses its own implementation
>> of the readline components it needs.  (Look for "HAVE_LIBREADLINE"
>> in libcfs/libcfs/util/parser.c)  This is the source of the null
>> pointer.
>>
>> I think libreadline should be available on every platform we wish to
>> build Lustre on, so I'd rather not fix the broken internal version
>> of it.  Given that, is there any objection to adding an explicit
>> BuildRequires to the spec, making it mandatory in the config
>> process, and removing all traces of Lustre's internal readline
>> implementation?  If not, I'll open a Jira ticket to do this.
>>
>> - Patrick
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

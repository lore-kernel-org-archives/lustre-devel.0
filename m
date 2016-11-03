From: Andrew Kanner <andrew.kanner@gmail.com>
Date: Thu, 03 Nov 2016 22:22:20 -0000
Subject: [lustre-devel] [PATCH] staging: lustre: fixed shadowed variable
	in socklnd_cb.c
In-Reply-To: <C754133A-93C3-4E41-92B2-F8CCA2B668FA@intel.com>
References: <1478210059-6091-1-git-send-email-andrew.kanner@gmail.com>
	<C754133A-93C3-4E41-92B2-F8CCA2B668FA@intel.com>
Message-ID: <CAKbttoHuY7rw=ozcjkBMKGB2f=Fb_mkvpMurukRDWyGKhvWCDw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "bevans@cray.com" <bevans@cray.com>, "bhaktipriya96@gmail.com" <bhaktipriya96@gmail.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

2016-11-04 1:12 GMT+03:00 Dilger, Andreas <andreas.dilger@intel.com>:
> On Nov 3, 2016, at 15:54, Andrew Kanner <andrew.kanner@gmail.com> wrote:
>>
>> Changed variable 'tx' name in local scope
>> Fixed: sparse warning:
>> socklnd_cb.c:2476:41: warning: symbol 'tx' shadows an earlier one
>> socklnd_cb.c:2435:25: originally declared here
>
> Looking at this more closely (or from a greater distance, hard to say),
> the outer-scope "tx" is used only after this inner-scope "tx", so in
> fact there is no benefit to having the inner-scope declaration at all.
>
> Removing it may save a stack variable (depending on how the compiler
> optimizes), and shouldn't affect functionality.
>
> Cheers, Andreas

I see, I'll correct it and resend as PATCH v2. Thank you.

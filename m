From: Lidza Louina <lidza.louina@oracle.com>
Date: Tue, 17 May 2016 10:22:20 -0400
Subject: [lustre-devel] [PATCH v2] staging/lustre/ptlrpc: Removes
 potential null dereference
In-Reply-To: <20160517065330.GA10957@mwanda>
References: <1463408271-18079-1-git-send-email-lidza.louina@oracle.com>
	<573A0A23.2010705@cray.com>
	<alpine.LFD.2.20.1605161912310.9721@casper.infradead.org>
	<8AEE9006-6CF8-4BB7-A236-808ACE3AB302@intel.com>
	<20160517065330.GA10957@mwanda>
Message-ID: <573B291C.2020609@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On 05/17/2016 02:53 AM, Dan Carpenter wrote:
> When I read the code, I just assumed desc was a pointer and it should
> have been:
>
> 	if (!desc)
> 		return NULL;
>
> For me, "if (rc) " is way more readable than "if (rc != 0) ".  So
> readability could go either way depending on what you're used to, I
> suppose.
>
> It should definitely == 0 and != 0 if you are talking about the actual
> number zero instead of success/fail like we are here.  Also it helps to
> use == 0 with strcmp() and friends (although half of the kernel does not
> know that trick yet).
>
> The other thing which I have noticed recently is that a lot of
> subsystems use a mix of "if (rc) " and "if (rc < 0) ".  It's annoying
> for Smatch because say a function only returns zero but the some of the
> callers check for < 0 and some check for != 0.  We can't know for sure
> that they are equivalent.
>
> regards,
> dan carpenter

Hey Dan,

if (rc < 0) and if (rc) pretty much translates to the same thing. It'll 
only return a negative error value if there are problems and 0 if it 
succeeds. I feel like the first way is more explicit, since negative 
numbers are usually used for errors. I've sent a 3rd version of the 
patch with (rc < 0).

And I'm not sure about the way other subsystems use return values. Here 
it should only either be less than or equal to 0 so it makes sense to  
me in this circumstance.

I ran smatch on my patched file `../smatch/smatch_scripts/kchecker 
drivers/staging/lustre/lustre/ptlrpc/sec_plain.c` and it didn't find any 
issues with it.

Lidza

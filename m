From: Kilian Cavalotti <kilian.cavalotti.work@gmail.com>
Date: Fri, 26 Oct 2012 08:24:08 +0200
Subject: [Lustre-devel] Language choice for Lustre tests
In-Reply-To: <20121025215243.GF2555@llnl.gov>
References: <EA3A770421F31B4BB895DD3AB9224495706F0E@fmsmsx119.amr.corp.intel.com>
	<BF3E1573-A1E3-47DF-B1B1-866EB65A0D49@xyratex.com>
	<EA3A770421F31B4BB895DD3AB9224495709D89@fmsmsx119.amr.corp.intel.com>
	<3E3EE9AC-9DD4-4DBC-8045-E9E8323685EB@xyratex.com>
	<5089AB8A.9070402@llnl.gov>
	<34F2324A-7C99-4B59-AB9D-9BDB60912BF3@xyratex.com>
	<20121025215243.GF2555@llnl.gov>
Message-ID: <CAJz=VjHoqmXKWe+YbHmN-SnaWECUBK39NTaVPhEA12wcg_qTUA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Prakash,

> Why do you think this? Bash is extremely modular using the "source"
> command.

> Not portable? Really? Bash is available on just about every Linux
> distribution that comes to mind. Definitely every one Lustre cares
> about.

> That is not Bash's fault. Bad code can be written in any language. It's
> up to the programmer to write "coherent" test scripts.
>
> How would switching languages improve on either of these two fronts?

I couldn't agree more. I'm still not sure why Bash has to be gotten
rid of, and what the improvement would be rewriting a whole new
testing framework from scratch in an other language, when a working
one currently exist. It can certainly be improved, but I'm pretty sure
Bash has been chosen for a reason at some point, and I'm not convinced
the reasons that lead to this choice are not valid anymore.

Cheers,
-- 
Kilian

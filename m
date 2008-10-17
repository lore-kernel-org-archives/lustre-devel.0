From: Robert Read <rread@sun.com>
Date: Fri, 17 Oct 2008 13:55:03 -0700
Subject: [Lustre-devel] COS performance issues
In-Reply-To: <200810171207.16313.alexander.zarochentsev@sun.com>
References: <200810081544.08292.alexander.zarochentsev@sun.com>
	<200810131836.37447.alexander.zarochentsev@sun.com>
	<48F36393.9020406@sun.com>
	<200810171207.16313.alexander.zarochentsev@sun.com>
Message-ID: <41338A16-5CFA-4979-BD68-35FE8D80455A@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Oct 17, 2008, at 01:07 , Alexander Zarochentsev wrote:
> The massive create tests shows the following results:
>
> COS=1
> Rate: 2085.73 creates/sec (total: 2 threads 625719 creates 300 secs)
> Rate: 2072.38 creates/sec (total: 2 threads 621713 creates 300 secs)
> Rate: 2053.80 creates/sec (total: 2 threads 616141 creates 300 secs)
>
> COS=0
> Rate: 2128.22 creates/sec (total: 2 threads 638465 creates 300 secs)
> Rate: 2151.05 creates/sec (total: 2 threads 645316 creates 300 secs)
> Rate: 2169.91 creates/sec (total: 2 threads 650974 creates 300 secs)
>
> Clean HEAD
>
> Rate: 2199.67 creates/sec (total: 2 threads 659900 creates 300 secs)
> Rate: 2213.95 creates/sec (total: 2 threads 664184 creates 300 secs)
> Rate: 2186.74 creates/sec (total: 2 threads 658209 creates 301 secs)
> Rate: 2206.10 creates/sec (total: 2 threads 661831 creates 300 secs)
> Rate: 2217.49 creates/sec (total: 2 threads 665247 creates 300 secs)
> Rate: 2230.86 creates/sec (total: 2 threads 669258 creates 300 secs)
>

Any idea why COS=0 was consistently a bit slower than HEAD?

robert

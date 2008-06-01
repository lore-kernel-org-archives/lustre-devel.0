From: Peter Braam <Peter.Braam@Sun.COM>
Date: Sun, 01 Jun 2008 10:44:27 +0800
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <92825021-D566-4805-9297-5EFBD3260D73@Sun.COM>
Message-ID: <C4682E0B.561F%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

That the total number of quota RPC's made by all OSS's (up to 5000 of them)
should not exceed something like 1/3 of this, based on today's hardware,
otherwise quota traffic will slow the cluster down.

We have seen big servers do 15,000 updates/sec sustained, so that is a
measure we can use at the moment.

Peter


On 6/1/08 10:41 AM, "Robert Gordon" <Robert.Gordon@Sun.COM> wrote:

> 
> On May 31, 2008, at 9:32 PM, Peter Braam wrote:
> 
>> A server cannot handle more than 15,000 RPC's / sec.
> 
> I'm curious (always ;) ) ..
> 
> what do you exactly mean by this statement ?
> 
> Thanks,
> Robert.. 

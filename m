From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 14 Feb 2017 08:23:02 +0000
Subject: [lustre-devel] Failing tests
In-Reply-To: <1486990042.4090.21.camel@informatik.uni-hamburg.de>
References: <1486985871.4090.13.camel@informatik.uni-hamburg.de>
	<CY4PR11MB1751064AAAE7D5A5202B1753CB590@CY4PR11MB1751.namprd11.prod.outlook.com>
	<1486990042.4090.21.camel@informatik.uni-hamburg.de>
Message-ID: <FBEBDA9A-26EC-45CE-A28F-0C1C49E7B06A@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 13, 2017, at 05:47, Michael Kuhn <michael.kuhn@informatik.uni-hamburg.de> wrote:
> 
> Hi Patrick,
> 
> thanks for the quick feedback!
> 
>> [...] or you can re-submit your patch yourself (Re-make the commit with the same Change ID, etc, and just push again), to restart the test process.
> 
> This forces all reviewers to redo their reviews, right? (That's why I
> first wanted to ask whether there was another way.) If this is not seen
> as a problem, though, I guess this is the easiest way.

Usually a comment on the patch can get the tests retriggered, assuming someone is CC'd on the patch.  Alternately, if you edit only the commit comment (which can be done directly in Gerrit) and then re-push the patch, the reviews will be kept but the patch will be retested.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation

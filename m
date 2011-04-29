From: Johann Lombardi <johann@whamcloud.com>
Date: Fri, 29 Apr 2011 20:01:04 +0200
Subject: [Lustre-devel] F/S stats visualisation
In-Reply-To: <662791CA-879E-4DB1-9C94-B93D7FA85384@whamcloud.com>
References: <008a01cc05f8$a6b26840$f41738c0$@com>
	<73AED5C780AE05478241DB067651A921023784B9@XYUS-EX22.xyus.xyratex.com>
	<662791CA-879E-4DB1-9C94-B93D7FA85384@whamcloud.com>
Message-ID: <20110429180104.GA5771@neo>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Apr 29, 2011 at 11:41:05AM -0600, Andreas Dilger wrote:
> On Apr 29, 2011, at 11:35, Nathan Rutman wrote:
> > That's interesting - why do you think opens >> closes?
> > Are we not tracking closes correctly?
> 
> I was wondering the same, and/or we are double-counting opens?  Clients won't send close RPCs if they are evicted (MDS does the close locally on eviction), but I'd hope that clients aren't evicted _that_ often.

It seems that we increment the open stat counter on resent (for reply reconstruction), but not for close. Maybe that's the reason?
It might also just be that open failed so no close is needed.

Johann

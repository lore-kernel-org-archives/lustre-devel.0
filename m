From: Guenter Roeck <linux@roeck-us.net>
Date: Fri, 26 Jun 2015 20:48:09 -0700
Subject: [lustre-devel] [PATCH] staging:lustre: remove irq.h from
	socklnd.h
In-Reply-To: <1435265986-10375-1-git-send-email-jsimmons@infradead.org>
References: <1435265986-10375-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20150627034809.GA3922@roeck-us.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 25, 2015 at 04:59:46PM -0400, James Simmons wrote:
> The header socklnd.h includes irq.h which is not need
> and doesn't exist in the OpenSFS lustre branch. Having
> irq.h in socklnd.h does break the build on the m68k
> platform. So we can safely remove it.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>

The m68k build problem is now seen in mainline, and this patch
fixes it.

Tested-by: Guenter Roeck <linux@roeck-us.net>

Guenter
